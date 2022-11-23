
-- ### Children ###
CREATE OR REPLACE VIEW `mv-santas-helper.santas_helper.child`
OPTIONS (
  description='All the naughty and nice children and what they would and wouldn\'t like for xmas'
) AS
WITH children AS (
  SELECT * 
  FROM UNNEST([
    STRUCT(1 AS id, 'Adrian' AS name, ARRAY<STRING>['SERVERLESS', 'DEV_OPS'] AS wish_present_type, ARRAY<STRING>['SALES', 'TYPESCRIPT'] AS dislike_present_type, 2 AS number_of_presents, FALSE AS naughty)
    , (2, 'Alex', ['GCP', 'AWS'], NULL, 3, FALSE) -- Note: Alex is very accommodating and will take on any job
    , (3, 'Glenn', NULL,  ARRAY<STRING>['AZURE'], 2, FALSE) -- Note: Glenn doesn't care what present he gets! No preferences
    , (4, 'Karin', NULL, NULL, 3, FALSE) -- Note: Karin is meh! Whatever!
    , (5, 'Marc', ['DEV_OPS', 'KUBERNETES', 'GCP'],  ARRAY<STRING>['AWS', 'AZURE'], 1, TRUE)
    , (6, 'Martin', ['DATABASE', 'SERVERLESS'], NULL, 2, FALSE)
    , (7, 'Matt', ['GCP'], NULL, 3, FALSE)
    , (8, 'Pete', ['AWS', 'AZURE'], NULL, 1, FALSE)
    , (9, 'Rob', NULL,  ARRAY<STRING>['DATABASE'], 2, FALSE)
    , (10, 'Sean', ['NODE', 'REACT', 'DATABASE'], NULL, 1, FALSE)
    , (11, 'Willis', ['SALES'], NULL, 2, FALSE)
  ]) 
)
SELECT *
FROM children
ORDER BY id;

-- ### Presents ###
CREATE OR REPLACE VIEW `mv-santas-helper.santas_helper.present`
OPTIONS (
  description='All the presents the elves have been making all year'
) AS
WITH presents AS (
  SELECT 1 AS id, 'Job #1' AS description, 'High' AS value, ARRAY<STRING>['AWS', 'DEV_OPS', 'KUBERNETES'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 2 AS id, 'Job #2' AS description, 'Low' AS value, ARRAY<STRING>['GCP', 'SERVERLESS'] AS present_types, 3 AS stock_level UNION ALL
  SELECT 3 AS id, 'Job #3' AS description, 'High' AS value, ARRAY<STRING>['AWS', 'DEV_OPS', 'DATABASE'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 4 AS id, 'Job #4' AS description, 'Medium' AS value, ARRAY<STRING>['AZURE', 'SERVERLESS'] AS present_types, 3 AS stock_level UNION ALL
  SELECT 5 AS id, 'Job #5' AS description, 'Low' AS value, ARRAY<STRING>['NODE', 'TYPESCRIPT'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 6 AS id, 'Job #6' AS description, 'High' AS value, ARRAY<STRING>['NODE'] AS present_types, 4 AS stock_level UNION ALL
  SELECT 7 AS id, 'Job #7' AS description, 'High' AS value, ARRAY<STRING>['SALES'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 8 AS id, 'Job #8' AS description, 'Low' AS value, ARRAY<STRING>['KUBERNETES', 'SERVERLESS'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 9 AS id, 'Job #9' AS description, 'Medium' AS value, ARRAY<STRING>['AZURE', 'SALES', 'DEV_OPS'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 10 AS id, 'Job #10' AS description, 'High' AS value, ARRAY<STRING>['SERVERLESS'] AS present_types, 3 AS stock_level UNION ALL
  SELECT 11 AS id, 'Job #11' AS description, 'High' AS value, ARRAY<STRING>['DEV_OPS'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 12 AS id, 'Job #12' AS description, 'Low' AS value, ARRAY<STRING>['TYPESCRIPT', 'REACT', 'NODE'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 13 AS id, 'Job #13' AS description, 'Low' AS value, ARRAY<STRING>['DATABASE'] AS present_types, 3 AS stock_level UNION ALL
  SELECT 14 AS id, 'Job #14' AS description, 'Medium' AS value, ARRAY<STRING>['SALES'] AS present_types, 4 AS stock_level UNION ALL
  SELECT 15 AS id, 'Job #15' AS description, 'High' AS value, ARRAY<STRING>['GCP', 'AWS'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 16 AS id, 'Job #16' AS description, 'Low' AS value, ARRAY<STRING>['AZURE', 'DATABASE'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 17 AS id, 'Job #17' AS description, 'High' AS value, ARRAY<STRING>['AWS'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 18 AS id, 'Job #18' AS description, 'Medium' AS value, ARRAY<STRING>['REACT'] AS present_types, 3 AS stock_level UNION ALL
  SELECT 19 AS id, 'Job #19' AS description, 'High' AS value, ARRAY<STRING>['AZURE'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 20 AS id, 'Job #20' AS description, 'Low' AS value, ARRAY<STRING>['SALES', 'REACT'] AS present_types, 2 AS stock_level
)
SELECT *
FROM presents
ORDER BY id;

-- ### Children/Presents ###
CREATE OR REPLACE VIEW `mv-santas-helper.santas_helper.child_present`
OPTIONS (
  description='All possible combinations of children and presents'
) AS
SELECT c.id AS child_id
, c.name AS child_name
, c.wish_present_type AS child_wish_present_type
, c.dislike_present_type AS child_dislike_present_type
, c.number_of_presents AS child_number_of_presents
, c.naughty AS child_naughty
, p.id AS present_id
, p.description AS present_description
, p.value AS present_value
, p.present_types AS present_types
, p.stock_level AS present_stock_levels
FROM `mv-santas-helper.santas_helper.child` AS c
CROSS JOIN `mv-santas-helper.santas_helper.present` AS p
ORDER BY c.id, p.id;

--- ### Child/Present - dislike score ###
CREATE OR REPLACE VIEW `mv-santas-helper.santas_helper.child_present_dislike_score`
OPTIONS (
  description='Negative scores for any presents that the children said they didn\'t like'
) AS
SELECT cp.child_id
, cp.present_id
, STRING_AGG(DISTINCT cdlpt) AS child_dislike_present_types
, STRING_AGG(DISTINCT pt) AS present_types
, COUNTIF(DISTINCT cdlpt IN UNNEST(cp.present_types)) AS dislike_match_count
, -9999999 * COUNTIF(DISTINCT cdlpt IN UNNEST(cp.present_types)) AS dislike_score
FROM `mv-santas-helper.santas_helper.child_present` AS cp
LEFT JOIN UNNEST(cp.child_dislike_present_type) AS cdlpt
LEFT JOIN UNNEST(cp.present_types) AS pt
GROUP BY cp.child_id
, cp.present_id
ORDER BY cp.child_id
, cp.present_id;

--- ### Child/Present - wish score ###
CREATE OR REPLACE VIEW `mv-santas-helper.santas_helper.child_present_wish_score`
OPTIONS (
  description='Postive scores for any presents that the children wished for'
) AS
SELECT cp.child_id
, cp.present_id
, STRING_AGG(DISTINCT cwpt) AS child_wish_present_types
, STRING_AGG(DISTINCT pt) AS present_types
, COUNTIF(DISTINCT cwpt IN UNNEST(cp.present_types)) AS wish_match_count
, 10 * COUNTIF(DISTINCT cwpt IN UNNEST(cp.present_types)) AS wish_score
FROM `mv-santas-helper.santas_helper.child_present` AS cp
LEFT JOIN UNNEST(cp.child_wish_present_type) AS cwpt
LEFT JOIN UNNEST(cp.present_types) AS pt
GROUP BY cp.child_id
, cp.present_id
ORDER BY cp.child_id
, cp.present_id;

--- ### Child/Present - present count ###
CREATE OR REPLACE VIEW `mv-santas-helper.santas_helper.child_present_count`
OPTIONS (
  description='The max amount of presents a child could potentially have if they have 1 of every present available'
) AS
SELECT cp.child_id
, COUNT(cp.present_id) AS present_count
FROM `mv-santas-helper.santas_helper.child_present` AS cp
GROUP BY cp.child_id
ORDER BY cp.child_id;

--- ### Child/Present - value count ###
CREATE OR REPLACE VIEW `mv-santas-helper.santas_helper.child_present_value_count`
OPTIONS (
  description='The count of value presents (high/medium/low) for each child'
) AS
SELECT cp.child_id
, cp.present_value
, COUNT(cp.present_id) AS present_count
FROM `mv-santas-helper.santas_helper.child_present` AS cp
GROUP BY cp.child_id
, cp.present_value
ORDER BY cp.child_id
, cp.present_value;

--- ### Child/Present - value score ###
CREATE OR REPLACE VIEW `mv-santas-helper.santas_helper.child_present_value_score`
OPTIONS (
  description='The score for present for each child based on the value'
) AS
SELECT cpc.child_id 
, cpc.present_count AS child_present_count
, cpvc.present_value
, cpvc.present_count AS present_value_count
, cpc.present_count / cpvc.present_count AS present_value_score
FROM `mv-santas-helper.santas_helper.child_present_count` AS cpc
LEFT JOIN `mv-santas-helper.santas_helper.child_present_value_count` AS cpvc ON cpc.child_id = cpvc.child_id
ORDER BY cpc.child_id;

--- ### Child/Present - value score ###
CREATE OR REPLACE VIEW `mv-santas-helper.santas_helper.child_present_score`
OPTIONS (
  description='The business rule scores and total score for the child/present combination'
) AS
WITH child_present_scores AS (
  SELECT cp.child_id
  , cp.child_name
  , cpds.child_dislike_present_types
  , cpws.child_wish_present_types
  , cp.present_id
  , cp.present_description
  , cp.present_value
  , cpws.present_types
  , COALESCE(cpds.dislike_score, 0) AS br_excl_present_dislike_score
  , COALESCE(cpws.wish_score, 0) AS br_weight_present_wish_score
  , COALESCE(cpvs.present_value_score, 0) AS br_weight_present_diversity_score
  , CASE
      WHEN cpvs.present_value IS NULL OR TRIM(cpvs.present_value) = '' THEN 0
      ELSE
        CASE
          WHEN cpvs.present_value = 'Low' THEN 1
          WHEN cpvs.present_value = 'Medium' THEN 2
          WHEN cpvs.present_value = 'High' THEN 3
        ELSE 0
      END
    END AS br_weight_product_value_score
  FROM `mv-santas-helper.santas_helper.child_present` AS cp
  LEFT JOIN `mv-santas-helper.santas_helper.child_present_dislike_score` AS cpds
    ON cp.child_id = cpds.child_id
    AND cp.present_id = cpds.present_id
  LEFT JOIN `mv-santas-helper.santas_helper.child_present_wish_score` AS cpws
    ON cp.child_id = cpws.child_id
    AND cp.present_id = cpws.present_id
  LEFT JOIN `mv-santas-helper.santas_helper.child_present_value_score` AS cpvs
    ON cp.child_id = cpvs.child_id
    AND cp.present_value = cpvs.present_value
)
SELECT *
, (br_excl_present_dislike_score + br_weight_present_wish_score + br_weight_present_diversity_score + br_weight_product_value_score) AS score
FROM child_present_scores
ORDER BY child_id
, present_id;







