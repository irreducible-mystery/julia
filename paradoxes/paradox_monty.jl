# ============================================================
# paradox_monty.jl — the door that was opened is not the door
#                    that was opened: mechanism over observation
# ============================================================
# LEDGER — Monte Carlo as court. Three hosts open the same door;
# the posterior depends on WHY the door opened, not THAT it did.
# The observation is identical across variants; the sampling
# mechanism is not. This is the whole paradox: probability lives
# in the mechanism, and MC forces you to write the mechanism down.
# ------------------------------------------------------------
# PRE-REGISTERED PREDICTIONS (written before running; each is a
#     hard claim — any miss fails the build):
#     P1  STANDARD host (knows the car, always opens a goat door,
#         never yours): P(win | switch) = 2/3, P(win | stay) = 1/3.
#     P2  MONTY FALL (host slips, opens a uniformly random other
#         door; we CONDITION on the trial surviving — goat shown):
#         P(win | switch, goat shown) = 1/2. Same reveal as P1,
#         different mechanism, different answer.
#     P3  N = 100 doors, host (knowing) opens 98 goats:
#         P(win | switch) = 99/100.
#     P4  (control) The unconditional car location is uniform:
#         each door carries the car 1/3 ± tol. If this fails, the
#         RNG court is corrupt and P1–P3 are void.
# CHOICE (flagged): tolerances are 10σ-ish at the stated n —
#     generous enough to be seed-robust, tight enough to kill a
#     wrong constant (1/2 vs 2/3 is ~150σ apart at n = 200_000).
# UNPROVABLE FROM INSIDE: that the simulator implements the story.
#     The code IS the story; read it, not this comment.
# ============================================================

import Random
rng = Random.MersenneTwister(20250101)

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))
function check(name, got, want, tol)
    ok = abs(got - want) <= tol
    println("  ", ok ? "PASS" : "MISS", "  ", name,
            "  got=", round(got, digits=4), "  want=", round(want, digits=4),
            "  tol=", tol)
    ok || fail(name)
end

const N = 200_000

# --- P4 control: the court itself -----------------------------
counts = zeros(Int, 3)
for _ in 1:N
    counts[rand(rng, 1:3)] += 1
end
println("P4  control — car placement uniform")
for d in 1:3
    check("door $d frequency", counts[d] / N, 1/3, 0.01)
end

# --- P1 standard host ------------------------------------------
function monty_standard(rng, n)
    sw = 0; st = 0
    for _ in 1:n
        car  = rand(rng, 1:3)
        pick = rand(rng, 1:3)
        goats = [d for d in 1:3 if d != pick && d != car]
        opened = goats[rand(rng, 1:length(goats))]
        switched = only(d for d in 1:3 if d != pick && d != opened)
        sw += (switched == car)
        st += (pick == car)
    end
    (sw / n, st / n)
end
psw, pst = monty_standard(rng, N)
println("P1  standard host (knows, always reveals a goat)")
check("P(win | switch)", psw, 2/3, 0.01)
check("P(win | stay)  ", pst, 1/3, 0.01)

# --- P2 Monty Fall: same reveal, different mechanism ------------
function monty_fall(rng, n)
    sw = 0; kept = 0
    for _ in 1:n
        car  = rand(rng, 1:3)
        pick = rand(rng, 1:3)
        others = [d for d in 1:3 if d != pick]
        opened = others[rand(rng, 1:2)]     # host does NOT know
        opened == car && continue           # condition: goat shown
        kept += 1
        switched = only(d for d in 1:3 if d != pick && d != opened)
        sw += (switched == car)
    end
    (sw / kept, kept)
end
pfall, kept = monty_fall(rng, N)
println("P2  Monty Fall (random door, conditioned on goat) — kept $kept/$N trials")
check("P(win | switch, goat shown)", pfall, 1/2, 0.01)

# --- P3 one hundred doors ---------------------------------------
function monty_100(rng, n; D = 100)
    sw = 0
    for _ in 1:n
        car  = rand(rng, 1:D)
        pick = rand(rng, 1:D)
        # host closes down to {pick, final}: final = car unless you hold it,
        # in which case a uniformly chosen goat survives. This IS the
        # 98-reveals mechanism, collapsed; the collapse is the claim P3 tests.
        final = pick == car ? rand(rng, [d for d in 1:D if d != pick]) : car
        sw += (final == car)
    end
    sw / n
end
p100 = monty_100(rng, N)
println("P3  100 doors, 98 informed reveals")
check("P(win | switch)", p100, 99/100, 0.005)

println(exitcode == 0 ? "ALL PASS — mechanism, not observation, sets the posterior." :
                        "BUILD FAILED")
exit(exitcode)
