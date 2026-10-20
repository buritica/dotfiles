#!/usr/bin/env bats
# An interactive zsh started from the deployed dotfiles.

setup() {
  load test_helper
}

@test "an interactive shell starts without errors" {
  run --separate-stderr env -i HOME="$TEST_HOME" PATH="$PATH" TERM=xterm-256color \
    zsh -i -c 'print -r -- started'
  [ "$status" -eq 0 ]
  [ "${lines[${#lines[@]}-1]}" = "started" ]
  # The only tolerated stderr is OMZ's own "not found" fallback notice
  # shellcheck disable=SC2154  # set by run --separate-stderr
  grep -v 'Oh My Zsh not found' <<<"$stderr" | { ! grep -q .; } \
    || { echo "stderr: $stderr"; return 1; }
}

@test "OMZ loads when installed, else the fallback prompt is used" {
  run zsh_i 'print -r -- "${ZSH_VERSION:+zsh} ${+functions[omz]} ${ZSH_THEME}"'
  [ "$status" -eq 0 ]
  if [ -n "${DOTFILES_TEST_OMZ:-}" ]; then
    [ "$output" = "zsh 1 geoffgarside" ]
  else
    [ "$output" = "zsh 0 geoffgarside" ]
    run zsh_i 'print -r -- $PS1'
    [[ "$output" == *'vcs_info_msg_0_'* ]]
  fi
}

@test "OMZ's git aliases don't clobber the shared worktree functions" {
  run zsh_i 'whence -w gwt gwta gwtr gwts gcommit'
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf '%s: function\n' gwt gwta gwtr gwts gcommit)" ]
}

@test "shared and personal functions are all defined" {
  local fns=(port killport ports envs envswitch envnew gwt fstash git-cleanup
             git-prune-local gcommit bench bench-compare mkd
             clip copyfile copypath tre fixup brew-diff dotfiles-sync sev)
  run zsh_i "whence -w ${fns[*]} | grep -v ': function\$'"
  [ -z "$output" ] || { echo "not functions: $output"; return 1; }
}

@test "the shared base's history settings survive OMZ and .exports" {
  # omz.zsh owns history for both accounts (estanli too); CI runs this with
  # and without OMZ, whose own smaller defaults must not win.
  run zsh_i 'print -r -- $HISTSIZE $SAVEHIST'
  [ "$output" = "120000 100000" ]
}

@test "the prompt carries the host emoji" {
  run zsh_i '[[ $PS1 == "💀 "* ]] && print -r -- prefixed'
  [ "$output" = "prefixed" ]

  run render_as crowntail dot_zshrc.tmpl
  grep -q 'export PS1="🦇 $PS1"' <<<"$output"
  run render_as severo dot_zshrc.tmpl
  grep -q 'export PS1="🤘 $PS1"' <<<"$output"
}

@test "security-gui exists on severo only" {
  run render_as severo dot_zshrc.tmpl
  grep -q '^security-gui()' <<<"$output"
  run render_as crowntail dot_zshrc.tmpl
  run ! grep -q 'security-gui' <<<"$output"
}

@test "every rendered zshrc parses" {
  for host in crowntail severo halfmoon deltatail; do
    render_as "$host" dot_zshrc.tmpl | zsh -n || { echo "zsh -n failed for $host"; return 1; }
  done
}

@test "zshenv falls back to a sane PATH without path.zsh" {
  run env -i HOME="$TEST_HOME" PATH=/usr/bin:/bin zsh -c 'print -l $path'
  [ "$status" -eq 0 ]
  local i_local i_usr
  i_local=$(grep -nx "$TEST_HOME/.local/bin" <<<"$output" | cut -d: -f1)
  i_usr=$(grep -nx /usr/bin <<<"$output" | cut -d: -f1)
  [ -n "$i_local" ] && [ "$i_local" -lt "$i_usr" ]
  grep -qx "$TEST_HOME/.local/share/mise/shims" <<<"$output"
}

@test "zshenv uses the ansible-rendered path.zsh when present" {
  mkdir -p "$TEST_HOME/.config/shell"
  echo 'export PATH="/from/path-zsh:$PATH"' > "$TEST_HOME/.config/shell/path.zsh"
  run env -i HOME="$TEST_HOME" PATH=/usr/bin:/bin zsh -c 'print -r -- $PATH'
  rm -rf "$TEST_HOME/.config/shell"
  [ "$output" = "/from/path-zsh:/usr/bin:/bin" ]
}
