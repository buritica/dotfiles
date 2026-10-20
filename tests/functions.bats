#!/usr/bin/env bats
# The shared zsh-base helpers, run in a real interactive shell.

setup() {
  load test_helper
}

@test "gcommit writes a conventional commit subject" {
  local repo
  repo="$(new_repo)"
  echo two >> "$repo/a.txt"
  hgit -C "$repo" add a.txt
  run zsh_i "cd '$repo' && gcommit feat 'add search' >/dev/null"
  [ "$status" -eq 0 ]
  [ "$(hgit -C "$repo" log -1 --format=%s)" = "feat: add search" ]

  echo three >> "$repo/a.txt"
  hgit -C "$repo" add a.txt
  run zsh_i "cd '$repo' && gcfix api 'resolve timeout' >/dev/null"
  [ "$status" -eq 0 ]
  [ "$(hgit -C "$repo" log -1 --format=%s)" = "fix(api): resolve timeout" ]
}

@test "gcommit without a message prints usage and fails" {
  run zsh_i 'gcommit'
  [ "$status" -eq 1 ]
  [[ "$output" == Usage:\ gcommit* ]]
}

@test "git helpers refuse to run outside a repo" {
  for fn in gwt gwta fstash git-cleanup git-prune-local; do
    run zsh_i "cd '$BATS_TEST_TMPDIR' && $fn"
    [ "$status" -eq 1 ] || { echo "$fn exited $status"; return 1; }
    [[ "$output" == *"Not a git repository"* ]]
  done
}

@test "gwta creates a branch worktree and cds into it" {
  local repo
  repo="$(new_repo)"
  run zsh_i "cd '$repo' && gwta feature-x >/dev/null 2>&1 && pwd"
  [ "$status" -eq 0 ]
  [ "$output" = "$(cd "$repo/.." && pwd)/feature-x" ]
  [ "$(hgit -C "$output" branch --show-current)" = "feature-x" ]
}

@test "git-cleanup with nothing merged says so" {
  local repo
  repo="$(new_repo)"
  run zsh_i "cd '$repo' && git-cleanup"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No merged branches"* ]]
}

@test "envnew creates an env file, from .env.template when there is one" {
  local dir="$BATS_TEST_TMPDIR/app"
  mkdir -p "$dir"
  run zsh_i "cd '$dir' && EDITOR=true envnew staging"
  [ "$status" -eq 0 ]
  [ -f "$dir/.env.staging" ] && [ ! -s "$dir/.env.staging" ]

  echo 'KEY=template' > "$dir/.env.template"
  run zsh_i "cd '$dir' && EDITOR=true envnew prod"
  [ "$(< "$dir/.env.prod")" = "KEY=template" ]

  run zsh_i "cd '$dir' && EDITOR=true envnew prod"
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "envswitch swaps .env, backs up the old one and keeps three backups" {
  local dir="$BATS_TEST_TMPDIR/app"
  mkdir -p "$dir"
  echo 'ENV=dev' > "$dir/.env.dev"
  echo 'ENV=prod' > "$dir/.env.prod"
  echo 'ENV=original' > "$dir/.env"
  # pre-existing backups, oldest first
  for i in 1 2 3; do
    echo "old$i" > "$dir/.env.backup.2020010${i}_000000"
    touch -t "20200${i}010000" "$dir/.env.backup.2020010${i}_000000"
  done

  run zsh_i "cd '$dir' && envswitch prod"
  [ "$status" -eq 0 ]
  [ "$(< "$dir/.env")" = "ENV=prod" ]
  run find "$dir" -maxdepth 1 -name '.env.backup.*'
  [ "${#lines[@]}" -eq 3 ]
  [ ! -e "$dir/.env.backup.20200101_000000" ]
  grep -lx 'ENV=original' "$dir"/.env.backup.*

  run zsh_i "cd '$dir' && envswitch nope"
  [ "$status" -eq 1 ]
  [[ "$output" == *".env.nope not found"* ]]
}

@test "port and killport require a port" {
  run zsh_i 'port'
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: port"* ]]
  run zsh_i 'killport'
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: killport"* ]]
}

@test "mkd creates nested dirs and enters them" {
  run zsh_i "mkd '$BATS_TEST_TMPDIR/a/b/c' && pwd"
  [ "$output" = "$BATS_TEST_TMPDIR/a/b/c" ]
}
