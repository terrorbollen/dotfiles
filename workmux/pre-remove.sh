#!/bin/sh
# pre_remove hook: runs before every worktree removal, including `rm -f` and
# agents cleaning up after themselves, so work that exists nowhere else is
# backed up and only deleted once a human says yes. Exiting 1 aborts removal.
set -eu

cd "$WM_WORKTREE_PATH"

dirty=$(git status --porcelain | wc -l | tr -d ' ')
# Commits on no remote and no other local branch are gone once this branch is
branch=$(git symbolic-ref --quiet --short HEAD || true)
unsaved=$(git rev-list --count HEAD --not --remotes --exclude="$branch" --branches)
[ "$dirty" -eq 0 ] && [ "$unsaved" -eq 0 ] && exit 0

backup="${XDG_STATE_HOME:-$HOME/.local/state}/workmux/backups/$WM_HANDLE-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"
git diff HEAD >"$backup/changes.diff"
git ls-files --others --exclude-standard -z >"$backup/untracked.list"
[ -s "$backup/untracked.list" ] && tar -czf "$backup/untracked.tgz" --null -T "$backup/untracked.list"
[ "$unsaved" -gt 0 ] && git bundle create -q "$backup/commits.bundle" HEAD --not --remotes --exclude="$branch" --branches

question="$WM_HANDLE has $dirty uncommitted file(s) and $unsaved unpushed commit(s). Backup: ${backup#"$HOME"/}. Remove anyway? (y/n) "

if { : >/dev/tty; } 2>/dev/null; then
  printf '%s' "$question" >/dev/tty
  read -r answer </dev/tty
elif tmux info >/dev/null 2>&1; then
  # Background removals (agents, `tmux run-shell -b`) have no terminal, so ask
  # on screen; display-popup blocks until the popup closes
  # The question goes in and the answer comes back through one file, so
  # nothing has to survive tmux's command quoting
  io=$(mktemp)
  printf '%s' "$question" >"$io"
  tmux display-popup -E -w 70% -h 6 -T ' remove worktree? ' \
    "cat '$io'; read -r a; echo \"\$a\" >'$io'"
  answer=$(cat "$io")
  rm -f "$io"
else
  echo "pre-remove: $WM_HANDLE has unsaved work and nobody to ask, keeping it" >&2
  exit 1
fi

case "$answer" in
  y | Y) exit 0 ;;
  *) echo "pre-remove: kept $WM_HANDLE" >&2; exit 1 ;;
esac
