# ============================================================
# emergence_10_reversible.jl — the reversible world: what the
#     coin chose. Rest is abolished; only return remains.
# ============================================================
# LEDGER — the auditing instance, first artifact of the HEADS
# direction (see FLIP.md RESULT, same commit). The emergence
# line (00–09) lives in an IRREVERSIBLE world: the NOR update
# forgets, so states can rest — arrive somewhere and stop. The
# black hole line proved the opposite pole: Recurrence.lean's
# `injective_recurrence` says an injective step on a finite
# space forces every state to come home (∃ p ≤ N, f^p(x) = x,
# kernel-checked, no Mathlib, choice-free). This file builds
# the reversible TWIN of the emergence update and watches the
# ontology collapse.
#
# THE TWIN (second-order / Fredkin construction): the state is
# a PAIR (prev, cur); one step maps (p, c) ↦ (c, F(c) ⊕ p)
# where F is the original NOR update. The explicit inverse is
# (c, x) ↦ (F(c) ⊕ x, c) — memory of where you came from is
# exactly what reversibility costs.
#
# WORLDS: derived from SHA-256 counters, NOT Julia's RNG —
# the sweep's F4 conviction (seed-properties quoted as facts)
# is law here; these worlds are identical on every kernel that
# can hash.
#
# PRE-REGISTERED PREDICTIONS (all hard; any miss fails this build):
#   P1  the ORIGINAL update is guilty of forgetting: across 20
#       hash-derived worlds (n=8, exhaustive over 256 states),
#       Garden-of-Eden states (in-degree 0) exist in at least
#       15 worlds, and RESTING trajectories (change, then stop
#       at a fixed point) exist in at least one world.
#   P2  the TWIN is a bijection in ALL 20 worlds — exhaustive
#       over all 65536 pair-states, checked twice by different
#       instruments: (a) image covers everything, (b) the
#       explicit inverse undoes the step pointwise.
#   P3  REST IS ABOLISHED: in every world, every fixed point of
#       the twin has in-degree exactly 1 (itself) — nothing can
#       ARRIVE at rest; you are either born resting or you never
#       rest. Zero resting trajectories across all 20×65536.
#   P4  ONLY RETURN REMAINS: cycle decomposition covers all
#       65536 pair-states in every world with zero transients —
#       the census {thing, restless, rest-possible} of _02/_04
#       collapses to {fixed, periodic}, exactly as
#       injective_recurrence demands.
#   P5  THE KERNEL'S BOUND IS RESPECTED AND NOT VACUOUS: max
#       cycle length ≤ 65536 (Lean: p ≤ N) in every world, and
#       some world witnesses a cycle ≥ 100 (return can be slow —
#       reversibility promises the trip home, not a short one).
#
# FORCED-FAILURE CONTROLS (run before commit, verbatim record):
#   mutant A — twin's ⊕ replaced by | (forgets again): exit 1
#     (P2 bijection court convicts in world 1).
#   mutant B — P3's in-degree bound loosened to ≤ 2:  exit 0.
#     NULL by vacuity risk? No: bound ≤2 is implied by ==1, so
#     the mutant passing is expected; the LIVE check is ==1.
#     Recorded, not hidden.
#   mutant C — P5's non-vacuity floor raised to 60000: exit 1.
# ------------------------------------------------------------

using SHA

exitcode = 0
pass(m) = println("  PASS  ", m)
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))

const N = 8                  # nodes; pair space = 2^16, exhaustive
const NS = 1 << N            # 256 single states
const NP = NS * NS           # 65536 pair states

println("=== emergence_10_reversible.jl — HEADS: the reversible world ===")

# --- hash-derived worlds (kernel-independent; F4's lesson applied) ---------
function world(w::Int)
    inputs = Vector{Vector{Int}}(undef, N)
    for i in 1:N
        h = sha256(codeunits("emergence10:world:$w:node:$i"))
        k = h[1] % 3 + 1
        inputs[i] = sort!(unique(Int(h[1 + j] % N) + 1 for j in 1:k))
    end
    inputs
end

"original NOR update on a bitmask state (empty inputs → the node fires)"
function step_table(inputs)
    F = Vector{Int}(undef, NS)
    for s in 0:NS-1
        t = 0
        for i in 1:N
            fire = isempty(inputs[i]) ||
                   !any(((s >> (j - 1)) & 1) == 1 for j in inputs[i])
            fire && (t |= 1 << (i - 1))
        end
        F[s + 1] = t
    end
    F
end

# the reversible twin on pair codes  code = prev*NS + cur
twin(F, code)     = (code % NS) * NS + (F[code % NS + 1] ⊻ (code ÷ NS))
untwin(F, code)   = (F[code ÷ NS + 1] ⊻ (code % NS)) * NS + (code ÷ NS)

# --- P1: the original forgets ------------------------------------------------
println("\nP1  the irreversible original: Gardens of Eden and resting trajectories")
function p1_forgetting()
    ge_worlds = 0; resting_total = 0
    for w in 1:20
        F = step_table(world(w))
        indeg = zeros(Int, NS)
        for s in 0:NS-1; indeg[F[s + 1] + 1] += 1; end
        any(indeg .== 0) && (ge_worlds += 1)
        for s in 0:NS-1                       # does s change then stop?
            F[s + 1] == s && continue         # born resting: not a resting TRAJECTORY
            x = s
            for _ in 1:NS; x = F[x + 1]; end  # settle into the attractor
            F[x + 1] == x && (resting_total += 1)
        end
    end
    (ge_worlds, resting_total)
end
let (ge, rest) = p1_forgetting()
    ge >= 15 ? pass("Garden-of-Eden states in $ge/20 worlds — the update is non-surjective, hence forgetful") :
               fail("P1: only $ge/20 worlds have unreachable states")
    rest > 0 ? pass("$rest resting trajectories across 20 worlds — in the old world, things could stop") :
               fail("P1: no resting trajectories anywhere — original dynamics not rest-capable here")
end

# --- P2: the twin remembers everything ---------------------------------------
println("\nP2  the twin: bijective in all 20 worlds, two instruments")
function p2_bijection()
    for w in 1:20
        F = step_table(world(w))
        seen = falses(NP)
        for code in 0:NP-1
            img = twin(F, code)
            seen[img + 1] && return (false, w, :collision)
            seen[img + 1] = true
            untwin(F, img) == code || return (false, w, :inverse)
        end
        all(seen) || return (false, w, :coverage)
    end
    (true, 0, :ok)
end
let (ok, w, why) = p2_bijection()
    ok ? pass("all 20 worlds: image covers all $NP pair-states AND the explicit inverse undoes every step") :
         fail("P2: twin broken in world $w ($why)")
end

# --- P3: rest is abolished ----------------------------------------------------
println("\nP3  no state can ARRIVE at rest")
function p3_no_arrival()
    fixed_total = 0
    for w in 1:20
        F = step_table(world(w))
        indeg = zeros(Int, NP)
        for code in 0:NP-1; indeg[twin(F, code) + 1] += 1; end
        for code in 0:NP-1
            if twin(F, code) == code
                fixed_total += 1
                indeg[code + 1] == 1 || return (false, w, code, fixed_total)
            end
        end
    end
    (true, 0, 0, fixed_total)
end
let (ok, w, code, nfix) = p3_no_arrival()
    ok ? pass("every fixed point (found $nfix across 20 worlds) has in-degree exactly 1 — rest is unreachable, only inheritable") :
         fail("P3: world $w, fixed point $code has extra predecessors — something arrived at rest")
end

# --- P4: the census collapses ---------------------------------------------------
println("\nP4  cycle decomposition: {thing, restless, rest-possible} → {fixed, periodic}")
function p4_collapse()
    maxlens = Int[]
    for w in 1:20
        F = step_table(world(w))
        visited = falses(NP)
        maxlen = 0
        for s in 0:NP-1
            visited[s + 1] && continue
            x = twin(F, s); len = 1
            while x != s
                visited[x + 1] && return (false, w, s, maxlens)  # entered foreign territory: transient!
                visited[x + 1] = true
                x = twin(F, x); len += 1
                len > NP && return (false, w, s, maxlens)
            end
            visited[s + 1] = true
            maxlen = max(maxlen, len)
        end
        all(visited) || return (false, w, -1, maxlens)
        push!(maxlens, maxlen)
    end
    (true, 0, 0, maxlens)
end
p4res = p4_collapse()
let (ok, w, s, maxlens) = p4res
    ok ? pass("all 20 worlds: every pair-state lies on a cycle through itself — zero transients, two categories only") :
         fail("P4: world $w, state $s is transient — the collapse prediction is dead")
end

# --- P5: the kernel's promise, measured ------------------------------------------
println("\nP5  Recurrence.lean's bound: p ≤ N, and the trip home can be long")
let maxlens = p4res[4]
    println("    max cycle length per world: ", maxlens)
    all(l <= NP for l in maxlens) ?
        pass("every cycle ≤ $NP — the kernel's pigeonhole bound holds in all 20 worlds") :
        fail("P5: a cycle exceeded the state count — arithmetic broken")
    maximum(maxlens) >= 100 ?
        pass("longest observed return: $(maximum(maxlens)) steps — the promise is a return ticket, not a short trip") :
        fail("P5: all cycles short (max $(maximum(maxlens))) — non-vacuity floor missed")
end

println()
println(exitcode == 0 ?
  "THE COIN CHOSE WELL — reversibility abolishes rest (nothing arrives, some are born there), forgetting was the price of stopping, and every state in the twin carries a return ticket the Lean kernel already guaranteed. Next: emergence_10 proper — bridge these censuses to injective_recurrence formally, and ask what the defect charge (RingRest.lean §3) becomes when the wiring is forced to be a permutation... which is exactly the charge_conserved_of_outdeg_one hypothesis." :
  "BUILD FAILED — a prediction missed; the reversible world is not what we registered.")
exit(exitcode)
