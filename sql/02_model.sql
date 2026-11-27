CREATE OR REPLACE TABLE dim_listing AS
WITH priced AS (
  SELECT listing_id, NTILE(4) OVER (ORDER BY price_aud) AS q
  FROM stg_listings
  WHERE price_aud BETWEEN 10 AND 3000
)
SELECT l.listing_id AS listing_key, l.neighbourhood, l.room_type, l.property_type,
       l.accommodates, l.bedrooms, l.price_aud,
       CASE p.q WHEN 1 THEN 'Q1 lowest' WHEN 2 THEN 'Q2' WHEN 3 THEN 'Q3' WHEN 4 THEN 'Q4 highest' END AS price_band,
       l.rating, l.number_of_reviews, l.number_of_reviews_ltm, l.host_type,
       l.minimum_nights, l.snapshot_date
FROM stg_listings l
LEFT JOIN priced p USING (listing_id);

CREATE OR REPLACE TABLE dim_date AS
SELECT d::DATE AS date,
       YEAR(d) AS year, QUARTER(d) AS quarter, MONTH(d) AS month,
       strftime(d, '%Y-%m') AS year_month,
       date_trunc('month', d)::DATE AS month_start
FROM generate_series(DATE '2009-01-01', DATE '2027-12-31', INTERVAL 1 DAY) AS t(d);

CREATE OR REPLACE TABLE fact_review AS
SELECT r.review_id, r.listing_id AS listing_key, r.review_date AS date_key,
       r.comment_clean, r.is_automated, LENGTH(r.comment_clean) AS comment_len
FROM stg_reviews r
JOIN dim_listing l ON l.listing_key = r.listing_id;

CREATE OR REPLACE TABLE dq_log AS
SELECT 'listings in raw file' AS check_name, COUNT(*) AS n FROM stg_listings_raw
UNION ALL SELECT 'listings kept', COUNT(*) FROM dim_listing
UNION ALL SELECT 'listings with usable price', COUNT(*) FROM dim_listing WHERE price_band IS NOT NULL
UNION ALL SELECT 'reviews in raw file', COUNT(*) FROM stg_reviews_raw
UNION ALL SELECT 'reviews after dedupe', COUNT(*) FROM stg_reviews
UNION ALL SELECT 'reviews with no matching listing (dropped)',
       (SELECT COUNT(*) FROM stg_reviews) - (SELECT COUNT(*) FROM fact_review)
UNION ALL SELECT 'automated postings flagged', COUNT(*) FROM fact_review WHERE is_automated;