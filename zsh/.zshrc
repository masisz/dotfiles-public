export LANG=ja_JP.UTF-8

if [ -d "/opt/homebrew/opt/tree-sitter-cli/bin" ]; then
  export PATH="/opt/homebrew/opt/tree-sitter-cli/bin:$PATH"
end

if [ -e "$HOME/.rbenv" ]; then
  eval "$(rbenv init - zsh)"
fi

if [ -e "$HOME/.cargo" ]; then
  source "$HOME/.cargo/env"
fi

if [ -e "$HOME/.dotnet" ]; then
  export PATH="$PATH:$HOME/.dotnet/tools"
fi

eval "$(zoxide init zsh)"

autoload -Uz colors
colors

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt share_history
setopt pushd_ignore_dups
setopt no_beep

alias ls='eza'
alias la='ls -a'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias vim='nvim'
alias cat='bat'

# plugin manager antigen
if [ ! -f "$HOME/antigen.zsh" ]; then
  echo "antigen not found. Installing..."
  curl -L git.io/antigen > $HOME/antigen.zsh
fi
source $HOME/antigen.zsh

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle jeffreytse/zsh-vi-mode

antigen apply

# starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
