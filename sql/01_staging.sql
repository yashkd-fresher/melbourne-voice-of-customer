CREATE OR REPLACE TABLE stg_listings AS
SELECT
  CAST(id AS BIGINT)                                           AS listing_id,
  TRIM(neighbourhood_cleansed)                                 AS neighbourhood,
  TRIM(room_type)                                              AS room_type,
  TRIM(property_type)                                          AS property_type,
  TRY_CAST(accommodates AS INTEGER)                            AS accommodates,
  TRY_CAST(bedrooms AS DOUBLE)                                 AS bedrooms,
  TRY_CAST(REPLACE(REPLACE(price, '$', ''), ',', '') AS DOUBLE) AS price_aud,
  TRY_CAST(minimum_nights AS INTEGER)                          AS minimum_nights,
  TRY_CAST(number_of_reviews AS INTEGER)                       AS number_of_reviews,
  TRY_CAST(number_of_reviews_ltm AS INTEGER)                   AS number_of_reviews_ltm,
  TRY_CAST(review_scores_rating AS DOUBLE)                     AS rating,
  TRY_CAST(calculated_host_listings_count AS INTEGER)          AS host_listings,
  CASE WHEN TRY_CAST(calculated_host_listings_count AS INTEGER) > 1
       THEN 'Multi-listing host' ELSE 'Single-listing host' END AS host_type,
  TRY_CAST(last_scraped AS DATE)                               AS snapshot_date
FROM stg_listings_raw
WHERE TRY_CAST(id AS BIGINT) IS NOT NULL;

CREATE OR REPLACE TABLE stg_reviews AS
WITH cleaned AS (
  SELECT
    CAST(id AS BIGINT)         AS review_id,
    CAST(listing_id AS BIGINT) AS listing_id,
    TRY_CAST("date" AS DATE)   AS review_date,
    TRIM(regexp_replace(regexp_replace(COALESCE(comments, ''), '<[^>]+>', ' ', 'g'), '\\s+', ' ', 'g')) AS comment_clean,
    LOWER(COALESCE(comments, '')) LIKE '%automated posting%'       AS is_automated
  FROM stg_reviews_raw
  WHERE TRY_CAST(id AS BIGINT) IS NOT NULL
)
SELECT *
FROM cleaned
WHERE review_date IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY listing_id, review_date, comment_clean ORDER BY review_id) = 1;