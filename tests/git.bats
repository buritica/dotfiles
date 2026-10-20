#!/usr/bin/env bats
# The deployed ~/.gitconfig, exercised with real repos.

setup() {
  load test_helper
}

@test "gitconfig parses and sets the identity" {
  run hgit config --global --list
  [ "$status" -eq 0 ]
  [ "$(hgit config --global user.email)" = "buritica@gmail.com" ]
  [ -n "$(hgit config --global user.name)" ]
}

@test "new repos start on main" {
  local repo
  repo="$(new_repo)"
  [ "$(hgit -C "$repo" branch --show-current)" = "main" ]
}

@test "git go creates a branch, then switches to it when it exists" {
  local repo
  repo="$(new_repo)"
  hgit -C "$repo" go topic
  [ "$(hgit -C "$repo" branch --show-current)" = "topic" ]
  hgit -C "$repo" go main
  hgit -C "$repo" go topic
  [ "$(hgit -C "$repo" branch --show-current)" = "topic" ]
}

@test "git amend keeps the message, git undo drops the commit but keeps the change" {
  local repo
  repo="$(new_repo)"
  echo two > "$repo/b.txt"
  hgit -C "$repo" add b.txt
  hgit -C "$repo" commit -q -m "add b"
  echo more >> "$repo/b.txt"
  hgit -C "$repo" add b.txt
  hgit -C "$repo" amend -q
  [ "$(hgit -C "$repo" log -1 --format=%s)" = "add b" ]
  [ "$(hgit -C "$repo" rev-list --count HEAD)" -eq 2 ]

  hgit -C "$repo" undo
  [ "$(hgit -C "$repo" rev-list --count HEAD)" -eq 1 ]
  [ "$(hgit -C "$repo" diff --cached --name-only)" = "b.txt" ]
}

@test "git wip / unwip round-trips uncommitted work" {
  local repo
  repo="$(new_repo)"
  echo wip > "$repo/w.txt"
  hgit -C "$repo" wip >/dev/null
  [ "$(hgit -C "$repo" log -1 --format=%s)" = "WIP" ]
  hgit -C "$repo" unwip
  [ "$(hgit -C "$repo" log -1 --format=%s)" = "initial" ]
  [ -f "$repo/w.txt" ]
}

@test "merges are fast-forward only" {
  local repo
  repo="$(new_repo)"
  hgit -C "$repo" switch -q -c side
  echo side > "$repo/s.txt"; hgit -C "$repo" add s.txt; hgit -C "$repo" commit -q -m side
  hgit -C "$repo" switch -q main
  echo main > "$repo/m.txt"; hgit -C "$repo" add m.txt; hgit -C "$repo" commit -q -m main
  run hgit -C "$repo" merge side
  [ "$status" -ne 0 ]
  [[ "$output" == *"fast-forward"* ]]
}

@test "git pr fetches a pull request head into pr-<n>" {
  local origin repo
  origin="$(new_repo)"
  hgit -C "$origin" update-ref refs/pull/7/head HEAD
  repo="$BATS_TEST_TMPDIR/clone"
  hgit clone -q "$origin" "$repo"
  hgit -C "$repo" pr 7 2>/dev/null
  [ "$(hgit -C "$repo" branch --show-current)" = "pr-7" ]
}
