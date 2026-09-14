-- Inner join: encounter data + risk profile
-- An INNER JOIN keeps only rows with a match in both tables — the fastest way to see how many encounters actually have a risk profile attached.
SELECT
  a.encounter_id, a.race, a.gender, a.age, a.readmitted,
  b.utilization_category, b.clinical_complexity
FROM `diabetes.staging_diabetic_data` AS a
INNER JOIN `diabetes.encounter_risk_profile` AS b
  ON a.encounter_id = b.encounter_id;

-- Left join: encounters + optional follow-up records
-- A small follow_up table only has records for encounters that were actually scheduled for follow-up. A LEFT JOIN keeps every encounter from the base table and fills in NULLs where no follow-up exists — an INNER JOIN would have silently dropped those rows.
SELECT
  a.encounter_id, a.gender, a.age, b.follow_up_status
FROM `diabetes.staging_diabetic_data` AS a
LEFT JOIN `diabetes.follow_up` AS b
  ON a.encounter_id = b.encounter_id;

-- Joining three tables
-- Chaining a second LEFT JOIN onto the first brings in follow-up detail on top of the risk profile, while still keeping every base encounter.
SELECT
  a.encounter_id, a.age, a.gender, a.readmitted,
  b.utilization_category, b.clinical_complexity,
  c.follow_up_status, c.days_to_follow_up,
  CASE WHEN c.follow_up_status IS NULL
       THEN 'Follow-up Missing' ELSE 'Follow-up Available' END AS follow_up_availability
FROM `diabetes.staging_diabetic_data` AS a
INNER JOIN `diabetes.encounter_risk_profile` AS b
  ON a.encounter_id = b.encounter_id
LEFT JOIN `diabetes.follow_up` AS c
  ON a.encounter_id = c.encounter_id;

-- Validating the join
-- Before trusting any downstream number, confirm the join didn't silently drop or duplicate rows — compare row counts before and after.
SELECT COUNT(*) AS original_rows
FROM `diabetes.staging_diabetic_data`;

SELECT COUNT(*) AS joined_rows
FROM `diabetes.staging_diabetic_data` AS a
INNER JOIN `diabetes.encounter_risk_profile` AS b
  ON a.encounter_id = b.encounter_id;

-- A duplicate key on either side of a join can silently multiply rows.
-- Checking for duplicate encounter_ids on the join key catches that before it corrupts a metric.
SELECT encounter_id, COUNT(*) AS n
FROM `diabetes.encounter_risk_profile`
GROUP BY encounter_id
HAVING n > 1;

