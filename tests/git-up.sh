#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GIT_UP="$SCRIPT_DIR/bin/git-up"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/git-up-tests.XXXXXX")"
TEST_COUNT=0

cleanup() {
	case "$TEST_ROOT" in
		"${TMPDIR:-/tmp}"/git-up-tests.*) rm -rf "$TEST_ROOT" ;;
	esac
}
trap cleanup EXIT

export HOME="$TEST_ROOT/home"
export GIT_CONFIG_NOSYSTEM=1
export NO_COLOR=1
mkdir -p "$HOME"

fail() {
	echo "not ok $TEST_COUNT - $1" >&2
	exit 1
}

assert_eq() {
	local expected="$1"
	local actual="$2"
	local message="$3"

	if [ "$expected" != "$actual" ]; then
		fail "$message (expected '$expected', got '$actual')"
	fi
}

assert_contains() {
	local haystack="$1"
	local needle="$2"
	local message="$3"

	case "$haystack" in
		*"$needle"*) ;;
		*) fail "$message (missing '$needle')" ;;
	esac
}

assert_not_contains() {
	local haystack="$1"
	local needle="$2"
	local message="$3"

	case "$haystack" in
		*"$needle"*) fail "$message (found '$needle')" ;;
		*) ;;
	esac
}

configure_repo() {
	git -C "$1" config user.name "git-up tests"
	git -C "$1" config user.email "git-up@example.invalid"
}

create_remote() {
	local remote_path="$1"
	local default_branch="$2"
	local seed_path="$3"

	git init --quiet --bare "$remote_path"
	git --git-dir="$remote_path" symbolic-ref HEAD "refs/heads/$default_branch"
	git init --quiet "$seed_path"
	configure_repo "$seed_path"
	git -C "$seed_path" checkout --quiet -b "$default_branch"
	printf 'initial\n' >"$seed_path/shared.txt"
	git -C "$seed_path" add shared.txt
	git -C "$seed_path" commit --quiet -m initial
	git -C "$seed_path" remote add origin "$remote_path"
	git -C "$seed_path" push --quiet origin "$default_branch"
}

advance_remote() {
	local remote_path="$1"
	local branch="$2"
	local work_path="$3"
	local content="$4"

	git clone --quiet --branch "$branch" "$remote_path" "$work_path"
	configure_repo "$work_path"
	printf '%s\n' "$content" >>"$work_path/remote.txt"
	git -C "$work_path" add remote.txt
	git -C "$work_path" commit --quiet -m "remote update"
	git -C "$work_path" push --quiet origin "$branch"
}

run_git_up() {
	local repo_path="$1"
	local output_path="$2"

	(
		cd "$repo_path"
		"$GIT_UP"
	) >"$output_path" 2>&1
}

begin_test() {
	TEST_COUNT=$((TEST_COUNT + 1))
	TEST_DIR="$TEST_ROOT/test-$TEST_COUNT"
	mkdir -p "$TEST_DIR"
}

pass() {
	echo "ok $TEST_COUNT - $1"
}

test_origin_default_branch() {
	begin_test
	create_remote "$TEST_DIR/origin.git" main "$TEST_DIR/seed"
	git clone --quiet "$TEST_DIR/origin.git" "$TEST_DIR/repo"
	configure_repo "$TEST_DIR/repo"
	git -C "$TEST_DIR/repo" checkout --quiet -b feature
	advance_remote "$TEST_DIR/origin.git" main "$TEST_DIR/advance" "origin main"

	run_git_up "$TEST_DIR/repo" "$TEST_DIR/output"
	assert_eq feature "$(git -C "$TEST_DIR/repo" branch --show-current)" "original branch was not restored"
	assert_eq "$(git --git-dir="$TEST_DIR/origin.git" rev-parse main)" "$(git -C "$TEST_DIR/repo" rev-parse main)" "local main was not updated"
	pass "uses origin's advertised default branch"
}

test_selected_upstream_default_branch() {
	begin_test
	create_remote "$TEST_DIR/upstream.git" main "$TEST_DIR/seed"
	git init --quiet --bare "$TEST_DIR/origin.git"
	git --git-dir="$TEST_DIR/origin.git" symbolic-ref HEAD refs/heads/master
	git -C "$TEST_DIR/seed" remote add fork "$TEST_DIR/origin.git"
	git -C "$TEST_DIR/seed" push --quiet fork main:main main:master
	git -C "$TEST_DIR/seed" push --quiet origin main:master
	git clone --quiet "$TEST_DIR/origin.git" "$TEST_DIR/repo"
	configure_repo "$TEST_DIR/repo"
	git -C "$TEST_DIR/repo" branch --quiet main origin/main
	git -C "$TEST_DIR/repo" checkout --quiet -b feature
	git -C "$TEST_DIR/repo" remote add upstream "$TEST_DIR/upstream.git"
	git -C "$TEST_DIR/repo" fetch --quiet upstream
	git -C "$TEST_DIR/repo" remote set-head upstream master
	advance_remote "$TEST_DIR/upstream.git" main "$TEST_DIR/advance" "upstream main"

	run_git_up "$TEST_DIR/repo" "$TEST_DIR/output"
	local output
	output="$(<"$TEST_DIR/output")"
	assert_contains "$output" "rebase upstream/main main" "selected remote's default branch was not used"
	assert_eq feature "$(git -C "$TEST_DIR/repo" branch --show-current)" "original branch was not restored"
	assert_eq "$(git --git-dir="$TEST_DIR/upstream.git" rev-parse main)" "$(git -C "$TEST_DIR/repo" rev-parse main)" "local main was not updated from upstream"
	assert_eq "$(git --git-dir="$TEST_DIR/upstream.git" rev-parse main)" "$(git --git-dir="$TEST_DIR/origin.git" rev-parse main)" "updated main was not pushed to origin"
	pass "prefers upstream and ignores a stale cached HEAD"
}

test_push_failure_restores_branch() {
	begin_test
	create_remote "$TEST_DIR/upstream.git" main "$TEST_DIR/seed"
	git init --quiet --bare "$TEST_DIR/origin.git"
	git --git-dir="$TEST_DIR/origin.git" symbolic-ref HEAD refs/heads/main
	git -C "$TEST_DIR/seed" remote add fork "$TEST_DIR/origin.git"
	git -C "$TEST_DIR/seed" push --quiet fork main
	git clone --quiet "$TEST_DIR/origin.git" "$TEST_DIR/repo"
	configure_repo "$TEST_DIR/repo"
	git -C "$TEST_DIR/repo" checkout --quiet -b feature
	git -C "$TEST_DIR/repo" remote add upstream "$TEST_DIR/upstream.git"
	advance_remote "$TEST_DIR/upstream.git" main "$TEST_DIR/advance" "rejected update"
	printf '#!/bin/sh\nexit 1\n' >"$TEST_DIR/origin.git/hooks/pre-receive"
	chmod +x "$TEST_DIR/origin.git/hooks/pre-receive"

	local status=0
	if run_git_up "$TEST_DIR/repo" "$TEST_DIR/output"; then
		fail "rejected push unexpectedly succeeded"
	else
		status=$?
	fi
	if [ "$status" -eq 0 ]; then
		fail "rejected push returned zero"
	fi
	assert_eq feature "$(git -C "$TEST_DIR/repo" branch --show-current)" "push failure did not restore original branch"
	assert_eq "$(git --git-dir="$TEST_DIR/upstream.git" rev-parse main)" "$(git -C "$TEST_DIR/repo" rev-parse main)" "successful rebase was not retained"
	pass "restores the original branch after a rejected push"
}

test_rebase_conflict_stays_in_rebase() {
	begin_test
	create_remote "$TEST_DIR/origin.git" main "$TEST_DIR/seed"
	git clone --quiet "$TEST_DIR/origin.git" "$TEST_DIR/repo"
	configure_repo "$TEST_DIR/repo"
	printf 'local\n' >"$TEST_DIR/repo/shared.txt"
	git -C "$TEST_DIR/repo" commit --quiet -am "local change"
	git -C "$TEST_DIR/repo" checkout --quiet -b feature
	git clone --quiet "$TEST_DIR/origin.git" "$TEST_DIR/advance"
	configure_repo "$TEST_DIR/advance"
	printf 'remote\n' >"$TEST_DIR/advance/shared.txt"
	git -C "$TEST_DIR/advance" commit --quiet -am "conflicting remote change"
	git -C "$TEST_DIR/advance" push --quiet origin main

	if run_git_up "$TEST_DIR/repo" "$TEST_DIR/output"; then
		fail "conflicting rebase unexpectedly succeeded"
	fi
	if [ ! -d "$TEST_DIR/repo/.git/rebase-merge" ] && [ ! -d "$TEST_DIR/repo/.git/rebase-apply" ]; then
		fail "conflicting rebase did not leave rebase state"
	fi
	assert_not_contains "$(<"$TEST_DIR/output")" "switching to feature" "conflict attempted to restore original branch"
	pass "leaves a conflicted rebase for the user to resolve"
}

test_detached_head_fails_before_fetch() {
	begin_test
	create_remote "$TEST_DIR/origin.git" main "$TEST_DIR/seed"
	git clone --quiet "$TEST_DIR/origin.git" "$TEST_DIR/repo"
	git -C "$TEST_DIR/repo" checkout --quiet --detach HEAD
	git -C "$TEST_DIR/repo" remote set-url origin "$TEST_DIR/missing.git"

	if run_git_up "$TEST_DIR/repo" "$TEST_DIR/output"; then
		fail "detached HEAD unexpectedly succeeded"
	fi
	local output
	output="$(<"$TEST_DIR/output")"
	assert_contains "$output" "git-up requires a checked-out branch; HEAD is detached" "detached HEAD error was not actionable"
	assert_not_contains "$output" "git fetch" "detached HEAD reached fetch"
	pass "rejects detached HEAD before fetching"
}

test_noninteractive_color_setup() {
	begin_test
	local status=0
	if (cd "$TEST_DIR" && env -u TERM -u NO_COLOR "$GIT_UP") >"$TEST_DIR/no-term" 2>&1; then
		fail "non-repository invocation unexpectedly succeeded"
	else
		status=$?
	fi
	assert_eq 1 "$status" "TERM-less invocation changed the normal validation status"
	local output
	output="$(<"$TEST_DIR/no-term")"
	assert_not_contains "$output" "tput" "TERM-less invocation emitted a tput diagnostic"
	assert_not_contains "$output" $'\033' "redirected output contained ANSI escapes"

	mkdir -p "$TEST_DIR/path"
	ln -s "$(command -v git)" "$TEST_DIR/path/git"
	ln -s "$(command -v basename)" "$TEST_DIR/path/basename"

	git init --quiet "$TEST_DIR/repo"
	configure_repo "$TEST_DIR/repo"
	printf 'colors\n' >"$TEST_DIR/repo/file.txt"
	git -C "$TEST_DIR/repo" add file.txt
	git -C "$TEST_DIR/repo" commit --quiet -m initial

	(cd "$TEST_DIR/repo" && /usr/bin/script -q "$TEST_DIR/color" env -u NO_COLOR TERM=xterm-256color "$GIT_UP") >/dev/null 2>&1 || true
	assert_contains "$(<"$TEST_DIR/color")" $'\033' "capable interactive output did not retain colors"
	(cd "$TEST_DIR/repo" && /usr/bin/script -q "$TEST_DIR/no-color" env NO_COLOR=1 TERM=xterm-256color "$GIT_UP") >/dev/null 2>&1 || true
	assert_not_contains "$(<"$TEST_DIR/no-color")" $'\033' "NO_COLOR output contained ANSI escapes"
	(cd "$TEST_DIR/repo" && /usr/bin/script -q "$TEST_DIR/no-tput" env -u NO_COLOR TERM=xterm-256color PATH="$TEST_DIR/path" /bin/bash "$GIT_UP") >/dev/null 2>&1 || true
	assert_not_contains "$(<"$TEST_DIR/no-tput")" "tput" "missing tput prevented normal validation"
	assert_not_contains "$(<"$TEST_DIR/no-tput")" $'\033' "missing tput produced ANSI escapes"
	pass "handles interactive, redirected, TERM-less, NO_COLOR, and tput-less output"
}

test_nonsymbolic_remote_head_error() {
	begin_test
	create_remote "$TEST_DIR/origin.git" main "$TEST_DIR/seed"
	git clone --quiet "$TEST_DIR/origin.git" "$TEST_DIR/repo"
	local head
	head="$(git --git-dir="$TEST_DIR/origin.git" rev-parse main)"
	git --git-dir="$TEST_DIR/origin.git" update-ref --no-deref HEAD "$head"

	if run_git_up "$TEST_DIR/repo" "$TEST_DIR/output"; then
		fail "non-symbolic remote HEAD unexpectedly succeeded"
	fi
	assert_contains "$(<"$TEST_DIR/output")" "default branch for remote 'origin' is not found" "default-branch error did not name selected remote"
	pass "reports a selected remote with no symbolic HEAD"
}

test_missing_default_branch_refs() {
	begin_test
	create_remote "$TEST_DIR/origin-local.git" main "$TEST_DIR/seed-local"
	git clone --quiet "$TEST_DIR/origin-local.git" "$TEST_DIR/repo-local"
	git -C "$TEST_DIR/repo-local" checkout --quiet -b feature
	git -C "$TEST_DIR/repo-local" branch -D main >/dev/null

	if run_git_up "$TEST_DIR/repo-local" "$TEST_DIR/local-output"; then
		fail "missing local default branch unexpectedly succeeded"
	fi
	assert_contains "$(<"$TEST_DIR/local-output")" "local branch 'main' is not found" "missing local branch was not reported clearly"

	create_remote "$TEST_DIR/origin-remote.git" main "$TEST_DIR/seed-remote"
	git -C "$TEST_DIR/seed-remote" branch other
	git -C "$TEST_DIR/seed-remote" push --quiet origin other
	git clone --quiet "$TEST_DIR/origin-remote.git" "$TEST_DIR/repo-remote"
	git -C "$TEST_DIR/repo-remote" config remote.origin.fetch "+refs/heads/other:refs/remotes/origin/other"
	git -C "$TEST_DIR/repo-remote" update-ref -d refs/remotes/origin/main

	if run_git_up "$TEST_DIR/repo-remote" "$TEST_DIR/remote-output"; then
		fail "missing fetched remote-tracking branch unexpectedly succeeded"
	fi
	assert_contains "$(<"$TEST_DIR/remote-output")" "origin/main is not found after fetch" "missing remote-tracking branch was not reported clearly"
	pass "validates local and fetched default-branch refs"
}

test_restore_failure_takes_precedence() {
	begin_test
	create_remote "$TEST_DIR/upstream.git" main "$TEST_DIR/seed"
	git init --quiet --bare "$TEST_DIR/origin.git"
	git --git-dir="$TEST_DIR/origin.git" symbolic-ref HEAD refs/heads/main
	git -C "$TEST_DIR/seed" remote add fork "$TEST_DIR/origin.git"
	git -C "$TEST_DIR/seed" push --quiet fork main
	git clone --quiet "$TEST_DIR/origin.git" "$TEST_DIR/repo"
	configure_repo "$TEST_DIR/repo"
	git -C "$TEST_DIR/repo" checkout --quiet -b feature
	git -C "$TEST_DIR/repo" remote add upstream "$TEST_DIR/upstream.git"
	advance_remote "$TEST_DIR/upstream.git" main "$TEST_DIR/advance" "double failure"

	mkdir -p "$TEST_DIR/path"
	local real_git
	real_git="$(command -v git)"
	printf '%s\n' \
		'#!/usr/bin/env bash' \
		"if [ \"\$1\" = push ]; then exit 41; fi" \
		"if [ \"\$1\" = checkout ] && [ \"\${2:-}\" = feature ]; then exit 42; fi" \
		"exec \"\$REAL_GIT\" \"\$@\"" >"$TEST_DIR/path/git"
	chmod +x "$TEST_DIR/path/git"

	local status=0
	if (
		cd "$TEST_DIR/repo"
		REAL_GIT="$real_git" PATH="$TEST_DIR/path:$PATH" "$GIT_UP"
	) >"$TEST_DIR/output" 2>&1; then
		fail "push and restore failures unexpectedly succeeded"
	else
		status=$?
	fi
	assert_eq 42 "$status" "restore failure did not determine the final status"
	local output
	output="$(<"$TEST_DIR/output")"
	assert_contains "$output" "Failed to restore feature [rc=42]" "restore failure was not reported"
	assert_contains "$output" "Push also failed [rc=41]" "earlier push failure was hidden"
	pass "reports both failures and prioritizes restoration status"
}

test_origin_default_branch
test_selected_upstream_default_branch
test_push_failure_restores_branch
test_rebase_conflict_stays_in_rebase
test_detached_head_fails_before_fetch
test_noninteractive_color_setup
test_nonsymbolic_remote_head_error
test_missing_default_branch_refs
test_restore_failure_takes_precedence

echo "1..$TEST_COUNT"
