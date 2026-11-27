CREATE OR REPLACE TABLE review_candidates AS
SELECT f.review_id, f.listing_key, l.neighbourhood, f.comment_clean
FROM fact_review f
JOIN dim_listing l ON l.listing_key = f.listing_key
WHERE NOT f.is_automated
  AND f.comment_len BETWEEN 30 AND 1500
  AND f.date_key >= DATE '2022-01-01'
QUALIFY ROW_NUMBER() OVER (PARTITION BY l.neighbourhood ORDER BY hash(f.review_id)) <= 400;