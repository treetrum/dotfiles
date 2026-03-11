# Sam Davis dot files

### Prerequisites

- Git
- Stow `brew install stow`

### Usage

1. Clone the repo to your home directory (location is important)
1. Stow the packages you want, e.g.:

```sh
stow zsh nvim tmux lazygit btop ghostty iterm2 vim
```

Or individually:

```sh
stow tmux
stow zsh
```

### Removing a package

Use the `-D` flag to remove a package's symlinks:

```sh
stow -D tmux
stow -D zsh
```

### Packages

| Package   | Stow target          |
|-----------|----------------------|
| `zsh`     | `~/.zshrc`, `~/.p10k.zsh`, `~/.config/zsh/` |
| `nvim`    | `~/.config/nvim/`    |
| `tmux`    | `~/.config/tmux/`    |
| `lazygit` | `~/.config/lazygit/` |
| `btop`    | `~/.config/btop/`    |
| `ghostty` | `~/.config/ghostty/` |
| `iterm2`  | `~/iterm2/`          |
| `vim`     | `~/.vimrc`           |
