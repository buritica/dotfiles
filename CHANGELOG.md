# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-04-27

### Added
- Comprehensive setup script for new Mac installations with:
  - Automatic Xcode Command Line Tools installation
  - Homebrew installation and configuration
  - Rosetta 2 installation for Apple Silicon Macs
  - 1Password CLI installation
  - Package management via Brewfile
  - Chezmoi dotfile management
  - macOS system settings configuration
  - CI environment detection and handling
  - Colorized output and status messages
  - Error handling and user feedback
- Improved CI workflow with caching and better error handling
- Enhanced security workflow with:
  - Optimized Trivy configuration for vulnerability scanning
  - Better error handling and local run support
  - Improved artifact management
  - Comprehensive security checks (Trivy, tfsec, Checkov)
- GitHub Actions workflows for CI and security
- Expanded test suite with:
  - Comprehensive shell script testing
  - Improved test coverage
  - Better test organization and structure
  - Automated test execution in CI
  - Test result reporting and analysis

### Changed
- Improved chezmoi initialization for both local and remote execution
- Enhanced Xcode Command Line Tools installation process
- Updated GitHub repository URL handling
- Streamlined setup process with better error handling
- Improved package management with Brewfile integration
- Enhanced macOS system settings configuration
- Enhanced test infrastructure and reporting

### Fixed
- Error handling in shell scripts
- Configuration file management
- Installation process for various tools
- Package management improvements
- Shell script compatibility issues
- CI/CD pipeline reliability
- Security workflow configuration and execution
- Homebrew PATH configuration for both Intel and Apple Silicon Macs
- Test reliability and flakiness issues

### Removed
- Dockerfile and Docker-based setup
- Legacy shell scripts and configurations

[0.1.0]: https://github.com/buritica/dotfiles/releases/tag/v0.1.0 