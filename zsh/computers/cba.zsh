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
  --include='*/' \
  --exclude='*' \
  $HOME/Developer/commbiz-web/ ."

# Homebrew

export PATH="${HOMEBREW_PREFIX}/opt/openssl/bin:$PATH"

# Prisma Proxy
alias unset-proxy="unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy"
export PRISMA_PROXY=http://cba.proxy.prismaaccess.com:8080
alias set-proxy-prisma="export http_proxy=$PRISMA_PROXY \
    && export https_proxy=$PRISMA_PROXY \
    && export HTTP_PROXY=$PRISMA_PROXY \
    && export HTTPS_PROXY=$PRISMA_PROXY"

# Update ANTHROPIC_AUTH_TOKEN
update_genai_token() {

    filepath="$HOME/dotfiles/.env"

    # Check if input is piped
    if [ ! -t 0 ]; then
        # Read from pipe
        read -r new_token
    else
        # Prompt for new token (secure)
        read -s "new_token?Enter new ANTHROPIC_AUTH_TOKEN: "
    fi

    if [ -z "$new_token" ]; then
        echo "No token entered. Aborting."
        return 1
    fi

    # Update .env file
    sed -i '' "s/^ANTHROPIC_AUTH_TOKEN=.*/ANTHROPIC_AUTH_TOKEN=\"$new_token\"/" "$filepath"
    echo ""
    echo "ANTHROPIC_AUTH_TOKEN updated successfully."

    # Reload .env to update environment variable in current session
    load_secrets
}

# Java - Set to Java 17 for CBA projects
export JAVA_HOME="/Library/Java/JavaVirtualMachines/amazon-corretto-17.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Setup alpaca proxy & certs
export {all,http,https}_proxy=http://localhost:3128
export AWS_CA_BUNDLE="$HOME/.config/cacert/cacert.pem"
export GIT_SSL_CAINFO="$HOME/.config/cacert/cacert.pem"
export NODE_EXTRA_CA_CERTS="$HOME/.config/cacert/cacert.pem"
export REQUESTS_CA_BUNDLE="$HOME/.config/cacert/cacert.pem"
export SSL_CERT_FILE="$HOME/.config/cacert/cacert.pem"
