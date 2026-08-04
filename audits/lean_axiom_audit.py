#!/usr/bin/env python3
"""My own independent axiom-audit generator. Extracts every theorem name
(namespace-aware) from a Lean file and appends #print axioms for each."""
import re, sys

src_path, out_path = sys.argv[1], sys.argv[2]
src = open(src_path).read()

names = []
stack = []
for line in src.splitlines():
    m = re.match(r'^namespace\s+(\S+)', line)
    if m:
        stack.append(m.group(1)); continue
    m = re.match(r'^end\s+(\S+)', line)
    if m and stack and stack[-1] == m.group(1):
        stack.pop(); continue
    m = re.match(r"^theorem\s+([A-Za-z_][A-Za-z_0-9'.]*)", line)
    if m:
        full = '.'.join(stack + [m.group(1)])
        names.append(full)

with open(out_path, 'w') as f:
    f.write(src)
    f.write('\n\n-- INDEPENDENT AUDIT (SuperNinja)\n')
    for n in names:
        f.write(f'#print axioms {n}\n')

print(f'{len(names)} theorems: {names}')
