#!/usr/bin/env bash

set -u

APP="./app/app.sh"

PASS=0
FAIL=0

pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

echo "======================================"
echo " Assignment 3 - Application Tests"
echo "======================================"
echo

if "$APP" help >/dev/null 2>&1; then
    pass "help command works"
else
    fail "help command works"
fi

if "$APP" system-info >/dev/null 2>&1; then
    pass "system-info command works"
else
    fail "system-info command works"
fi

"$APP" invalid-command >/dev/null 2>&1
rc=$?

if [[ "$rc" -eq 2 ]]; then
    pass "invalid command returns exit code 2"
else
    fail "invalid command returns exit code 2"
fi

"$APP" check-host >/dev/null 2>&1
rc=$?

if [[ "$rc" -eq 2 ]]; then
    pass "missing host returns exit code 2"
else
    fail "missing host returns exit code 2"
fi

if "$APP" check-host google.com >/dev/null 2>&1; then
    pass "valid host check works"
else
    fail "valid host check works"
fi

"$APP" check-port localhost >/dev/null 2>&1
rc=$?

if [[ "$rc" -eq 2 ]]; then
    pass "missing port returns exit code 2"
else
    fail "missing port returns exit code 2"
fi

"$APP" check-port localhost abc >/dev/null 2>&1
rc=$?

if [[ "$rc" -eq 2 ]]; then
    pass "non-numeric port returns exit code 2"
else
    fail "non-numeric port returns exit code 2"
fi

"$APP" check-port localhost 0 >/dev/null 2>&1
rc=$?

if [[ "$rc" -eq 2 ]]; then
    pass "port 0 returns exit code 2"
else
    fail "port 0 returns exit code 2"
fi

"$APP" check-port localhost 70000 >/dev/null 2>&1
rc=$?

if [[ "$rc" -eq 2 ]]; then
    pass "out-of-range port returns exit code 2"
else
    fail "out-of-range port returns exit code 2"
fi

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

[[ "$FAIL" -eq 0 ]]
