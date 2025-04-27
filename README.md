# Dotfiles

[![CI](https://github.com/buritica/dotfiles/actions/workflows/ci.yaml/badge.svg)](https://github.com/buritica/dotfiles/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/buritica/dotfiles/branch/master/graph/badge.svg)](https://codecov.io/gh/buritica/dotfiles)
[![Documentation](https://img.shields.io/badge/docs-GitHub%20Pages-blue.svg)](https://buritica.github.io/dotfiles/)
[![License](https://img.shields.io/github/license/buritica/dotfiles.svg)](LICENSE)

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

## License

MIT