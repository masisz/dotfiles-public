export LANG=ja_JP.UTF-8

if [ -d "/opt/homebrew/opt/tree-sitter-cli/bin" ]; then
  export PATH="/opt/homebrew/opt/tree-sitter-cli/bin:$PATH"
fi

if [ -e "$HOME/.rbenv" ]; then
  eval "$(rbenv init - zsh)"
fi

if [ -e "$HOME/.cargo" ]; then
  source "$HOME/.cargo/env"
fi

if [ -e "$HOME/.dotnet" ]; then
  export PATH="$PATH:$HOME/.dotnet/tools"
fi

if [ -d "$HOME/go/bin" ]; then
  export PATH="$HOME/go/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

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
alias vi='nvim'
alias vim='nvim'
alias cat='bat'

# Zsh plugins (managed via Homebrew on macOS / system packages on Linux; no remote curl)
_brew_prefix=""
if [ -d "/opt/homebrew" ]; then
  _brew_prefix="/opt/homebrew"
elif [ -d "/usr/local/Homebrew" ]; then
  _brew_prefix="/usr/local"
elif command -v brew >/dev/null 2>&1; then
  _brew_prefix="$(brew --prefix)"
fi

# 1. zsh-completions (must be added to fpath before compinit)
if [ -n "$_brew_prefix" ] && [ -d "$_brew_prefix/share/zsh-completions" ]; then
  fpath=("$_brew_prefix/share/zsh-completions" $fpath)
fi
autoload -Uz compinit
compinit

# 2. zsh-autosuggestions
for _p in \
  "${_brew_prefix:+$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh}" \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  if [ -n "$_p" ] && [ -f "$_p" ]; then
    source "$_p"
    break
  fi
done

# 3. zsh-vi-mode
for _p in \
  "${_brew_prefix:+$_brew_prefix/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh}" \
  "${_brew_prefix:+$_brew_prefix/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh}" \
  "/usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"; do
  if [ -n "$_p" ] && [ -f "$_p" ]; then
    source "$_p"
    break
  fi
done

# 4. starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# 5. zsh-syntax-highlighting (must be sourced near the end)
for _p in \
  "${_brew_prefix:+$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}" \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  if [ -n "$_p" ] && [ -f "$_p" ]; then
    source "$_p"
    break
  fi
done
unset _brew_prefix _p

# Local machine-specific configuration (not tracked in dotfiles-public)
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
