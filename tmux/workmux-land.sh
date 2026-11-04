#!/bin/sh
# Land the current worktree once its PR has merged: fast-forward main, delete
# the remote branch and remove the worktree and its window.
set -eu

top=$(git rev-parse --show-toplevel)
root=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
[ "$top" != "$root" ] || { echo "Not in a worktree: run this from the worktree's window." >&2; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "Uncommitted changes: commit or discard them first." >&2; exit 1; }

git fetch -q origin
main=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD || echo origin/main)
# Only merge commits keep the branch's commits in main; squash and rebase
# merges create new ones, which git alone cannot match up
git merge-base --is-ancestor HEAD "$main" || {
  echo "Not merged into $main yet. If it was squash-merged, remove it with prefix w x." >&2
  exit 1
}

if [ "$(git -C "$root" symbolic-ref --quiet --short HEAD)" = "${main#origin/}" ] &&
  [ -z "$(git -C "$root" status --porcelain)" ]; then
  git -C "$root" merge -q --ff-only "$main"
else
  # The popup closes on success, so say it where it stays visible
  tmux display-message -d 5000 "land: main checkout is not on a clean ${main#origin/}, left it alone"
fi

# The upstream can differ from the local branch name (pushed as local:remote)
remote_branch=$(git for-each-ref --format='%(upstream:lstrip=3)' "$(git symbolic-ref HEAD)")
# Removing the worktree kills this window and the popup with it, so the rest
# runs on the tmux server; the remote delete is in there so nothing waits on it
tmux run-shell -b -c "$root" \
  "${remote_branch:+git push -q origin --delete '$remote_branch' >/dev/null 2>&1;} workmux rm -f '$(basename "$top")'"
