// ring_rest.rs — translated from julia/emergence/lean/RingRest.lean.
//
// The Lean file PROVES; this file can only CHECK. Where Lean quantifies
// over every state in ℤ, Rust must budget magnitude: i128 tops out near
// 1.7·10^38, so the "astronomically large" states here stop at ~10^30 —
// a ceiling Lean does not have, and Elixir (bignums) does not have either.
// In exchange, Rust makes explicit two decisions the other languages bury:
// which "%" you mean (rem_euclid below — the same care Lean's author spent
// dodging Classical.choice in the Int→Nat divisibility descent), and who
// owns the RNG state (nobody shares it by accident).

struct Rng(u64); // SplitMix64 — no crates, fully deterministic
impl Rng {
    fn next(&mut self) -> u64 {
        self.0 = self.0.wrapping_add(0x9E37_79B9_7F4A_7C15);
        let mut z = self.0;
        z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
        z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
        z ^ (z >> 31)
    }
    fn below(&mut self, n: u64) -> u64 {
        self.next() % n
    }
}

// IsFix m L s  ⇝  a decidable check on ONE concrete finite state
fn is_fix(m: u64, s: &[u64]) -> bool {
    let n = s.len();
    (0..n).all(|i| s[i] < m && s[i] == (s[(i + 1) % n] + 1) % m)
}

// dvd_imp_rest's constructive witness: s i = (L - i mod L) mod m
fn countdown(m: u64, l: usize) -> Vec<u64> {
    (0..l).map(|i| (l as u64 - (i as u64 % l as u64)) % m).collect()
}

// ∃ s, IsFix m L s  ⇝  exhaustion of [0,m)^L (the move Lean got to skip)
fn exists_rest(m: u64, l: usize) -> bool {
    let mut s = vec![0u64; l];
    loop {
        if is_fix(m, &s) {
            return true;
        }
        let mut i = 0;
        loop {
            if i == l {
                return false;
            }
            s[i] += 1;
            if s[i] < m {
                break;
            }
            s[i] = 0;
            i += 1;
        }
    }
}

// defect m L s i = (s i − s (prev i) − 1) emod m — rem_euclid IS Int.emod
// for positive m. Rust's `%` is truncated; the translation must choose.
fn defects(m: u64, s: &[i128]) -> Vec<i128> {
    let n = s.len();
    (0..n)
        .map(|i| (s[i] - s[(i + n - 1) % n] - 1).rem_euclid(m as i128))
        .collect()
}

fn defect_sum(m: u64, s: &[i128]) -> i128 {
    defects(m, s).iter().sum()
}

// gaugeState L j — distance-from-j walking forward around the ring
fn gauge(l: usize, j: usize) -> Vec<i128> {
    (0..l)
        .map(|i| if j <= i { (i - j) as i128 } else { (i + l - j) as i128 })
        .collect()
}

// Section 3's fig8(2,3) wiring: mark 0 listens to both loop tails
fn fig8(i: usize) -> &'static [usize] {
    match i {
        0 => &[1, 3],
        1 => &[0],
        2 => &[0],
        3 => &[2],
        _ => &[],
    }
}

fn g_defect_sum(m: u64, inputs: fn(usize) -> &'static [usize], s: &[i128], n: usize) -> i128 {
    (0..n)
        .map(|i| {
            let insum: i128 = inputs(i).iter().map(|&j| s[j]).sum();
            (s[i] - insum - 1).rem_euclid(m as i128)
        })
        .sum()
}

// a wild state: negative, and ~10^30 in magnitude (i128's ceiling keeps
// the subtraction in defects() safely inside the type — a budget the
// original theorem never had to negotiate)
fn wild(rng: &mut Rng, l: usize) -> Vec<i128> {
    (0..l)
        .map(|_| {
            let sign: i128 = if rng.below(2) == 0 { -1 } else { 1 };
            let hi = rng.below(9) as i128 + 1;
            sign * (hi * 10i128.pow(30) + rng.below(1_000_000) as i128)
        })
        .collect()
}

fn main() {
    let bar = "─".repeat(66);

    println!("{bar}");
    println!("1. succ_ring_rest_iff — the theorem, demoted back to the table");
    println!("   (L ∈ 2..9, m ∈ {{2,3}}: the exact cases Lean says Julia exhausted)");
    println!("{bar}");
    for m in [2u64, 3] {
        let row: Vec<String> = (2..=9)
            .map(|l| {
                let found = exists_rest(m, l);
                let law = (l as u64) % m == 0;
                let mark = if found == law { "✓" } else { "✗" };
                format!("L={l}:{}{mark}", if found { "rest" } else { "  — " })
            })
            .collect();
        println!("   m={m}  {}", row.join("  "));
    }
    println!("   every cell agrees with the law  ∃ rest ⇔ L % m == 0");

    println!("\n{bar}");
    println!("2. dvd_imp_rest — the constructive witness runs at sizes");
    println!("   exhaustion cannot reach (7^700 states; we check ONE)");
    println!("{bar}");
    let w = countdown(7, 700);
    println!("   countdown state on (m=7, L=700): IsFix? {}", is_fix(7, &w));

    println!("\n{bar}");
    println!("3. defect_sum_invariant — the charge refuses to move.");
    println!("   200 wild states each: negative, ~10^30 in magnitude —");
    println!("   as far as i128 lets a translation of ℤ go.");
    println!("{bar}");
    let mut rng = Rng(0x5EED);
    for (m, l) in [(3u64, 4usize), (3, 8), (2, 5), (4, 6), (3, 6)] {
        let mut charges: Vec<i128> = (0..200)
            .map(|_| defect_sum(m, &wild(&mut rng, l)).rem_euclid(m as i128))
            .collect();
        charges.sort();
        charges.dedup();
        println!(
            "   (m={m}, L={l})  charge over 200 wild states: {:?}   Lean predicts: {}",
            charges,
            (-(l as i128)).rem_euclid(m as i128)
        );
    }

    println!("\n{bar}");
    println!("4. defect_gauge — blame is a choice, the total is a fact");
    println!("{bar}");
    let (m, l, j) = (5u64, 12usize, 7usize);
    let ds = defects(m, &gauge(l, j));
    println!("   gauge state (m={m}, L={l}, j={j}) defects: {ds:?}");
    println!(
        "   only edge {j} carries charge {} = -L mod m = {}",
        ds[j],
        (-(l as i128)).rem_euclid(m as i128)
    );

    println!("\n{bar}");
    println!("5. charge_dial on fig8(2,3) — Section 3's example, sampled");
    println!("{bar}");
    let dial_ok = (0..200).all(|_| {
        let s = wild(&mut rng, 4);
        let lhs = g_defect_sum(3, fig8, &s, 4).rem_euclid(3);
        let rhs = (-s[0] - 4).rem_euclid(3);
        lhs == rhs
    });
    println!("   charge ≡ −s₀ − 4 (mod 3) on 200 wild states: {dial_ok}");

    println!("\n{bar}");
    println!("6. Borrowed certainty — deciding ¬∃ where search cannot go");
    println!("{bar}");
    let (m, l) = (5u64, 701usize);
    let charge = defect_sum(m, &wild(&mut rng, l)).rem_euclid(m as i128);
    println!("   (m=5, L=701): 5^701 states — unsearchable. One state's charge: {charge}");
    println!("   rest_iff_charge_zero (trusted from Lean, not re-proved here)");
    println!(
        "   ⇒ {}.",
        if charge == 0 {
            "a rest state exists"
        } else {
            "NO rest state exists"
        }
    );
    println!("   The runtime can now SAY it, but only because the kernel SAW it.");
}
