link-untracked() {
  emulate -L zsh
  setopt pipefail
  setopt extendedglob
  setopt null_glob

  # ========= CONFIG (explicit allowlist: RELATIVE PATH GLOBS) =========
  # These are relative to the source root.
  # Examples:
  #   ".env"                 -> only root .env
  #   "**/.env"              -> .env at any depth (including root)
  #   "**/*/*.local.*"       -> *.local.* at least 2 levels deep
  #   "**/*.local.*"         -> *.local.* at any depth
  #   "**/lefthook-local.yml"-> lefthook-local.yml at any depth
  local -a ALLOW_GLOBS=(
    "**/.env"
    "**/*/*.local.*"
    "**/lefthook-local.yml"
  )

  # Directories to skip while searching (anywhere in the path)
  local -a SKIP_DIRS=(
    ".git"
    "node_modules"
    ".next"
    ".turbo"
    "dist"
    "build"
    "coverage"
  )
  # ===================================================================

  local src_root="$1"
  if [[ -z "$src_root" ]]; then
    echo "Usage: link-untracked /path/to/source-root"
    return 2
  fi

  src_root="${src_root:A}"
  if [[ ! -d "$src_root" ]]; then
    echo "Source path is not a directory: $src_root"
    return 2
  fi

  local dest_root="${PWD:A}"
  if [[ "$dest_root" == "$src_root" ]]; then
    echo "Source and destination are the same directory. Nothing to do."
    return 0
  fi

  echo "Source: $src_root"
  echo "Dest:   $dest_root"
  echo "Allowlist globs:"
  printf "  %s\n" "${ALLOW_GLOBS[@]}"
  echo

  # Helper: skip anything inside unwanted dirs
  _is_skipped_path() {
    local p="$1"
    local d
    for d in "${SKIP_DIRS[@]}"; do
      [[ "$p" == *"/$d/"* ]] && return 0
    done
    return 1
  }

  # Helper: link file preserving relative path
  _link_rel() {
    local abs_src="$1"
    local rel="${abs_src#$src_root/}"
    local abs_dest="$dest_root/$rel"

    mkdir -p "${abs_dest:h}"

    if [[ -e "$abs_dest" && ! -L "$abs_dest" ]]; then
      echo "Exists and is not a symlink, skipping: $rel"
      return 0
    fi

    ln -sfn "$abs_src" "$abs_dest"
    echo "Linked $rel"
  }

  local pat src
  for pat in "${ALLOW_GLOBS[@]}"; do
    # Expand relative glob under source root
    local full_pat="$src_root/$pat"

    # ${~var} tells zsh "treat var as a glob pattern"
    for src in ${~full_pat}(N-.); do
      _is_skipped_path "$src" && continue
      _link_rel "$src"
    done
  done

  echo
  echo "Done."
}