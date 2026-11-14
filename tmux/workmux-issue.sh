#!/bin/sh
# Search every not-done Linear issue with fzf and open a workmux worktree on the
# issue's branch, in the current repo, with Claude ready in it.
# Borrows linear-tui's OAuth token: Linear CLIs only take API keys, which SSO
# workspaces may not hand out. The list call also fetches each description, so
# the preview reads a local file.
set -e

ISSUE_FILE=$(mktemp)
PAGE_FILE=$(mktemp)
trap 'rm -f "$ISSUE_FILE" "$PAGE_FILE"' EXIT
QUERY='query($after: String) { issues(first: 250, after: $after,
  filter: { state: { type: { nin: ["completed", "canceled", "duplicate"] } } }) {
  pageInfo { hasNextPage endCursor }
  nodes { identifier title branchName description priority state { name type }
    project { name } assignee { isMe displayName } } } }'
# The workspace has more not-done issues than one page holds
echo '[]' > "$ISSUE_FILE"
after=null
while :; do
  # The token lasts a day and only linear-tui refreshes it
  if ! curl -sf https://api.linear.app/graphql \
    -H "Authorization: Bearer $(jq -r .access_token ~/.linear-tui/credentials.json)" \
    -H 'Content-Type: application/json' \
    --data "$(jq -n --arg q "$QUERY" --argjson after "$after" '{query: $q, variables: {after: $after}}')" > "$PAGE_FILE"; then
    echo "Linear login missing or expired: open linear-tui (prefix w l) once to refresh it"
    exit 1
  fi
  jq -s '.[0] + .[1].data.issues.nodes' "$ISSUE_FILE" "$PAGE_FILE" > "$ISSUE_FILE.new" && mv "$ISSUE_FILE.new" "$ISSUE_FILE"
  [ "$(jq -r .data.issues.pageInfo.hasNextPage "$PAGE_FILE")" = true ] || break
  after=$(jq .data.issues.pageInfo.endCursor "$PAGE_FILE")
done

export ISSUE_FILE
export PREVIEW_JQ='.[] | select(.identifier == $id)
  | "# \(.identifier) \(.title)\n\n**\(.state.name)** · \(.assignee.displayName // "unassigned") · \(.project.name // "no project") · `\(.branchName)`\n\n\(.description // "_No description_")"'

# Linear priority: 0 none, 1 urgent, 2 high, 3 medium, 4 low
ROWS_JQ='
def c(code; s): "\u001b[\(code)m\(s)\u001b[0m";
def prio: [c(90; " "), c(31; "!!!"), c(33; "!!"), c(37; "!"), c(90; "·")][.priority];
def state: {started: c(33; "◐"), unstarted: c(37; "○")}[.state.type] // c(90; "◌");
def who: if .assignee.isMe then c(32; "me") else c(90; .assignee.displayName // "-") end;
sort_by(.assignee.isMe != true, ({started: 0, unstarted: 1}[.state.type] // 2),
  (if .priority == 0 then 5 else .priority end))
| .[] | [.identifier, state, prio, .title, who, c(90; .project.name // "")] | @tsv'

# FZF_DEFAULT_OPTS sets --tmux (no popup inside a popup) and --height 40% (half-empty popup)
id=$(jq -r "$ROWS_JQ" "$ISSUE_FILE" |
  fzf --no-tmux --height=100% --ansi --delimiter='\t' --prompt='issue> ' \
    --header='yours first   │   ◐ started  ○ todo  ◌ backlog   │   !!! urgent  !! high  ! medium  · low' \
    --preview='jq -r --arg id {1} "$PREVIEW_JQ" "$ISSUE_FILE" | glow --style=dark --width="$FZF_PREVIEW_COLUMNS" -' \
    --preview-window=wrap,60% \
    --bind='ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up' |
  cut -f1)

# Cancelled: exit 0 so display-popup -EE closes instead of holding the popup open
[ -n "$id" ] || exit 0
branch=$(jq -r --arg id "$id" '.[] | select(.identifier == $id) | .branchName' "$ISSUE_FILE")
# Linear prefixes branchName with the full username; workmux handles read better short
branch="isak/${branch#*/}"
# Popups have no TMUX_PANE, which workmux needs to know where it is
export TMUX_PANE=$(tmux display -p '#{pane_id}')
# -o reopens the worktree of an issue already in progress instead of failing.
# -a without -p starts Claude with an empty input: sometimes it's just a chat
workmux add -o "$branch" --session -a claude
