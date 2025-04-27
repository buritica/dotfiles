# Contributing to dotfiles

Thank you for your interest in contributing to this repository! This document outlines the process for contributing to this project.

## Development Workflow

1. **Fork the Repository**
   - Create a fork of this repository to your GitHub account
   - Clone your fork locally: `git clone git@github.com:your-username/dotfiles.git`

2. **Create a Feature Branch**
   - Create a new branch for your changes:
     ```bash
     git checkout -b feature/your-feature-name
     ```
   - Or for bug fixes:
     ```bash
     git checkout -b fix/your-bug-fix
     ```
   - Or for documentation:
     ```bash
     git checkout -b docs/your-doc-update
     ```

3. **Make Your Changes**
   - Make your changes in your local branch
   - Test your changes thoroughly
   - Commit your changes with clear, descriptive commit messages

4. **Push Your Changes**
   - Push your branch to your fork:
     ```bash
     git push origin your-branch-name
     ```

5. **Create a Pull Request**
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Select your branch from your fork
   - Fill in the PR template with details about your changes
   - Wait for CI checks to pass
   - Address any feedback or requested changes

## Important Notes

- **Direct Commits to Master are Not Allowed**: All changes must go through a pull request process
- **CI Checks are Required**: All CI checks must pass before a PR can be merged
- **Security Scans**: Weekly security scans run automatically, but don't block PR merges
- **Branch Naming**: Use descriptive branch names with prefixes:
  - `feature/` for new features
  - `fix/` for bug fixes
  - `docs/` for documentation updates
  - `chore/` for maintenance tasks

## Branch Protection Rules

The `master` branch is protected with the following rules:

- **CI Checks**: All CI checks must pass before merging
- **Force Push Protection**: Force pushes are not allowed
- **Conversation Resolution**: All conversations must be resolved before merging
- **Fork Syncing**: Fork syncing is allowed
- **Branch Deletion**: Branch deletion is not allowed
- **Branch Locking**: Branch is not locked

## Security Checks

- Security scans run automatically every Sunday at midnight
- The security workflow includes:
  - tfsec for infrastructure security scanning
  - Checkov for infrastructure security scanning
  - Results are uploaded as SARIF format

## Code Style and Guidelines

- Follow existing code style and patterns
- Keep commits focused and atomic
- Write clear commit messages
- Update documentation when making changes

## Getting Help

If you need help or have questions:
- Open an issue in the repository
- Check existing issues for similar questions
- Review the repository documentation

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project. 