#!/usr/bin/env zsh
#
# Symlink installer for dotfiles-public (without GNU Stow).
# Links individual files from each package directory into $HOME,
# safely replacing old directory symlinks and backing up existing regular files.

emulate -LR zsh
setopt errexit nounset pipefail

DOTFILES_DIR="${0:A:h}"
BACKUP_ROOT="${HOME}/.dotfiles_backup"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"

DRY_RUN=0
UNLINK_MODE=0
NO_BACKUP=0
typeset -a TARGET_PACKAGES
TARGET_PACKAGES=()

# Packages that are only applied by default on macOS
typeset -a MACOS_ONLY_PACKAGES
MACOS_ONLY_PACKAGES=(karabiner)

# Packages that are only applied by default on Windows (managed via install.ps1)
typeset -a WINDOWS_ONLY_PACKAGES
WINDOWS_ONLY_PACKAGES=(powershell)

# Counters & state
count_linked=0
count_updated=0
count_skipped=0
count_backed_up=0
count_unlinked=0
typeset -A SEEN_UNLINKED_DIRS

usage() {
  cat <<'EOF'
Usage: ./install.zsh [OPTIONS] [PACKAGE ...]

Create or update symlinks from this repository into $HOME without GNU Stow.
Links are created per file so untracked/sensitive files in the same directory
(e.g. ~/.config/gh/hosts.yml, ~/.config/tmux/plugins) stay outside this repo.

Options:
  -n, --dry-run    Show planned actions without making any changes
  -u, --unlink     Remove symlinks that point into this repository
      --no-backup  Overwrite existing regular files without backing them up
  -l, --list       List detected packages and exit
  -h, --help       Show this help message

Examples:
  ./install.zsh --dry-run
  ./install.zsh
  ./install.zsh ghostty wezterm starship
  ./install.zsh --unlink
EOF
}

log_info() {
  printf '[INFO]   %s\n' "$1"
}

log_action() {
  local tag="$1"
  local msg="$2"
  if (( DRY_RUN )); then
    printf '[DRYRUN] %-10s %s\n' "$tag" "$msg"
  else
    printf '[%-6s] %s\n' "$tag" "$msg"
  fi
}

log_warn() {
  printf '[WARN]   %s\n' "$1" >&2
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

is_in_array() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

discover_packages() {
  local dir name entry
  local has_dot
  local -a pkgs entries
  pkgs=()
  for dir in "${DOTFILES_DIR}"/*(/N); do
    name="${dir:t}"
    [[ "$name" == .* ]] && continue
    # Treat as a dotfiles package if it contains dotfiles or a .config directory
    entries=("${dir}"/*(DN))
    has_dot=0
    for entry in "${entries[@]}"; do
      if [[ "${entry:t}" == .* ]]; then
        has_dot=1
        break
      fi
    done
    if (( has_dot )); then
      pkgs+=("$name")
    fi
  done
  print -rl -- "${pkgs[@]}"
}

should_ignore_rel_path() {
  local rel="$1"
  local base="${rel:t}"
  case "$base" in
    .DS_Store|*.swp|*.bak|*~)
      return 0
      ;;
  esac
  case "$rel" in
    .config/tmux/plugins/*|.config/tmux/plugins)
      return 0
      ;;
  esac
  return 1
}

ensure_real_parent_dir() {
  local target_dir="$1"

  if [[ "$target_dir" != "$HOME" && "$target_dir" != "$HOME/"* ]]; then
    if (( ! DRY_RUN )); then
      mkdir -p "$target_dir"
    fi
    return 0
  fi

  local rel="${target_dir#$HOME}"
  rel="${rel#/}"
  [[ -z "$rel" ]] && return 0

  local current="$HOME"
  local part old_target
  for part in "${(@s:/:)rel}"; do
    current="${current}/${part}"
    if [[ -L "$current" ]]; then
      if [[ -z "${SEEN_UNLINKED_DIRS[$current]:-}" ]]; then
        old_target="$(readlink "$current")"
        log_action "REPL-DIR" "${current} (symlink -> ${old_target}) -> real directory"
        SEEN_UNLINKED_DIRS[$current]=1
        if (( ! DRY_RUN )); then
          rm "$current"
          mkdir -p "$current"
        fi
      fi
    elif [[ -e "$current" && ! -d "$current" ]]; then
      log_warn "Cannot create directory because a file exists at: ${current}"
      return 1
    elif [[ ! -d "$current" ]]; then
      if (( ! DRY_RUN )); then
        mkdir -p "$current"
      fi
    fi
  done
  return 0
}

has_unlinked_ancestor() {
  local target_path="$1"
  local dir
  for dir in "${(@k)SEEN_UNLINKED_DIRS}"; do
    if [[ "$target_path" == "${dir}/"* ]]; then
      return 0
    fi
  done
  return 1
}

backup_existing() {
  local dest="$1"
  local rel="$2"
  local backup_path="${BACKUP_DIR}/${rel}"

  log_action "BACKUP" "${dest} -> ${backup_path}"
  if (( ! DRY_RUN )); then
    mkdir -p "${backup_path:h}"
    mv "$dest" "$backup_path"
  fi
  count_backed_up=$(( count_backed_up + 1 ))
}

link_file() {
  local src="$1"
  local rel="$2"
  local dest="${HOME}/${rel}"

  ensure_real_parent_dir "${dest:h}"

  if (( DRY_RUN )) && has_unlinked_ancestor "$dest"; then
    log_action "LINK" "${dest} -> ${src}"
    count_linked=$(( count_linked + 1 ))
    return 0
  fi

  if [[ -L "$dest" ]]; then
    if [[ -e "$dest" && "${dest:A}" == "${src:A}" ]]; then
      log_action "SKIP" "${dest} (already linked)"
      count_skipped=$(( count_skipped + 1 ))
      return 0
    fi
    local old_target
    old_target="$(readlink "$dest")"
    log_action "UPDATE" "${dest} (was -> ${old_target}) -> ${src}"
    if (( ! DRY_RUN )); then
      rm "$dest"
      ln -s "$src" "$dest"
    fi
    count_updated=$(( count_updated + 1 ))
    return 0
  fi

  if [[ -e "$dest" ]]; then
    if (( NO_BACKUP )); then
      log_action "REMOVE" "${dest} (--no-backup)"
      if (( ! DRY_RUN )); then
        rm -rf "$dest"
      fi
    else
      backup_existing "$dest" "$rel"
    fi
  fi

  log_action "LINK" "${dest} -> ${src}"
  if (( ! DRY_RUN )); then
    ln -s "$src" "$dest"
  fi
  count_linked=$(( count_linked + 1 ))
}

unlink_file() {
  local src="$1"
  local rel="$2"
  local dest="${HOME}/${rel}"

  if [[ -L "$dest" && -e "$dest" && "${dest:A}" == "${src:A}" ]]; then
    log_action "UNLINK" "${dest}"
    if (( ! DRY_RUN )); then
      rm "$dest"
    fi
    count_unlinked=$(( count_unlinked + 1 ))
  else
    log_action "SKIP" "${dest} (not linked to this repo)"
    count_skipped=$(( count_skipped + 1 ))
  fi
}

process_package() {
  local pkg="$1"
  local pkg_dir="${DOTFILES_DIR}/${pkg}"

  if [[ ! -d "$pkg_dir" ]]; then
    log_warn "Package directory not found: ${pkg}"
    return 1
  fi

  log_info "Package: ${pkg}"

  local -a files
  files=("${pkg_dir}"/**/*(DN^/))
  if (( ${#files[@]} == 0 )); then
    log_warn "No files found in package: ${pkg}"
    return 0
  fi

  local src rel
  for src in "${files[@]}"; do
    rel="${src#${pkg_dir}/}"
    if should_ignore_rel_path "$rel"; then
      continue
    fi
    if (( UNLINK_MODE )); then
      unlink_file "$src" "$rel"
    else
      link_file "$src" "$rel"
    fi
  done
}

main() {
  local list_only=0

  while (( $# > 0 )); do
    case "$1" in
      -n|--dry-run)
        DRY_RUN=1
        ;;
      -u|--unlink)
        UNLINK_MODE=1
        ;;
      --no-backup)
        NO_BACKUP=1
        ;;
      -l|--list)
        list_only=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        TARGET_PACKAGES+=("$@")
        break
        ;;
      -*)
        log_warn "Unknown option: $1"
        usage >&2
        exit 1
        ;;
      *)
        TARGET_PACKAGES+=("$1")
        ;;
    esac
    shift
  done

  local -a all_packages
  all_packages=("${(@f)$(discover_packages)}")

  if (( list_only )); then
    print -rl -- "${all_packages[@]}"
    exit 0
  fi

  local explicit=0
  if (( ${#TARGET_PACKAGES[@]} > 0 )); then
    explicit=1
  else
    TARGET_PACKAGES=("${all_packages[@]}")
  fi

  if (( ${#TARGET_PACKAGES[@]} == 0 )); then
    log_warn "No packages found in ${DOTFILES_DIR}"
    exit 1
  fi

  log_info "Repository: ${DOTFILES_DIR}"
  log_info "Target HOME: ${HOME}"
  (( DRY_RUN )) && log_info "Mode: dry-run (no changes will be made)"

  local pkg
  for pkg in "${TARGET_PACKAGES[@]}"; do
    if (( ! explicit )) && is_in_array "$pkg" "${WINDOWS_ONLY_PACKAGES[@]}"; then
      log_info "Skipping Windows-only package on $(uname -s): ${pkg}"
      continue
    fi
    if (( ! explicit )) && ! is_macos && is_in_array "$pkg" "${MACOS_ONLY_PACKAGES[@]}"; then
      log_info "Skipping macOS-only package on $(uname -s): ${pkg}"
      continue
    fi
    process_package "$pkg"
  done

  printf '\n'
  if (( UNLINK_MODE )); then
    log_info "Done. unlinked=${count_unlinked}, skipped=${count_skipped}"
  else
    log_info "Done. linked=${count_linked}, updated=${count_updated}, skipped=${count_skipped}, backed_up=${count_backed_up}"
    if (( count_backed_up > 0 && ! DRY_RUN )); then
      log_info "Backups saved to: ${BACKUP_DIR}"
    fi
  fi
}

main "$@"
