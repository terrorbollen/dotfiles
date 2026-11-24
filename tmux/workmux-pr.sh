#!/bin/sh
# Pick a PR awaiting your review in any repo with fzf and open it for review in
# a fresh workmux worktree of that repo's local clone.
# The search also fetches each body, so the preview reads a local file
# instead of calling `gh pr view` (~1s) for every highlighted PR.
set -e

PR_FILE=$(mktemp)
trap 'rm -f "$PR_FILE"' EXIT
# review-requested also matches requests to your teams, unlike user-review-requested.
# GraphQL because `gh search prs` has no CI or review decision fields
gh api graphql -f query='{ search(query: "is:pr is:open review-requested:@me", type: ISSUE, first: 100) {
  nodes { ... on PullRequest { number title body isDraft reviewDecision author { login }
    repository { nameWithOwner } commits(last: 1) { nodes { commit { statusCheckRollup { state } } } } } } } }' \
  --jq '[.data.search.nodes[] | .repo = .repository.nameWithOwner
    | .ci = .commits.nodes[0].commit.statusCheckRollup.state | .id = "\(.repo)#\(.number)"]' > "$PR_FILE"

export PR_FILE
# Bodies are markdown with inline HTML (dependabot is mostly HTML): strip the
# tags and decode the common entities before glow renders the markdown
export PREVIEW_JQ='.[] | select(.id == $id) | .body
  | gsub("<br ?/?>"; "\n") | gsub("<li>"; "- ") | gsub("</li>|</p>"; "\n") | gsub("<[^>]+>"; "")
  | gsub("&lt;"; "<") | gsub("&gt;"; ">") | gsub("&quot;"; "\"") | gsub("&#39;"; "\u0027") | gsub("&amp;"; "&")
  | gsub("\n\\s*\n(\\s*\n)+"; "\n\n")'

ROWS_JQ='
def c(code; s): "\u001b[\(code)m\(s)\u001b[0m";
def ci: {SUCCESS: c(32; "✓"), FAILURE: c(31; "✗"), ERROR: c(31; "✗"), PENDING: c(33; "…"), EXPECTED: c(33; "…")}[.ci] // " ";
def review: if .isDraft then c(90; "◌ draft")
  elif .reviewDecision == "CHANGES_REQUESTED" then c(31; "✗ changes")
  elif .reviewDecision == "APPROVED" then c(32; "✓ approved")
  else c(37; "○ open") end;
.[] | [.id, ci, review, .title, c(90; .author.login)] | @tsv'

# FZF_DEFAULT_OPTS sets --tmux (no popup inside a popup) and --height 40% (half-empty popup)
id=$(jq -r "$ROWS_JQ" "$PR_FILE" |
  fzf --no-tmux --height=100% --ansi --delimiter='\t' --prompt='PR> ' \
    --header='CI ✓ pass  ✗ fail  … running   │   ✓ approved  ✗ changes  ◌ draft' \
    --preview='jq -r --arg id {1} "$PREVIEW_JQ" "$PR_FILE" | glow --style=dark --width="$FZF_PREVIEW_COLUMNS" -' \
    --preview-window=wrap,60% \
    --bind='ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up' |
  cut -f1)

# Cancelled: exit 0 so display-popup -EE closes instead of holding the popup open
[ -n "$id" ] || exit 0
repo=${id%#*} n=${id#*#}
# Main checkouts only: their .git is a directory, a worktree's is a file
dir=$(for g in ~/*/*/.git ~/*/*/*/.git; do
  [ -d "$g" ] && git -C "$g/.." remote get-url origin 2>/dev/null | grep -qiE "[:/]$repo(\.git)?$" && dirname "$g" && break
done; true)
[ -n "$dir" ] || { echo "No local clone of $repo under ~/*/ or ~/*/*/"; exit 1; }
cd "$dir"
# Popups have no TMUX_PANE, which workmux needs to know where it is; tmux
# still resolves the popup's owning pane, so recover it from there
export TMUX_PANE=$(tmux display -p '#{pane_id}')
# A local review-<n> branch never collides with an existing checkout of the
# PR branch (e.g. your own PR), so this always gets a fresh worktree
workmux add -o --pr "$n" "review-$n"
# workmux tracks the PR's head branch, which `gh pr view` (prefix g) cannot
# map back to review-<n>; the pull ref it can
git config "branch.review-$n.merge" "refs/pull/$n/head"
