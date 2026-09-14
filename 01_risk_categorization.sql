-- Defining High Utilization
-- High Utilization is defined as 2 or more emergency visits OR 2 or more prior inpatient visits.
SELECT
  CASE
    WHEN number_emergency >= 2 OR number_inpatient >= 2
      THEN 'High Utilization'
    ELSE 'Low Utilization'
  END AS Utilization_Category,
  COUNT(*) AS encounters
FROM `diabetes.staging_diabetic_data`
GROUP BY Utilization_Category
ORDER BY encounters DESC;

-- Defining High Complexity
-- High Complexity is defined as 8 or more diagnoses OR 15 or more medications on the encounter.
SELECT
  CASE
    WHEN number_diagnoses >= 8 OR num_medications >= 15
      THEN 'High Complexity'
    ELSE 'Low Complexity'
  END AS Complexity_Category,
  COUNT(*) AS encounters,
  ROUND(AVG(time_in_hospital), 2) AS avg_length_of_stay
FROM `diabetes.staging_diabetic_data`
GROUP BY Complexity_Category
ORDER BY encounters DESC;

-- Combining into a Risk Category
-- High Risk requires BOTH High Utilization and High Complexity at the same time — this is a deliberately strict definition so 'High Risk' identifies encounters that are stressing the system on more than one dimension at once, not just one.
WITH categories AS (
  SELECT
    *,
    CASE WHEN number_emergency >= 2 OR number_inpatient >= 2
      THEN 'High Utilization' ELSE 'Low Utilization' END AS Utilization_Category,
    CASE WHEN number_diagnoses >= 8 OR num_medications >= 15
      THEN 'High Complexity' ELSE 'Low Complexity' END AS Complexity_Category
  FROM `diabetes.staging_diabetic_data`
)
SELECT
  Utilization_Category,
  Complexity_Category,
  CASE WHEN Utilization_Category = 'High Utilization'
        AND Complexity_Category = 'High Complexity'
       THEN 'High Risk' ELSE 'Low Risk' END AS Risk_Category,
  COUNT(*) AS encounters
FROM categories
GROUP BY Utilization_Category, Complexity_Category, Risk_Category
ORDER BY encounters DESC;

-- Readmission rate by category
-- With the three categories defined, the first real analytical question: does any one of them actually relate to 30-day readmission?
SELECT
  Risk_Category,
  COUNT(*) AS total_encounters,
  COUNTIF(day30_readmission = 'Within 30 days') AS readmissions,
  ROUND(COUNTIF(day30_readmission = 'Within 30 days') / COUNT(*) * 100, 2) AS readmission_rate
FROM `diabetes.encounter_analysis`
GROUP BY Risk_Category;

