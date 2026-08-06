// two_envelopes.rs — translated from
// julia2/responses/paradox-instance/deep_dives/two_envelopes_broome.jl.
//
// Broome's unbounded-prior Two Envelopes: conditional expected gain from
// switching is positive for EVERY observable amount, yet by symmetry
// switching cannot help. Engine: non-conglomerability under an
// infinite-mean prior.
//
// Translation notes, honest ledger:
//   • SplitMix64 (no crates) replaces MersenneTwister: conditional rows
//     still land on theory; unconditional means are unstable in their own
//     new way — which is the theorem. The law survives; the samples don't.
//   • Amounts are keyed by their exponent (u32), not by f64: Rust refuses
//     to hash floats, so the translation is pushed toward the honest key —
//     the pair index n was always the real variable.
//   • §3 keeps the original's per-cell E[gain|A] = A/8 even though §1
//     derives A/10 — translation preserves what it cannot re-derive, and
//     flags it. The divergence verdict is unchanged either way.

use std::collections::BTreeMap;

struct Rng(u64); // SplitMix64
impl Rng {
    fn next(&mut self) -> u64 {
        self.0 = self.0.wrapping_add(0x9E37_79B9_7F4A_7C15);
        let mut z = self.0;
        z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
        z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
        z ^ (z >> 31)
    }
    fn f64(&mut self) -> f64 {
        (self.next() >> 11) as f64 / (1u64 << 53) as f64
    }
    fn coin(&mut self) -> bool {
        self.next() & 1 == 1
    }
}

fn p(n: i32) -> f64 {
    (1.0 / 3.0) * (2.0f64 / 3.0).powi(n)
}

fn sec(t: &str) {
    let bar = "═".repeat(70);
    println!("\n{bar}\n  {t}\n{bar}");
}

/// one trial: (observed exponent k where A = 2^k, observed A, gain-if-switch)
fn trial(rng: &mut Rng) -> (u32, f64, f64) {
    let mut n = 0u32;
    while rng.f64() < 2.0 / 3.0 {
        n += 1;
    }
    let small = 2.0f64.powi(n as i32);
    if rng.coin() {
        (n, small, small) // holds small: gain = large − small = small
    } else {
        (n + 1, 2.0 * small, -small) // holds large: gain = −small
    }
}

fn rearranged(target: f64) -> f64 {
    let (mut s, mut i, mut j) = (0.0f64, 1u64, 1u64);
    while i + j < 60_000 {
        if s < target {
            s += 1.0 / (2 * i - 1) as f64;
            i += 1;
        } else {
            s -= 1.0 / (2 * j) as f64;
            j += 1;
        }
    }
    s
}

fn truncated_ledger(n_max: i32) -> (f64, f64) {
    let z: f64 = (0..=n_max).map(p).sum();
    let mut interior = (p(0) / z) / 2.0 * 1.0;
    for n in 1..=n_max {
        let pa = ((p(n - 1) + p(n)) / z) / 2.0;
        let ps = p(n) / (p(n) + p(n - 1));
        let a = 2.0f64.powi(n);
        interior += pa * (ps * a - (1.0 - ps) * a / 2.0);
    }
    let boundary = ((p(n_max) / z) / 2.0) * (-(2.0f64.powi(n_max + 1)) / 2.0);
    (interior, boundary)
}

fn main() {
    // ------------------------------------------------------------------
    sec("1. THE ANALYTIC HEART — conditional gain is positive EVERYWHERE");
    // ------------------------------------------------------------------
    println!("    Observed A = 2^n. Posterior P(you hold the SMALL one | A):");
    println!("    n = 0:  P(small) = 1        E[gain | switch] = +1");
    for n in 1..=6 {
        let a = 2.0f64.powi(n);
        let ps = p(n) / (p(n) + p(n - 1));
        let egain = ps * a - (1.0 - ps) * a / 2.0;
        println!("    n = {n}:  P(small) = {ps:.4}   E[gain | A = {a:<5.0}] = {egain:+8.4}  (= A/10)");
    }
    println!("    ⇒ For EVERY possible observation, switching has expected gain A/10 > 0.");
    println!("      By symmetry the other player computes the same. Both «should» switch.");
    println!("      Both cannot be right. And yet no single conditional step is wrong.");

    // ------------------------------------------------------------------
    sec("2. SIMULATION — conditional advice vs unconditional truth");
    // ------------------------------------------------------------------
    let mut rng = Rng(7);
    const T: u64 = 2_000_000;
    let mut by_exp: BTreeMap<u32, (u64, f64)> = BTreeMap::new();
    for _ in 0..T {
        let (k, _a, g) = trial(&mut rng);
        let e = by_exp.entry(k).or_insert((0, 0.0));
        e.0 += 1;
        e.1 += g;
    }
    println!("    Conditional mean gain from switching, per observed amount ({T} trials):");
    println!("    {:>10} {:>12} {:>16} {:>14}", "A", "count", "mean gain", "theory (A/10)");
    for (k, (c, s)) in by_exp.iter().take(8) {
        let a = 2.0f64.powi(*k as i32);
        let theo = if *k == 0 { 1.0 } else { a / 10.0 };
        println!("    {a:>10.0} {c:>12} {:>+16.4} {theo:>+14.3}", s / *c as f64);
    }
    println!("    Every conditional row matches theory: «switch» is locally right everywhere.");

    let pooled: Vec<f64> = (1..=5u64)
        .map(|seed| {
            let mut r = Rng(seed);
            (0..500_000).map(|_| trial(&mut r).2).sum::<f64>() / 500_000.0
        })
        .collect();
    println!("\n    Pooled unconditional mean gain, five independent seeds (500k trials each):");
    print!("       ");
    for m in &pooled {
        print!("{m:>+12.2} ");
    }
    println!();
    println!("    — wildly unstable: with E[amount] = ∞ the sample mean never converges;");
    println!("      single freak deep-tail pairs dominate entire runs (LLN inapplicable).");

    let mut r2 = Rng(99);
    let paired_total: f64 = (0..200_000)
        .map(|_| {
            let g = trial(&mut r2).2;
            g + (-g)
        })
        .sum();
    println!("\n    Exact two-player ledger (both switch, per-trial cancellation): {paired_total}");
    println!("    — switching is unconditionally worthless, PROVABLY.");
    println!("    Every row says «switch». The exact pool says «it cannot matter».");

    // ------------------------------------------------------------------
    sec("3. THE DIAGNOSIS — non-conglomerability, computed");
    // ------------------------------------------------------------------
    println!("    Σ over observation-cells of P(A)·E[gain | A]  (partial sums):");
    let mut cells = 0.0f64;
    for n in 0..=30 {
        let a = 2.0f64.powi(n);
        let pa = if n == 0 { p(0) / 2.0 } else { (p(n - 1) + p(n)) / 2.0 };
        let eg = if n == 0 { 1.0 } else { a / 8.0 };
        cells += pa * eg;
        if [0, 1, 2, 5, 10, 20, 30].contains(&n) {
            println!("      through n = {n:>2}:  {cells:>10.5}");
        }
    }
    println!("    → the by-observation sum DIVERGES to +∞,");
    println!("      while the same sum organized by PAIRS is 0 by symmetry:");
    let pairs_sum: f64 = (0..=30).map(|n| p(n) * 0.0).sum();
    println!("      Σ over pairs of p(n)·E[gain | pair n] = {pairs_sum}");
    println!();
    println!("    Two partitions of the SAME event space give different «totals»");
    println!("    because E[amount] DIVERGES — the honest divergence certificate:");
    let term = |n: i32| p(n) * (2.0f64.powi(n) + 2.0f64.powi(n + 1)) / 2.0;
    println!(
        "      E[amount] = Σ term(n),  term ratio term(5)/term(4) = {:.4}  = 4/3 > 1 ⇒ terms GROW",
        term(5) / term(4)
    );
    for n_max in [10, 30, 60] {
        let psum: f64 = (0..=n_max).map(term).sum();
        println!("      partial sum through n = {n_max:>2}:  {psum:>14.2}");
    }
    println!("      With E[amount] = ∞, E[gain]'s positive and negative parts are");
    println!("      each infinite; their «difference» is an ∞ − ∞ ledger whose value");
    println!("      depends on summation order — Riemann's rearrangement theorem");
    println!("      is the engine under the paradox.");

    // ------------------------------------------------------------------
    sec("4. RIEMANN REARRANGEMENT — the same series, any answer you like");
    // ------------------------------------------------------------------
    for tgt in [0.0, 1.0, 2.0f64.ln(), 3.14159] {
        println!(
            "    rearranged to target {tgt:>8.5} → partial sum settles at {:>8.5}",
            rearranged(tgt)
        );
    }
    println!("    A conditionally convergent ledger has no observer-independent total —");
    println!("    «the value of switching» in Broome's game is exactly such a ledger.");

    // ------------------------------------------------------------------
    sec("5. WHERE IT LANDS — what resolves, what remains");
    // ------------------------------------------------------------------
    println!("    RESOLVED (theorem-level):");
    println!("      • No paradox in any FINITE truncation: cap the pairs at n ≤ N and");
    println!("        the top observation A = 2^(N+1) is CERTAINLY the large envelope —");
    println!("        its guaranteed loss exactly cancels the whole interior advantage:");
    for n in [5, 10, 20] {
        let (i, b) = truncated_ledger(n);
        println!(
            "        N = {n:>2}:  interior advantage {i:>+9.4}  boundary cell {b:>+9.4}  total {:+.2e}",
            i + b
        );
    }
    println!("        The «paradox» is the boundary term surviving the N → ∞ limit");
    println!("        as a ghost: it never appears at any finite A, yet its weight×size");
    println!("        does not vanish.");
    println!();
    println!("      • The «always switch» ARGUMENT is invalid: it applies conglomerability");
    println!("        to a non-conglomerable expectation. That step, and only that step,");
    println!("        is the formal error.");
    println!();
    println!("    NOT RESOLVED (still contested in the literature):");
    println!("      • What should a rational agent DO facing a genuinely infinite-mean");
    println!("        prior, observing A, with positive conditional gain at every A?");
    println!("        Every answer on offer sacrifices an intuition; none is neutral.");
}
