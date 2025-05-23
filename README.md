# Dotfiles

[![CI](https://github.com/buritica/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/buritica/dotfiles/actions/workflows/ci.yml)
[![Security](https://github.com/buritica/dotfiles/actions/workflows/security.yml/badge.svg)](https://github.com/buritica/dotfiles/actions/workflows/security.yml)
[![codecov](https://codecov.io/gh/buritica/dotfiles/branch/master/graph/badge.svg)](https://codecov.io/gh/buritica/dotfiles)
[![unknown](https://img.shields.io/badge/status-unknown-lightgrey.svg)](https://github.com/buritica/dotfiles)
[![docs](https://img.shields.io/badge/docs-GitHub%20Pages-blue.svg)](https://buritica.github.io/dotfiles/)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

My personal dotfiles and system configuration, managed with [chezmoi](https://chezmoi.io/). This repository contains everything needed to bootstrap and maintain a consistent development environment across macOS machines.

## Overview

This setup provides:
- A curated selection of development tools and productivity apps via Homebrew
- Optimized macOS system settings for performance and privacy
- Custom shell configuration with Zsh, including prompt and aliases
- VS Code development environment setup
- Automated installation and configuration of essential tools

## Quick Start

### For a Brand New Mac

1. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

2. Clone and run the setup script:
   ```bash
   git clone https://github.com/buritica/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ./setup.sh
   ```

3. Follow the on-screen instructions to complete the setup.

### For an Existing Setup

To update your environment with the latest changes:

```bash
cd ~/.dotfiles
git pull
./setup.sh
```

## What's Included

### Development Tools
- Homebrew packages for development (Docker, Git, etc.)
- VS Code with essential extensions
- Development CLI tools (gh, awscli, etc.)

### Productivity Apps
- 1Password, Alfred, and other essential utilities
- Microsoft Office suite
- Communication tools (Slack, Zoom, etc.)

### System Configuration
- Optimized macOS settings
- Custom shell configuration
- Privacy-focused defaults

## How It Works

The `setup.sh` script:
1. Installs Homebrew if not present
2. Installs chezmoi for dotfiles management
3. Applies all dotfiles and configurations
4. Installs all specified Homebrew packages and casks
5. Configures macOS system settings
6. Sets up development environment

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