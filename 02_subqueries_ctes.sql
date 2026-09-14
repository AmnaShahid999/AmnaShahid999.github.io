-- Scalar subquery: above-average stays
-- A subquery in the WHERE clause compares each row against a single aggregate value computed on the fly.
SELECT encounter_id, time_in_hospital
FROM `diabetes.staging_diabetic_data`
WHERE time_in_hospital > (
  SELECT AVG(time_in_hospital) FROM `diabetes.staging_diabetic_data`
)
ORDER BY time_in_hospital DESC;

-- Subquery for a population percentage
-- Two independent scalar subqueries — one for the numerator, one for the denominator — answer 'what share of encounters are patients aged 70+?' in a single statement.
SELECT
  (SELECT COUNT(*) FROM `diabetes.staging_diabetic_data`
   WHERE age IN ('[70-80)', '[80-90)', '[90-100)'))
  /
  (SELECT COUNT(*) FROM `diabetes.staging_diabetic_data`)
  * 100 AS pct_aged_70_plus;

-- The same logic as a CTE
-- A CTE names the intermediate result so it can be reused and read top-to-bottom, rather than nesting subqueries inside each other.
WITH avg_stats AS (
  SELECT
    AVG(num_medications) AS avg_medications,
    AVG(number_diagnoses) AS avg_diagnoses
  FROM `diabetes.staging_diabetic_data`
)
SELECT COUNT(*) AS above_average_encounters
FROM `diabetes.staging_diabetic_data`, avg_stats
WHERE num_medications > avg_stats.avg_medications
   OR number_diagnoses > avg_stats.avg_diagnoses;

-- CTE + subquery together
-- Combining both: build the utilization/complexity flags in a CTE, then use a subquery to turn the count into a percentage of the full population.
WITH categories AS (
  SELECT
    CASE WHEN number_emergency >= 2 OR number_inpatient >= 2
      THEN 'High Utilization' ELSE 'Low Utilization' END AS Utilization,
    CASE WHEN number_diagnoses >= 8 OR num_medications >= 15
      THEN 'High Complexity' ELSE 'Lower Complexity' END AS Complexity
  FROM `diabetes.staging_diabetic_data`
)
SELECT
  (SELECT COUNTIF(Utilization = 'High Utilization' AND Complexity = 'High Complexity')
   FROM categories)
  /
  (SELECT COUNT(*) FROM `diabetes.staging_diabetic_data`)
  * 100 AS pct_both_high;

