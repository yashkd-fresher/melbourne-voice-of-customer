import duckdb
from langdetect import detect_langs, DetectorFactory

DetectorFactory.seed = 0   # makes results repeatable

con = duckdb.connect('data/processed/voc.duckdb')
rows = con.sql('SELECT review_id, comment_clean FROM review_candidates').fetchall()

out = []
for review_id, text in rows:
    try:
        best = detect_langs(text)[0]
        out.append((review_id, best.lang, round(best.prob, 3)))
    except Exception:
        out.append((review_id, 'unknown', 0.0))

con.execute('CREATE OR REPLACE TABLE review_language (review_id BIGINT, lang VARCHAR, prob DOUBLE)')
con.executemany('INSERT INTO review_language VALUES (?, ?, ?)', out)
print('languages detected:', len(out))
print(con.sql('SELECT lang, COUNT(*) AS n FROM review_language GROUP BY 1 ORDER BY n DESC LIMIT 5'))