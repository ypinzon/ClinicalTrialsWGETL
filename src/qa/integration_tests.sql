-------------------------------------------------------------------
-- Observational Health Data Sciences and Informatics
-- Clinical Trials Workgroup
-------------------------------------------------------------------
DROP TABLE IF EXISTS temp.test_report PURGE;

CREATE TABLE temp.test_report
  (
     test_id          INT,
     rule_id          STRING,
     test_description STRING,
     expected_result  INT,
     actual_result    INT,
     passed_flg       STRING
  ) using parquet;


-------------------------------------------------------------------
-- cdm.person tests
-------------------------------------------------------------------
INSERT INTO temp.test_report
SELECT 1                                                               AS
       test_id,
       'person'                                                        AS
       rule_id,
       'Count difference between the cdm and the source after filters' AS
       test_description,
       0                                                               AS
       expected_result,
       result                                                          AS
       actual_result,
       CASE
         WHEN result = 0 THEN 'Passed'
         ELSE 'Failed'
       END                                                             AS
       passed_flg
FROM   (SELECT ( (SELECT Count(*)
                  FROM   cdm.person) - (SELECT Count(*)
                                        FROM   src.dm
                                        WHERE  usubjid IS NOT NULL
                                               AND rfpendtc IS NOT NULL
                                               AND age IS NOT NULL
                                               AND Cast(Concat(Cast(Year(dmdtc)
                                                                    - age
                                                                    AS INT),
                                                        '-01-01') AS DATE) <=
                                                   Cast(
                                                   '2015-03-31' AS DATE)) ) AS  -- Interim Analysis Data Cutoff Date
               result)
       tbl;


-------------------------------------------------------------------
-- cdm.observation_period tests
-------------------------------------------------------------------
-- Check if each person has an observation period
INSERT INTO temp.test_report
SELECT 2                                                AS test_id,
       'observation_period'                             AS rule_id,
       'Check if each person has an observation period' AS test_description,
       0                                                AS expected_result,
       result                                           AS actual_result,
       CASE
         WHEN result = 0 THEN 'Passed'
         ELSE 'Failed'
       end                                              AS passed_flg
FROM   (SELECT ( (SELECT Count(*)
                  FROM   cdm.person) - (SELECT Count(DISTINCT op.person_id)
                                        FROM   cdm.observation_period op
                                               INNER JOIN cdm.person per
                                                       ON per.person_id =
                                                          op.person_id)
                      ) AS
               result) tbl;

-- Check if the end date is always greater or equal to the start date
INSERT INTO temp.test_report
SELECT 3                                                                    AS
       test_id,
       'observation_period'                                                 AS
       rule_id,
       'Check if the end date is always greater or equal to the start date' AS
       test_description,
       0                                                                    AS
       expected_result,
       result                                                               AS
       actual_result,
       CASE
         WHEN result = 0 THEN 'Passed'
         ELSE 'Failed'
       end                                                                  AS
       passed_flg
FROM   (SELECT Count(*) AS result
        FROM   cdm.observation_period
        WHERE  observation_period_start_date > observation_period_end_date) tbl;

-- Check if the observation_period_start_date is in a correct range
INSERT INTO temp.test_report
SELECT 4                                                                  AS
       test_id,
       'observation_period'                                               AS
       rule_id,
       'Check if the observation_period_start_date is in a correct range' AS
       test_description,
       0                                                                  AS
       expected_result,
       result                                                             AS
       actual_result,
       CASE
         WHEN result = 0 THEN 'Passed'
         ELSE 'Failed'
       end                                                                AS
       passed_flg
FROM   (SELECT Count(*) AS result
        FROM   cdm.observation_period op
               LEFT JOIN cdm.person per
                      ON per.person_id = op.person_id
               LEFT JOIN cdm.death dth
                      ON dth.person_id = op.person_id
        WHERE  op.observation_period_start_date <
               Cast(Concat(per.year_of_birth, '-01-01') AS
                       date)
                OR ( op.observation_period_start_date >
                     Cast('2015-03-31' AS date) )  -- Interim Analysis Data Cutoff Date
                OR ( dth.death_date IS NOT NULL
                     AND Date_add(dth.death_date, 60) <
                         op.observation_period_start_date )) tbl;

-- Check if the observation_period_end_date is in a correct range
INSERT INTO temp.test_report
SELECT 5                                                                AS
       test_id,
       'observation_period'                                             AS
       rule_id,
       'Check if the observation_period_end_date is in a correct range' AS
       test_description,
       0                                                                AS
       expected_result,
       result                                                           AS
       actual_result,
       CASE
         WHEN result = 0 THEN 'Passed'
         ELSE 'Failed'
       end                                                              AS
       passed_flg
FROM   (SELECT Count(*) AS result
        FROM   cdm.observation_period op
               LEFT JOIN cdm.person per
                      ON per.person_id = op.person_id
               LEFT JOIN cdm.death dth
                      ON dth.person_id = op.person_id
        WHERE  op.observation_period_end_date <
               Cast(Concat(per.year_of_birth, '-01-01'
               ) AS
                       date)
                OR ( op.observation_period_end_date > Cast('2015-03-31' AS date)  -- Interim Analysis Data Cutoff Date
                   )
                OR ( dth.death_date IS NOT NULL
                     AND Date_add(dth.death_date, 60) <
                         op.observation_period_end_date
                   )) tbl;


-------------------------------------------------------------------
-- cdm.death tests
-------------------------------------------------------------------
-- Count difference between the cdm and the source
INSERT INTO temp.test_report
SELECT 6                                                 AS test_id,
       'death'                                           AS rule_id,
       'Count difference between the cdm and the source' AS test_description,
       0                                                 AS expected_result,
       result                                            AS actual_result,
       CASE
         WHEN result = 0 THEN 'Passed'
         ELSE 'Failed'
       end                                               AS passed_flg
FROM   (SELECT ( (SELECT Count(*)
                  FROM   cdm.death) - (SELECT Count(*)
                                       FROM   src.dm src
                                              INNER JOIN cdm.person per
                                                      ON per.person_source_value
                                                         =
                                                         src.usubjid
                                       WHERE  src.dthfl = 'Y'
                                              AND src.dthdtc IS NOT NULL) ) AS
               result)
       tbl;
