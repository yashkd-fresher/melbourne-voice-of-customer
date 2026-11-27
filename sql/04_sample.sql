CREATE OR REPLACE TABLE review_sample AS
WITH english AS (
  SELECT c.review_id, c.listing_key, c.neighbourhood, c.comment_clean
  FROM review_candidates c
  JOIN review_language g USING (review_id)
  WHERE g.lang = 'en' AND g.prob >= 0.9
),
ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY neighbourhood ORDER BY hash(review_id)) AS rn,
            COUNT(*) OVER (PARTITION BY neighbourhood) AS english_available
  FROM english
)
SELECT review_id, listing_key, neighbourhood, comment_clean, english_available
FROM ranked
WHERE rn <= 100;