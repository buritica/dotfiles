#!/usr/bin/env bats
# What `chezmoi apply` puts in $HOME.

setup() {
  load test_helper
}

@test "apply leaves nothing to change, and verify passes" {
  run cz diff --exclude=scripts
  [ "$status" -eq 0 ]
  [ -z "$output" ]

  run cz verify --exclude=scripts
  [ "$status" -eq 0 ]
}

@test "shell config, git config and the shared zsh base are deployed" {
  for f in .zshrc .zshenv .gitconfig .ripgreprc \
           .my/.aliases .my/.exports .my/.functions .my/.macos \
           .config/zsh-base/omz.zsh .config/zsh-base/functions.zsh \
           .config/ghostty/config .ssh/config .ssh/id_ed25519.pub; do
    [ -s "$TEST_HOME/$f" ] || { echo "missing: ~/$f"; return 1; }
  done
}

@test "repo-only files stay out of \$HOME" {
  run cz managed --include=files,dirs,symlinks
  [ "$status" -eq 0 ]
  for f in README.md CLAUDE.md CONTRIBUTING.md CHANGELOG.md LICENSE .cursorrules \
           setup.sh test.sh .yamllint .gitignore .github tests; do
    if grep -qx -- "$f" <<<"$output"; then
      echo "deployed but should be ignored: $f"
      return 1
    fi
  done
}

@test "the macOS defaults script is executable and ~/.ssh is private" {
  [ -x "$TEST_HOME/.my/.macos" ]
  local mode
  mode="$(stat -c '%a' "$TEST_HOME/.ssh" 2>/dev/null || stat -f '%Lp' "$TEST_HOME/.ssh")"
  [ "$mode" = "700" ]
}

@test "id_halfmoon.pub deploys to halfmoon only" {
  run cz managed --include=files
  run ! grep -qx '.ssh/id_halfmoon.pub' <<<"$output"

  run cz managed --include=files --override-data '{"chezmoi":{"hostname":"halfmoon"}}'
  grep -qx '.ssh/id_halfmoon.pub' <<<"$output"
}

@test "the macOS defaults run script re-runs when ~/.my/.macos changes" {
  # run_onchange_ re-runs when its rendered content changes; the embedded
  # hash of the defaults script is what makes an edit to it trigger a re-run.
  local want
  want="$(sha256sum "$DOTFILES_SRC/dot_my/executable_dot_macos" 2>/dev/null \
    || shasum -a 256 "$DOTFILES_SRC/dot_my/executable_dot_macos")"
  want="${want%% *}"
  run cz execute-template < "$DOTFILES_SRC/run_onchange_apply-macos-defaults.sh.tmpl"
  [ "$status" -eq 0 ]
  grep -q "macos hash: $want" <<<"$output"
}

@test "pinned externals land where omz.zsh looks for them" {
  [ -z "${DOTFILES_TEST_NO_EXTERNALS:-}" ] || skip "externals disabled"
  local plugins="$TEST_HOME/.oh-my-zsh/custom/plugins"
  [ -f "$plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ]
  [ -f "$plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ]
  [ -f "$plugins/zsh-defer/zsh-defer.plugin.zsh" ]
}
