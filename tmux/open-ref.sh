#!/bin/sh
# Open a reference: URL, Linear issue (INN-123), GitHub #123 or path:line.
# Usage: open-ref.sh TEXT [X]  - with X, TEXT is a line and the
# whitespace-delimited token at column X is opened (tmux copy mode gd).
# Repo-relative refs resolve against the active tmux pane's directory.
# Alacritty starts from the Dock without Homebrew on PATH.
PATH=/opt/homebrew/bin:$PATH

ref=$1
if [ -n "$2" ]; then
  ref=$(printf '%s\n' "$1" | awk -v x="$2" '{
    s = x + 1; e = x + 1
    while (s > 1 && substr($0, s - 1, 1) !~ /[ \t]/) s--
    while (e <= length($0) && substr($0, e, 1) !~ /[ \t]/) e++
    print substr($0, s, e - s) }')
fi
dir=$(tmux display -p '#{pane_current_path}')

fail() { tmux display-message -l "$1"; exit 1; }

case $ref in
  *://*|mailto:*)
    open "$(printf '%s' "$ref" | grep -oE '[a-z]+:[^]>)"'\'' ]+' | head -1)" ;;
  *)
    id=$(printf '%s' "$ref" | grep -ioE '\binn-[0-9]+' | head -1)
    n=$(printf '%s' "$ref" | grep -oE '#[0-9]+' | head -1)
    loc=$(printf '%s' "$ref" | grep -oE '[^:(]+:[0-9]+' | head -1)
    if [ -n "$id" ]; then
      open -a Linear "https://linear.app/innspire-digital/issue/$(echo "$id" | tr a-z A-Z)"
    elif [ -n "$n" ]; then
      cd "$dir" && err=$(gh browse "${n#\#}" 2>&1 >/dev/null) || fail "$err"
    elif [ -n "$loc" ]; then
      file=${loc%:*}
      [ -f "$file" ] || [ -f "$dir/$file" ] || fail "No such file: $file"
      tmux display-popup -E -w 80% -h 80% -d "$dir" "nvim +${loc##*:} '$file'"
    else
      fail "Nothing to open: $ref"
    fi ;;
esac
