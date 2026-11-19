# Zsh Configuration

This directory contains the zsh configuration, set via `ZDOTDIR` in `~/.zshenv`.

## Directory Structure

```
~/.config/zsh/
├── .zshrc              # Main configuration
├── .zsh_history        # Command history
└── plugins/
    ├── zsh-autosuggestions/
    └── zsh-syntax-highlighting/
```

## Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+T` | Fuzzy find directories (relative to cwd) |
| `Ctrl+G` | Fuzzy find directories (from home) |
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+F` | Accept autosuggestion |

## Features

- **Starship Prompt**: Customizable prompt (config at `~/.config/starship.toml`)
- **Autosuggestions**: Shows suggestions as you type (grey text)
- **Syntax Highlighting**: Valid commands are green, invalid are red
- **Zoxide**: Smart `cd`. Use `z <partial_name>` to jump to frequent directories
- **FZF Integration**: Fuzzy finding for directories and history

## Aliases

| Alias | Command |
|-------|---------|
| `ll` | `ls -l` |
| `la` | `ls -la` |
| `grep` | `grep --color=auto` |
| `..` | `cd ..` |

## Reload Config

```bash
source ~/.config/zsh/.zshrc
```
