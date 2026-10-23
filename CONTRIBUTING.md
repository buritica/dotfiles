# Contributing to dotfiles

## Workflow

1. Branch off `master` with a prefix: `feature/`, `fix/`, `docs/` or `chore/`.
2. Make the change and run `./test.sh` (syntax checks, shellcheck, then the bats suite in `tests/`).
3. Open a pull request with a conventional-commit title (`type: description`, e.g. `fix: zsh path issue`).
4. CI must pass and every conversation must be resolved before it merges.

Managed hosts get `master` through the machines repo's `chezmoi` role (see the "Dotfiles" section of its `CLAUDE.md`). Changes under `dot_config/zsh-base/` also reach the `estanli` account on severo on its next dotfiles deploy, so keep that directory portable.

## Branch protection

`master` requires the `ci` check to pass (on an up-to-date branch) and all conversations resolved. Force pushes, branch deletion and direct commits are not allowed. The rules live in `.github/branch-protection.json`.

## Checks

- **ci** (`.github/workflows/ci.yml`) runs `test.sh` on Ubuntu and macOS with Oh My Zsh, plus the bats suite without it on Ubuntu.
- **security** (`.github/workflows/security.yml`) runs ShellCheck and Trivy's config scanner on pull requests and every Sunday at midnight, and uploads the Trivy results as SARIF. It isn't a required check.

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project.
