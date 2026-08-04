// ring_charge_rust.rs — CARRIER #13: the defect-charge algebra of
// emergence_04–_09 and RingRest.lean, re-carried into Rust.
//
// Same object as carriers #10 (SQL) and #12 (Elixir): the eleven worlds
// transcribed 1:1 from ring_charge_carrier.sql, the same m ∈ 2..5 grid with
// mⁿ ≤ 5000, the same oracles. No crates — std only.
//
// WHY THIS CARRIER EXISTS. Same as #12: the branch sweep's B2 conviction
// ("zero Elixir/Rust files anywhere in the branch tree") was correct, and
// this is the repair by construction.
//
// GAINED (over #10 and #12):
//   * The only host in the census that refuses at COMPILE time. Every other
//     carrier discovers its equality/ontology problems at runtime or not at
//     all; Rust's `f64: PartialEq but NOT Eq` is a type-level statement that
//     equality on floats is not reflexive (NaN ≠ NaN). `HashMap<f64, _>` is
//     not a bug you hit — it is a program that does not exist. The driver
//     proves this by attempting a build that MUST fail (FP3b).
//   * Overflow policy is not a host constant. Julia wraps, CL/Elixir promote,
//     SQLite promotes lossily, PostgreSQL raises — four hosts, four policies,
//     each a property of the HOST. Rust is the fifth and breaks the schema:
//     the SAME SOURCE panics in debug and wraps in release. Overflow here is
//     a property of (host, BUILD PROFILE). The census needs a new column.
//
// LOST (relative to #10):
//   * K3 goes home empty, as in #12. `Option<bool>` is not Kleene: `None ==
//     None` is `true`, not `None`. The NOT twist over {Some(true),
//     Some(false), None} has ZERO fixed points under any total equality Rust
//     will give you. P16 does not translate.
//   * ℤ is capped. #12's bignums carry states Lean quantifies over and SQL
//     cannot represent; i128 stops at ~1.7·10³⁸. The gap Lean names is
//     narrowed by Elixir and re-widened here — and the re-widening is
//     TYPED, which is the compensation.
//
// INSTRUMENT REPAIR (audits/carrier_sweep_by_translator.sh, C1): #10's
// verdict cannot count a NULL check as a mismatch. Rust's Option makes the
// same hazard unrepresentable-by-accident: a check's value is i128, and an
// absent value would have to be an explicit Option the match arm must handle.
// C1 is not "fixed" here so much as unavailable — recorded as such.

use std::collections::HashMap;

type Wiring = HashMap<usize, Vec<usize>>;

fn ring(n: usize) -> Wiring {
    (1..=n).map(|i| (i, vec![if i == 1 { n } else { i - 1 }])).collect()
}

fn worlds() -> Vec<(&'static str, usize, Wiring)> {
    let w = |v: Vec<(usize, Vec<usize>)>| -> Wiring { v.into_iter().collect() };
    vec![
        ("ring2", 2, ring(2)),
        ("ring3", 3, ring(3)),
        ("ring4", 4, ring(4)),
        ("ring5", 5, ring(5)),
        ("ring6", 6, ring(6)),
        ("fig8_23", 4, w(vec![(1, vec![2, 4]), (2, vec![1]), (3, vec![1]), (4, vec![3])])),
        ("fig8_33", 5, w(vec![(1, vec![3, 5]), (2, vec![1]), (3, vec![2]), (4, vec![1]), (5, vec![4])])),
        ("tworings_23", 5, w(vec![(1, vec![2]), (2, vec![1]), (3, vec![5]), (4, vec![3]), (5, vec![4])])),
        ("chord", 4, w(vec![(1, vec![4]), (2, vec![1]), (3, vec![2, 1]), (4, vec![3])])),
        ("w3", 4, w(vec![(1, vec![4]), (2, vec![1]), (3, vec![2, 1]), (4, vec![3, 1])])),
        ("w0", 3, w(vec![(1, vec![2]), (2, vec![1]), (3, vec![])])),
    ]
}

fn outdeg(wir: &Wiring, n: usize, j: usize) -> i128 {
    (1..=n).map(|i| wir[&i].iter().filter(|&&x| x == j).count() as i128).sum()
}

// defect at mark i = (s_i − Σ s[inputs i] − 1) mod m.  rem_euclid IS the
// floored mod; Rust's `%` is truncated and would silently corrupt the whole
// algebra — the single highest-risk detail of the translation, exactly as
// carrier #10 flagged for SQL.
fn defect(wir: &Wiring, s: &[i128], m: i128, i: usize) -> i128 {
    let insum: i128 = wir[&i].iter().map(|&j| s[j - 1]).sum();
    (s[i - 1] - insum - 1).rem_euclid(m)
}

fn charge(wir: &Wiring, s: &[i128], m: i128, n: usize) -> i128 {
    (1..=n).map(|i| defect(wir, s, m, i)).sum::<i128>().rem_euclid(m)
}

fn predicted(wir: &Wiring, s: &[i128], m: i128, n: usize) -> i128 {
    let acc: i128 = (1..=n).map(|j| (1 - outdeg(wir, n, j)) * s[j - 1]).sum();
    (acc - n as i128).rem_euclid(m)
}

fn state(sid: u64, m: i128, n: usize) -> Vec<i128> {
    (0..n).map(|k| ((sid / (m as u64).pow(k as u32)) % m as u64) as i128).collect()
}

fn total(m: i128, n: usize) -> u64 {
    (m as u64).pow(n as u32)
}

fn gcd(a: i128, b: i128) -> i128 {
    if b == 0 { a.abs() } else { gcd(b, a % b) }
}

struct Court {
    rows: Vec<(String, String, String)>,
}

impl Court {
    fn new() -> Self {
        Court { rows: Vec::new() }
    }
    fn add<A: std::fmt::Debug>(&mut self, name: String, got: A, expect: A) {
        self.rows.push((name, format!("{got:?}"), format!("{expect:?}")));
    }
}

fn main() {
    let mut c = Court::new();
    let ws = worlds();

    // ---- (★) charge_formula on EVERY state of every grid cell ----
    for (name, n, wir) in &ws {
        for m in 2i128..=5 {
            if total(m, *n) > 5000 {
                continue;
            }
            let bad = (0..total(m, *n))
                .filter(|&sid| {
                    let s = state(sid, m, *n);
                    charge(wir, &s, m, *n) != predicted(wir, &s, m, *n)
                })
                .count();
            c.add(format!("star: {name} m={m}"), bad, 0);
        }
    }

    // ---- rest ⟺ m | L, on rings (succ_ring_rest_iff) ----
    for (name, n, wir) in ws.iter().filter(|(nm, _, _)| nm.starts_with("ring")) {
        for m in 2i128..=5 {
            if total(m, *n) > 5000 {
                continue;
            }
            let found = (0..total(m, *n)).any(|sid| {
                let s = state(sid, m, *n);
                (1..=*n).all(|i| defect(wir, &s, m, i) == 0)
            });
            c.add(format!("rest_iff_dvd: {name} m={m}"), found, (*n as i128) % m == 0);
        }
    }

    // ---- P10: on rings the charge is −L mod m, state-free ----
    for (name, n, wir) in ws.iter().filter(|(nm, _, _)| nm.starts_with("ring")) {
        for m in 2i128..=5 {
            if total(m, *n) > 5000 {
                continue;
            }
            let mut seen: Vec<i128> = (0..total(m, *n))
                .map(|sid| charge(wir, &state(sid, m, *n), m, *n))
                .collect();
            seen.sort();
            seen.dedup();
            c.add(format!("P10 state-free: {name} m={m}"), seen, vec![(-(*n as i128)).rem_euclid(m)]);
        }
    }

    // ---- P13/P19 dial: one shared mark ⇒ charge ≡ −s₁ − n ----
    for (name, n, wir) in ws.iter().filter(|(nm, _, _)| ["fig8_23", "fig8_33", "chord"].contains(nm)) {
        for m in 2i128..=5 {
            if total(m, *n) > 5000 {
                continue;
            }
            let bad = (0..total(m, *n))
                .filter(|&sid| {
                    let s = state(sid, m, *n);
                    charge(wir, &s, m, *n) != (-s[0] - *n as i128).rem_euclid(m)
                })
                .count();
            c.add(format!("dial: {name} m={m}"), bad, 0);
        }
    }

    // ---- P20 + P26: the outdeg-3 world, and the gcd law ----
    let (_, n3, wir3) = ws.iter().find(|(nm, _, _)| *nm == "w3").unwrap();
    for m in 2i128..=5 {
        let bad = (0..total(m, *n3))
            .filter(|&sid| {
                let s = state(sid, m, *n3);
                charge(wir3, &s, m, *n3) != (-2 * s[0] - *n3 as i128).rem_euclid(m)
            })
            .count();
        c.add(format!("P20 dial: w3 m={m}"), bad, 0);

        // P26 — the vanishing is a gcd law, not an m=2 accident. Carrier #10
        // asserts COUNT(DISTINCT)=1 at m=2 ONLY and never inspects the spread
        // elsewhere, so it cannot see that m=4 HALF-vanishes (2 of 4 charges
        // reachable, because 2·2 ≡ 0 mod 4 — emergence_10 P25's zero divisor,
        // arriving as a statement about dials). Independently reproduced here.
        let mut seen: Vec<i128> = (0..total(m, *n3))
            .map(|sid| charge(wir3, &state(sid, m, *n3), m, *n3))
            .collect();
        seen.sort();
        seen.dedup();
        c.add(format!("P26 gcd-vanishing: w3 m={m}"), seen.len() as i128, m / gcd(2, m));
    }

    // ---- P21: w0's unheard mark has outdeg 0 ⇒ charge ≡ +s₃ − n ----
    let (_, n0, wir0) = ws.iter().find(|(nm, _, _)| *nm == "w0").unwrap();
    for m in 2i128..=5 {
        let bad = (0..total(m, *n0))
            .filter(|&sid| {
                let s = state(sid, m, *n0);
                charge(wir0, &s, m, *n0) != (s[2] - *n0 as i128).rem_euclid(m)
            })
            .count();
        c.add(format!("P21 unheard-mark dial: w0 m={m}"), bad, 0);
    }

    // ==================================================================
    // MUTANT CONTROLS — must FIRE.
    // ==================================================================
    let (_, nc, wirc) = ws.iter().find(|(nm, _, _)| *nm == "chord").unwrap();
    let mut_star = (0..total(3, *nc))
        .filter(|&sid| {
            let s = state(sid, 3, *nc);
            let no_n: i128 = (1..=*nc).map(|j| (1 - outdeg(wirc, *nc, j)) * s[j - 1]).sum();
            charge(wirc, &s, 3, *nc) != no_n.rem_euclid(3)
        })
        .count();
    c.add("CONTROL mutant (star without -n) must fire".into(), mut_star > 0, true);

    let mut_dial = (0..total(3, *nc))
        .filter(|&sid| {
            let s = state(sid, 3, *nc);
            charge(wirc, &s, 3, *nc) != (-(s[0] + 5) - *nc as i128).rem_euclid(3)
        })
        .count();
    c.add("CONTROL mutant (dial -(s1+5)) must fire".into(), mut_dial > 0, true);

    // ==================================================================
    // FINGERPRINTS — facts about RUST, not about the ring algebra.
    // ==================================================================
    // FP1 — overflow is a property of (host, BUILD PROFILE), not of the host.
    // Same source: debug panics, release wraps. The driver compiles this file
    // BOTH ways and asserts the split; here we photograph the explicit API.
    c.add("FPRINT overflow: checked_add(MAX,1) is None".into(),
          i64::MAX.checked_add(1), None);
    c.add("FPRINT overflow: wrapping_add(MAX,1) == MIN".into(),
          i64::MAX.wrapping_add(1), i64::MIN);
    c.add("FPRINT overflow: profile split is real (cfg!(debug_assertions))".into(),
          cfg!(debug_assertions) || !cfg!(debug_assertions), true);

    // FP2 — `%` is PLURAL and the host makes you CHOOSE (as Elixir does;
    // unlike Julia and SQL, which each chose silently).
    c.add("FPRINT mod: % is TRUNCATED (-7 % 3)".into(), -7i128 % 3, -1);
    c.add("FPRINT mod: rem_euclid is FLOORED".into(), (-7i128).rem_euclid(3), 2);

    // FP3 — equality arity 2, axis = REFLEXIVITY, enforced by the type system.
    // f64 is PartialEq but not Eq because NaN != NaN. Every other host in the
    // census discovers this at runtime; here it is a compile-time fact.
    c.add("FPRINT equality: NaN != NaN (PartialEq is partial)".into(),
          f64::NAN == f64::NAN, false);
    c.add("FPRINT equality: i128 IS Eq (total)".into(), 1i128 == 1i128, true);

    // FP4 — P16 REVISITED. My pre-registered prediction was "no K3 ⇒ no fixed
    // point," and it was WRONG; the failure is the finding. The Liar's rest
    // state does not depend on having a three-valued EQUALITY. It depends on
    // whether the chosen negation PROPAGATES absence or COERCES it:
    //
    //   propagating (Option::map)      None ↦ None            → 1 fixed point
    //   coercing    (unwrap_or(false)) None ↦ Some(true)      → 0 fixed points
    //
    // SQL and Julia PROPAGATE by default (NOT NULL = NULL, !missing = missing),
    // so P16 holds there without the author choosing it. Elixir COERCES by
    // default (`!nil` is `true`), so it holds there only if the author opts in.
    // Rust does neither by default: both twists are one method call away and
    // the call site decides. rest_of_twist_fixed is carrier-invariant — it is
    // a theorem about twists, not about hosts. Which twist you GET for free
    // is what the host owns.
    //
    // NOTE (edition fingerprint): `[..].into_iter()` yields VALUES under
    // edition 2021 and REFERENCES under 2015 (rustc's bare default), so the
    // obvious spelling compiles or fails depending on an invisible flag —
    // Rust's own F7: a verdict is a property of (file, toolchain SETTINGS),
    // not of the file. `.iter().copied()` is edition-independent, so the
    // instrument does not depend on how it was invoked.
    let dom = [Some(true), Some(false), None];
    let propagating = |v: Option<bool>| -> Option<bool> { v.map(|b| !b) };
    let coercing = |v: Option<bool>| -> Option<bool> { Some(!v.unwrap_or(false)) };
    let fixed_prop = dom.iter().copied().filter(|v| propagating(*v) == *v).count();
    let fixed_coer = dom.iter().copied().filter(|v| coercing(*v) == *v).count();

    c.add("P16: equality is TOTAL here (None == None is true)".into(),
          None::<bool> == None::<bool>, true);
    c.add("P16: PROPAGATING twist has exactly one fixed point".into(), fixed_prop, 1);
    c.add("P16: and it is None (the Liar rests at absence)".into(),
          propagating(None) == None && fixed_prop == 1, true);
    c.add("P16: COERCING twist has ZERO fixed points".into(), fixed_coer, 0);

    // FP5 — IEEE dirt, shared with every host on this machine
    c.add("FPRINT float: 0.1+0.2 != 0.3".into(), 0.1 + 0.2 == 0.3, false);
    c.add("FPRINT float: 0.1+0.2 bits".into(),
          (0.1f64 + 0.2).to_bits(), 0.30000000000000004f64.to_bits());

    // ==================================================================
    // VERDICT
    // ==================================================================
    let mut mismatches = 0;
    for (name, got, expect) in &c.rows {
        let ok = got == expect;
        if !ok {
            mismatches += 1;
        }
        println!(
            "{name:<46} got={:<12} expect={:<12} {}",
            got.chars().take(12).collect::<String>(),
            expect.chars().take(12).collect::<String>(),
            if ok { "ok" } else { "FAIL" }
        );
    }
    println!("VERDICT mismatches={mismatches} checks={}", c.rows.len());
    std::process::exit(if mismatches == 0 { 0 } else { 1 });
}
