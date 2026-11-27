import duckdb

con = duckdb.connect('data/processed/voc.duckdb')

con.execute('''
    CREATE OR REPLACE TABLE stg_listings_raw AS
    SELECT * FROM read_csv('data/raw/listings.csv.gz', header = true, all_varchar = true)
''')

# Privacy: select only the columns needed. Reviewer names and IDs are never loaded.
con.execute('''
    CREATE OR REPLACE TABLE stg_reviews_raw AS
    SELECT id, listing_id, "date", comments
    FROM read_csv('data/raw/reviews.csv.gz', header = true, all_varchar = true)
''')

print('listings loaded:', con.sql('SELECT COUNT(*) FROM stg_listings_raw').fetchone()[0])
print('reviews loaded: ', con.sql('SELECT COUNT(*) FROM stg_reviews_raw').fetchone()[0])
print('snapshot date:  ', con.sql('SELECT MAX(last_scraped) FROM stg_listings_raw').fetchone()[0])