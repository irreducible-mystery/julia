/- ============================================================
   RingRest.lean — emergence_04 §IV, promoted from evidence to proof.

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
