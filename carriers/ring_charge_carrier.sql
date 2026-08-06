-- ring_charge_carrier.sql — CARRIER #10: the defect-charge algebra of
-- emergence_04–_09 and RingRest.lean, re-carried into SQL (SQLite dialect).
--
-- The thread's tenth carrier and its first non-Julia, non-Lean one. The
-- object is unchanged: finite wirings over Z/m under the sum-combiner and
-- the succ twist; states; per-mark defects; the charge; the out-degree
-- formula (★). What changes is the instrument:
--
--   * There is NO SWEEP ORDER in this carrier. The census is a set, not a
--     loop. Two convicted instrument crimes of this repo — _03's smuggled
--     in-place sweep order and _05's soft-scope flag that could never fail
--     — are not merely avoided here; they are INEXPRESSIBLE. A declarative
--     carrier cannot commit them.
--   * New fingerprints arrive to replace them (see FINGERPRINT checks):
--     SQL's % is truncated division and returns negatives (Julia's mod is
--     floored — the whole charge algebra sits on that difference); SUM over
--     an empty group is NULL, not 0 (Julia's init=0 is COALESCE here); and
--     an INNER JOIN silently DROPS the unheard mark rather than erroring.
--   * SQL's NULL is Kleene K3 — the semantics Julia's `missing` was
--     imported from. The K3 court at the end runs rest_of_twist_fixed
--     wearing SQL: the NOT twist has exactly one fixed point, and it is
--     NULL. P16, home again.
--
-- ORACLES (what each check is judged against):
--   rest ⟺ m|L (rings)ledger.....succ_ring_rest_iff   RingRest.lean §1
--   charge ≡ −L, state-free......defect_sum_invariant RingRest.lean §2 (P10)
--   rest ⟺ charge = 0 (rings)....rest_iff_charge_zero RingRest.lean §2
--   (★) Σd ≡ Σ(1−outdeg)s − n....charge_formula       RingRest.lean §3
--   one-shared-mark dial.........charge_dial          RingRest.lean §3 (P13/P19)
--   outdeg-3 / m=2 vanishing.....P20                  emergence_09.jl
--   unheard mark +1 dial.........P21                  emergence_09.jl
--
-- Every check row carries (got, expect). Controls are deliberately wrong
-- laws whose FIRING is the expectation — an instrument that cannot say no
-- proves nothing (the _07 discipline). The final line is the receipt:
--   VERDICT mismatches=0 checks=N
-- The driver (run_carriers.sh) pins N; a silently truncated run FAILS.
--
-- Requires SQLite ≥ 3.39 (IS NOT DISTINCT FROM). Pure SQL: no pow(), no
-- extensions — integer powers come from a recursive CTE, not from floats.
-- The instrument should not carry the dirt it is testing for.

-- ====================================================================
-- WORLDS — wirings as edge tables. `wiring(w, mark, input)` = mark hears
-- input. Transcribed 1:1 from the Julia constructors (fig8, two_rings,
-- chord, w3, w0 verbatim from emergence_05/_07/_09).
-- ====================================================================
CREATE TABLE world  (w TEXT PRIMARY KEY, n INTEGER, kind TEXT);
CREATE TABLE wiring (w TEXT, mark INTEGER, input INTEGER);

-- rings: mark i hears i-1 (mark 1 hears L)
INSERT INTO world VALUES ('ring2',2,'ring'),('ring3',3,'ring'),
  ('ring4',4,'ring'),('ring5',5,'ring'),('ring6',6,'ring');
WITH RECURSIVE mk(i) AS (SELECT 1 UNION ALL SELECT i+1 FROM mk WHERE i < 6)
INSERT INTO wiring
  SELECT wo.w, mk.i, CASE WHEN mk.i = 1 THEN wo.n ELSE mk.i - 1 END
  FROM world wo JOIN mk ON mk.i <= wo.n WHERE wo.kind = 'ring';

-- fig8(2,3): n=4, loops {1,2} and {1,3,4} sharing mark 1  (emergence_05)
INSERT INTO world VALUES ('fig8_23',4,'fig8');
INSERT INTO wiring VALUES ('fig8_23',1,2),('fig8_23',1,4),
  ('fig8_23',2,1),('fig8_23',3,1),('fig8_23',4,3);
-- fig8(3,3): n=5
INSERT INTO world VALUES ('fig8_33',5,'fig8');
INSERT INTO wiring VALUES ('fig8_33',1,3),('fig8_33',1,5),
  ('fig8_33',2,1),('fig8_33',3,2),('fig8_33',4,1),('fig8_33',5,4);
-- two_rings(2,3): disjoint control, n=5  (emergence_05)
INSERT INTO world VALUES ('tworings_23',5,'2rings');
INSERT INTO wiring VALUES ('tworings_23',1,2),('tworings_23',2,1),
  ('tworings_23',3,5),('tworings_23',4,3),('tworings_23',5,4);
-- chord: ring of 4, mark 3 also hears mark 1 → outdeg(1)=2  (emergence_09 P19)
INSERT INTO world VALUES ('chord',4,'chord');
INSERT INTO wiring VALUES ('chord',1,4),('chord',2,1),
  ('chord',3,2),('chord',3,1),('chord',4,3);
-- w3: ring of 4, marks 3 AND 4 also hear mark 1 → outdeg(1)=3  (emergence_09 P20)
INSERT INTO world VALUES ('w3',4,'w3');
INSERT INTO wiring VALUES ('w3',1,4),('w3',2,1),
  ('w3',3,2),('w3',3,1),('w3',4,3),('w3',4,1);
-- w0: 1↔2 ring, mark 3 unheard and hearing nothing  (emergence_09 P21)
INSERT INTO world VALUES ('w0',3,'w0');
INSERT INTO wiring VALUES ('w0',1,2),('w0',2,1);

-- ====================================================================
-- STATE SPACES — every state of every (world, m) with m^n ≤ 5000,
-- m ∈ 2..5. Exhaustion, not sampling; the grid bound is declared, not
-- silent. Integer powers via recursion (no floats in the instrument).
-- ====================================================================
CREATE TABLE ms(m INTEGER);
INSERT INTO ms VALUES (2),(3),(4),(5);

CREATE TABLE powers AS
WITH RECURSIVE pw(m,e,p) AS (
  SELECT m, 0, 1 FROM ms
  UNION ALL SELECT m, e+1, p*m FROM pw WHERE e < 6)
SELECT m, e, p FROM pw;

CREATE TABLE modgrid AS
SELECT wo.w, ms.m, wo.n, wo.kind, pw.p AS total
FROM world wo CROSS JOIN ms
JOIN powers pw ON pw.m = ms.m AND pw.e = wo.n
WHERE pw.p <= 5000;

CREATE TABLE states AS
WITH RECURSIVE st(w,m,sid,total) AS (
  SELECT w, m, 0, total FROM modgrid
  UNION ALL SELECT w, m, sid+1, total FROM st WHERE sid+1 < total)
SELECT w, m, sid FROM st;

CREATE TABLE marks AS
WITH RECURSIVE mk(i) AS (SELECT 1 UNION ALL SELECT i+1 FROM mk WHERE i < 6)
SELECT i FROM mk;

-- cell value of mark i in state sid: base-m digit i  (Julia: digits(sid, base=m, pad=n))
CREATE TABLE cells AS
SELECT s.w, s.m, s.sid, mk.i AS mark, (s.sid / pw.p) % s.m AS v
FROM states s
JOIN world wo ON wo.w = s.w
JOIN marks mk ON mk.i <= wo.n
JOIN powers pw ON pw.m = s.m AND pw.e = mk.i - 1;
CREATE INDEX cells_ix ON cells(w, m, sid, mark);

-- ====================================================================
-- THE MACHINERY — defect, charge, outdeg, (★). Julia's
--   defect(w,s,i,m) = mod(s[i] - sum(s[w.inputs[i]]; init=0) - 1, m)
-- The floored mod is spelled ((x % m) + m) % m — SQL's % is truncated
-- (see FINGERPRINT checks). Julia's init=0 is COALESCE(...,0): SUM over
-- no rows is NULL here, and mark 3 of w0 has no rows.
-- ====================================================================
CREATE TABLE insums AS
SELECT wr.w, ci.m, ci.sid, wr.mark, SUM(ci.v) AS s
FROM wiring wr
JOIN cells ci ON ci.w = wr.w AND ci.mark = wr.input
GROUP BY wr.w, ci.m, ci.sid, wr.mark;

CREATE TABLE defects AS
SELECT c.w, c.m, c.sid, c.mark,
       ((c.v - COALESCE(i.s, 0) - 1) % c.m + c.m) % c.m AS d
FROM cells c
LEFT JOIN insums i ON i.w=c.w AND i.m=c.m AND i.sid=c.sid AND i.mark=c.mark;

-- rest = every defect zero. Defects live in [0,m), so SUM(d)=0 ⟺ all zero;
-- the charge is SUM(d) mod m — zero charge does NOT imply rest in general.
CREATE TABLE charges AS
SELECT w, m, sid, SUM(d) % m AS ch, SUM(d) AS raw
FROM defects GROUP BY w, m, sid;

CREATE TABLE outdegs AS
SELECT wo.w, mk.i AS mark, COALESCE(cnt.c, 0) AS od
FROM world wo JOIN marks mk ON mk.i <= wo.n
LEFT JOIN (SELECT w, input AS mark, COUNT(*) AS c
           FROM wiring GROUP BY w, input) cnt
       ON cnt.w = wo.w AND cnt.mark = mk.i;

-- (★): predicted charge ≡ Σ_j (1 − outdeg(j))·s_j − n   (mod m)
CREATE TABLE predicted AS
SELECT c.w, c.m, c.sid,
       ((SUM((1 - o.od) * c.v) - wo.n) % c.m + c.m) % c.m AS pch
FROM cells c
JOIN outdegs o ON o.w = c.w AND o.mark = c.mark
JOIN world wo ON wo.w = c.w
GROUP BY c.w, c.m, c.sid;

-- ====================================================================
-- THE CHECKS
-- ====================================================================
CREATE TABLE results (name TEXT, got INTEGER, expect INTEGER);

-- (★) on EVERY state of EVERY (world, m) cell — the graph-general
-- charge_formula, verified relationally. Expect 0 violations per cell.
INSERT INTO results
SELECT 'star: ' || ch.w || ' m=' || ch.m, SUM(ch.ch != p.pch), 0
FROM charges ch JOIN predicted p ON p.w=ch.w AND p.m=ch.m AND p.sid=ch.sid
GROUP BY ch.w, ch.m;

-- rings: rest exists ⟺ m | L   (succ_ring_rest_iff, by census)
INSERT INTO results
SELECT 'rest_iff_dvd: ' || g.w || ' m=' || g.m,
       (EXISTS (SELECT 1 FROM charges c
                WHERE c.w=g.w AND c.m=g.m AND c.raw=0)) = (g.n % g.m = 0), 1
FROM modgrid g WHERE g.kind = 'ring';

-- rings: P10 — one charge class, and it is (−L) mod m
INSERT INTO results
SELECT 'P10_conserved: ' || ch.w || ' m=' || ch.m,
       (COUNT(DISTINCT ch.ch) = 1
        AND MIN(ch.ch) = ((-g.n % g.m) + g.m) % g.m), 1
FROM charges ch JOIN modgrid g ON g.w=ch.w AND g.m=ch.m
WHERE g.kind = 'ring' GROUP BY ch.w, ch.m;

-- rings: rest exists ⟺ the (constant) charge is zero  (rest_iff_charge_zero)
INSERT INTO results
SELECT 'rest_iff_charge0: ' || g.w || ' m=' || g.m,
       (EXISTS (SELECT 1 FROM charges c
                WHERE c.w=g.w AND c.m=g.m AND c.raw=0))
     = ((SELECT MIN(ch) FROM charges c
         WHERE c.w=g.w AND c.m=g.m) = 0), 1
FROM modgrid g WHERE g.kind = 'ring';

-- one-shared-mark dial (charge_dial): fig8 = P13, chord = P19.
-- Law: charge ≡ −(s₁ + n) mod m, on every state.
INSERT INTO results
SELECT (CASE WHEN g.kind='chord' THEN 'P19' ELSE 'P13' END)
       || '_dial_law: ' || ch.w || ' m=' || ch.m,
       SUM(ch.ch != (((-(c1.v + g.n)) % ch.m) + ch.m) % ch.m), 0
FROM charges ch
JOIN cells c1 ON c1.w=ch.w AND c1.m=ch.m AND c1.sid=ch.sid AND c1.mark=1
JOIN modgrid g ON g.w=ch.w AND g.m=ch.m
WHERE g.kind IN ('fig8','chord')
GROUP BY ch.w, ch.m;

-- P13: every charge class attained; zero exactly on the rest value s₁ ≡ −n
INSERT INTO results
SELECT 'P13_all_classes: ' || ch.w || ' m=' || ch.m,
       COUNT(DISTINCT ch.ch) = ch.m, 1
FROM charges ch JOIN modgrid g ON g.w=ch.w AND g.m=ch.m
WHERE g.kind = 'fig8' GROUP BY ch.w, ch.m;

INSERT INTO results
SELECT 'P13_zero_fiber: ' || ch.w || ' m=' || ch.m,
       SUM((ch.ch = 0) != (c1.v = ((-g.n % g.m) + g.m) % g.m)), 0
FROM charges ch
JOIN cells c1 ON c1.w=ch.w AND c1.m=ch.m AND c1.sid=ch.sid AND c1.mark=1
JOIN modgrid g ON g.w=ch.w AND g.m=ch.m
WHERE g.kind = 'fig8' GROUP BY ch.w, ch.m;

-- P14: disjoint rings — conserved, total charge ≡ −n = −(L1+L2)
INSERT INTO results
SELECT 'P14_disjoint: ' || ch.w || ' m=' || ch.m,
       (COUNT(DISTINCT ch.ch) = 1
        AND MIN(ch.ch) = ((-g.n % g.m) + g.m) % g.m), 1
FROM charges ch JOIN modgrid g ON g.w=ch.w AND g.m=ch.m
WHERE g.kind = '2rings' GROUP BY ch.w, ch.m;

-- P20: outdeg-3 world — charge ≡ −(2·s₁ + 4); and the m=2 vanishing
INSERT INTO results
SELECT 'P20_law: ' || ch.w || ' m=' || ch.m,
       SUM(ch.ch != (((-(2*c1.v + 4)) % ch.m) + ch.m) % ch.m), 0
FROM charges ch
JOIN cells c1 ON c1.w=ch.w AND c1.m=ch.m AND c1.sid=ch.sid AND c1.mark=1
JOIN modgrid g ON g.w=ch.w AND g.m=ch.m
WHERE g.kind = 'w3' GROUP BY ch.w, ch.m;

INSERT INTO results
SELECT 'P20_m2_dial_vanishes', COUNT(DISTINCT ch) = 1 AND MIN(ch) = 0, 1
FROM charges WHERE w = 'w3' AND m = 2;

-- P21: unheard mark — positive dial, charge ≡ s₃ − 3
INSERT INTO results
SELECT 'P21_law: ' || ch.w || ' m=' || ch.m,
       SUM(ch.ch != (((c3.v - 3) % ch.m) + ch.m) % ch.m), 0
FROM charges ch
JOIN cells c3 ON c3.w=ch.w AND c3.m=ch.m AND c3.sid=ch.sid AND c3.mark=3
JOIN modgrid g ON g.w=ch.w AND g.m=ch.m
WHERE g.kind = 'w0' GROUP BY ch.w, ch.m;

-- ====================================================================
-- CONTROLS — wrong laws that MUST fire (expect = 1 means "fires").
-- An instrument that cannot say no proves nothing (_07's discipline).
-- ====================================================================
-- (★) with the −n term dropped must be violated somewhere (fig8_23, m=3)
INSERT INTO results
SELECT 'CONTROL_star_minus_n_dropped_fires',
       (SELECT COUNT(*) FROM charges ch
        JOIN (SELECT c.w, c.m, c.sid,
                     ((SUM((1 - o.od) * c.v)) % c.m + c.m) % c.m AS pch
              FROM cells c
              JOIN outdegs o ON o.w=c.w AND o.mark=c.mark
              WHERE c.w='fig8_23' AND c.m=3
              GROUP BY c.w, c.m, c.sid) q
          ON q.w=ch.w AND q.m=ch.m AND q.sid=ch.sid
        WHERE ch.ch != q.pch) > 0, 1;

-- the deliberately wrong dial −(s₁+5) must be rejected on the chord (m=3)
INSERT INTO results
SELECT 'CONTROL_wrong_dial_fires',
       (SELECT COUNT(*) FROM charges ch
        JOIN cells c1 ON c1.w=ch.w AND c1.m=ch.m AND c1.sid=ch.sid AND c1.mark=1
        WHERE ch.w='chord' AND ch.m=3
          AND ch.ch != (((-(c1.v + 5)) % 3) + 3) % 3) > 0, 1;

-- ====================================================================
-- FINGERPRINTS — where THIS host edits results, photographed in the act.
-- Julia wraps Int64; Lean budgets axioms; SQL does the following.
-- ====================================================================
-- SQL's % is truncated division: -7 % 3 = -1, not 2. Julia's floored mod
-- would give 2. Uncorrected, every negative defect would be off by m.
INSERT INTO results
SELECT 'FPRINT_percent_is_truncated', (-7 % 3 = -1), 1;

-- the correction used throughout — ((x % m) + m) % m — is a floored mod:
-- in [0,m) and congruent to x, swept over x ∈ −25..25, m ∈ 2..5.
INSERT INTO results
SELECT 'FPRINT_emod_correct_on_sweep',
       SUM(NOT (e >= 0 AND e < m AND (x - e) % m = 0)), 0
FROM (WITH RECURSIVE xs(x) AS (SELECT -25 UNION ALL SELECT x+1 FROM xs WHERE x < 25)
      SELECT xs.x, ms.m, ((xs.x % ms.m) + ms.m) % ms.m AS e FROM xs CROSS JOIN ms);

-- SUM over the unheard mark's empty in-list is NULL, not 0. Julia needed
-- init=0; this carrier needs COALESCE. Omit it and the defect is not
-- wrong — it is NULL, and NULL poisons every aggregate it touches.
INSERT INTO results
SELECT 'FPRINT_null_poison_without_coalesce',
       (SELECT COUNT(*) FROM cells c
        WHERE c.w='w0' AND c.mark=3 AND c.m=2
          AND (c.v - (SELECT SUM(c2.v) FROM wiring wr
                      JOIN cells c2 ON c2.w=wr.w AND c2.m=c.m
                                   AND c2.sid=c.sid AND c2.mark=wr.input
                      WHERE wr.w=c.w AND wr.mark=c.mark) - 1) IS NULL) > 0, 1;

-- the INNER-JOIN formulation does not even go NULL: the unheard mark
-- VANISHES from the aggregate. Silent row loss is this host's soft scope.
INSERT INTO results
SELECT 'FPRINT_inner_join_drops_unheard_mark',
       (SELECT COUNT(DISTINCT mark) FROM insums WHERE w = 'w0') = 2
       AND (SELECT n FROM world WHERE w = 'w0') = 3, 1;

-- ====================================================================
-- THE K3 COURT — P16, home again. SQL's NULL is the Kleene third value
-- Julia's `missing` was imported from. The NOT twist over {0, 1, NULL}
-- has exactly one fixed point under the decidable equality
-- (IS NOT DISTINCT FROM), and it is NULL: rest_of_twist_fixed, wearing
-- SQL. The Liar rests here for the same reason it rests in Base Julia.
-- ====================================================================
INSERT INTO results SELECT 'K3_not_null_is_null',   (NOT NULL) IS NULL, 1;
INSERT INTO results SELECT 'K3_null_eq_null_is_null', (NULL = NULL) IS NULL, 1;
INSERT INTO results SELECT 'K3_isequal_total', NULL IS NOT DISTINCT FROM NULL, 1;
INSERT INTO results
SELECT 'K3_liar_fixed_point_is_exactly_null',
       (SELECT COUNT(*) = 1 AND COUNT(v) = 0
        FROM (SELECT column1 AS v
              FROM (VALUES (0),(1),(NULL))
              WHERE (NOT column1) IS NOT DISTINCT FROM column1)), 1;

-- ====================================================================
-- RECEIPT — read the VERDICT line, not the prose. The driver pins the
-- check count; fewer checks than pinned is a FAIL (a truncated census
-- must not pass — the flag that couldn't fail, remembered).
-- ====================================================================
SELECT printf('%-42s got=%-4d expect=%-4d %s', name, got, expect,
              CASE WHEN got = expect THEN 'ok' ELSE 'FAIL' END)
FROM results;

SELECT printf('VERDICT mismatches=%d checks=%d',
              (SELECT COUNT(*) FROM results WHERE got != expect),
              (SELECT COUNT(*) FROM results));
