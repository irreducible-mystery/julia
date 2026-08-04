/- ============================================================
   RingRest.lean — emergence_04 §IV, promoted from evidence to proof.
   Section 2 adds emergence_06's named handoff (defect_sum_invariant,
   defect_gauge, rest_iff_charge_zero). Section 3 adds (★), the
   graph-general charge formula emergence_07 named and _08's residue
   listed as unclaimed: charge_formula, charge_conserved_of_outdeg_one
   (conservation is an out-degree property, ALL wirings), charge_dial
   (the figure-eight dial law, every one-shared-mark topology).

   The Julia files can only exhaust fixed (L, m). These theorems
   quantify over ALL ring lengths L, ALL moduli m, and (for the
   involution result) ALL wiring functions at once — the unbounded
   family emergence_04's residue said "exhaustion cannot go there."
   The kernel can.

   No imports. Axiom budget, declared honestly: `omega` normalizes
   through `propext` and `Quot.sound` — standard, classical-choice-free,
   sorry-free. The C6 artifact managed zero axioms because everything
   was `decide` on closed terms; these theorems quantify over infinite
   families, so that luxury is gone. One near-miss caught during
   development: `Int.natCast_dvd_natCast` would have dragged
   Classical.choice into charge_zero_iff_dvd; the divisibility descent
   Int → Nat is done by |·| (natAbs) instead, keeping the whole file
   choice-free. The audit lines at the bottom print the exact ledger;
   verify.sh-style honesty: read them.
   ============================================================ -/

namespace RingRest

/-- A synchronous fixed point ("rest state") of the succ-twisted ring
    of length `L` over `Z/m`: values live below `m`, and every mark
    equals twist-of-its-single-input, the next mark around the ring.
    States are `Nat → Nat` read at indices mod `L`. -/
def IsFix (m L : Nat) (s : Nat → Nat) : Prop :=
  (∀ i, s i < m) ∧ (∀ i, s i = (s ((i + 1) % L) + 1) % m)

/-- Chain lemma: walking `k` steps around the ring accumulates `+k`. -/
theorem chain (m L : Nat) (s : Nat → Nat) (h : IsFix m L s) :
    ∀ k, s 0 = (s (k % L) + k) % m := by
  intro k
  induction k with
  | zero =>
      rw [Nat.zero_mod, Nat.add_zero, Nat.mod_eq_of_lt (h.1 0)]
  | succ k ih =>
      have hidx : (k % L + 1) % L = (k + 1) % L := Nat.mod_add_mod k L 1
      have hstep := h.2 (k % L)
      rw [hidx] at hstep
      rw [ih, hstep, Nat.mod_add_mod]
      have harith : s ((k + 1) % L) + 1 + k = s ((k + 1) % L) + (k + 1) := by omega
      rw [harith]

/-- Forward: if the succ-ring rests, the order of the twist divides
    the wiring-cycle length. Holds for EVERY `m`, EVERY `L`. -/
theorem rest_imp_dvd (m L : Nat) (_hL : 0 < L)
    (s : Nat → Nat) (h : IsFix m L s) : L % m = 0 := by
  have hc := chain m L s h L
  rw [Nat.mod_self] at hc
  -- hc : s 0 = (s 0 + L) % m
  have hdiv := Nat.mod_add_div (s 0 + L) m
  rw [← hc] at hdiv
  -- hdiv : s 0 + m * ((s 0 + L) / m) = s 0 + L
  have hq : m * ((s 0 + L) / m) = L := by omega
  rw [← hq, Nat.mul_mod_right]

/-- Backward: if `m ∣ L`, the explicit countdown state
    `s i = (L - i % L) % m` is a rest state. Constructive witness. -/
theorem dvd_imp_rest (m L : Nat) (hm : 0 < m) (hL : 0 < L)
    (h : L % m = 0) : ∃ s : Nat → Nat, IsFix m L s := by
  refine ⟨fun i => (L - i % L) % m, fun i => Nat.mod_lt _ hm, fun i => ?_⟩
  show (L - i % L) % m = ((L - (i + 1) % L % L) % m + 1) % m
  have hi : i % L < L := Nat.mod_lt _ hL
  have hii : (i + 1) % L % L = (i + 1) % L := Nat.mod_eq_of_lt (Nat.mod_lt _ hL)
  rw [hii, Nat.mod_add_mod]
  -- goal: (L - i % L) % m = (L - (i + 1) % L + 1) % m
  cases Nat.lt_or_ge (i % L) (L - 1) with
  | inl hlt =>
      have hsucc : (i + 1) % L = i % L + 1 := by
        have : (i + 1) % L = (i % L + 1) % L := (Nat.mod_add_mod i L 1).symm
        rw [this, Nat.mod_eq_of_lt (by omega)]
      rw [hsucc]
      have : L - (i % L + 1) + 1 = L - i % L := by omega
      rw [this]
  | inr hge =>
      have heq : i % L = L - 1 := by omega
      have hsucc : (i + 1) % L = 0 := by
        have h1 : (i + 1) % L = (i % L + 1) % L := (Nat.mod_add_mod i L 1).symm
        rw [h1, heq]
        have : L - 1 + 1 = L := by omega
        rw [this, Nat.mod_self]
      rw [hsucc, heq, Nat.sub_zero]
      have h2 : L - (L - 1) = 1 := by omega
      rw [h2]
      -- goal: 1 % m = (L + 1) % m ; from L % m = 0
      have h3 : (L + 1) % m = (L % m + 1) % m := (Nat.mod_add_mod L m 1).symm
      rw [h3, h, Nat.zero_add]

/-- **The divisibility law, unbounded.** emergence_04 §IV checked this at
    L ∈ 2..9 for m ∈ {2,3} by exhaustion; this closes EVERY case at once:
    a succ-twisted ring rests iff the twist's order divides the loop. -/
theorem succ_ring_rest_iff (m L : Nat) (hm : 0 < m) (hL : 0 < L) :
    (∃ s : Nat → Nat, IsFix m L s) ↔ L % m = 0 :=
  ⟨fun ⟨s, hs⟩ => rest_imp_dvd m L hL s hs, dvd_imp_rest m L hm hL⟩

/-- Instances the Julia table printed (§IV, L ∈ 2..9): now corollaries. -/
example : ¬ ∃ s, IsFix 3 8 s := fun ⟨s, hs⟩ => by
  have := rest_imp_dvd 3 8 (by omega) s hs; omega
example : ∃ s, IsFix 3 9 s := dvd_imp_rest 3 9 (by omega) (by omega) rfl
example : ∃ s, IsFix 2 8 s := dvd_imp_rest 2 8 (by omega) (by omega) rfl
example : ¬ ∃ s, IsFix 2 9 s := fun ⟨s, hs⟩ => by
  have := rest_imp_dvd 2 9 (by omega) s hs; omega

/-- **The involution half, over ALL wirings at once.** Any twist with a
    fixed point gives rest on ANY single-input world — not just rings:
    the constant state at the fixed locus is a rest state. This is
    emergence_04's "neg regains rest" (P2/P3), freed from every topology.
    Julia can only sample wiring functions; this quantifies over them. -/
theorem rest_of_twist_fixed (tw wire : Nat → Nat) (x0 : Nat)
    (hx : tw x0 = x0) :
    ∃ s : Nat → Nat, ∀ i, s i = tw (s (wire i)) :=
  ⟨fun _ => x0, fun _ => hx.symm⟩

/-- Corollary: neg-twisted single-input worlds ALWAYS rest (the all-zeros
    state), for every modulus and every wiring. The ternary neg-census of
    emergence_04 §V ("0 restless") is an instance, not an accident. -/
theorem neg_world_rest (m : Nat) (wire : Nat → Nat) :
    ∃ s : Nat → Nat, ∀ i, s i = (m - s (wire i)) % m :=
  rest_of_twist_fixed (fun x => (m - x) % m) wire 0
    (by rw [Nat.sub_zero, Nat.mod_self])

/- ============================================================
   SECTION 2 — THE DEFECT CHARGE (emergence_06 §II–III, the named
   handoff). Julia exhausted P10 at fixed (m, L) over states in
   [0, m)^L and sampled large cases. These theorems close it for
   EVERY modulus m (including m = 0, where emod is the identity
   and the raw telescope already gives -L), EVERY length L ≥ 1,
   and EVERY state s : Nat → Int — including states with values
   outside [0, m), negative, or astronomically large, which no
   Julia sweep visits. The gauge theorem (P11) closes too: the
   witness is explicit, no choice, no classical axioms beyond
   omega's usual propext/Quot.sound.
   ============================================================ -/

/-- Previous index around a ring of length `L` (0-based): `prevIdx L 0 = L-1`. -/
def prevIdx (L i : Nat) : Nat := (i + L - 1) % L

theorem prevIdx_zero (L : Nat) (hL : 0 < L) : prevIdx L 0 = L - 1 := by
  show (0 + L - 1) % L = L - 1
  rw [Nat.zero_add]
  exact Nat.mod_eq_of_lt (by omega)

theorem prevIdx_succ (L t : Nat) (ht : t < L) : prevIdx L (t + 1) = t := by
  show (t + 1 + L - 1) % L = t
  have h : t + 1 + L - 1 = t + L := by omega
  rw [h, Nat.add_mod_right]
  exact Nat.mod_eq_of_lt ht

/-- The raw (un-reduced) gap across edge `i`: how far `s i` overshoots
    `s (i-1) + 1`. Julia's `s[i] - s[prev(i)] - 1` before the `mod`. -/
def rawGap (L : Nat) (s : Nat → Int) (i : Nat) : Int :=
  s i - s (prevIdx L i) - 1

/-- The defect at edge `i`, exactly emergence_06's
    `defect(s,i,m) = mod(s[i] - s[prev(i)] - 1, m)`. -/
def defect (m L : Nat) (s : Nat → Int) (i : Nat) : Int :=
  rawGap L s i % (m : Int)

/-- Left-fold sum of the first `n` values of `f`. -/
def sumTo (f : Nat → Int) : Nat → Int
  | 0 => 0
  | n + 1 => sumTo f n + f n

/-- Reducing each summand mod `m` does not change the sum mod `m`. -/
theorem sumTo_emod (f : Nat → Int) (m : Int) :
    ∀ n, sumTo (fun i => f i % m) n % m = sumTo f n % m := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih =>
      show (sumTo (fun i => f i % m) n + f n % m) % m = (sumTo f n + f n) % m
      rw [Int.add_emod, ih, Int.emod_emod_of_dvd _ (Int.dvd_refl m), ← Int.add_emod]

/-- The telescope: the sum of the first `k+1` raw gaps collapses to
    endpoints minus the count. The "one telescoping induction" of the
    handoff, done once, for all rings. -/
theorem telescope (L : Nat) (hL : 0 < L) (s : Nat → Int) :
    ∀ k, k + 1 ≤ L →
      sumTo (rawGap L s) (k + 1) = s k - s (L - 1) - ((k : Int) + 1) := by
  intro k
  induction k with
  | zero =>
      intro _
      show 0 + (s 0 - s (prevIdx L 0) - 1) = s 0 - s (L - 1) - (((0 : Nat) : Int) + 1)
      rw [prevIdx_zero L hL]
      omega
  | succ k ih =>
      intro hk1
      have hk : k + 1 ≤ L := by omega
      have ht : k < L := by omega
      show sumTo (rawGap L s) (k + 1) + (s (k + 1) - s (prevIdx L (k + 1)) - 1)
          = s (k + 1) - s (L - 1) - (((k + 1 : Nat) : Int) + 1)
      rw [ih hk, prevIdx_succ L k ht]
      omega

/-- **P10, unbounded: conservation of error.** For EVERY modulus `m`,
    EVERY ring length `L ≥ 1`, and EVERY state `s : Nat → Int` — resting,
    thrashing, or arbitrary garbage far outside `[0, m)` — the total
    defect around the loop is `-L mod m`. The error total is a
    topological invariant of the wiring; no state can touch it.
    emergence_06 exhausted this at seven (m, L) pairs and sampled two
    more; this is all of them at once, over a strictly larger state
    space than Julia enumerates. -/
theorem defect_sum_invariant (m L : Nat) (hL : 0 < L) (s : Nat → Int) :
    sumTo (defect m L s) L % (m : Int) = (-(L : Int)) % (m : Int) := by
  have h1 : sumTo (defect m L s) L % (m : Int) = sumTo (rawGap L s) L % (m : Int) :=
    sumTo_emod (rawGap L s) (m : Int) L
  have hL1 : L - 1 + 1 = L := by omega
  have h2 := telescope L hL s (L - 1) (by omega)
  rw [hL1] at h2
  have h3 : s (L - 1) - s (L - 1) - (((L - 1 : Nat) : Int) + 1) = -(L : Int) := by
    omega
  rw [h1, h2, h3]

/-- The gauge witness: distance-from-`j` walking forward around the ring.
    Every equation holds on the nose except the one at edge `j`. -/
def gaugeState (L j : Nat) : Nat → Int :=
  fun i => if j ≤ i then ((i - j : Nat) : Int) else ((i + L - j : Nat) : Int)

theorem gauge_off (m L j : Nat) (hL : 0 < L) (_hj : j < L) :
    ∀ i, i < L → i ≠ j → defect m L (gaugeState L j) i = 0 := by
  intro i hi hij
  have hraw : rawGap L (gaugeState L j) i = 0 := by
    cases i with
    | zero =>
        have hj1 : 1 ≤ j := by omega
        show gaugeState L j 0 - gaugeState L j (prevIdx L 0) - 1 = 0
        rw [prevIdx_zero L hL]
        simp only [gaugeState]
        rw [if_neg (by omega : ¬ j ≤ 0), if_pos (by omega : j ≤ L - 1)]
        omega
    | succ t =>
        have ht : t < L := by omega
        show gaugeState L j (t + 1) - gaugeState L j (prevIdx L (t + 1)) - 1 = 0
        rw [prevIdx_succ L t ht]
        simp only [gaugeState]
        cases Nat.lt_or_ge t j with
        | inl hlt =>
            have h1 : t + 1 < j := by omega
            rw [if_neg (by omega : ¬ j ≤ t + 1), if_neg (by omega : ¬ j ≤ t)]
            omega
        | inr hge =>
            rw [if_pos (by omega : j ≤ t + 1), if_pos hge]
            omega
  show rawGap L (gaugeState L j) i % (m : Int) = 0
  rw [hraw]
  exact Int.zero_emod _

theorem gauge_at (m L j : Nat) (hL : 0 < L) (hj : j < L) :
    defect m L (gaugeState L j) j = (-(L : Int)) % (m : Int) := by
  have hraw : rawGap L (gaugeState L j) j = -(L : Int) := by
    cases j with
    | zero =>
        show gaugeState L 0 0 - gaugeState L 0 (prevIdx L 0) - 1 = -(L : Int)
        rw [prevIdx_zero L hL]
        simp only [gaugeState]
        rw [if_pos (Nat.le_refl 0), if_pos (Nat.zero_le _)]
        omega
    | succ t =>
        have ht : t < L := by omega
        show gaugeState L (t + 1) (t + 1) - gaugeState L (t + 1) (prevIdx L (t + 1)) - 1
            = -(L : Int)
        rw [prevIdx_succ L t ht]
        simp only [gaugeState]
        rw [if_pos (Nat.le_refl (t + 1)), if_neg (by omega : ¬ t + 1 ≤ t)]
        omega
  show rawGap L (gaugeState L j) j % (m : Int) = (-(L : Int)) % (m : Int)
  rw [hraw]

/-- **P11, unbounded: gauge freedom of blame.** For every edge `j` of every
    ring there is an explicit state whose ONLY nonzero defect is at `j`,
    carrying the entire charge `-L mod m`. WHERE truth breaks is a choice;
    THAT it breaks, and by how much, is a fact. Constructive witness —
    no search, no exhaustion. -/
theorem defect_gauge (m L : Nat) (hL : 0 < L) (j : Nat) (hj : j < L) :
    ∃ s : Nat → Int,
      (∀ i, i < L → i ≠ j → defect m L s i = 0) ∧
      defect m L s j = (-(L : Int)) % (m : Int) :=
  ⟨gaugeState L j, gauge_off m L j hL hj, gauge_at m L j hL hj⟩

/-- The charge vanishes exactly when the twist's order divides the loop. -/
theorem charge_zero_iff_dvd (m L : Nat) (hL : 0 < L) (s : Nat → Int) :
    sumTo (defect m L s) L % (m : Int) = 0 ↔ L % m = 0 := by
  rw [defect_sum_invariant m L hL s]
  constructor
  · intro h
    have hdvd : (m : Int) ∣ -(L : Int) := Int.dvd_of_emod_eq_zero h
    obtain ⟨k, hk⟩ := Int.dvd_neg.mp hdvd
    -- descend Int divisibility to Nat by |·| — avoids Classical.choice,
    -- which Int.natCast_dvd_natCast would smuggle into the ledger
    have habs := congrArg Int.natAbs hk
    rw [Int.natAbs_natCast, Int.natAbs_mul, Int.natAbs_natCast] at habs
    rw [habs, Nat.mul_mod_right]
  · intro h
    obtain ⟨k, hk⟩ := Nat.dvd_of_mod_eq_zero h
    refine Int.emod_eq_zero_of_dvd (Int.dvd_neg.mpr ⟨(k : Int), ?_⟩)
    rw [hk, Int.natCast_mul]

/-- **The refinement link, closed.** The ring rests iff the defect charge
    of ANY state — even one arbitrary garbage state — vanishes. This is
    the sense in which the charge strictly refines `succ_ring_rest_iff`:
    the kernel's binary verdict is the zero-fiber of an m-valued invariant
    that is measurable from inside any single state. -/
theorem rest_iff_charge_zero (m L : Nat) (hm : 0 < m) (hL : 0 < L) (s : Nat → Int) :
    (∃ t : Nat → Nat, IsFix m L t) ↔ sumTo (defect m L s) L % (m : Int) = 0 :=
  (succ_ring_rest_iff m L hm hL).trans (charge_zero_iff_dvd m L hL s).symm

/-- The charges emergence_06 §II printed, now corollaries for ALL states. -/
example (s : Nat → Int) : sumTo (defect 3 4 s) 4 % ((3:Nat):Int) = 2 := by
  rw [defect_sum_invariant 3 4 (by omega) s]; rfl
example (s : Nat → Int) : sumTo (defect 3 8 s) 8 % ((3:Nat):Int) = 1 := by
  rw [defect_sum_invariant 3 8 (by omega) s]; rfl
example (s : Nat → Int) : sumTo (defect 2 5 s) 5 % ((2:Nat):Int) = 1 := by
  rw [defect_sum_invariant 2 5 (by omega) s]; rfl
example (s : Nat → Int) : sumTo (defect 4 6 s) 6 % ((4:Nat):Int) = 2 := by
  rw [defect_sum_invariant 4 6 (by omega) s]; rfl
example (s : Nat → Int) : sumTo (defect 3 6 s) 6 % ((3:Nat):Int) = 0 := by
  rw [defect_sum_invariant 3 6 (by omega) s]; rfl

/- ============================================================
   SECTION 3 — THE GRAPH-GENERAL CHARGE FORMULA (★), the move
   emergence_07 left named and emergence_08's residue lists as
   unclaimed. Julia derived (★) on paper and exhausted it at
   fixed worlds; these theorems close it for EVERY finite wiring
   `inputs : Nat → List Nat` (marks 0..n-1, arbitrary in-lists,
   arbitrary multiplicity), EVERY modulus, EVERY state in ℤ.
   Consequences proven, not sampled:
     • charge_conserved_of_outdeg_one — _07's P12, conserved
       direction: out-degree 1 everywhere ⟹ charge ≡ −n for
       every state. Conservation is an out-degree property, for
       ALL wirings at once — not just disjoint rings.
     • charge_dial — _07's P13, generalized: ONE mark of
       out-degree 2, the rest 1 ⟹ charge ≡ −(s j₀) − n. The
       dial law holds for every "one shared mark" topology,
       not just fig8(L1,L2).
     • ring_gRaw_eq / Section 2 recovered — the ring is the
       permutation case; defect_sum_invariant transfers along a
       pointwise equality of raw gaps.
   ============================================================ -/

/-- Sum of a list of integers. -/
def lsum : List Int → Int
  | [] => 0
  | a :: t => a + lsum t

/-- Multiplicity of mark `j` in an input list. -/
def cnt (j : Nat) : List Nat → Nat
  | [] => 0
  | a :: t => (if a = j then 1 else 0) + cnt j t

/-- Out-degree of mark `j` in the wiring `inputs` over marks `0..n-1`:
    how many times `j` is listened to, counted with multiplicity. -/
def outdegI (inputs : Nat → List Nat) (n j : Nat) : Int :=
  sumTo (fun i => (cnt j (inputs i) : Int)) n

/-- Raw gap at mark `i` under the sum-combiner and succ-twist:
    emergence_07's `s[i] − Σ s[inputs[i]] − 1` before the mod. -/
def gRaw (inputs : Nat → List Nat) (s : Nat → Int) (i : Nat) : Int :=
  s i - lsum ((inputs i).map s) - 1

/-- The defect at mark `i` of a general wiring. -/
def gDefect (m : Nat) (inputs : Nat → List Nat) (s : Nat → Int) (i : Nat) : Int :=
  gRaw inputs s i % (m : Int)

/- ---- sumTo algebra (base library only, everything by induction) ---- -/

theorem sumTo_congr_lt (f g : Nat → Int) :
    ∀ n, (∀ i, i < n → f i = g i) → sumTo f n = sumTo g n := by
  intro n
  induction n with
  | zero => intro _; rfl
  | succ n ih =>
      intro h
      show sumTo f n + f n = sumTo g n + g n
      rw [ih (fun i hi => h i (by omega)), h n (by omega)]

theorem sumTo_add (f g : Nat → Int) :
    ∀ n, sumTo (fun i => f i + g i) n = sumTo f n + sumTo g n := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih =>
      show sumTo (fun i => f i + g i) n + (f n + g n)
          = (sumTo f n + f n) + (sumTo g n + g n)
      rw [ih]; omega

theorem sumTo_sub (f g : Nat → Int) :
    ∀ n, sumTo (fun i => f i - g i) n = sumTo f n - sumTo g n := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih =>
      show sumTo (fun i => f i - g i) n + (f n - g n)
          = (sumTo f n + f n) - (sumTo g n + g n)
      rw [ih]; omega

theorem sumTo_const_zero : ∀ n, sumTo (fun _ => (0 : Int)) n = 0 := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih =>
      show sumTo (fun _ => (0 : Int)) n + 0 = 0
      rw [ih]; rfl

theorem sumTo_const_one : ∀ n, sumTo (fun _ => (1 : Int)) n = (n : Int) := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih =>
      show sumTo (fun _ => (1 : Int)) n + 1 = ((n + 1 : Nat) : Int)
      rw [ih]; omega

theorem sumTo_mul_right (f : Nat → Int) (x : Int) :
    ∀ n, sumTo (fun i => f i * x) n = sumTo f n * x := by
  intro n
  induction n with
  | zero => show (0 : Int) = 0 * x; rw [Int.zero_mul]
  | succ n ih =>
      show sumTo (fun i => f i * x) n + f n * x = (sumTo f n + f n) * x
      rw [ih, Int.add_mul]

/-- Fubini for finite double sums: the interchange that makes (★) one
    telescoping computation instead of a per-graph argument. -/
theorem sumTo_swap (G : Nat → Nat → Int) (n : Nat) :
    ∀ N, sumTo (fun i => sumTo (G i) n) N
        = sumTo (fun j => sumTo (fun i => G i j) N) n := by
  intro N
  induction N with
  | zero =>
      show (0 : Int) = sumTo (fun j => sumTo (fun i => G i j) 0) n
      rw [sumTo_congr_lt (fun j => sumTo (fun i => G i j) 0) (fun _ => (0 : Int))
            n (fun _ _ => rfl), sumTo_const_zero]
  | succ N ih =>
      show sumTo (fun i => sumTo (G i) n) N + sumTo (G N) n
          = sumTo (fun j => sumTo (fun i => G i j) (N + 1)) n
      rw [ih, ← sumTo_add]
      exact sumTo_congr_lt _ _ n (fun j _ => rfl)

/-- Kronecker sums: a delta-weighted sum picks out one term. -/
theorem kron_zero (a : Nat) (s : Nat → Int) :
    ∀ N, ¬ a < N → sumTo (fun j => (if a = j then (1 : Int) else 0) * s j) N = 0 := by
  intro N
  induction N with
  | zero => intro _; rfl
  | succ N ih =>
      intro h
      show sumTo (fun j => (if a = j then (1 : Int) else 0) * s j) N
            + (if a = N then (1 : Int) else 0) * s N = 0
      rw [ih (by omega), if_neg (by omega : ¬ a = N), Int.zero_mul]
      rfl

theorem kron (a : Nat) (s : Nat → Int) :
    ∀ N, a < N → sumTo (fun j => (if a = j then (1 : Int) else 0) * s j) N = s a := by
  intro N
  induction N with
  | zero => intro h; exact absurd h (Nat.not_lt_zero a)
  | succ N ih =>
      intro h
      show sumTo (fun j => (if a = j then (1 : Int) else 0) * s j) N
            + (if a = N then (1 : Int) else 0) * s N = s a
      cases Nat.lt_or_ge a N with
      | inl hlt => rw [ih hlt, if_neg (by omega : ¬ a = N), Int.zero_mul, Int.add_zero]
      | inr _ =>
          have ha : a = N := by omega
          rw [kron_zero a s N (by omega), if_pos ha, Int.one_mul, Int.zero_add, ha]

/-- A list-sum of states equals the multiplicity-weighted sum over all
    marks, provided the list stays below `n`. -/
theorem lsum_eq_weighted (s : Nat → Int) (n : Nat) :
    ∀ l : List Nat, (∀ j, j ∈ l → j < n) →
      lsum (l.map s) = sumTo (fun j => (cnt j l : Int) * s j) n := by
  intro l
  induction l with
  | nil =>
      intro _
      show (0 : Int) = sumTo (fun j => ((0 : Nat) : Int) * s j) n
      rw [sumTo_congr_lt (fun j => ((0 : Nat) : Int) * s j) (fun _ => (0 : Int))
            n (fun j _ => by rw [Int.natCast_zero, Int.zero_mul]), sumTo_const_zero]
  | cons a t ih =>
      intro hmem
      show s a + lsum (t.map s) = sumTo (fun j => (cnt j (a :: t) : Int) * s j) n
      have ht : ∀ j, j ∈ t → j < n := fun j hj => hmem j (List.mem_cons_of_mem a hj)
      have ha : a < n := hmem a List.mem_cons_self
      have hsplit : ∀ j, (cnt j (a :: t) : Int) * s j
          = (if a = j then (1 : Int) else 0) * s j + (cnt j t : Int) * s j := by
        intro j
        show ((if a = j then 1 else 0) + cnt j t : Nat) * s j = _
        by_cases h : a = j
        · rw [if_pos h, if_pos h]
          show ((1 + cnt j t : Nat) : Int) * s j = 1 * s j + (cnt j t : Int) * s j
          rw [Int.natCast_add, Int.add_mul, Int.natCast_one]
        · rw [if_neg h, if_neg h]
          show ((0 + cnt j t : Nat) : Int) * s j = 0 * s j + (cnt j t : Int) * s j
          rw [Nat.zero_add, Int.zero_mul, Int.zero_add]
      rw [sumTo_congr_lt _ _ n (fun j _ => hsplit j), sumTo_add, ih ht, kron a s n ha]

/-- **(★), raw form.** For any wiring whose input lists stay below `n`,
    the total raw gap telescopes to the out-degree-weighted sum:
    `Σᵢ gRaw i = Σⱼ (1 − outdeg j)·s j − n`. emergence_07 derived this
    on paper and exhausted it at m ∈ 2..4 on five worlds; this is every
    world, every state, no modulus even needed yet. -/
theorem charge_formula_raw (inputs : Nat → List Nat) (n : Nat)
    (hbound : ∀ i, i < n → ∀ j ∈ inputs i, j < n) (s : Nat → Int) :
    sumTo (gRaw inputs s) n
      = sumTo (fun j => (1 - outdegI inputs n j) * s j) n - (n : Int) := by
  have step1 : sumTo (gRaw inputs s) n
      = sumTo s n - sumTo (fun i => lsum ((inputs i).map s)) n - (n : Int) := by
    have h1 : sumTo (gRaw inputs s) n
        = sumTo (fun i => (s i - lsum ((inputs i).map s)) - 1) n :=
      sumTo_congr_lt _ _ n (fun i _ => rfl)
    rw [h1, sumTo_sub (fun i => s i - lsum ((inputs i).map s)) (fun _ => (1 : Int)),
        sumTo_sub s (fun i => lsum ((inputs i).map s)), sumTo_const_one]
  have step2 : sumTo (fun i => lsum ((inputs i).map s)) n
      = sumTo (fun i => sumTo (fun j => (cnt j (inputs i) : Int) * s j) n) n :=
    sumTo_congr_lt _ _ n (fun i hi => lsum_eq_weighted s n (inputs i) (hbound i hi))
  have step3 : sumTo (fun i => sumTo (fun j => (cnt j (inputs i) : Int) * s j) n) n
      = sumTo (fun j => outdegI inputs n j * s j) n := by
    rw [sumTo_swap (fun i j => (cnt j (inputs i) : Int) * s j) n n]
    exact sumTo_congr_lt _ _ n
      (fun j _ => sumTo_mul_right (fun i => (cnt j (inputs i) : Int)) (s j) n)
  have step4 : sumTo s n - sumTo (fun j => outdegI inputs n j * s j) n
      = sumTo (fun j => (1 - outdegI inputs n j) * s j) n := by
    rw [← sumTo_sub s (fun j => outdegI inputs n j * s j)]
    exact sumTo_congr_lt _ _ n (fun j _ => by
      rw [Int.sub_mul, Int.one_mul])
  rw [step1, step2, step3]
  omega

/-- **(★) mod m** — the defect-charge of any finite wiring. -/
theorem charge_formula (m : Nat) (inputs : Nat → List Nat) (n : Nat)
    (hbound : ∀ i, i < n → ∀ j ∈ inputs i, j < n) (s : Nat → Int) :
    sumTo (gDefect m inputs s) n % (m : Int)
      = (sumTo (fun j => (1 - outdegI inputs n j) * s j) n - (n : Int)) % (m : Int) := by
  have h := sumTo_emod (gRaw inputs s) (m : Int) n
  -- gDefect is definitionally (fun i => gRaw inputs s i % m)
  show sumTo (fun i => gRaw inputs s i % (m : Int)) n % (m : Int) = _
  rw [h, charge_formula_raw inputs n hbound s]

/-- **P12, conserved direction, for ALL wirings**: out-degree 1
    everywhere ⟹ the charge is `−n mod m` for EVERY state. This is why
    disjoint rings conserve: they are out-degree-one wirings — but so is
    every permutation wiring, proven here at once. -/
theorem charge_conserved_of_outdeg_one (m : Nat) (inputs : Nat → List Nat) (n : Nat)
    (hbound : ∀ i, i < n → ∀ j ∈ inputs i, j < n)
    (hod : ∀ j, j < n → outdegI inputs n j = 1) (s : Nat → Int) :
    sumTo (gDefect m inputs s) n % (m : Int) = (-(n : Int)) % (m : Int) := by
  rw [charge_formula m inputs n hbound s]
  have hz : sumTo (fun j => (1 - outdegI inputs n j) * s j) n = 0 := by
    rw [sumTo_congr_lt (fun j => (1 - outdegI inputs n j) * s j) (fun _ => (0 : Int)) n
          (fun j hj => by rw [hod j hj]; omega), sumTo_const_zero]
  rw [hz]
  have : (0 : Int) - (n : Int) = -(n : Int) := by omega
  rw [this]

/-- **P13, generalized — the dial law.** ONE mark `j₀` of out-degree 2,
    every other mark out-degree 1 ⟹ the charge is `−(s j₀) − n mod m`:
    read off the shared mark, tunable through every residue class.
    emergence_07 verified this for fig8(L1,L2) at six (m,L1,L2) tuples;
    this is every "one shared mark" wiring — any two structures sharing
    any single mark, any lengths, any topology elsewhere. -/
theorem charge_dial (m : Nat) (inputs : Nat → List Nat) (n j₀ : Nat)
    (hbound : ∀ i, i < n → ∀ j ∈ inputs i, j < n) (hj₀ : j₀ < n)
    (hod2 : outdegI inputs n j₀ = 2)
    (hod1 : ∀ j, j < n → j ≠ j₀ → outdegI inputs n j = 1) (s : Nat → Int) :
    sumTo (gDefect m inputs s) n % (m : Int)
      = (-(s j₀) - (n : Int)) % (m : Int) := by
  rw [charge_formula m inputs n hbound s]
  have hpick : sumTo (fun j => (1 - outdegI inputs n j) * s j) n = -(s j₀) := by
    have hshape : ∀ j, j < n → (1 - outdegI inputs n j) * s j
        = (if j₀ = j then (1 : Int) else 0) * (-(s j)) := by
      intro j hj
      by_cases h : j₀ = j
      · rw [if_pos h, ← h, hod2]; omega
      · rw [if_neg h, hod1 j hj (fun he => h he.symm)]; omega
    rw [sumTo_congr_lt _ _ n hshape, kron j₀ (fun j => -(s j)) n hj₀]
  rw [hpick]

/-- **Section 2 recovered.** The ring is the out-degree-one case: on the
    ring wiring `i ↦ [prevIdx L i]`, the general raw gap IS Section 2's
    `rawGap`, pointwise — so `defect_sum_invariant` is an instance of the
    graph-general machinery, as _07 predicted ("its permutation case"). -/
theorem ring_gRaw_eq (L : Nat) (s : Nat → Int) (i : Nat) :
    gRaw (fun k => [prevIdx L k]) s i = rawGap L s i := by
  show s i - (s (prevIdx L i) + 0) - 1 = s i - s (prevIdx L i) - 1
  omega

theorem ring_charge_via_general (m L : Nat) (hL : 0 < L) (s : Nat → Int) :
    sumTo (gDefect m (fun k => [prevIdx L k]) s) L % (m : Int)
      = (-(L : Int)) % (m : Int) := by
  have h : sumTo (gDefect m (fun k => [prevIdx L k]) s) L
      = sumTo (defect m L s) L :=
    sumTo_congr_lt _ _ L (fun i _ => by
      show gRaw (fun k => [prevIdx L k]) s i % (m : Int) = rawGap L s i % (m : Int)
      rw [ring_gRaw_eq])
  rw [h, defect_sum_invariant m L hL s]

/-- The concrete figure-eight emergence_05/_07 exhausted — fig8(2,3),
    0-based: mark 0 listens to the two loop tails {1, 3}; the wiring
    facts are discharged by `decide`, the law by `charge_dial`. For ALL
    states and (here) m = 3: charge ≡ −(s₀) − 4. -/
def fig8_23 : Nat → List Nat :=
  fun i => if i = 0 then [1, 3] else if i = 1 then [0]
           else if i = 2 then [0] else if i = 3 then [2] else []

example (s : Nat → Int) :
    sumTo (gDefect 3 fig8_23 s) 4 % (3 : Int) = (-(s 0) - 4) % (3 : Int) :=
  charge_dial 3 fig8_23 4 0
    (by decide) (by omega) (by decide) (by decide) s

end RingRest

-- ============ AXIOM AUDIT (the receipts) ============
#print axioms RingRest.chain
#print axioms RingRest.rest_imp_dvd
#print axioms RingRest.dvd_imp_rest
#print axioms RingRest.succ_ring_rest_iff
#print axioms RingRest.rest_of_twist_fixed
#print axioms RingRest.neg_world_rest
#print axioms RingRest.telescope
#print axioms RingRest.defect_sum_invariant
#print axioms RingRest.defect_gauge
#print axioms RingRest.charge_zero_iff_dvd
#print axioms RingRest.rest_iff_charge_zero
#print axioms RingRest.charge_formula_raw
#print axioms RingRest.charge_formula
#print axioms RingRest.charge_conserved_of_outdeg_one
#print axioms RingRest.charge_dial
#print axioms RingRest.ring_charge_via_general
