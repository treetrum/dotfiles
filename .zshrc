# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

# powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Load completions
autoload -U compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=*' # Enable case-insensitive and fuzzy matching
zstyle ':completion:*' menu select # highlights the active tab completion
bindkey '^[[Z' reverse-menu-complete # allows shift-tab for backwards nav

# Fish like history behaviour (up arrow fuzzy searching)
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# History
setopt share_history # Share history between shells
setopt hist_ignore_dups # Ignore duplicate commands in history
HISTSIZE=20000 # Store 20,000 lines in memory
SAVEHIST=20000 # Store 20,000 lines on disk

# Make option-backspace work more like standard macos
autoload -U select-word-style
select-word-style bash

# Make instant prompt less verbose
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Aliases
alias ll="ls -l"
alias p="pnpm"
alias pn="pnpm"

# Source all function files from functions_dir
functions_dir=~/.zsh-functions
for func_file in "$functions_dir"/*.zsh; do
    [[ -e "$func_file" ]] && source "$func_file"
done

# Source the machine specific config if it exists
if [ -f ~/.not-tracked.zsh ]; then
  source ~/.not-tracked.zsh
fi

# Oh My ZSH plugins
zinit snippet OMZ::plugins/git/git.plugin.zsh

# Setup iterm2 to read from dotfiles
is_zsh_setup=$(defaults read com.googlecode.iterm2.plist LoadPrefsFromCustomFolder)
if [[ "$is_zsh_setup" != "1" ]]; then
    echo "Configuring iTerm2"
    defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/dotfiles/iterm2"
    defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
fi

# Plugins
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light dominik-schwabe/zsh-fnm
zinit light zsh-users/zsh-syntax-highlighting # important for this plugin to be last. See https://github.com/zsh-users/zsh-syntax-highlighting?tab=readme-ov-file#why-must-zsh-syntax-highlightingzsh-be-sourced-at-the-end-of-the-zshrc-file

# To customize prompt, run `p10k configure` or edit ~/dotfiles/.p10k.zsh.
[[ ! -f ~/dotfiles/.p10k.zsh ]] || source ~/dotfiles/.p10k.zsh

# pnpm
export PNPM_HOME="/Users/$(whoami)/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/Users/daviss15/.bun/_bun" ] && source "/Users/daviss15/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
