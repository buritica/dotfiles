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

### For an Existing Setup

```bash
chezmoi update
```

## What's Included

Shell (zsh + Oh My Zsh), git, Ghostty and macOS preferences. No packages: those live in the machines repo's `ansible/roles/packages/files/Brewfile`.

## How It Works

`setup.sh` checks chezmoi is installed and runs `chezmoi init --apply` against this repo. chezmoi applies the dotfiles, pulls zsh plugins (`.chezmoiexternal.toml`) and runs the macOS defaults script when it changes.

## Release Process

This repository uses an automated release process through GitHub Actions. When changes are merged to the master branch:

1. Tests are run to ensure stability
2. A new version is automatically determined based on PR labels:
   - `version/major`: Bumps the major version (e.g., 1.0.0 → 2.0.0)
   - `version/patch`: Bumps the patch version (e.g., 1.0.0 → 1.0.1)
   - No label: Bumps the minor version (e.g., 1.0.0 → 1.1.0)
3. A changelog is automatically generated from commit messages
4. A new GitHub release is created with:
   - Semantic version tag (e.g., v1.0.0)
   - Release notes from the changelog
   - Associated commit history

To trigger a specific version bump, simply add the appropriate label to your pull request before merging.

## License

MIT