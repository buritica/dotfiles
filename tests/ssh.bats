#!/usr/bin/env bats
# The deployed ~/.ssh/config, as ssh itself resolves it (ssh -G; nothing
# connects). UseKeychain is Apple-only, so IgnoreUnknown lets Linux ssh parse it.

setup() {
  load test_helper
}

ssh_g() {
  ssh -G -F "$1" -o IgnoreUnknown=UseKeychain "$2"
}

@test "every host goes through the 1Password agent with the main key" {
  run ssh_g "$TEST_HOME/.ssh/config" example.com
  [ "$status" -eq 0 ]
  grep -qx 'identityagent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"' <<<"$output" \
    || grep -qix 'identityagent .*/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock' <<<"$output"
  grep -qx 'identityfile ~/.ssh/id_ed25519' <<<"$output"
}

@test "on halfmoon, github.com uses the halfmoon deploy key first" {
  local cfg="$BATS_TEST_TMPDIR/halfmoon_config"
  render_as halfmoon private_dot_ssh/config.tmpl > "$cfg"
  run ssh_g "$cfg" github.com
  [ "$status" -eq 0 ]
  [ "$(grep '^identityfile ' <<<"$output" | head -1)" = "identityfile ~/.ssh/id_halfmoon" ]

  run ssh_g "$TEST_HOME/.ssh/config" github.com
  [ "$(grep '^identityfile ' <<<"$output" | head -1)" = "identityfile ~/.ssh/id_ed25519" ]
}

@test "fleet aliases resolve to Tailscale names and reuse connections" {
  run ssh_g "$TEST_HOME/.ssh/config" severo
  [ "$status" -eq 0 ]
  grep -qx 'hostname severo.chestnut-shark.ts.net' <<<"$output"
  grep -qx 'controlmaster auto' <<<"$output"
  grep -qx 'stricthostkeychecking accept-new' <<<"$output"

  run ssh_g "$TEST_HOME/.ssh/config" estanli
  grep -qx 'hostname severo.chestnut-shark.ts.net' <<<"$output"
  grep -qx 'user estanli' <<<"$output"
}

@test "on crowntail, halfmoon uses the deploy key and skips the agent" {
  local cfg="$BATS_TEST_TMPDIR/crowntail_config"
  render_as crowntail private_dot_ssh/config.tmpl > "$cfg"
  run ssh_g "$cfg" halfmoon
  [ "$status" -eq 0 ]
  [ "$(grep '^identityfile ' <<<"$output" | head -1)" = "identityfile ~/.ssh/id_halfmoon_deploy" ]
  grep -qx 'identityagent none' <<<"$output"
  grep -qx 'identitiesonly yes' <<<"$output"
  grep -qx 'hostname halfmoon.chestnut-shark.ts.net' <<<"$output"

  run ssh_g "$TEST_HOME/.ssh/config" halfmoon
  grep -qix 'identityagent .*1password/t/agent.sock' <<<"$output"
}
