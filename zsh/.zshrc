
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

BREW_PREFIX=/opt/homebrew

# History
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify share_history
alias history='fc -il 1'

# Directories
setopt auto_cd auto_pushd pushd_ignore_dups pushd_minus

# Misc
setopt interactive_comments long_list_jobs no_flow_control

# Completion
setopt always_to_end complete_in_word
fpath=("$BREW_PREFIX/share/zsh/site-functions" $fpath)
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

eval "$(mise activate zsh)"

# Plugins (brew install zsh-autosuggestions zsh-vi-mode zsh-syntax-highlighting)
ZVM_INIT_MODE=sourcing
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
source "$BREW_PREFIX/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

bindkey '^ ' autosuggest-accept

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Prompt: edit ~/.config/starship.toml
eval "$(starship init zsh)"

alias ls='eza'

alias compose='docker compose'
alias k=kubectl
alias vi=nvim . 


# Created by `pipx` on 2025-03-10 12:36:27
export PATH="$PATH:/Users/isakfriis-jespersen/.local/bin"

# cached shell-init: regenerate via `zcache-rebuild` after upgrades
zcache-rebuild() {
  mkdir -p ~/.cache/zsh
  fzf --zsh             > ~/.cache/zsh/fzf.zsh
  zoxide init zsh       > ~/.cache/zsh/zoxide.zsh
  kubectl completion zsh > ~/.cache/zsh/kubectl.zsh
  echo "zsh init caches rebuilt"
}
[[ -f ~/.cache/zsh/fzf.zsh ]] || fzf --zsh > ~/.cache/zsh/fzf.zsh
source ~/.cache/zsh/fzf.zsh
[[ -f ~/.cache/zsh/kubectl.zsh ]] || kubectl completion zsh > ~/.cache/zsh/kubectl.zsh
source ~/.cache/zsh/kubectl.zsh

export FZF_DEFAULT_OPTS='--height 40% --tmux bottom,40% --layout reverse --border top'
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' \
  --preview-window=up:3:wrap \
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' \
  --color header:italic \
  --header 'Press CTRL-Y to copy command into clipboard'"

# bun completions
[ -s "/Users/isakfriis-jespersen/.bun/_bun" ] && source "/Users/isakfriis-jespersen/.bun/_bun"

[[ -f ~/.cache/zsh/zoxide.zsh ]] || zoxide init zsh > ~/.cache/zsh/zoxide.zsh
source ~/.cache/zsh/zoxide.zsh

# Must be sourced after all other widgets are defined
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
