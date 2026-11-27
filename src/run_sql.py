import duckdb, pathlib, sys

con = duckdb.connect('data/processed/voc.duckdb')
prefixes = sys.argv[1:]
files = sorted(pathlib.Path('sql').glob('*.sql'))
if prefixes:
    files = [f for f in files if any(f.name.startswith(p) for p in prefixes)]
for f in files:
    print('Running', f.name)
    try:
        con.execute(f.read_text())
    except Exception:
        print('FAILED in', f.name)
        raise
print('SQL finished')