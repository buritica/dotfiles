# Shared helpers for the bats suite. setup_suite.bash has already applied the
# dotfiles into $TEST_HOME.

bats_require_minimum_version 1.5.0  # run --separate-stderr, run !

# chezmoi against the test home and the copied source
cz() {
  HOME="$TEST_HOME" XDG_CONFIG_HOME='' XDG_DATA_HOME='' XDG_CACHE_HOME='' XDG_STATE_HOME='' \
    chezmoi --source "$DOTFILES_SRC" "$@"
}

# Render a source template as if chezmoi ran on <hostname>.
render_as() {
  local host="$1" template="$2"
  cz execute-template --override-data "{\"chezmoi\":{\"hostname\":\"$host\"}}" \
    < "$DOTFILES_SRC/$template"
}

# Run a command inside an interactive zsh started from the test home, with a
# clean environment. Only what the command prints after startup is kept, so
# the "dotfiles sourced" banner and OMZ noise stay out of assertions.
zsh_i() {
  env -i HOME="$TEST_HOME" PATH="$PATH" TERM=xterm-256color USER="${USER:-runner}" \
    GIT_CONFIG_NOSYSTEM=1 \
    zsh -i -c "print -r -- '@@ready'; $1" 2>&1 | awk 'seen; /^@@ready$/ { seen = 1 }'
  return "${PIPESTATUS[0]}"
}

# git with the deployed ~/.gitconfig and nothing else
hgit() {
  HOME="$TEST_HOME" GIT_CONFIG_NOSYSTEM=1 GIT_PAGER=cat GIT_EDITOR=true git "$@"
}

# A fresh repo with one commit on main; prints its path
new_repo() {
  local dir
  dir="$(mktemp -d "$BATS_TEST_TMPDIR/repo.XXXXXX")"
  hgit -C "$dir" init -q
  echo one > "$dir/a.txt"
  hgit -C "$dir" add a.txt
  hgit -C "$dir" commit -q -m "initial"
  echo "$dir"
}
