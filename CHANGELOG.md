# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Changed
- Migrated container runtime from Colima to OrbStack (removed `dot_colima/`, qemu)
- Replaced Age encryption with the 1Password SSH agent; `known_hosts` self-populates (removed `~/.chez.txt` requirement and the encrypted known_hosts)
- Replaced hostname `profile` (home/work/media) with `capabilities` (work / make_music / play_games / media_server); all hosts core-only for now
- `~/.tool-versions` now owned by ansible (mise role), not chezmoi
- macOS defaults applied via `run_onchange_apply-macos-defaults.sh` (sudo-resilient) instead of `setup.sh`
- Added Ghostty config to chezmoi; stopped hard-managing `~/.claude/settings.json` (drifts per-machine)

## 0.2.0

### Added
- Lazy loading for direnv (~50-100ms startup savings)
- Lazy loading for asdf (~100-200ms startup savings)
- User feedback for pmset restartfreeze support detection
- GitHub CLI config with `co: pr checkout` alias
- Claude Code settings with enabled plugins
- `.tool-versions` for asdf (python, nodejs, rust)

### Changed
- Migrated from nodenv to asdf for unified version management
- Replaced deprecated macOS commands with modern equivalents:
  - System Preferences → System Settings (Ventura+)
  - systemsetup → pmset for power management
- Removed docker formula and cask (using Colima for containers)

### Fixed
- Deprecated launchctl notification center command
- Conflicting pmset sleep settings
- Duplicate emptytrash alias
- Intel Mac compatibility for asdf path (uses HOMEBREW_PREFIX)
- SIP-safe error handling for sleepimage operations

### Removed
- nodenv initialization (replaced by asdf)
- docker brew formula and cask (using Colima)
- Duplicate power management settings block

## 0.1.1

### Added
- Branch protection rules for master branch

### Changed
- Bumped tfsec-action from 1.0.0 to 1.0.3

### Fixed
- GitHub Actions workflow conditions for local runs using `act`
- Environment variable handling in CI and security workflows
- SARIF file paths in security workflow

## 0.1.0

### Added
- Comprehensive setup script for new Mac installations
- Homebrew and Brewfile package management
- Chezmoi dotfile management with Age encryption
- macOS system settings configuration
- GitHub Actions workflows for CI and security
- Expanded test suite

### Changed
- Improved chezmoi initialization
- Enhanced Xcode Command Line Tools installation
- Streamlined setup process with better error handling

### Fixed
- Homebrew PATH configuration for Intel and Apple Silicon Macs
- Shell script compatibility issues

### Removed
- Dockerfile and Docker-based setup
- Legacy shell scripts and configurations
