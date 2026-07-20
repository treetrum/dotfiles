# Aliases

alias open-chrome-no-cors='open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="$HOME/chrome-user-data-dir" --disable-web-security'

alias rsync-cbz-untracked="rsync -avm \
  --exclude='node_modules/' \
  --exclude='.turbo/' \
  --exclude='.next/' \
  --include='.env' \
  --include='lefthook-local.yml' \
  --include='config.yml' \
  --include='dev_server.db' \
  --include='*local.*' \
  --include='*/' \
  --exclude='*' \
  $HOME/Developer/commbiz-web/ ."

alias copy-untracked-cbz='copy-untracked -g "**/dev_server.db" -g "**/config.yml"'

# Run all turbo tasks whose name starts with "codegen:" (reads ./turbo.json in cwd).
# Pass extra args through to turbo, e.g. `cba-codegen --filter=web`.
alias cbz-codegen='pnpm turbo $(jq -r ".tasks | keys[] | select(startswith(\"codegen:\"))" turbo.json | tr "\n" " ")'

# Bootstrap a fresh commbiz-web worktree: copy untracked files, install deps, run codegen.
cbz-wt-bootstrap() {
  echo "==> Copying untracked files"
  if ! copy-untracked-cbz; then
    echo "Error: failed to copy untracked files" >&2
    return 1
  fi

  echo "==> Installing dependencies"
  if ! pnpm install; then
    echo "Error: pnpm install failed" >&2
    return 1
  fi

  echo "==> Running codegen"
  if ! cbz-codegen; then
    echo "Error: codegen failed" >&2
    return 1
  fi

  echo "==> Worktree bootstrap complete"
}

# Homebrew

export PATH="${HOMEBREW_PREFIX}/opt/openssl/bin:$PATH"

# Prisma Proxy
alias unset-proxy="unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy"
export PRISMA_PROXY="$CBA_PRISMA_PROXY"
alias set-proxy-prisma="export http_proxy=$PRISMA_PROXY \
    && export https_proxy=$PRISMA_PROXY \
    && export HTTP_PROXY=$PRISMA_PROXY \
    && export HTTPS_PROXY=$PRISMA_PROXY"

# Update PORTKEY_API_KEY
update_portkey_token() {

    filepath="$HOME/dotfiles/zsh/.env"

    # Check if input is piped
    if [ ! -t 0 ]; then
        # Read from pipe
        read -r new_token
    else
        # Prompt for new token (secure)
        read -s "new_token?Enter new PORTKEY_API_KEY: "
        echo "" # Move to a new line after input
    fi

    if [ -z "$new_token" ]; then
        echo "No token entered. Aborting."
        return 1
    fi

    # Escape characters that would break the sed expression (/, \, &)
    local escaped_token
    escaped_token=$(printf '%s' "$new_token" | sed 's/[\&/]/\\&/g')

    # Update .env file
    sed -i '' "s/^PORTKEY_API_KEY=.*/PORTKEY_API_KEY=\"$escaped_token\"/" "$filepath"
    echo "PORTKEY_API_KEY updated successfully."

    # Reload .env to update environment variable in current session
    load_secrets
}

# Java - Set to Java 17 for CBA projects
export JAVA_HOME="/Library/Java/JavaVirtualMachines/amazon-corretto-17.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Prevent opencode from making extra network requests (times out on CBA network)
export OPENCODE_DISABLE_MODELS_FETCH=1

# Setup alpaca proxy & certs
export {all,http,https}_proxy=http://localhost:3128
export AWS_CA_BUNDLE="$HOME/.config/cacert/cacert.pem"
export GIT_SSL_CAINFO="$HOME/.config/cacert/cacert.pem"
export NODE_EXTRA_CA_CERTS="$HOME/.config/cacert/cacert.pem"
export REQUESTS_CA_BUNDLE="$HOME/.config/cacert/cacert.pem"
export SSL_CERT_FILE="$HOME/.config/cacert/cacert.pem"

# Corepack
export COREPACK_NPM_REGISTRY="$CBA_COREPACK_NPM_REGISTRY"
export COREPACK_INTEGRITY_KEYS="0"
