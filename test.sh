#!/usr/bin/env bash
# Runs every check CI runs: syntax (bash -n, zsh -n), shellcheck, then the bats
# suite in tests/, which applies the dotfiles into a throwaway $HOME and
# exercises the result (see tests/setup_suite.bash for its env knobs).
#
# Needs chezmoi, bats, zsh and git; shellcheck is used when installed.
set -euo pipefail

cd "$(dirname "$0")"

missing=()
for tool in chezmoi bats zsh git; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done
if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing: ${missing[*]} (brew install chezmoi bats-core zsh git)" >&2
    exit 1
fi

echo "==> bash -n"
for f in setup.sh test.sh dot_my/executable_dot_macos tests/*.bash; do
    bash -n "$f"
done

echo "==> zsh -n"
# Everything zsh sources, including the rendered .zshrc
for f in dot_zshenv dot_config/zsh-base/*.zsh dot_my/dot_aliases dot_my/dot_exports dot_my/dot_functions; do
    zsh -n "$f"
done
chezmoi execute-template --source . < dot_zshrc.tmpl | zsh -n

if command -v shellcheck >/dev/null 2>&1; then
    echo "==> shellcheck"
    shellcheck --severity=warning setup.sh test.sh tests/*.bash tests/*.bats
else
    echo "==> shellcheck not installed, skipping"
fi

echo "==> bats"
bats tests/
