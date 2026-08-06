#!/usr/bin/env bash
# run_carriers.sh — the court for the non-Julia carriers. Exit 0 iff both
# carriers pass AND each ran its pinned number of checks. The pinned counts
# are the point: a truncated census must not pass (_05's flag that couldn't
# fail, remembered at the driver level).
set -u
cd "$(dirname "$0")"
status=0

echo "== carrier #10: ring/charge algebra in SQL (sqlite3) =="
if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "** sqlite3 not found (need >= 3.39 for IS NOT DISTINCT FROM)"; exit 2
fi
if ! out="$(sqlite3 -bail -batch ':memory:' < ring_charge_carrier.sql)"; then
  printf '%s\n' "$out"; echo "** FAIL: sqlite3 errored"; exit 1
fi
printf '%s\n' "$out"
expected="VERDICT mismatches=0 checks=151"
verdict="$(printf '%s\n' "$out" | grep '^VERDICT ' || true)"
if [ "$verdict" != "$expected" ]; then
  echo "** FAIL: verdict '$verdict' != pinned '$expected'"; status=1
fi

echo
echo "== carrier #11: mu4 battery in Common Lisp (sbcl) =="
if ! command -v sbcl >/dev/null 2>&1; then
  echo "** sbcl not found"; exit 2
fi
sbcl --script mu4_battery.lisp || status=1

echo
if [ "$status" -eq 0 ]; then
  echo "BOTH CARRIERS PASSED — read the exit code, not the text"
else
  echo "SOMETHING FAILED"
fi
exit "$status"
