# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-04-27

### Added
- BATS testing infrastructure and documentation
- Comprehensive setup script for new Mac installations
- macOS settings flag file and ignore it in chezmoi
- Rosetta 2 installation for Apple Silicon Macs
- Modernize testing and CI setup

### Fixed
- Error handling for Address Book settings
- ShellCheck warnings and variable handling
- Dependency review configuration
- YAML linting configuration
- Chezmoi repository URL and Brewfile installation
- Flag file path and brew bundle permissions
- Email value handling
- Chezmoi initialization
- macOS settings script error handling
- Spotlight settings using mdutil
- Xcode Command Line Tools installation
- CodeQL analysis configuration
- Homebrew taps cleanup
- Brewfile moreutils entry
- Gitconfig and test script improvements
- Security scan and dependency review
- Variable expansion in scripts
- Setup script order
- 1Password CLI installation
- BATS installation
- macOS-specific tests in CI
- Grammarly cask name
- Kcov installation and BATS setup
- Security workflow actions
- CodeQL action configuration
- Brewfile path
- macOS settings script path
- GitHub URL for remote repository
- CI workflow directory permissions

### Reverted
- Revert "Update CI workflow and add BATS test helpers" 