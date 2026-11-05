#!/bin/zsh -f
# which-key style hints: when the prefix sits unanswered, a panel at the bottom
# lists what the next key does. Usage: which-key.sh <key table> <client>
table=$1 client=$2

case $table in
  prefix) hints=(
    c window  - split  '|' vsplit  m zoom  v copy  w +workmux
    D docker  K k9s  Q sql  Y yazi  T term  r reload  '?' 'all keys'
  ) ;;
  workmux) hints=(
    n 'new feature'  a 'new feature+prompt'  p 'my reviews'  i 'start issue'
    d dashboard  l linear  w worktrees  s sidebar  r rebase  m 'land merged'
    x remove  g 'clean merged'
  ) ;;
esac

column=24

if [[ -z $WK_PANEL ]]; then
  # A key pressed during the delay already went straight to tmux
  read current width <<< $(tmux display -c $client -p '#{client_key_table} #{client_width}')
  [[ $current == $table ]] || exit 0
  per_row=$(( (width - 4) / column ))
  rows=$(( ($#hints / 2 + per_row - 1) / per_row ))
  # Closing from inside counts as a failure, and run-shell would show that
  # failure over the pane
  tmux display-popup -c $client -E -b rounded -T " $table " \
    -S 'fg=#cba6f7' -s 'bg=#181825' -x 0 -y '#{client_height}' -w 100% -h $((rows + 2)) \
    -e WK_PANEL=$per_row "$0 $table $client" >/dev/null 2>&1
  exit 0
fi

# A key pressed while the popup was opening went to tmux, not to this panel
[[ $(tmux display -c $client -p '#{client_key_table}') == $table ]] || exit 0

# A cursor would sit in the panel, as if it were somewhere to type
printf '\e[?25l'
for ((i = 1; i < $#hints; i += 2)); do
  printf ' \e[1;38;2;203;166;247m%s\e[0m \e[38;2;205;214;244m%-*s\e[0m' $hints[i] $((column - 3 - $#hints[i] + 1)) $hints[i+1]
  (( (i + 1) / 2 % WK_PANEL )) || print
done

# The popup takes all input, so the key has to be handed back to tmux. It must
# land after the popup closes, or the popup would swallow it again.
read -rsk1 key
case $key in
  $'\e')
    if read -rsk2 -t0.02 rest; then
      case $rest in
        '[A') key=Up ;;
        '[B') key=Down ;;
        '[C') key=Right ;;
        '[D') key=Left ;;
      esac
    fi
    [[ $key == $'\e' ]] && exec tmux display-popup -c $client -C \; switch-client -c $client -T root
    ;;
  ' ') key=Space ;;
  $'\r'|$'\n') key=Enter ;;
  ';') key='\;' ;;
  [$'\x01'-$'\x1a']) key=C-${(#)$(( #key + 96 ))} ;;
esac
exec tmux display-popup -c $client -C \; send-keys -K -c $client -- $key
