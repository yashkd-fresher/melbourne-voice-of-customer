import duckdb, sys

con = duckdb.connect('data/processed/voc.duckdb', read_only=True)
checks = {
    'listing_key is unique': 'SELECT COUNT(*) = COUNT(DISTINCT listing_key) FROM dim_listing',
    'listings have a neighbourhood': 'SELECT COUNT(*) = 0 FROM dim_listing WHERE neighbourhood IS NULL',
    'at least 80% of listings have a usable price': "SELECT AVG(CASE WHEN price_band IS NOT NULL THEN 1.0 ELSE 0 END) >= 0.8 FROM dim_listing",
    'review dates are not after the snapshot': 'SELECT COUNT(*) = 0 FROM fact_review f, (SELECT MAX(snapshot_date) AS s FROM dim_listing) x WHERE f.date_key > x.s',
    'every review has a listing': 'SELECT COUNT(*) = 0 FROM fact_review f LEFT JOIN dim_listing l ON l.listing_key = f.listing_key WHERE l.listing_key IS NULL',
    'sample has no automated postings': 'SELECT COUNT(*) = 0 FROM review_sample s JOIN fact_review f USING (review_id) WHERE f.is_automated',
    'sample is at most 100 per neighbourhood': 'SELECT MAX(n) <= 100 FROM (SELECT COUNT(*) AS n FROM review_sample GROUP BY neighbourhood)',
    'sample covers at least 5 neighbourhoods': 'SELECT COUNT(DISTINCT neighbourhood) >= 5 FROM review_sample',
    'no reviewer name or id columns anywhere': "SELECT COUNT(*) = 0 FROM information_schema.columns WHERE lower(column_name) LIKE '%reviewer%'",
}
failed = 0
for name, sql in checks.items():
    ok = con.execute(sql).fetchone()[0]
    print(('PASS  ' if ok else 'FAIL  ') + name)
    failed += (not ok)
sys.exit(1 if failed else 0)