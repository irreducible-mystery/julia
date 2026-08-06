# ============================================================
# flip.jl — the flip itself. One fair bit from a crooked,
#     un-re-rollable source; the outcome was purchasable by
#     no one, including the author.
# ============================================================
# LEDGER — the auditing instance. FLIP.md (previous commit)
# pre-registered everything here: source = SHA of the commit
# that ADDED FLIP.md, expanded by SHA-256 counter mode into a
# stream biased to p = 179/256, von-Neumann-extracted; the
# first accepted bit decides the repo's next direction:
#     1 (HEADS) → reversible-world emergence_10
#     0 (TAILS) → extractor proved in Lean
#
# VERIFICATION OBLIGATIONS (from FLIP.md, all hard):
#   V1  the anchor is recomputed from `git log --diff-filter=A`
#       at runtime AND must equal the constant recorded below —
#       hard-coding without the runtime check would let a cheat
#       shop for a luckier "anchor"; disagreement exits 1.
#   V2  the derived raw stream is verifiably biased: first
#       100_000 bits within 5σ of 179/256, AND convicted of
#       unfairness at >5σ (a fair source here would mean the
#       expansion is broken and the flip void).
#   V3  the extractor used is byte-identical in behavior to
#       fair_coin.jl's: both are run on the same 1000-bit
#       prefix and must agree bit-for-bit.
#   V4  determinism: the entire derivation repeated from
#       scratch inside this process must reproduce the same
#       first accepted bit.
#
# The outcome is printed, and asserted to match the RESULT
# recorded in FLIP.md (appended in this same commit) — so the
# receipt and the prose can never drift apart silently.
# ------------------------------------------------------------

using SHA

exitcode = 0
pass(m) = println("  PASS  ", m)
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))

root = normpath(joinpath(dirname(@__FILE__), ".."))

println("=== flip.jl — one bit, witnessed ===")

# --- V1: recover the anchor from history, check against the record --------
const RECORDED_ANCHOR = "a97753befca40a5892d0aae3441aa9116143441c"
println("\nV1  the anchor: the commit that added FLIP.md")
anchor = let
    log = readchomp(`git -C $root log --diff-filter=A --format=%H --follow -- fair-coin/FLIP.md`)
    shas = split(log)
    isempty(shas) ? "" : String(last(shas))   # oldest = the ADD
end
length(anchor) == 40 ?
    pass("anchor recovered from git history: $anchor") :
    fail("V1: could not recover an ADD commit for FLIP.md")
anchor == RECORDED_ANCHOR ?
    pass("runtime anchor == recorded anchor (no anchor-shopping possible)") :
    fail("V1: anchor mismatch — recorded $RECORDED_ANCHOR, history says $anchor")

# --- the derivation (pure, kernel-independent) -----------------------------
"biased bit stream: SHA-256(anchor:i) counter mode, bit = (byte < 179)"
function biased_bits(anchor::String, nbits::Int)
    bits = Vector{Bool}(undef, nbits)
    i = 0; k = 0
    while k < nbits
        for byte in sha256(codeunits(string(anchor, ":", i)))
            k == nbits && break
            k += 1
            bits[k] = byte < 0xb3           # 179: P(bit) = 179/256
        end
        i += 1
    end
    bits
end
"von Neumann, identical contract to fair_coin.jl: (a,b) a≠b → emit b"
function extract_vn(bits::AbstractVector{Bool})
    out = Bool[]
    for k in 1:2:length(bits)-1
        a, b = bits[k], bits[k+1]
        a != b && push!(out, b)
    end
    out
end

# --- V2: the source must be crooked exactly as advertised ------------------
println("\nV2  the source: biased to 179/256, and provably not fair")
let raw = biased_bits(anchor, 100_000), p0 = 179 / 256,
    z179 = (count(raw) / 100_000 - p0) / sqrt(p0 * (1 - p0) / 100_000),
    zfair = (count(raw) / 100_000 - 0.5) / sqrt(0.25 / 100_000)
    abs(z179) <= 5 ?
        pass("stream within 5σ of 179/256 (z = $(round(z179, digits=2))σ)") :
        fail("V2: stream not at advertised bias (z=$z179) — expansion broken, flip void")
    abs(zfair) > 5 ?
        pass("stream convicted of unfairness at $(round(zfair, digits=1))σ — the coin really is crooked") :
        fail("V2: source looks fair — nothing to launder, flip void")
end

# --- V3: same extractor as the credentialed one ----------------------------
println("\nV3  the extractor: agrees with fair_coin.jl on a shared prefix")
let prefix = biased_bits(anchor, 1000),
    here = extract_vn(prefix),
    creds = let src = read(joinpath(root, "fair-coin/fair_coin.jl"), String)
        m = Module()
        # evaluate ONLY fair_coin.jl's extractor definition, verbatim from source
        i = findfirst("function extract_vn", src)
        j = findnext("\nend", src, last(i))   # the column-0 end closes the function
        Base.include_string(m, src[first(i):last(j)])
        f = Base.invokelatest(getglobal, m, :extract_vn)
        Base.invokelatest(f, prefix)
    end
    here == creds ?
        pass("extractors agree bit-for-bit on 1000-bit prefix ($(length(here)) accepted)") :
        fail("V3: extractor drift between flip.jl and fair_coin.jl")
end

# --- the flip, and V4 --------------------------------------------------------
println("\nTHE FLIP")
function first_fair_bit(anchor)
    bits = biased_bits(anchor, 4096)
    ext = extract_vn(bits)
    isempty(ext) && error("no accepted pair in 4096 bits — probability ~2^-1400, investigate")
    ext[1]
end
flip1 = first_fair_bit(anchor)
flip2 = first_fair_bit(anchor)          # V4: full re-derivation
flip1 == flip2 ?
    pass("V4: independent re-derivation reproduces the bit") :
    fail("V4: flip not deterministic — void")
outcome = flip1
println("    first accepted bit = ", Int(outcome), " → ",
        outcome ? "HEADS: the reversible world (emergence_10 direction)" :
                  "TAILS: the extractor goes into the Lean kernel")

# --- receipt/prose lockstep --------------------------------------------------
println("\nV5  FLIP.md's RESULT section must state this same outcome")
let md = read(joinpath(root, "fair-coin/FLIP.md"), String)
    parts = split(md, "## RESULT")
    length(parts) == 2 ?
        pass("RESULT section exists") :
        fail("V5: RESULT missing from FLIP.md — append it in this commit")
    result = length(parts) == 2 ? parts[2] : ""
    want = outcome ? "HEADS" : "TAILS"
    other = outcome ? "TAILS: " : "HEADS: "   # the wrong outcome's stake line
    occursin(want, result) ?
        pass("FLIP.md's RESULT records $want — prose and receipt agree") :
        fail("V5: FLIP.md's RESULT does not record $want — prose has drifted from the artifact")
    occursin(other, result) &&
        fail("V5: RESULT also claims the other outcome — ambiguous record")
end

# --- V6: the drawn floors must stay in the record -----------------------------
# Added after a direct challenge ("is it random?"). The answer is NO —
# deterministic end to end; what was bought is unchooseability, and that
# rests on a stack of ARBITRARY floors (iid model, random-oracle faith,
# threat model, append-only history, 5σ). The house sin is not drawing
# floors, it is forgetting them — so their ledger gets a failure channel:
# delete or degrade FLIP.md's THE FLOORS section and this flip goes VOID.
println("\nV6  the floors ledger: the memory of the arbitrary is load-bearing")
let md = read(joinpath(root, "fair-coin/FLIP.md"), String)
    occursin("## THE FLOORS", md) ?
        pass("THE FLOORS section present in FLIP.md") :
        fail("V6: floors ledger deleted — a forgotten floor voids the flip")
    for needle in ("mul_comm", "random oracle", "threat model", "5σ",
                   "Nothing in this flip is random")
        occursin(needle, md) ||
            fail("V6: floor '$needle' missing from the ledger — redrawn without record")
    end
    count(occursin(md), ("mul_comm", "random oracle", "threat model", "5σ",
                         "Nothing in this flip is random")) == 5 &&
        pass("all five named floors on the record: proof, model, faith, contract, drawn line")
end

println()
println(exitcode == 0 ?
  "FLIP STANDS — anchored, biased, laundered, reproduced, recorded. Nobody chose this bit (a threat-model claim, not a theorem — the full ledger of drawn floors under this receipt is FLIP.md's THE FLOORS section; nothing here is random, it is merely unchooseable)." :
  "FLIP VOID — at least one obligation missed; the outcome above is not binding.")
exit(exitcode)
