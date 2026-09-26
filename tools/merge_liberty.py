#!/usr/bin/env python3
# Merge several Liberty (.lib) files into one library: ABC reads only one library at a time.
#   python3 tools/merge_liberty.py out.lib first.lib second.lib ...
# The header (units, operating conditions, table templates) comes from the first file; every
# cell(...) group of every file is appended, and later files' table templates are added too.
import sys, re
def groups(text, keyword):
    out, i = [], 0
    pat = re.compile(r'\n\s*' + keyword + r'\s*\(')
    while True:
        m = pat.search(text, i)
        if not m: return out
        j = text.index('{', m.end()); depth = 0; k = j
        while True:
            c = text[k]
            if c == '{': depth += 1
            elif c == '}':
                depth -= 1
                if depth == 0: break
            k += 1
        out.append(text[m.start():k + 1]); i = k + 1
out_path, first, *rest = sys.argv[1:]
base = open(first).read()
end = base.rstrip().rfind('}')
extra, seen = [], set(re.findall(r'\n\s*lu_table_template\s*\(\s*(\w+)', base))
for path in rest:
    t = open(path).read()
    for g in groups(t, 'lu_table_template'):
        name = re.search(r'lu_table_template\s*\(\s*(\w+)', g).group(1)
        if name not in seen: seen.add(name); extra.append(g)
    extra += groups(t, 'cell')
open(out_path, 'w').write(base[:end] + '\n'.join(extra) + '\n}\n')
print(f'{out_path}: {len(groups(base, "cell")) + sum(1 for e in extra if e.lstrip().startswith("cell"))} cells')
