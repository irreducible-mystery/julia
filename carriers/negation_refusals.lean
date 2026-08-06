/- negation_refusals.lean — CAN `#guard_msgs` BE POINTED AT A NEGATION?

   I asked this on julia3claude PR #2, whose `Expressibility.lean` uses
   `#guard_msgs` to turn REJECTIONS into build-checked artifacts. The axiom
   ledger prices what you CAN prove; rejection-capture is the only instrument
   in these three repos that certifies what you CANNOT. Negation looked like
   the place to point it. Kelly asked me to go find out, so this file is the
   answer, with every claim run rather than reasoned.

   The answer is FOUR-LAYERED, and one layer is a correction of my own guess.

   ── (a) YES, for the fixed point. ────────────────────────────────────────
   The Liar type — a proposition that IS its own negation — is refused by the
   KERNEL on strict positivity. My runtime censuses could only ENUMERATE a
   three-element domain and report "zero fixed points." Lean refuses to let
   the object be formed at all. That is a genuine negative certificate about
   negation, and it is capturable.

   ── (b) YES, for classical reasoning in DATA position. ───────────────────
   `Classical.propDecidable` cannot produce a `Bool`. The compiler refuses and
   NAMES the culprit. With a decidable proposition the identical shape
   compiles and runs (control below). So "the classical negation cannot
   compute" is a build-checked artifact.

   ── (b′) NO — and this one corrects me. ──────────────────────────────────
   I guessed that `#eval` on a `Classical.byContradiction` witness would be a
   certificate about DNE. It is not. `#eval` on `trivial : True` is refused
   with the SAME message: proofs are erased, classical or not. That refusal is
   about `Prop`, and says nothing whatever about negation. Probe recorded
   below so the false lead stays visible.

   ── (c) NOT NEEDED, for the fixed point as a theorem. ────────────────────
   `¬(P ↔ ¬P)` is provable with ZERO axioms, for EVERY proposition. Lean does
   not need a rejection to say negation has no fixed point — it proves it
   outright, unbounded, where SQL/Elixir/Rust enumerated three values.

   ── (d) NO, for the thing I actually asked. ──────────────────────────────
   There is no `#guard_msgs` formulation whose captured rejection means
   "double-negation elimination is not derivable here." A captured error is
   the elaborator's verdict on ONE EXPRESSION; underivability is a claim about
   the EMPTINESS OF A SEARCH SPACE. Rejecting a candidate is not proving
   nonexistence — `#guard_msgs` in that use would be exactly the instrument
   this thread keeps convicting: a check that cannot fail for the reason it
   claims. Certifying underivability needs a model construction, i.e.
   metatheory, which is a different artifact and not this tool.

   THE SHAPE: rejection-capture certifies "this cannot be BUILT." It cannot
   certify "this cannot be PROVED." Those differ exactly where the census's
   ∃/∀ line falls — the same line the very first translation ran into.

   Run:  lean carriers/negation_refusals.lean      (exit 0 iff every pinned
   message matches; a changed compiler message is a FAILURE, by design)
-/

/-! ## (a) The fixed point of negation cannot be constructed -/

/--
error: (kernel) arg #1 of 'Liar.mk' has a non positive occurrence of the datatypes being declared
-/
#guard_msgs in
inductive Liar : Prop where
  | mk : (Liar → False) → Liar

/-- CONTROL: the same shape with the arrow the other way is accepted, so the
    rejection above is about NEGATIVE occurrence, not about self-reference. -/
inductive Fine : Prop where
  | mk : (False → Fine) → Fine

/-! ## (b) Classical reasoning cannot produce data -/

/--
error: failed to compile definition, consider marking it as 'noncomputable' because it depends on 'Classical.propDecidable', which is 'noncomputable'
-/
#guard_msgs in
def oracle (P : Prop) : Bool := @ite Bool P (Classical.propDecidable P) true false

/-- CONTROL: identical shape, decidable proposition — compiles and runs. -/
def decidableVersion (n : Nat) : Bool := @ite Bool (n = 0) (Nat.decEq n 0) true false

/-- info: true -/
#guard_msgs in
#eval decidableVersion 0

/-! ## (b′) The false lead, kept visible: `#eval` refusal is about `Prop`,
    not about DNE. A constructive proof is refused with the same message. -/

theorem constructiveProof : True := trivial

/-- error: Cannot evaluate, proofs are not computationally relevant -/
#guard_msgs in
#eval constructiveProof

/-! ## (c) What needs no rejection at all -/

/-- Negation has no fixed point — for EVERY proposition, with no axioms.
    The runtimes enumerated {true, false, nil} and counted. This quantifies
    over all of `Prop`. -/
theorem no_fixed_point (P : Prop) : ¬(P ↔ ¬P) := by
  intro h
  have np : ¬P := fun p => (h.mp p) p
  exact np (h.mpr np)

/-- And the orbit result the census measured by hand, proved: the negation
    orbit on `Prop` is stationary from step three. -/
theorem orbit_stabilises (P : Prop) : (¬¬¬P) ↔ (¬P) :=
  ⟨fun h p => h (fun np => np p), fun np h => h np⟩

#print axioms no_fixed_point
#print axioms orbit_stabilises
