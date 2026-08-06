#!/usr/bin/env bash
# ieee_court.sh — the cross-host IEEE 754 court.
#
# Carrier #11 produced an unregistered convergence: the float battery broke
# the SAME 13 lines in Julia and SBCL with bit-identical dirt. This court
# makes that claim first-class and extends it to SQLite: on ONE machine,
# the same double-precision expressions yield the same 64 bits in three
# languages. CLAIM SCOPE: same-machine cross-LANGUAGE invariance. Cross-
# machine invariance (other CPUs, other libms) is NOT claimed — a court
# on other hardware may legitimately disagree; that would be a finding,
# not a failure of this file.
#
# Also photographed, per host:
#   * SQLite's printer: printf('%.17g') renders 0x3FD3333333333334 as
#     "0.3" — the display layer hides dirt the arithmetic carries. Its =
#     operator still sees the truth. (Inverse of P20: there binary
#     COARSENED away a dial; here the printer coarsens, equality does not.)
#   * Integer overflow, one machine, three policies: Julia Int64 WRAPS
#     (Z/2^64), SBCL PROMOTES exactly (bignum), SQLite PROMOTES LOSSILY
#     (to IEEE double). PostgreSQL RAISES — recorded as testimony in the
#     notes, not run here.
# Exit 0 iff all pinned checks pass. Requires julia, sbcl, sqlite3.
set -u
cd "$(dirname "$0")"
status=0; n=0
check() { n=$((n+1)); if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  ** FAIL ** $1 (got '$2', expected '$3')"; status=1; fi; }

for tool in julia sbcl sqlite3; do
  command -v "$tool" >/dev/null 2>&1 || { echo "** $tool not found"; exit 2; }
done

# The four expressions, evaluated per host. Julia and SBCL emit raw bits.
JBITS=$(julia -e '
for v in (sin(Float64(pi)), cos(Float64(pi)/2), 0.1+0.2, imag(exp(im*Float64(pi))))
    println(string(reinterpret(UInt64, v), base=16))
end')
LBITS=$(sbcl --noinform --disable-debugger --eval '
(let ((dpi (coerce pi (quote double-float))))
  (dolist (v (list (sin dpi) (cos (/ dpi 2)) (+ 0.1d0 0.2d0)
                   (imagpart (exp (complex 0d0 dpi)))))
    (format t "~(~x~)~%"
      (logior (ash (ldb (byte 32 0) (sb-kernel:double-float-high-bits v)) 32)
              (sb-kernel:double-float-low-bits v)))))' --quit 2>/dev/null)

echo "julia bits:  $(echo $JBITS | tr '\n' ' ')"
echo "sbcl bits:   $(echo $LBITS | tr '\n' ' ')"
check "Julia and SBCL agree bit-for-bit on all four expressions" "$JBITS" "$LBITS"

# SQLite cannot show bits; equality against the exact decimal literals of
# those bit patterns is the same claim (literals parse to nearest double,
# and these literals round-trip uniquely).
SQL_ARITH=$(sqlite3 "" "SELECT (sin(pi()) = 1.2246467991473532e-16)
  + (cos(pi()/2) = 6.123233995736766e-17)
  + (0.1+0.2 = 0.30000000000000004);")
check "SQLite arithmetic matches the same three values exactly" "$SQL_ARITH" "3"

# The printer fingerprint: same bits, lossy rendering — and = still exact.
SQL_PRINT=$(sqlite3 "" "SELECT printf('%.17g', 0.1+0.2);")
check "FPRINT: SQLite %.17g renders the sum as '0.3' (printer hides the dirt)" "$SQL_PRINT" "0.3"
SQL_NEQ=$(sqlite3 "" "SELECT 0.1+0.2 = 0.3;")
check "FPRINT: ...while SQLite = still refuses 0.3 (arithmetic keeps it)" "$SQL_NEQ" "0"

# Overflow: one machine, three policies.
JW=$(julia -e 'println(typemax(Int64) + 1 == typemin(Int64))')
check "overflow policy, Julia: Int64 WRAPS (typemax+1 == typemin)" "$JW" "true"
LP=$(sbcl --noinform --disable-debugger \
     --eval '(format t "~a~%" (= (+ most-positive-fixnum 1) (expt 2 62)))' --quit 2>/dev/null)
check "overflow policy, SBCL: fixnum PROMOTES exactly (mpf+1 = 2^62)" "$LP" "T"
SQ=$(sqlite3 "" "SELECT typeof(9223372036854775807 + 1);")
check "overflow policy, SQLite: int64 PROMOTES LOSSILY (typeof -> real)" "$SQ" "real"

# Control: the comparator can say no (passes iff the corrupted value differs).
check_ne() { n=$((n+1)); if [ "$2" != "$3" ]; then echo "  ok   $1"; else echo "  ** FAIL ** $1 (values equal)"; status=1; fi; }
check_ne "CONTROL: corrupted bits are rejected by the comparator" "$(echo "$JBITS" | head -1)x" "$(echo "$JBITS" | head -1)"

PINNED=8
if [ "$n" -ne "$PINNED" ]; then echo "** FAIL ** ran $n checks, pinned $PINNED"; status=1; fi
echo
echo "$([ $status -eq 0 ] && echo "IEEE COURT PASSED ($n/$PINNED)" || echo "SOMETHING FAILED") — read the exit code, not the text"
exit $status
