# run_all.jl — exit 0 iff every paradox court passes.
# Prose is ledger; these exit codes are the evidence.
const FILES = [
    "paradox_monty.jl",
    "paradox_bertrand.jl",
    "paradox_petersburg.jl",
    "paradox_simpson_birthday.jl",
    "modified_mc.jl",
    "paradox_tags.jl",
    "audit_paradoxes_by_author.jl",
]

dir = dirname(@__FILE__)
bad = 0
for f in FILES
    println("═"^64)
    println("RUNNING ", f)
    println("═"^64)
    p = run(ignorestatus(`$(Base.julia_cmd()) $(joinpath(dir, f))`))
    if p.exitcode != 0
        global bad += 1
        println(">> $f EXITED $(p.exitcode)")
    end
end
println("═"^64)
println(bad == 0 ? "ALL FILES EXIT 0" : "$bad FILE(S) FAILED")
exit(bad == 0 ? 0 : 1)
