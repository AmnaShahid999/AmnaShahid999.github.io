-- Building the permanent analytical table
-- Rather than re-deriving Utilization, Complexity, and Risk in every query, they're computed once into a permanent table — this is also where the earlier utilization bug (an accidental <= instead of >=) gets caught and fixed for good.
CREATE OR REPLACE TABLE `diabetes.encounter_analysis` AS
WITH encounter_categories AS (
  SELECT
    encounter_id, patient_nbr, race, gender, age,
    time_in_hospital, num_lab_procedures, num_procedures, num_medications,
    number_outpatient, number_emergency, number_inpatient, number_diagnoses,
    A1Cresult, max_glu_serum, change, diabetesMed, readmitted,

    CASE WHEN number_emergency >= 2 OR number_inpatient >= 2
      THEN 'High Utilization' ELSE 'Low Utilization' END AS Utilization_Category,

    CASE WHEN number_diagnoses >= 8 OR num_medications >= 15
      THEN 'High Complexity' ELSE 'Low Complexity' END AS Complexity_Category,

    CASE WHEN readmitted = '<30'
      THEN 'Within 30 days' ELSE 'Not within 30 days' END AS day30_readmission

  FROM `diabetes.staging_diabetic_data`
)
SELECT
  *,
  CASE WHEN Utilization_Category = 'High Utilization'
        AND Complexity_Category = 'High Complexity'
       THEN 'High Risk' ELSE 'Low Risk' END AS Risk_Category
FROM encounter_categories;

-- Validating row counts and keys
-- The table should have exactly as many rows as the source, and encounter_id — the grain of this table — should never repeat.
SELECT COUNT(*) AS staging_rows FROM `diabetes.staging_diabetic_data`;
SELECT COUNT(*) AS analysis_rows FROM `diabetes.encounter_analysis`;

SELECT encounter_id, COUNT(*) AS n
FROM `diabetes.encounter_analysis`
GROUP BY encounter_id
HAVING n >= 2;

-- Validating the derived logic itself
-- It's not enough to check that the columns exist — each CASE statement's logic needs to be checked against the raw fields it was built from. Each of these three checks should return zero.
-- Should return 0: no encounter should be flagged High Utilization
-- unless it actually meets the threshold.
SELECT COUNTIF(Utilization_Category = 'High Utilization') AS should_be_zero
FROM `diabetes.encounter_analysis`
WHERE number_emergency < 2 AND number_inpatient < 2;

-- Should return 0: same check for Complexity.
SELECT COUNTIF(Complexity_Category = 'High Complexity') AS should_be_zero
FROM `diabetes.encounter_analysis`
WHERE number_diagnoses < 8 AND num_medications < 15;

-- Should return 0: High Risk requires both flags, not just one.
SELECT COUNTIF(Risk_Category = 'High Risk') AS should_be_zero
FROM `diabetes.encounter_analysis`
WHERE Complexity_Category != 'High Complexity'
   OR Utilization_Category != 'High Utilization';

-- Sanity-checking against the baseline
-- Final check: the overall averages in the new table should match the baseline profiling numbers from Day 1 — if they don't, something broke in the build.
SELECT
  COUNT(*) AS total_encounters,
  ROUND(AVG(time_in_hospital), 2) AS avg_time_in_hospital,
  ROUND(AVG(num_medications), 2) AS avg_num_medications,
  ROUND(AVG(number_diagnoses), 2) AS avg_number_diagnoses
FROM `diabetes.encounter_analysis`;

