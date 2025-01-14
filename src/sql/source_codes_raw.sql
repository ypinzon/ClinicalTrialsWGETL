-------------------------------------------------------------------
-- Observational Health Data Sciences and Informatics
-- Clinical Trials Workgroup
-------------------------------------------------------------------
DROP TABLE IF EXISTS temp.source_codes_raw PURGE;

CREATE TABLE temp.source_codes_raw
  (
     domain_id             STRING,
     vocabulary_id         STRING,
     default_vocabulary_id STRING,
     source_code           STRING,
     concept_name          STRING
  ) using parquet;

-------------------------------------------------------------------
-- DM: CODES FOR ETHNICITY
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Ethnicity'               AS domain_id,
                'PHUSE_DM_ETHNIC_maps_to' AS vocabulary_id,
                'PHUSE_Unknown_DM_ETHNIC' AS default_vocabulary_id,
                src.ethnic                AS source_code,
                src.ethnic                AS concept_name
FROM   src.dm src
WHERE  src.ethnic IS NOT NULL;


-------------------------------------------------------------------
-- DM: CODES FOR RACE
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Race'                  AS domain_id,
                'PHUSE_DM_RACE_maps_to' AS vocabulary_id,
                'PHUSE_Unknown_DM_RACE' AS default_vocabulary_id,
                src.race                AS source_code,
                src.race                AS concept_name
FROM   src.dm src
WHERE  src.race IS NOT NULL;

-------------------------------------------------------------------
-- AE: MedDRA codes
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Condition'            AS domain_id,
                'PHUSE_MedDRA_maps_to' AS vocabulary_id,
                'PHUSE_Unknown_MedDRA' AS default_vocabulary_id,
                src.aellt              AS source_code,
                src.aellt              AS concept_name
FROM   src.ae src
WHERE  src.aellt IS NOT NULL;

-------------------------------------------------------------------
-- AE: Severity
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Observation'            AS domain_id,
                'PHUSE_AE_AESEV_maps_to' AS vocabulary_id,
                'PHUSE_Unknown_AE_AESEV' AS default_vocabulary_id,
                'Severity/Intensity'
                || '|'
                || src.aesev             AS source_code,
                'Severity/Intensity'
                || '|'
                || src.aesev             AS concept_name
FROM   src.ae src
WHERE  src.aesev IS NOT NULL;

-------------------------------------------------------------------
-- AE: Seriousness
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Observation'            AS domain_id,
                'PHUSE_AE_AESER_maps_to' AS vocabulary_id,
                'PHUSE_Unknown_AE_AESER' AS default_vocabulary_id,
                'Serious Event'
                || '|'
                || src.aeser             AS source_code,
                'Serious Event'
                || '|'
                || CASE
                     WHEN src.aeser = 'Y' THEN 'Yes'
                     WHEN src.aeser = 'N' THEN 'No'
                     ELSE ''
                   end                   AS concept_name
FROM   src.ae src
WHERE  src.aeser IS NOT NULL;

-------------------------------------------------------------------
-- AE: Relation to the Study Drug
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Observation'            AS domain_id,
                'PHUSE_AE_AEREL_maps_to' AS vocabulary_id,
                'PHUSE_Unknown_AE_AEREL' AS default_vocabulary_id,
                'Relationship to Study Drug (Causality)'
                || '|'
                || src.aerel             AS source_code,
                'Relationship to Study Drug (Causality)'
                || '|'
                || src.aerel             AS concept_name
FROM   src.ae src
WHERE  src.aerel IS NOT NULL;

-------------------------------------------------------------------
-- AE: Outcome of Adverse Event
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Observation'            AS domain_id,
                'PHUSE_AE_AEOUT_maps_to' AS vocabulary_id,
                'PHUSE_Unknown_AE_AEOUT' AS default_vocabulary_id,
                'Outcome of Adverse Event'
                || '|'
                || src.aeout             AS source_code,
                'Outcome of Adverse Event'
                || '|'
                || src.aeout             AS concept_name
FROM   src.ae src
WHERE  src.aeout IS NOT NULL;

-------------------------------------------------------------------
-- AE: Occurred with Overdose
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Observation'            AS domain_id,
                'PHUSE_AE_AESOD_maps_to' AS vocabulary_id,
                'PHUSE_Unknown_AE_AESOD' AS default_vocabulary_id,
                'Occurred with Overdose'
                || '|'
                || src.aesod             AS source_code,
                'Occurred with Overdose'
                || '|'
                || CASE
                     WHEN src.aesod = 'Y' THEN 'Yes'
                     WHEN src.aesod = 'N' THEN 'No'
                     ELSE ''
                   end                   AS concept_name
FROM   src.ae src
WHERE  src.aesod IS NOT NULL;

-------------------------------------------------------------------
-- AE: Persistant or Significant Disability/Incapacity
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Condition'                 AS domain_id,
                'PHUSE_AE_AESDISAB_maps_to' AS vocabulary_id,
                'PHUSE_Unknown_AE_AESDISAB' AS default_vocabulary_id,
                'Persist or Signif Disability/Incapacity'
                || '|'
                || src.aesdisab             AS source_code,
                'Occurred with Overdose'
                || '|'
                || CASE
                     WHEN src.aesdisab = 'Y' THEN 'Yes'
                     WHEN src.aesdisab = 'N' THEN 'No'
                     ELSE ''
                   end                      AS concept_name
FROM   src.ae src
WHERE  src.aesdisab IS NOT NULL;

-------------------------------------------------------------------
-- CM: Concomitant Medications
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Drug'                       AS domain_id,
                'PHUSE_CM_maps_to'           AS vocabulary_id,
                'PHUSE_Unknown_CM'           AS default_vocabulary_id,
                src.cmtrt
                || '|'
                || src.cmdose
                || '|'
                || Coalesce(src.cmdosu, '')
                || '|'
                || Coalesce(src.cmroute, '') AS source_code,
                src.cmtrt
                || '|'
                || src.cmdose
                || '|'
                || Coalesce(src.cmdosu, '')
                || '|'
                || Coalesce(src.cmroute, '') AS concept_name
FROM   src.cm src
WHERE  src.cmtrt IS NOT NULL;

-------------------------------------------------------------------
-- CM: Concomitant Medications, Route
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Route'                      AS domain_id,
                'PHUSE_CM_ROUTE_maps_to'     AS vocabulary_id,
                'PHUSE_Unknown_CM_ROUTE'     AS default_vocabulary_id,
                src.cmroute                  AS source_code,
                src.cmroute                  AS concept_name
FROM   src.cm src
WHERE  src.cmroute IS NOT NULL;

-------------------------------------------------------------------
-- DM: Patient consented to clinical trial
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT 'Observation'                                   AS domain_id,
       'PHUSE_DM_maps_to'                              AS vocabulary_id,
       'PHUSE_Unknown_DM'                              AS default_vocabulary_id,
       'Patient consented to clinical trial'           AS source_code,
       'Patient consented to clinical trial (finding)' AS concept_name;

-------------------------------------------------------------------
-- DM: Trial arm
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT 'Observation'                     AS domain_id,
       'PHUSE_DM_maps_to'                AS vocabulary_id,
       'PHUSE_Unknown_DM'                AS default_vocabulary_id,
       'Clinical trial arm'              AS source_code,
       'Clinical trial arm'              AS concept_name;

-------------------------------------------------------------------
-- DS: Trial Outcome
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Observation'               AS domain_id,
                'PHUSE_DS_DSDECOD_maps_to'  AS vocabulary_id,
                'PHUSE_Unknown_DS_DSDECOD'  AS default_vocabulary_id,
                src.dsdecod                 AS source_code,
                src.dsdecod                 AS concept_name
FROM   src.ds src
WHERE  src.dscat != 'OTHER EVENT'
       AND src.dsdecod IS NOT NULL;

-------------------------------------------------------------------
-- SV: visit concepts (topic 2)
-------------------------------------------------------------------
INSERT INTO temp.source_codes_raw
SELECT DISTINCT 'Visit'                     AS domain_id,
                'PHUSE_SV_VISIT_maps_to'    AS vocabulary_id,
                'PHUSE_Unknown_SV_VISIT'    AS default_vocabulary_id,
                IFNULL(src.epoch || ':', '')
                || src.visit                AS source_code,
                IFNULL(src.epoch || ':', '')
                || src.visit                AS concept_name
FROM   src.sv src
WHERE  IFNULL(src.epoch || ':', '')
       || src.visit IS NOT NULL;
