link-untracked() {
  emulate -L zsh
  setopt pipefail
  setopt extendedglob
  setopt null_glob

  # Parse flags and path
  local use_copy=0
  local force=0
  local src_root=""
  
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --copy)
        use_copy=1
        shift
        ;;
      --force|-f)
        force=1
        shift
        ;;
      -*)
        echo "Unknown flag: $1"
        echo "Usage: link-untracked [--copy] [--force|-f] /path/to/source-root"
        return 2
        ;;
      *)
        if [[ -n "$src_root" ]]; then
          echo "Error: Multiple paths specified"
          echo "Usage: link-untracked [--copy] [--force|-f] /path/to/source-root"
          return 2
        fi
        src_root="$1"
        shift
        ;;
    esac
  done

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

  if [[ -z "$src_root" ]]; then
    echo "Usage: link-untracked [--copy] [--force|-f] /path/to/source-root"
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
  if [[ "$use_copy" -eq 1 ]]; then
    echo "Mode:   copy"
  else
    echo "Mode:   symlink"
  fi
  if [[ "$force" -eq 1 ]]; then
    echo "Force:  enabled (will overwrite existing files)"
  fi
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

  # Helper: link or copy file preserving relative path
  _process_file() {
    local abs_src="$1"
    local rel="${abs_src#$src_root/}"
    local abs_dest="$dest_root/$rel"

    mkdir -p "${abs_dest:h}"

    if [[ "$use_copy" -eq 1 ]]; then
      if [[ -e "$abs_dest" ]]; then
        if [[ "$force" -eq 1 ]]; then
          rm -f "$abs_dest"
          cp "$abs_src" "$abs_dest"
          echo "Copied (overwrite) $rel"
        else
          echo "Exists, skipping: $rel"
          return 0
        fi
      else
        cp "$abs_src" "$abs_dest"
        echo "Copied $rel"
      fi
    else
      if [[ -e "$abs_dest" && ! -L "$abs_dest" ]]; then
        if [[ "$force" -eq 1 ]]; then
          rm -f "$abs_dest"
          ln -sfn "$abs_src" "$abs_dest"
          echo "Linked (overwrite) $rel"
        else
          echo "Exists and is not a symlink, skipping: $rel"
          return 0
        fi
      else
        ln -sfn "$abs_src" "$abs_dest"
        echo "Linked $rel"
      fi
    fi
  }

  local pat src
  for pat in "${ALLOW_GLOBS[@]}"; do
    # Expand relative glob under source root
    local full_pat="$src_root/$pat"

    # ${~var} tells zsh "treat var as a glob pattern"
    for src in ${~full_pat}(N-.); do
      _is_skipped_path "$src" && continue
      _process_file "$src"
    done
  done

  echo
  echo "Done."
}