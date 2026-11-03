#!/bin/sh
# Pick an open PR with fzf and open it for review in a fresh workmux worktree.
# The list call also fetches each body, so the preview reads a local file
# instead of calling `gh pr view` (~1s) for every highlighted PR.
set -e

PR_FILE=$(mktemp)
ME_FILE=$(mktemp)
trap 'rm -f "$PR_FILE" "$ME_FILE"' EXIT
gh api user --jq .login > "$ME_FILE" &
gh pr list --limit 100 \
  --json number,title,headRefName,body,author,isDraft,reviewDecision,reviewRequests,statusCheckRollup > "$PR_FILE"
wait

export PR_FILE
# Bodies are markdown with inline HTML (dependabot is mostly HTML): strip the
# tags and decode the common entities before glow renders the markdown
export PREVIEW_JQ='.[] | select(.number == $n) | .body
  | gsub("<br ?/?>"; "\n") | gsub("<li>"; "- ") | gsub("</li>|</p>"; "\n") | gsub("<[^>]+>"; "")
  | gsub("&lt;"; "<") | gsub("&gt;"; ">") | gsub("&quot;"; "\"") | gsub("&#39;"; "\u0027") | gsub("&amp;"; "&")
  | gsub("\n\\s*\n(\\s*\n)+"; "\n\n")'

ROWS_JQ='
def c(code; s): "\u001b[\(code)m\(s)\u001b[0m";
def ci: [.statusCheckRollup[] | (.conclusion // .state)] as $r
  | if any($r[]; . == "FAILURE" or . == "ERROR" or . == "CANCELLED" or . == "TIMED_OUT" or . == "ACTION_REQUIRED") then c(31; "✗")
    elif any($r[]; . == "PENDING" or . == "" or . == null) then c(33; "…")
    elif ($r | length) > 0 then c(32; "✓")
    else " " end;
def review: if .isDraft then c(90; "◌ draft")
  elif .reviewDecision == "CHANGES_REQUESTED" then c(31; "✗ changes")
  elif .reviewDecision == "APPROVED" then c(32; "✓ approved")
  elif .author.login == $me then c(34; "★ yours")
  elif any(.reviewRequests[]; .login == $me) then c("1;33"; "● review you")
  else c(37; "○ open") end;
.[] | [.number, ci, review, .title, c(90; .author.login)] | @tsv'

# FZF_DEFAULT_OPTS sets --tmux (no popup inside a popup) and --height 40% (half-empty popup)
n=$(jq -r --arg me "$(cat "$ME_FILE")" "$ROWS_JQ" "$PR_FILE" |
  fzf --no-tmux --height=100% --ansi --delimiter='\t' --prompt='PR> ' \
    --header='CI ✓ pass  ✗ fail  … running   │   ● review you  ★ yours  ✓ approved  ✗ changes  ◌ draft' \
    --preview='jq -r --argjson n {1} "$PREVIEW_JQ" "$PR_FILE" | glow --style=dark --width="$FZF_PREVIEW_COLUMNS" -' \
    --preview-window=wrap,60% \
    --bind='ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up' |
  cut -f1)

# Cancelled: exit 0 so display-popup -EE closes instead of holding the popup open
[ -n "$n" ] || exit 0
# Popups have no TMUX_PANE, which workmux needs to know where it is; tmux
# still resolves the popup's owning pane, so recover it from there
export TMUX_PANE=$(tmux display -p '#{pane_id}')
# A local review-<n> branch never collides with an existing checkout of the
# PR branch (e.g. your own PR), so this always gets a fresh worktree
exec workmux add -o --pr "$n" "review-$n" --session
