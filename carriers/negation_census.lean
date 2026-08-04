/- negation_census.lean — NEGATION, carried into the kernel (Lean half).

   The Elixir and Rust halves found that a host's negation is classified by
   whether it PROPAGATES or COERCES its third value, and that this decides
   involutivity. Lean answers the question the runtimes can only gesture at:
   *which half of classical negation does the host actually drop, and what
   does it cost to get it back?* The `#print axioms` ledger is the receipt —
   this repo's own discipline, applied to negation itself.

   The finding: ONE HOST CARRIES TWO NEGATIONS with different logics.
   `Bool`'s `!` is involutive and free. `Prop`'s `¬` is neither — and the
   ledger names the exact price of each classical law.

   No imports. Run:  lean carriers/negation_census.lean
-/

namespace NegCensus

/-! ## Bool: negation is an involution, and it is free. -/

theorem bool_dne (b : Bool) : (!(!b)) = b := by cases b <;> rfl
theorem bool_lem (b : Bool) : (b || !b) = true := by cases b <;> rfl
/-- Exactly the fixed-point count the runtimes measured: zero. -/
theorem bool_no_fixed_point (b : Bool) : (!b) ≠ b := by cases b <;> simp

/-! ## Prop: BOTH classical laws are purchased, and the ledger prints the bill. -/

theorem prop_dne (P : Prop) : ¬¬P → P := fun h => Classical.byContradiction h
theorem prop_lem (P : Prop) : P ∨ ¬P := Classical.em P

/-! ## What IS free constructively — and it is exactly the one-way half.

    You may always ADD a double negation, and you may always collapse THREE
    negations to one. What you may not do is REMOVE two. So intuitionistic
    negation is not involutive but it IS eventually constant: the orbit
    ¬P, ¬¬P, ¬¬¬P, … stabilises from the third step on.

    That is the same shape the Elixir half measured for a COERCING `!`,
    which stabilises from the second step on (`¬³nil = ¬nil`). Two very
    different hosts, one structure: a negation that is not an involution is
    a negation whose orbit collapses to a fixed tail. The involutive
    negations (Bool here, SQL's K3 NOT, a propagating `Option::map`) have
    orbits of period 2; the non-involutive ones (Prop, Elixir's `!`) have
    orbits that stop moving. Period-2 versus eventually-constant is the
    classification the whole census was circling. -/

theorem prop_dni (P : Prop) : P → ¬¬P := fun p np => np p
theorem prop_tne (P : Prop) : ¬¬¬P → ¬P := fun h p => h (fun np => np p)
/-- The other direction of triple negation is free too: the orbit really is
    stationary from step 3, not merely shrinking. -/
theorem prop_tni (P : Prop) : ¬P → ¬¬¬P := fun np h => h np

/-! ## The asymmetry, stated once: ¬¬ is a closure operator on Prop.
    Monotone (not stated here), inflationary (`prop_dni`), and idempotent —
    `¬¬¬¬P ↔ ¬¬P`, provable with no axioms at all. Classical logic is the
    assumption that this closure is the identity. -/

theorem prop_dn_idempotent (P : Prop) : (¬¬¬¬P) ↔ (¬¬P) :=
  ⟨fun h => fun np => h (fun k => k np), fun h => fun k => k h⟩

end NegCensus

/- ============ THE LEDGER (the receipts) ============
   Expected, and the point of the file:
     bool_*            — no axioms. Involutive negation is free.
     prop_dni/tne/tni  — no axioms. The one-way half is free.
     prop_dn_idempotent— no axioms. The closure is free.
     prop_dne/prop_lem — Classical.choice. Both classical laws are purchased,
                         and at the SAME price: in Lean neither DNE nor LEM is
                         cheaper than the other. Contrast SQL's K3, which gets
                         DNE for nothing and cannot buy LEM at all.
   ================================================== -/
#print axioms NegCensus.bool_dne
#print axioms NegCensus.bool_lem
#print axioms NegCensus.bool_no_fixed_point
#print axioms NegCensus.prop_dni
#print axioms NegCensus.prop_tne
#print axioms NegCensus.prop_tni
#print axioms NegCensus.prop_dn_idempotent
#print axioms NegCensus.prop_dne
#print axioms NegCensus.prop_lem
