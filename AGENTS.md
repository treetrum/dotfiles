# AGENTS.md — Dotfiles Repository

This is a personal dotfiles repository managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a "stow package" that mirrors the `$HOME` hierarchy; `stow <pkg>` creates
symlinks from `$HOME` into the corresponding package directory.

---

## Repository Layout

```
dotfiles/
├── btop/        → ~/.config/btop/
├── ghostty/     → ~/.config/ghostty/
├── iterm2/      → ~/iterm2/
├── lazygit/     → ~/.config/lazygit/
├── nvim/        → ~/.config/nvim/
├── tmux/        → ~/.config/tmux/
├── vim/         → ~/.vimrc
└── zsh/         → ~/.zshrc, ~/.p10k.zsh, ~/.config/zsh/
```

---

## Build / Deployment Commands

There is **no build system, no Makefile, no package.json, and no test suite** in this repo.
Deployment is purely via Stow.

```sh
# Install all packages
stow zsh nvim tmux lazygit btop ghostty iterm2 vim

# Install a single package
stow zsh
stow nvim

# Remove a package's symlinks
stow -D zsh
stow -D nvim

# Restow (useful after adding new files to a package)
stow -R zsh
```

---

## Linting / Formatting

There is no CI or standalone lint runner. Linting and formatting are applied **inside Neovim**
via Mason-managed tools. The relevant tools and their scope:

| Tool        | Scope                        | Config                          |
|-------------|------------------------------|---------------------------------|
| `stylua`    | Lua (`nvim/`)                | `nvim/.config/nvim/stylua.toml` |
| `shfmt`     | Shell scripts (`zsh/`)       | No config file; installed via Mason |
| `shellcheck`| Shell scripts                | No config file; installed via Mason |
| `prettier`  | JS/TS/JSON/YAML (projects)   | Only activates when `.prettierrc` is present |
| `biome`     | JS/TS (projects)             | Only activates when run from a project CWD |

To manually format Lua:
```sh
stylua nvim/.config/nvim/lua/
```

To manually lint shell files:
```sh
shellcheck zsh/.config/zsh/functions/*.zsh
shellcheck zsh/.zshrc
```

---

## Code Style Guidelines

### General

- **Indentation:** 2 spaces for all files (Zsh, Lua, YAML, JSON). No tabs except in vendored code.
- **Line length:** 120 columns (enforced by StyLua for Lua; follow the same limit for shell).
- **Trailing whitespace:** avoid it.
- **No AI-generated comment bloat:** keep comments concise and meaningful.

---

### Zsh / Shell Scripts

**File structure**
- Function files live in `zsh/.config/zsh/functions/<name>.zsh`.
- Each file defines one or more related shell functions (no shebang — files are sourced, not executed).
- Machine-specific config belongs in `zsh/.config/zsh/not-tracked.zsh` (gitignored), never committed.

**Naming conventions**
- User-facing functions: `kebab-case` (e.g., `create-branch-from-main`, `kill-process-on-port`)
- Internal/utility functions: `snake_case` (e.g., `load_secrets`, `time_command`)
- Private helpers inside a function: `_underscore_prefix` (e.g., `_is_skipped_path`, `_link_rel`)
- Local variables: `snake_case` declared with `local`
- Exported environment variables: `SCREAMING_SNAKE_CASE`

**Quoting and brackets**
- Always double-quote variable expansions: `"$1"`, `"$var"`, `"$some_path"`
- Use `[[ ]]` double-brackets for conditionals (Zsh extended test, not POSIX `[ ]`)
- Exception: use `[ -f "..." ]` for POSIX portability when sourcing files in `.zshrc`

**Error handling**
```zsh
# Always guard required arguments
if [[ -z "$1" ]]; then
  echo "Usage: my-function <arg>"
  return 1
fi

# Use return codes consistently
# return 0  → success or no-op
# return 1  → general error
# return 2  → bad arguments / usage error

# Check for optional tools before using them
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi
```

**Paths**
- Use `${XDG_CONFIG_HOME:-$HOME/.config}` everywhere instead of hardcoding `~/.config`.
- Resolve absolute paths with Zsh's `:A` modifier: `src_root="${src_root:A}"`.

**Comments**
- Use `# Capitalized` section headers with a blank line before them.
- Inline comments on the same line for short clarifications.
- Separate logical blocks with a blank line, not separator lines (except in complex config sections).

**Example function skeleton:**
```zsh
my-function() {
  if [[ -z "$1" ]]; then
    echo "Usage: my-function <required-arg>"
    return 1
  fi

  local input="$1"
  local output_file="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/something"

  # Do the thing
  echo "Processing $input"
}
```

---

### Lua (Neovim configuration)

All Lua lives under `nvim/.config/nvim/lua/`. The config uses the
[LazyVim](https://www.lazyvim.org/) framework; customizations override or extend LazyVim defaults.

**Formatting** (enforced by `stylua.toml`):
- 2-space indentation
- 120-column width
- Spaces, not tabs

**Plugin specs** (`lua/plugins/*.lua`):
- Each file returns a single table: `return { "author/plugin", opts = { ... } }`
- Use `opts = function(_, opts)` to extend LazyVim plugin defaults rather than replacing them
- Keep plugin files focused: one plugin (or one tightly related group) per file

**Options and keymaps** (`lua/config/`):
- `options.lua` — Neovim options only; reference the LazyVim defaults URL in a comment
- `keymaps.lua` — `vim.keymap.set()` calls with explicit `{ silent = true }` where appropriate
- Group related keymaps with a `-- Description` comment above each group

**Style:**
```lua
-- Good: explicit mode, silent option
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { silent = true })

-- Plugin spec pattern
return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      biome = { require_cwd = true },
    },
  },
}
```

---

### Configuration Files (YAML, TOML, tmux, etc.)

- YAML: 2-space indentation; no trailing spaces.
- tmux.conf: flat `set`/`bind` format; group related settings with a blank line.
- No auto-generated content should be committed (exception: `.p10k.zsh` is generated by
  `p10k configure` and is intentionally committed).

---

## Git Conventions

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): short imperative description
```

- **Types:** `feat`, `chore`, `fix`, `refactor`, `docs`
- **Scopes:** match the package name — `zsh`, `nvim`, `tmux`, `lazygit`, `ghostty`, `btop`
- **Message:** lowercase, imperative mood, no period
- **Examples:**
  ```
  feat(zsh): add link-untracked helper function
  chore(nvim): sync lazy-lock.json
  fix(zsh): prevent duplicate PATH entries for pnpm
  ```

---

## Secrets and Sensitive Files

- `~/.env` is **gitignored** and loaded at shell startup via `load_secrets()` in `.zshrc`.
- `zsh/.config/zsh/not-tracked.zsh` and `zsh/.config/zsh/computers/` are gitignored.
- **Never commit** API tokens, passwords, or machine-specific paths.
- The `link-untracked` function exists specifically to symlink `.env` and `*.local.*` files
  from a separate (private) source tree into a project without committing them.

---

## Adding a New Package

1. Create a top-level directory mirroring `$HOME` structure:
   ```
   mypkg/
   └── .config/
       └── mypkg/
           └── config.toml
   ```
2. Run `stow mypkg` from the dotfiles root.
3. Add the package to the stow command in `README.md`.

## Adding a New Zsh Function

1. Create `zsh/.config/zsh/functions/<function-name>.zsh`.
2. The function is auto-sourced by the glob loop in `.zshrc` — no further wiring needed.
3. Follow the naming and error-handling conventions above.
