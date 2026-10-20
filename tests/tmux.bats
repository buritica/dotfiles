#!/usr/bin/env bats
# The deployed ~/.tmux.conf, loaded by a real tmux server.

setup() {
  load test_helper
  command -v tmux >/dev/null 2>&1 || skip "tmux not installed"
}

@test "~/.tmux.conf loads without errors" {
  local sock="dotfiles-test-$$"
  # new-session -f exits 0 even on config errors; source-file does not.
  run env HOME="$TEST_HOME" tmux -L "$sock" -f /dev/null \
    new-session -d "sleep 5" \; source-file "$TEST_HOME/.tmux.conf"
  tmux -L "$sock" kill-server 2>/dev/null || true
  [ "$status" -eq 0 ] || { echo "$output"; return 1; }
}
