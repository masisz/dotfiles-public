#!/usr/bin/env zsh
#
# macOS bootstrap script for dotfiles-public.
# Installs Homebrew (with explicit user confirmation), packages from Brewfile
# plus optional local/extra Brewfiles, and clones masisz.nvim if not present.
# Never runs `brew bundle --cleanup` so existing apps/packages are never removed.

emulate -LR zsh
setopt errexit nounset pipefail

DOTFILES_DIR="${0:A:h}"
BREWFILE="${DOTFILES_DIR}/Brewfile"
REPO_LOCAL_BREWFILE="${DOTFILES_DIR}/Brewfile.local"
HOME_LOCAL_BREWFILE="${HOME}/.Brewfile.local"
LOCAL_BREWFILE_EXAMPLE="${DOTFILES_DIR}/Brewfile.local.example"
HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
HOMEBREW_PKG_URL="https://github.com/Homebrew/brew/releases"
NVIM_REPO_URL="https://github.com/masisz/masisz.nvim.git"
NVIM_CONFIG_DIR="${HOME}/.config/nvim"

DRY_RUN=0
CHECK_ONLY=0
NO_LOCAL=0
RUN_LINK=0
SKIP_UPDATE=0
SKIP_NVIM=0
INIT_LOCAL=0
typeset -a EXTRA_BREWFILES
EXTRA_BREWFILES=()

usage() {
  cat <<'EOF'
Usage: ./setup-macos.zsh [OPTIONS]

Install Homebrew (if missing, after confirmation), packages from Brewfile,
and clone masisz.nvim into ~/.config/nvim (if not already present).

Local Brewfiles (gitignored / machine-specific) are automatically loaded if present:
  1. ./Brewfile.local
  2. ~/.Brewfile.local

Options:
  -n, --dry-run            Show planned actions without making any changes
  -c, --check              Check whether Brewfile dependencies are already satisfied
  -f, --extra-file <path>  Additional Brewfile to apply (may be specified multiple times)
      --init-local         Create ~/.Brewfile.local from Brewfile.local.example and exit
      --skip-update        Skip `brew update` before installing packages
      --skip-nvim          Skip cloning masisz.nvim into ~/.config/nvim
      --no-local           Ignore ./Brewfile.local and ~/.Brewfile.local even if present
      --link               Run ./install.zsh after installing Homebrew packages
  -h, --help               Show this help message

Examples:
  ./setup-macos.zsh --init-local
  ./setup-macos.zsh --dry-run
  ./setup-macos.zsh --check
  ./setup-macos.zsh
  ./setup-macos.zsh --extra-file ~/Brewfile.work --link
EOF
}

log_info() {
  printf '[INFO]   %s\n' "$1"
}

log_warn() {
  printf '[WARN]   %s\n' "$1" >&2
}

log_error() {
  printf '[ERROR]  %s\n' "$1" >&2
}

load_brew_env() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return 0
  fi
  if [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return 0
  fi
  return 1
}

init_local_brewfile() {
  if [[ -e "$HOME_LOCAL_BREWFILE" ]]; then
    log_info "Local Brewfile already exists: ${HOME_LOCAL_BREWFILE} (not overwritten)"
    return 0
  fi
  if [[ ! -f "$LOCAL_BREWFILE_EXAMPLE" ]]; then
    log_error "Template not found: ${LOCAL_BREWFILE_EXAMPLE}"
    return 1
  fi
  if (( DRY_RUN )); then
    log_info "[DRYRUN] Would copy ${LOCAL_BREWFILE_EXAMPLE} -> ${HOME_LOCAL_BREWFILE}"
    return 0
  fi
  cp "$LOCAL_BREWFILE_EXAMPLE" "$HOME_LOCAL_BREWFILE"
  log_info "Created local Brewfile: ${HOME_LOCAL_BREWFILE}"
  log_info "Edit it to add machine-specific packages, then run ./setup-macos.zsh"
}

install_homebrew() {
  log_warn "Homebrew is not installed."
  printf '\n'
  printf '  Official install script : %s\n' "$HOMEBREW_INSTALL_URL"
  printf '  Official .pkg installer : %s\n' "$HOMEBREW_PKG_URL"
  printf '\n'

  if (( DRY_RUN )); then
    log_info "[DRYRUN] Would prompt to download and run Homebrew official install script."
    return 0
  fi

  if (( CHECK_ONLY )); then
    log_error "Homebrew is required before checking Brewfile."
    return 1
  fi

  if [[ ! -t 0 ]]; then
    log_error "Interactive terminal required to confirm Homebrew installation."
    log_info "Install Homebrew manually from ${HOMEBREW_PKG_URL} and re-run this script."
    return 1
  fi

  local reply=""
  printf 'Download and run the official Homebrew install script now? [y/N]: '
  read -r reply
  if [[ "$reply" != [yY] && "$reply" != [yY][eE][sS] ]]; then
    log_info "Skipped Homebrew installation. Install it manually and re-run this script."
    return 1
  fi

  local tmp_script
  tmp_script="$(mktemp -t homebrew-install.XXXXXX)"
  trap 'rm -f "${tmp_script:-}"' EXIT INT TERM

  log_info "Downloading Homebrew installer to temporary file..."
  curl -fsSL --proto '=https' --tlsv1.2 "$HOMEBREW_INSTALL_URL" -o "$tmp_script"

  log_info "Running Homebrew installer..."
  /bin/bash "$tmp_script"

  rm -f "$tmp_script"
  trap - EXIT INT TERM

  if ! load_brew_env; then
    log_error "Homebrew installation finished, but 'brew' was not found in standard paths."
    return 1
  fi
}

run_brew_bundle() {
  local file="$1"
  local label="$2"

  if (( DRY_RUN )); then
    log_info "[DRYRUN] Would run: brew bundle --file=${file}"
    return 0
  fi

  if (( CHECK_ONLY )); then
    log_info "Checking ${label}: ${file}"
    if brew bundle check --file="$file" --verbose; then
      log_info "All dependencies in ${label} are satisfied."
    else
      log_warn "Some dependencies in ${label} are not installed yet."
      return 1
    fi
    return 0
  fi

  log_info "Installing packages from ${label}: ${file}"
  # Never pass --cleanup so existing apps/packages are not removed
  brew bundle --file="$file"
}

fix_zsh_compinit_permissions() {
  local brew_prefix
  if ! command -v brew >/dev/null 2>&1; then
    return 0
  fi
  brew_prefix="$(brew --prefix)"

  local -a dirs
  dirs=(
    "${brew_prefix}/share"
    "${brew_prefix}/share/zsh"
    "${brew_prefix}/share/zsh/site-functions"
    "${brew_prefix}/share/zsh-completions"
  )

  local dir mode
  for dir in "${dirs[@]}"; do
    [[ -d "$dir" ]] || continue
    mode="$(stat -f '%Lp' "$dir")"
    if (( (8#$mode & 8#022) != 0 )); then
      if (( DRY_RUN )); then
        log_info "[DRYRUN] Would run: chmod go-w ${dir} (current mode: ${mode})"
      else
        log_info "Tightening permissions for zsh compinit: chmod go-w ${dir} (was ${mode})"
        chmod go-w "$dir"
      fi
    fi
  done
}

setup_neovim() {
  if (( SKIP_NVIM )); then
    return 0
  fi

  if [[ -e "$NVIM_CONFIG_DIR" || -L "$NVIM_CONFIG_DIR" ]]; then
    log_info "Neovim config already exists: ${NVIM_CONFIG_DIR} (skipped)"
    return 0
  fi

  if (( DRY_RUN )); then
    log_info "[DRYRUN] Would run: git clone ${NVIM_REPO_URL} ${NVIM_CONFIG_DIR}"
    return 0
  fi

  if ! command -v git >/dev/null 2>&1; then
    log_warn "git not found; skipping Neovim config clone (${NVIM_REPO_URL})."
    return 1
  fi

  log_info "Cloning Neovim config (${NVIM_REPO_URL}) -> ${NVIM_CONFIG_DIR}"
  mkdir -p "${NVIM_CONFIG_DIR:h}"
  git clone "$NVIM_REPO_URL" "$NVIM_CONFIG_DIR"
}

main() {
  while (( $# > 0 )); do
    case "$1" in
      -n|--dry-run)
        DRY_RUN=1
        ;;
      -c|--check)
        CHECK_ONLY=1
        ;;
      -f|--extra-file)
        if (( $# < 2 )); then
          log_error "Missing path argument for $1"
          exit 1
        fi
        shift
        EXTRA_BREWFILES+=("$1")
        ;;
      --init-local)
        INIT_LOCAL=1
        ;;
      --skip-update)
        SKIP_UPDATE=1
        ;;
      --skip-nvim)
        SKIP_NVIM=1
        ;;
      --no-local)
        NO_LOCAL=1
        ;;
      --link)
        RUN_LINK=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        usage >&2
        exit 1
        ;;
    esac
    shift
  done

  if (( INIT_LOCAL )); then
    init_local_brewfile
    exit $?
  fi

  if [[ "$(uname -s)" != "Darwin" ]]; then
    log_error "This script is intended for macOS only (detected: $(uname -s))."
    exit 1
  fi

  if [[ ! -f "$BREWFILE" ]]; then
    log_error "Brewfile not found: ${BREWFILE}"
    exit 1
  fi

  local extra_file
  for extra_file in "${EXTRA_BREWFILES[@]}"; do
    if [[ ! -f "$extra_file" ]]; then
      log_error "Extra Brewfile not found: ${extra_file}"
      exit 1
    fi
  done

  if ! load_brew_env; then
    install_homebrew
  else
    log_info "Homebrew found: $(command -v brew)"
  fi

  if (( ! DRY_RUN && ! CHECK_ONLY && ! SKIP_UPDATE )); then
    log_info "Updating Homebrew..."
    brew update
  fi

  local check_failed=0
  if ! run_brew_bundle "$BREWFILE" "Brewfile"; then
    check_failed=1
  fi

  if (( ! NO_LOCAL )); then
    if [[ -f "$REPO_LOCAL_BREWFILE" ]]; then
      if ! run_brew_bundle "$REPO_LOCAL_BREWFILE" "./Brewfile.local"; then
        check_failed=1
      fi
    fi
    if [[ -f "$HOME_LOCAL_BREWFILE" ]]; then
      if ! run_brew_bundle "$HOME_LOCAL_BREWFILE" "~/.Brewfile.local"; then
        check_failed=1
      fi
    fi
  fi

  for extra_file in "${EXTRA_BREWFILES[@]}"; do
    if ! run_brew_bundle "$extra_file" "$extra_file"; then
      check_failed=1
    fi
  done

  if (( CHECK_ONLY )); then
    exit "$check_failed"
  fi

  fix_zsh_compinit_permissions
  setup_neovim

  if (( RUN_LINK )); then
    local installer="${DOTFILES_DIR}/install.zsh"
    if [[ ! -x "$installer" ]]; then
      log_error "Symlink installer not found or not executable: ${installer}"
      exit 1
    fi
    if (( DRY_RUN )); then
      log_info "[DRYRUN] Would run: ${installer}"
    else
      log_info "Running symlink installer..."
      "$installer"
    fi
  fi

  log_info "macOS setup complete."
}

main "$@"
