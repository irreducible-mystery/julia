/- ============================================================
   Recurrence.lean — PR #5's "found fact," promoted to theorem.

   blackhole_in_my_state_space.jl P6 FOUND (its word) that the
   Feistel hole's radiation recurs at L = 15250 and that the same
   χ² court which acquits the stream below recurrence convicts it
   above. The file registered this as an empirical discovery
   ("my toy found this on its own; I did not put it in").

   It was never contingent. These theorems close it for EVERY
   finite deterministic system at once:

     • orbit_collision — any dynamics on a state space of size n
       collides with itself within n steps (pigeonhole, proven
       from scratch — no Mathlib, no Finset, no cardinality
       library: the counting is done by explicit induction).
     • eventually_periodic — hence every trajectory is lasso-
       shaped: preperiod + cycle, with cycle length ≤ n.
     • injective_recurrence — if the dynamics is a bijection
       (Feistel is; audited by injectivity sweep in
       audit_pr5_by_stranger.jl), the lasso has no tail: the
       orbit returns to its STARTING point. Poincaré recurrence
       for finite reversible systems, in four lines of descent.
     • emission_periodic — whatever you EMIT from the orbit
       (any observable, e.g. "low byte") inherits the period.
       Thermality of a finite reversible hole has an expiration
       date ≤ its state count — for every scrambler, every
       observable, every starting state, not just Feistel at
       seed 0x0007.

   The division of labor, stated exactly: the kernel proves the
   stream MUST repeat with period ≤ 65536; which period (15250),
   and that χ² convicts at 13×L — those are census facts, Julia's
   court. Existence is the theorem; the date on the expiration
   stamp is the measurement.

   Axiom ledger printed below. No imports.
   ============================================================ -/

namespace Recurrence

/-- `iter f k x` — the k-th step of the dynamics `f` from `x`. -/
def iter (f : Nat → Nat) : Nat → Nat → Nat
  | 0,     x => x
  | k + 1, x => f (iter f k x)

/-- **Pigeonhole, from scratch.** If `g` maps `{0..n}` (that is n+1
    values) into `{0..n-1}` (n values), two inputs collide. Induction:
    either something ≤ n already collides with `g (n+1)`, or we repair
    `g` into a map on one fewer pigeon and recurse. -/
theorem pigeonhole : ∀ (n : Nat) (g : Nat → Nat),
    (∀ i, i ≤ n → g i < n) → ∃ i j, i < j ∧ j ≤ n ∧ g i = g j := by
  intro n
  induction n with
  | zero =>
      intro g hg
      exact absurd (hg 0 (Nat.le_refl 0)) (Nat.not_lt_zero _)
  | succ n ih =>
      intro g hg
      by_cases hcase : ∃ i, i ≤ n ∧ g i = g (n + 1)
      · obtain ⟨i, hi, heq⟩ := hcase
        exact ⟨i, n + 1, by omega, Nat.le_refl _, heq⟩
      · -- no i ≤ n hits g (n+1); repair the top value n down to g (n+1)
        have hne : ∀ i, i ≤ n → g i ≠ g (n + 1) := by
          intro i hi hcontra
          exact hcase ⟨i, hi, hcontra⟩
        have hgtop : g (n + 1) < n + 1 := hg (n + 1) (Nat.le_refl _)
        have hbound : ∀ i, i ≤ n → (fun i => if g i = n then g (n + 1) else g i) i < n := by
          intro i hi
          show (if g i = n then g (n + 1) else g i) < n
          by_cases htop : g i = n
          · rw [if_pos htop]
            -- g (n+1) < n+1 and g (n+1) ≠ g i = n, so g (n+1) < n
            have : g (n + 1) ≠ n := fun he => hne i hi (by rw [htop, he])
            omega
          · rw [if_neg htop]
            have : g i < n + 1 := hg i (by omega)
            omega
        obtain ⟨i, j, hij, hjn, heq⟩ :=
          ih (fun i => if g i = n then g (n + 1) else g i) hbound
        -- unpack the repair
        have hi : i ≤ n := by omega
        have heq' : (if g i = n then g (n + 1) else g i)
                  = (if g j = n then g (n + 1) else g j) := heq
        by_cases hgi : g i = n <;> by_cases hgj : g j = n
        · exact ⟨i, j, hij, by omega, by rw [hgi, hgj]⟩
        · rw [if_pos hgi, if_neg hgj] at heq'
          exact absurd heq'.symm (hne j hjn)
        · rw [if_neg hgi, if_pos hgj] at heq'
          exact absurd heq' (hne i hi)
        · rw [if_neg hgi, if_neg hgj] at heq'
          exact ⟨i, j, hij, by omega, heq'⟩

/-- **Every finite orbit collides within n steps.** If the dynamics
    keeps states below `n`, then among the first `n+1` orbit points two
    are equal — with indices ≤ n. This is P6's existence claim with the
    constants stripped: no Feistel, no keys, no seed. -/
theorem orbit_collision (f : Nat → Nat) (n : Nat) (_hn : 0 < n)
    (hf : ∀ x, x < n → f x < n) (x0 : Nat) (hx0 : x0 < n) :
    ∃ i j, i < j ∧ j ≤ n ∧ iter f i x0 = iter f j x0 := by
  have horbit : ∀ k, iter f k x0 < n := by
    intro k
    induction k with
    | zero => exact hx0
    | succ k ih => exact hf _ ih
  have hg : ∀ i, i ≤ n → iter f i x0 < n := fun i _ => horbit i
  exact pigeonhole n (fun i => iter f i x0) hg

/-- Iterates compose: step `a + b` is step `a` after step `b`. -/
theorem iter_add (f : Nat → Nat) (a b : Nat) (x : Nat) :
    iter f (a + b) x = iter f a (iter f b x) := by
  induction a with
  | zero => rw [Nat.zero_add]; rfl
  | succ a ih =>
      have hidx : a + 1 + b = (a + b) + 1 := by omega
      rw [hidx]
      show f (iter f (a + b) x) = f (iter f a (iter f b x))
      rw [ih]

/-- **Lasso shape.** After the collision the orbit is periodic: there
    is a phase `i` and a period `p` with `0 < p ≤ n` such that from
    phase `i` on, advancing `p` steps returns the same state — and
    hence so does advancing any multiple of `p`. -/
theorem eventually_periodic (f : Nat → Nat) (n : Nat) (hn : 0 < n)
    (hf : ∀ x, x < n → f x < n) (x0 : Nat) (hx0 : x0 < n) :
    ∃ i p, 0 < p ∧ p ≤ n ∧
      ∀ k, iter f (i + k + p) x0 = iter f (i + k) x0 := by
  obtain ⟨i, j, hij, hjn, heq⟩ := orbit_collision f n hn hf x0 hx0
  refine ⟨i, j - i, by omega, by omega, ?_⟩
  intro k
  have h1 : i + k + (j - i) = k + j := by omega
  have h2 : i + k = k + i := by omega
  rw [h1, h2, iter_add f k j x0, iter_add f k i x0, heq]

/-- Injective dynamics cancel: equal images at height `k+1` force
    equal states at height `k`. -/
theorem iter_cancel (f : Nat → Nat) (hinj : ∀ a b, f a = f b → a = b) :
    ∀ i j x, iter f (i + 1) x = iter f (j + 1) x → iter f i x = iter f j x :=
  fun _ _ _ h => hinj _ _ h

/-- **Poincaré recurrence, finite reversible case.** If `f` is
    injective (every bijection is), the lasso has NO tail: the orbit
    returns exactly to `x0`, with period `0 < p ≤ n`. PR #5's Feistel
    hole is injective (a Feistel network is a bijection by
    construction; audited empirically in audit_pr5_by_stranger.jl),
    so its radiation was ALWAYS going to repeat — the theorem holds
    before any census runs. -/
theorem injective_recurrence (f : Nat → Nat) (n : Nat) (hn : 0 < n)
    (hf : ∀ x, x < n → f x < n) (hinj : ∀ a b, f a = f b → a = b)
    (x0 : Nat) (hx0 : x0 < n) :
    ∃ p, 0 < p ∧ p ≤ n ∧ iter f p x0 = x0 := by
  obtain ⟨i, j, hij, hjn, heq⟩ := orbit_collision f n hn hf x0 hx0
  -- peel i applications off both sides by injectivity
  have peel : ∀ i j, iter f i x0 = iter f (i + j) x0 → x0 = iter f j x0 := by
    intro i
    induction i with
    | zero =>
        intro j h
        rw [Nat.zero_add] at h
        exact h
    | succ i ih =>
        intro j h
        have hshape : i + 1 + j = (i + j) + 1 := by omega
        rw [hshape] at h
        exact ih j (iter_cancel f hinj i (i + j) x0 h)
  have hsplit : j = i + (j - i) := by omega
  rw [hsplit] at heq
  exact ⟨j - i, by omega, by omega, (peel i (j - i) heq).symm⟩

/-- **The emitted stream inherits the period.** Any observable `obs`
    of the state (PR #5 emits the low byte) repeats with the orbit's
    period. "A finite-state hole cannot stay thermal forever" is not
    a property of Feistel networks or of χ²: it is this theorem. The
    expiration date e^S exists for every finite reversible scrambler,
    every observable, every start. -/
theorem emission_periodic (f : Nat → Nat) (obs : Nat → Nat) (n : Nat)
    (hn : 0 < n) (hf : ∀ x, x < n → f x < n)
    (hinj : ∀ a b, f a = f b → a = b) (x0 : Nat) (hx0 : x0 < n) :
    ∃ p, 0 < p ∧ p ≤ n ∧
      ∀ k, obs (iter f (k + p) x0) = obs (iter f k x0) := by
  obtain ⟨p, hp, hpn, hret⟩ := injective_recurrence f n hn hf hinj x0 hx0
  refine ⟨p, hp, hpn, fun k => ?_⟩
  rw [iter_add f k p x0, hret]

end Recurrence

-- ============ AXIOM AUDIT (the receipts) ============
#print axioms Recurrence.pigeonhole
#print axioms Recurrence.orbit_collision
#print axioms Recurrence.eventually_periodic
#print axioms Recurrence.injective_recurrence
#print axioms Recurrence.emission_periodic
