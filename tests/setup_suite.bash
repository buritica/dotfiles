# Applies the dotfiles once into a throwaway $HOME that every test file shares.
#
# Env knobs:
#   DOTFILES_TEST_OMZ=<dir>       an Oh My Zsh checkout to put in ~/.oh-my-zsh
#                                 first, like an existing host's; the exact
#                                 .oh-my-zsh external replaces it on apply
#   DOTFILES_TEST_NO_EXTERNALS=1  drop .chezmoiexternal.toml (no Oh My Zsh or
#                                 plugins unless DOTFILES_TEST_OMZ is set), for
#                                 the fallback prompt or when GitHub archive
#                                 downloads are blocked
#
# Scripts are always excluded: the run_onchange script runs ~/.my/.macos, which
# writes real defaults and killalls Finder/Dock.

setup_suite() {
  local repo
  repo="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

  export DOTFILES_SRC="$BATS_SUITE_TMPDIR/src"
  export TEST_HOME="$BATS_SUITE_TMPDIR/home"
  mkdir -p "$TEST_HOME"

  cp -R "$repo" "$DOTFILES_SRC"
  rm -rf "$DOTFILES_SRC/.git"
  if [ -n "${DOTFILES_TEST_NO_EXTERNALS:-}" ]; then
    rm -f "$DOTFILES_SRC/.chezmoiexternal.toml"
  fi

  if [ -n "${DOTFILES_TEST_OMZ:-}" ]; then
    cp -R "$DOTFILES_TEST_OMZ" "$TEST_HOME/.oh-my-zsh"
  fi

  HOME="$TEST_HOME" XDG_CONFIG_HOME='' XDG_DATA_HOME='' XDG_CACHE_HOME='' XDG_STATE_HOME='' \
    chezmoi init --source "$DOTFILES_SRC" --apply --exclude=scripts --no-tty
}
