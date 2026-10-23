# Dotfiles

[![CI](https://github.com/buritica/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/buritica/dotfiles/actions/workflows/ci.yml)
[![Security](https://github.com/buritica/dotfiles/actions/workflows/security.yml/badge.svg)](https://github.com/buritica/dotfiles/actions/workflows/security.yml)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

My personal dotfiles and system configuration, managed with [chezmoi](https://chezmoi.io/). Packages and machine setup live in [buritica/machines](https://github.com/buritica/machines); this repo is config only.

## Overview

This setup provides:
- Custom shell configuration with Zsh, including prompt and aliases
- Optimized macOS system settings for performance and privacy
- git and Ghostty configuration

## Quick Start

### For a Brand New Mac

Managed Macs get these dotfiles from [buritica/machines](https://github.com/buritica/machines) (`bootstrap.sh`, then `provision.yml`). On any other Mac with chezmoi installed:

1. Clone and run the setup script:
   ```bash
   git clone https://github.com/buritica/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ./setup.sh
   ```

2. Restart your terminal.

### Updating

Managed hosts (crowntail, halfmoon, severo) get dotfiles from the machines repo's `chezmoi` role; see the "Dotfiles" section of its `CLAUDE.md`. Don't run `chezmoi update` or `chezmoi apply` by hand there. `chezmoi update` is only for a Mac the machines repo doesn't manage.

## What's Included

- zsh with Oh My Zsh and the zsh plugins, pinned in `.chezmoiexternal.toml`, and the starship prompt
- A shared zsh base (`dot_config/zsh-base/`) that the `estanli` account on severo also loads
- git (with difftastic and git-absorb aliases), tmux, SSH client config, ripgrep, direnv, gh, atuin, lazygit and Ghostty
- macOS preferences (`~/.my/.macos`, laptops only)

No packages: those live in the machines repo's `ansible/roles/packages/files/Brewfile`.

## How It Works

`setup.sh` checks chezmoi is installed and runs `chezmoi init --apply` against this repo. chezmoi applies the dotfiles, pulls zsh plugins (`.chezmoiexternal.toml`) and runs the macOS defaults script when it changes.

## License

MIT