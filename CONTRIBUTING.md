# Contributing to Dotfiles

Thank you for your interest in contributing to this dotfiles repository! This document provides guidelines and instructions for contributing.

## Development Setup

1. Install required tools:
   ```bash
   # Install shellcheck
   brew install shellcheck

   # Install shfmt
   brew install shfmt

   # Install BATS
   brew install bats-core

   # Install chezmoi
   brew install chezmoi
   ```

2. Clone the repository:
   ```bash
   git clone https://github.com/buritica/dotfiles.git
   cd dotfiles
   ```

## Testing

We use BATS (Bash Automated Testing System) for testing. To run tests:

```bash
bats test
```

## Code Style

- Shell scripts should follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use `shfmt` to format shell scripts
- All shell scripts must pass `shellcheck` without warnings

## Pull Request Process

1. Create a feature branch from `master`
2. Make your changes
3. Run tests locally
4. Update documentation if needed
5. Submit a pull request

## Commit Messages

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` for new features
- `fix:` for bug fixes
- `chore:` for maintenance tasks
- `docs:` for documentation updates
- `test:` for test updates
- `refactor:` for code refactoring

## Release Process

Releases are automated through GitHub Actions when changes are merged to master:

1. Tests are run
2. Security checks are performed
3. Changelog is generated
4. Release is created with version tag

## Questions?

If you have questions, please open an issue in the repository. 