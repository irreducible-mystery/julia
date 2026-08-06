// negation_census.rs — NEGATION, carried across hosts (Rust half).
//
// Companion to negation_census.exs. Same duality (N1); this half reaches what
// Elixir can only model — the FIXED-WIDTH case, exhaustively — and the two
// places where negation's own behaviour is decided by something outside the
// program text.
//
// THE DUALITY, restated: on ℤ/m the doubling map φ(x) = 2x satisfies
//     x fixed by negation ⟺ 2x ≡ 0 ⟺ x ∈ ker φ,     P26's dial image = im φ,
//     |ker φ| · |im φ| = m.
// emergence_09's "m=2 vanishing" and RingRest.lean's "neg regains rest" are
// one theorem read from opposite ends.
//
// THE FIXED-WIDTH PAYOFF: iN is exactly ℤ/2^N, so gcd(2, 2^N) = 2 predicts
// that negation on any signed integer type has EXACTLY TWO fixed points —
// 0 and MIN. Checked exhaustively over all 256 i8 and all 65536 i16 below.
// Julia's `-typemin(Int64) == typemin(Int64)` is not a quirk; it is ker φ.
//
// AND THE STING: in a debug build, `-i8::MIN` PANICS. The second fixed point
// is unreachable. THE NUMBER OF FIXED POINTS OF NEGATION IS A PROPERTY OF
// (host, BUILD PROFILE) — 2 in release, 1-plus-a-crash in debug. The census's
// overflow column and this negation study are the same finding twice.
// run_negation_census.sh proves that half by compiling one file both ways.

fn gcd(a: u128, b: u128) -> u128 { if b == 0 { a } else { gcd(b, a % b) } }

fn neg_fixed_count(m: i64) -> usize {
    (0..m).filter(|&x| (-x).rem_euclid(m) == x).count()
}
fn dial_image_size(m: i64, d: i64, c: i64) -> usize {
    let mut v: Vec<i64> = (0..m).map(|s| (d * s + c).rem_euclid(m)).collect();
    v.sort(); v.dedup(); v.len()
}

struct Court { rows: Vec<(String, String, String)> }
impl Court {
    fn new() -> Self { Court { rows: Vec::new() } }
    fn add<A: std::fmt::Debug>(&mut self, name: String, got: A, expect: A) {
        self.rows.push((name, format!("{got:?}"), format!("{expect:?}")));
    }
}

fn main() {
    let mut c = Court::new();

    // =================================================================
    // N1 — THE DUALITY, exhaustively for m = 1..64
    // =================================================================
    for m in 1i64..=64 {
        let fp = neg_fixed_count(m);
        let img = dial_image_size(m, -2, -4);
        c.add(format!("N1 m={m}: |neg fixed| = gcd(2,m), and fp*img = m"),
              (fp as u128, (fp * img) as u128),
              (gcd(2, m as u128), m as u128));
    }

    // =================================================================
    // N2 — FIXED WIDTH IS ℤ/2^N. Exhaustive; this is the case Elixir and
    // Common Lisp cannot suffer (they promote) and Julia suffers silently.
    // =================================================================
    let i8_fixed: Vec<i8> = (i8::MIN..=i8::MAX).filter(|&x| x.wrapping_neg() == x).collect();
    c.add("N2 i8 EXHAUSTIVE (256 values): fixed points of wrapping_neg".into(),
          i8_fixed.clone(), vec![i8::MIN, 0]);
    c.add("N2 i8: count = gcd(2, 2^8) = 2".into(), i8_fixed.len() as u128, gcd(2, 256));

    let i16_fixed: Vec<i16> = (i16::MIN..=i16::MAX).filter(|&x| x.wrapping_neg() == x).collect();
    c.add("N2 i16 EXHAUSTIVE (65536 values): fixed points".into(),
          i16_fixed.clone(), vec![i16::MIN, 0]);
    c.add("N2 i16: count = gcd(2, 2^16) = 2".into(), i16_fixed.len() as u128, gcd(2, 65536));

    // i64: the same two, verified directly (2^64 is not enumerable)
    c.add("N2 i64: MIN is self-negating (ker φ, not a quirk)".into(),
          i64::MIN.wrapping_neg(), i64::MIN);
    c.add("N2 i64: 0 is self-negating".into(), 0i64.wrapping_neg(), 0i64);
    c.add("N2 i64: MIN is exactly 2^63 reinterpreted".into(),
          i64::MIN as u64, 1u64 << 63);

    // N2b — under WRAPPING, negation is a total involution: -(-x) = x for
    // every i8, MIN included. Under CHECKED arithmetic it is a PARTIAL
    // function: checked_neg(MIN) is None. Same operator, two totalities.
    let involutive = (i8::MIN..=i8::MAX).all(|x| x.wrapping_neg().wrapping_neg() == x);
    c.add("N2b wrapping negation is a TOTAL involution on i8 (exhaustive)".into(),
          involutive, true);
    c.add("N2b checked negation is PARTIAL: checked_neg(MIN) is None".into(),
          i8::MIN.checked_neg(), None);
    let checked_defined = (i8::MIN..=i8::MAX).filter(|x| x.checked_neg().is_some()).count();
    c.add("N2b checked_neg is defined on 255 of 256 values".into(), checked_defined, 255);

    // =================================================================
    // N3 — INVOLUTIVITY IS DECIDED BY PROPAGATE-VS-COERCE (as in #12)
    // =================================================================
    let dom = [Some(true), Some(false), None];
    let propagating = |v: Option<bool>| v.map(|b| !b);
    let coercing = |v: Option<bool>| Some(!v.unwrap_or(false));

    c.add("N3 propagating: DNE holds for all 3".into(),
          dom.iter().copied().filter(|&v| propagating(propagating(v)) == v).count(), 3);
    c.add("N3 coercing: DNE holds for only 2 of 3".into(),
          dom.iter().copied().filter(|&v| coercing(coercing(v)) == v).count(), 2);
    c.add("N3 propagating has exactly one fixed point (None)".into(),
          dom.iter().copied().filter(|&v| propagating(v) == v).count(), 1);
    c.add("N3 coercing has zero fixed points".into(),
          dom.iter().copied().filter(|&v| coercing(v) == v).count(), 0);
    c.add("N3 coercing: ¬¬None is Some(false), not None".into(),
          coercing(coercing(None)), Some(false));

    // =================================================================
    // N5 — THE FIXED-POINT COUNT DEPENDS ON THE EQUALITY. Negation flips the
    // sign bit unconditionally, so under BIT identity it has NO fixed point;
    // under `==` it has two (both zeros), because -0.0 == 0.0. Swept over all
    // 65536 top-16-bit f32 patterns: every exponent, every sign, NaN, Inf,
    // and subnormals included.
    // =================================================================
    let mut bit_fixed = 0usize;
    let mut eq_fixed = 0usize;
    for hi in 0u32..=0xFFFF {
        let x = f32::from_bits(hi << 16);
        if (-x).to_bits() == x.to_bits() { bit_fixed += 1; }
        if -x == x { eq_fixed += 1; }
    }
    c.add("N5 under BIT identity: negation has ZERO fixed points (65536 swept)".into(),
          bit_fixed, 0);
    c.add("N5 under ==: exactly two (+0.0 and -0.0)".into(), eq_fixed, 2);
    c.add("N5 -0.0 == 0.0 but the bits differ".into(),
          (-0.0f64 == 0.0f64, (-0.0f64).to_bits() == 0.0f64.to_bits()), (true, false));
    // NaN: not fixed by negation, and not even self-equal — the value that
    // breaks reflexivity is also the value negation cannot pin down.
    c.add("N5 NaN is not a fixed point, and is not self-equal either".into(),
          (-f64::NAN == f64::NAN, f64::NAN == f64::NAN), (false, false));

    // =================================================================
    // N6 — neg_world_rest: the neg twist always has a fixed point (0), so
    // neg-twisted worlds ALWAYS rest, for every modulus and every wiring.
    // The rest states ARE the fixed points — N1's left half, operationally.
    // =================================================================
    for m in [2i64, 3, 4, 6, 9, 12] {
        let resting: Vec<i64> = (0..m).filter(|&x0| (m - x0).rem_euclid(m) == x0).collect();
        let fixed: Vec<i64> = (0..m).filter(|&x| (-x).rem_euclid(m) == x).collect();
        c.add(format!("N6 m={m}: neg-world rest states = negation's fixed points"),
              resting, fixed);
    }

    // =================================================================
    // CONTROLS
    // =================================================================
    c.add("CONTROL: a wrong gcd law must fire".into(),
          (1i64..=40).any(|m| neg_fixed_count(m) as u128 != gcd(3, m as u128)), true);
    c.add("CONTROL: d=-1 dial never collapses".into(),
          (2i64..=40).all(|m| dial_image_size(m, -1, 0) == m as usize), true);

    // =================================================================
    let mut mismatches = 0;
    for (name, got, expect) in &c.rows {
        if got != expect {
            mismatches += 1;
            println!("{name:<54} got={got} expect={expect} FAIL");
        }
    }
    println!("({} passing rows suppressed; failures printed above)", c.rows.len() - mismatches);
    println!("VERDICT mismatches={mismatches} checks={}", c.rows.len());
    std::process::exit(if mismatches == 0 { 0 } else { 1 });
}
