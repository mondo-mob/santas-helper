########################################################################################################################
#
# Setup the views used by the notebook with sample data, and scores explained in the blog.
#
# Note: the intention for this script was to run it directly from the notebook - but if you just want to run the SQL
# directly in BigQuery, perform a search and replace in this file for the <project-id>.<dataset-id> variables and
# replace with your own dataset. I.e.
#
# {project_id}.{dataset_id}
# mv-santas-helper.santas_helper
#
# The project and BigQuery dataset will need to already exist!
#
########################################################################################################################


###### Children ########################################################################################################
# Example using UNNEST & STRUCT to generate sample data
# A child has the following present categories to choose from:
# ACTION_FIGURES, CRAFTS, BUILDING, DOLLS, EDUCATIONAL, TECHNOLOGY, PUZZLES, SOFT_TOYS, MODELS, SPORTS, REMOTE_CONTROL
# They can choose 1 or more of the categories for both their wish and dislike present types.
# Leaving a category NULL means they don't have a particular wish/dislike
########################################################################################################################
CREATE OR REPLACE VIEW `{project_id}.{dataset_id}.child`
OPTIONS (
  description='All the naughty and nice children and what they would and wouldn\'t like for xmas'
) AS
WITH children AS (
  SELECT *
  FROM UNNEST([
    STRUCT(1 AS id, 'Adrian' AS name, ARRAY<STRING>['ACTION_FIGURES', 'CRAFTS'] AS wish_present_type, ARRAY<STRING>['REMOTE_CONTROL', 'MODELS'] AS dislike_present_type, 2 AS number_of_presents, FALSE AS naughty)
    , (2, 'Alex', ['DOLLS', 'EDUCATIONAL'], NULL, 3, FALSE)
    , (3, 'Glenn', NULL,  ARRAY<STRING>['TECHNOLOGY'], 2, TRUE)
    , (4, 'Karin', NULL, NULL, 3, FALSE)
    , (5, 'Marc', ['CRAFTS', 'BUILDING', 'DOLLS'],  ARRAY<STRING>['EDUCATIONAL', 'TECHNOLOGY'], 1, FALSE)
    , (6, 'Martin', ['SPORTS', 'ACTION_FIGURES'], NULL, 2, FALSE)
    , (7, 'Matt', ['DOLLS'], NULL, 3, FALSE)
    , (8, 'Pete', ['EDUCATIONAL', 'TECHNOLOGY'], NULL, 1, FALSE)
    , (9, 'Rob', NULL,  ARRAY<STRING>['SPORTS'], 2, FALSE)
    , (10, 'Sean', ['SOFT_TOYS', 'PUZZLES', 'SPORTS'], NULL, 1, FALSE)
    , (11, 'Willis', ['REMOTE_CONTROL'], NULL, 2, FALSE)
  ])
)
SELECT *
FROM children
ORDER BY id;


###### Presents ########################################################################################################
# Alternative example using UNION ALL to generate sample data and achieve the same effect as UNNEST & STRUCT
# A present can be 1 or more of the same categories used for the children wish/dislike lists:
# ACTION_FIGURES, CRAFTS, BUILDING, DOLLS, EDUCATIONAL, TECHNOLOGY, PUZZLES, SOFT_TOYS, MODELS, SPORTS, REMOTE_CONTROL
########################################################################################################################
CREATE OR REPLACE VIEW `{project_id}.{dataset_id}.present`
OPTIONS (
  description='Inventory of the presents the Elves have been making all year'
) AS
WITH presents AS (
  SELECT 1 AS id, 'Present #1' AS description, 'High' AS value, ARRAY<STRING>['EDUCATIONAL', 'CRAFTS', 'BUILDING'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 2 AS id, 'Present #2' AS description, 'Low' AS value, ARRAY<STRING>['DOLLS', 'ACTION_FIGURES'] AS present_types, 3 AS stock_level UNION ALL
  SELECT 3 AS id, 'Present #3' AS description, 'High' AS value, ARRAY<STRING>['EDUCATIONAL', 'CRAFTS', 'SPORTS'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 4 AS id, 'Present #4' AS description, 'Medium' AS value, ARRAY<STRING>['TECHNOLOGY', 'ACTION_FIGURES'] AS present_types, 3 AS stock_level UNION ALL
  SELECT 5 AS id, 'Present #5' AS description, 'Low' AS value, ARRAY<STRING>['SOFT_TOYS', 'MODELS'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 6 AS id, 'Present #6' AS description, 'High' AS value, ARRAY<STRING>['SOFT_TOYS'] AS present_types, 4 AS stock_level UNION ALL
  SELECT 7 AS id, 'Present #7' AS description, 'High' AS value, ARRAY<STRING>['REMOTE_CONTROL'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 8 AS id, 'Present #8' AS description, 'Low' AS value, ARRAY<STRING>['BUILDING', 'ACTION_FIGURES'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 9 AS id, 'Present #9' AS description, 'Medium' AS value, ARRAY<STRING>['TECHNOLOGY', 'REMOTE_CONTROL', 'CRAFTS'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 10 AS id, 'Present #10' AS description, 'High' AS value, ARRAY<STRING>['ACTION_FIGURES'] AS present_types, 3 AS stock_level UNION ALL
  SELECT 11 AS id, 'Present #11' AS description, 'High' AS value, ARRAY<STRING>['CRAFTS'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 12 AS id, 'Present #12' AS description, 'Low' AS value, ARRAY<STRING>['MODELS', 'PUZZLES', 'SOFT_TOYS'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 13 AS id, 'Present #13' AS description, 'Low' AS value, ARRAY<STRING>['SPORTS'] AS present_types, 3 AS stock_level UNION ALL
  SELECT 14 AS id, 'Present #14' AS description, 'Medium' AS value, ARRAY<STRING>['REMOTE_CONTROL'] AS present_types, 4 AS stock_level UNION ALL
  SELECT 15 AS id, 'Present #15' AS description, 'High' AS value, ARRAY<STRING>['DOLLS', 'EDUCATIONAL'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 16 AS id, 'Present #16' AS description, 'Low' AS value, ARRAY<STRING>['TECHNOLOGY', 'SPORTS'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 17 AS id, 'Present #17' AS description, 'High' AS value, ARRAY<STRING>['EDUCATIONAL'] AS present_types, 2 AS stock_level UNION ALL
  SELECT 18 AS id, 'Present #18' AS description, 'Medium' AS value, ARRAY<STRING>['PUZZLES'] AS present_types, 3 AS stock_level UNION ALL
  SELECT 19 AS id, 'Present #19' AS description, 'High' AS value, ARRAY<STRING>['TECHNOLOGY'] AS present_types, 1 AS stock_level UNION ALL
  SELECT 20 AS id, 'Present #20' AS description, 'Low' AS value, ARRAY<STRING>['REMOTE_CONTROL', 'PUZZLES'] AS present_types, 2 AS stock_level
)
SELECT *
FROM presents
ORDER BY id;


###### Children/Presents ###############################################################################################
# Every combination possible of Children and Presents
########################################################################################################################
CREATE OR REPLACE VIEW `{project_id}.{dataset_id}.child_present`
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
FROM `{project_id}.{dataset_id}.child` AS c
CROSS JOIN `{project_id}.{dataset_id}.present` AS p
ORDER BY c.id, p.id;


###### Child/Present - dislike score ###################################################################################
# To summarise what is going on in this SQL:
#
# - We start with all the child/present combinations (the child_present view).
# - We then join on all the child dislikes. We can think of the UNNEST syntax as effectively converting the array of
#   children dislikes and converting them into a separate table to join to.
# - Similarly, we join to the all the present types, again using the UNNEST syntax.
# - In order to use SQL aggregate functions, we need to GROUP the data. We want the original combinations of children
#   and presents, so we group on the child and present ids respectively.
# - The selection of the child and present ids are for reference. Similarly, the STRING_AGG function groups the array
#   that we split up into a comma separated string - we can use this later to verify the logic has worked correctly.
# - The dislike_match_count is used to count how many matches of our disliked present categories there are in the
#   current present category - again, used for reference.
# - The dislike_score uses the same logic, but multiples this count by a large negative number (-9999999) - the more
#   matches, the larger the number - although a single count will ensure the child never receives the present.
########################################################################################################################
CREATE OR REPLACE VIEW `{project_id}.{dataset_id}.child_present_dislike_score`
OPTIONS (
  description='Negative scores for any presents that the children said they didn\'t like'
) AS
SELECT cp.child_id
, cp.present_id
, STRING_AGG(DISTINCT cdlpt) AS child_dislike_present_types
, STRING_AGG(DISTINCT pt) AS present_types
, COUNTIF(DISTINCT cdlpt IN UNNEST(cp.present_types)) AS dislike_match_count
, -9999999 * COUNTIF(DISTINCT cdlpt IN UNNEST(cp.present_types)) AS dislike_score
FROM `{project_id}.{dataset_id}.child_present` AS cp
LEFT JOIN UNNEST(cp.child_dislike_present_type) AS cdlpt
LEFT JOIN UNNEST(cp.present_types) AS pt
GROUP BY cp.child_id
, cp.present_id
ORDER BY cp.child_id
, cp.present_id;

--- ### Child/Present - wish score ###
CREATE OR REPLACE VIEW `{project_id}.{dataset_id}.child_present_wish_score`
OPTIONS (
  description='Positive scores for any presents that the children wished for'
) AS
SELECT cp.child_id
, cp.present_id
, STRING_AGG(DISTINCT cwpt) AS child_wish_present_types
, STRING_AGG(DISTINCT pt) AS present_types
, COUNTIF(DISTINCT cwpt IN UNNEST(cp.present_types)) AS wish_match_count
, 10 * COUNTIF(DISTINCT cwpt IN UNNEST(cp.present_types)) AS wish_score
FROM `{project_id}.{dataset_id}.child_present` AS cp
LEFT JOIN UNNEST(cp.child_wish_present_type) AS cwpt
LEFT JOIN UNNEST(cp.present_types) AS pt
GROUP BY cp.child_id
, cp.present_id
ORDER BY cp.child_id
, cp.present_id;

--- ### Child/Present - present count ###
CREATE OR REPLACE VIEW `{project_id}.{dataset_id}.child_present_count`
OPTIONS (
  description='The max amount of presents a child could potentially have if they have 1 of every present available'
) AS
SELECT cp.child_id
, COUNT(cp.present_id) AS present_count
FROM `{project_id}.{dataset_id}.child_present` AS cp
GROUP BY cp.child_id
ORDER BY cp.child_id;

--- ### Child/Present - value count ###
CREATE OR REPLACE VIEW `{project_id}.{dataset_id}.child_present_value_count`
OPTIONS (
  description='The count of value presents (high/medium/low) for each child'
) AS
SELECT cp.child_id
, cp.present_value
, COUNT(cp.present_id) AS present_count
FROM `{project_id}.{dataset_id}.child_present` AS cp
GROUP BY cp.child_id
, cp.present_value
ORDER BY cp.child_id
, cp.present_value;

--- ### Child/Present - value score ###
CREATE OR REPLACE VIEW `{project_id}.{dataset_id}.child_present_value_score`
OPTIONS (
  description='The score for present for each child based on the value'
) AS
SELECT cpc.child_id
, cpc.present_count AS child_present_count
, cpvc.present_value
, cpvc.present_count AS present_value_count
, 10 * cpvc.present_count / cpc.present_count AS present_diversity_score
FROM `{project_id}.{dataset_id}.child_present_count` AS cpc
LEFT JOIN `{project_id}.{dataset_id}.child_present_value_count` AS cpvc ON cpc.child_id = cpvc.child_id
ORDER BY cpc.child_id;

--- ### Child/Present - value score ###
CREATE OR REPLACE VIEW `{project_id}.{dataset_id}.child_present_score`
OPTIONS (
  description='The business rule scores and total score for the child/present combination'
) AS
WITH child_present_scores AS (
  SELECT cp.child_id
  , cp.child_name
  , cp.child_naughty
  , cpds.child_dislike_present_types
  , cpws.child_wish_present_types
  , cp.present_id
  , cp.present_description
  , cp.present_value
  , cpws.present_types
  , COALESCE(cpds.dislike_score, 0) AS br_excl_present_dislike_score
  , COALESCE(cpws.wish_score, 0) AS br_weight_present_wish_score
  , COALESCE(cpvs.present_diversity_score, 0) AS br_weight_present_diversity_score
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
  FROM `{project_id}.{dataset_id}.child_present` AS cp
  LEFT JOIN `{project_id}.{dataset_id}.child_present_dislike_score` AS cpds
    ON cp.child_id = cpds.child_id
    AND cp.present_id = cpds.present_id
  LEFT JOIN `{project_id}.{dataset_id}.child_present_wish_score` AS cpws
    ON cp.child_id = cpws.child_id
    AND cp.present_id = cpws.present_id
  LEFT JOIN `{project_id}.{dataset_id}.child_present_value_score` AS cpvs
    ON cp.child_id = cpvs.child_id
    AND cp.present_value = cpvs.present_value
)
SELECT *
, (br_excl_present_dislike_score + br_weight_present_wish_score + br_weight_present_diversity_score + br_weight_product_value_score) AS score
FROM child_present_scores
ORDER BY child_id
, score DESC
, present_id;







