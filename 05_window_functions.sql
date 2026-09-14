-- Why a window function instead of GROUP BY
-- GROUP BY collapses every row in a group into one summary row. A window function computes the same group-level average but keeps every individual encounter_id visible alongside it — necessary for comparing one patient's stay to their peer-group average.
SELECT
  encounter_id,
  age,
  time_in_hospital,
  ROUND(AVG(time_in_hospital) OVER (PARTITION BY age), 2) AS avg_stay_for_age_group
FROM `diabetes.encounter_analysis`;

-- Flagging above/below peer average
-- Once the window average is available per row, a CASE statement turns it into a simple two-category comparison.
WITH peer_avg AS (
  SELECT
    encounter_id, age, time_in_hospital,
    AVG(time_in_hospital) OVER (PARTITION BY age) AS avg_stay_for_age_group
  FROM `diabetes.encounter_analysis`
)
SELECT
  encounter_id, age, time_in_hospital, avg_stay_for_age_group,
  CASE WHEN time_in_hospital > avg_stay_for_age_group
    THEN 'Above Peer Average' ELSE 'At/Below Peer Average' END AS stay_vs_peers
FROM peer_avg;

-- Ranking within groups
-- ROW_NUMBER() with QUALIFY finds the 5 longest stays within each Risk Category without a separate subquery to filter on the rank.
SELECT
  encounter_id,
  Risk_Category,
  time_in_hospital,
  ROW_NUMBER() OVER (PARTITION BY Risk_Category ORDER BY time_in_hospital DESC) AS stay_rank
FROM `diabetes.encounter_analysis`
QUALIFY stay_rank <= 5;

-- Combining partitions: age AND risk category together
-- Partitioning by more than one column at once narrows the peer group further — comparing a patient only to others who share both their age bracket and their risk level.
WITH peer_avg AS (
  SELECT
    *,
    AVG(time_in_hospital) OVER (PARTITION BY age, Risk_Category) AS peer_group_avg
  FROM `diabetes.encounter_analysis`
)
SELECT
  encounter_id, age, Risk_Category, time_in_hospital, peer_group_avg,
  CASE WHEN time_in_hospital > peer_group_avg
    THEN 'Above Peer Average' ELSE 'At/Below Peer Average' END AS comparison
FROM peer_avg;

-- Putting it together: the final risk-readmission question
-- The question the whole project was building toward: do High Risk encounters actually see higher 30-day readmission than Low Risk ones, and how does that vary by age group?
SELECT
  Risk_Category,
  COUNT(*) AS total_encounters,
  COUNTIF(day30_readmission = 'Within 30 days') AS readmissions,
  ROUND(COUNTIF(day30_readmission = 'Within 30 days') / COUNT(*) * 100, 2) AS readmission_rate
FROM `diabetes.encounter_analysis`
GROUP BY Risk_Category;

SELECT
  age,
  Risk_Category,
  COUNT(*) AS total_encounters,
  ROUND(COUNTIF(day30_readmission = 'Within 30 days') / COUNT(*) * 100, 2) AS readmission_rate
FROM `diabetes.encounter_analysis`
GROUP BY age, Risk_Category
ORDER BY age, Risk_Category;

