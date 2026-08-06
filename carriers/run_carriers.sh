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
# --- soft-spot repair (audited-by-fifth): the count alone is gameable. ---
# 151 rows named "dummy_0".."dummy_150", each (1,1), replicate the pinned
# VERDICT exactly while checking nothing. Pin a hash of the CHECK NAMES
# (order-independent) as well as the count: a gutted or renamed census
# now fails even when it keeps the row count honest.
expected_names_hash="f68bbe3277f5f8157728abd481b1f11d992f462d71d4ad47f53883e55a6cff28"
names_hash="$(printf '%s\n' "$out" | grep -v '^VERDICT' | sed -E 's/ +got=.*//' | sort | sha256sum | cut -d' ' -f1)"
if [ "$names_hash" != "$expected_names_hash" ]; then
  echo "** FAIL: check-name hash '$names_hash' != pinned '$expected_names_hash' (names/count preserved but identities changed, or the census was gutted)"
  status=1
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
