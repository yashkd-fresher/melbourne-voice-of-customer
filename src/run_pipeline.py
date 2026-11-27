import subprocess, sys

steps = [
    ['src/ingest.py'],
    ['src/run_sql.py', '01', '02', '03'],
    ['src/detect_language.py'],
    ['src/run_sql.py', '04'],
    ['src/validate.py'],
]
for s in steps:
    print('==>', ' '.join(s))
    r = subprocess.run([sys.executable] + s)
    if r.returncode != 0:
        print('Stopped at', ' '.join(s))
        sys.exit(r.returncode)
print('Pipeline complete.')