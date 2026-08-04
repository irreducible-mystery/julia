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
   families, so that luxury is gone. The audit lines at the bottom
   print the exact ledger; verify.sh-style honesty: read them.
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

end RingRest

-- ============ AXIOM AUDIT (the receipts) ============
#print axioms RingRest.chain
#print axioms RingRest.rest_imp_dvd
#print axioms RingRest.dvd_imp_rest
#print axioms RingRest.succ_ring_rest_iff
#print axioms RingRest.rest_of_twist_fixed
#print axioms RingRest.neg_world_rest
