# Codebook — Diabetes 130-US Hospitals Dataset

Source table: `diabetes.staging_diabetic_data`. Derived table: `diabetes.encounter_analysis` (built in `04_analytical_table.sql`).

## Raw fields used

| Field | Type | Description |
|---|---|---|
| `encounter_id` | INTEGER | Unique identifier for the hospital encounter (grain of the analysis). |
| `patient_nbr` | INTEGER | Unique identifier for the patient; a patient may have multiple encounters. |
| `race` | STRING | Patient race, as recorded. |
| `gender` | STRING | Patient gender, as recorded. |
| `age` | STRING | Age bracket, e.g. `[70-80)` — 10-year bins. |
| `time_in_hospital` | INTEGER | Length of stay, in days. |
| `num_lab_procedures` | INTEGER | Number of lab tests performed during the encounter. |
| `num_procedures` | INTEGER | Number of procedures (excluding lab tests) performed. |
| `num_medications` | INTEGER | Number of distinct medications administered during the encounter. |
| `number_outpatient` | INTEGER | Number of outpatient visits by the patient in the year preceding the encounter. |
| `number_emergency` | INTEGER | Number of emergency visits by the patient in the year preceding the encounter. |
| `number_inpatient` | INTEGER | Number of inpatient visits by the patient in the year preceding the encounter. |
| `number_diagnoses` | INTEGER | Number of diagnoses entered for the encounter. |
| `A1Cresult` | STRING | HbA1c test result category (e.g. `>8`, `>7`, `Norm`, or not measured). |
| `max_glu_serum` | STRING | Glucose serum test result category. |
| `change` | STRING | Whether a change was made to diabetic medications during the encounter (`Ch` / `No`). |
| `diabetesMed` | STRING | Whether a diabetes medication was prescribed. |
| `readmitted` | STRING | Original readmission field: `<30`, `>30`, or `NO`. |

## Derived fields

| Field | Built in | Logic |
|---|---|---|
| `Utilization_Category` | `01_risk_categorization.sql` | `High Utilization` if `number_emergency >= 2` OR `number_inpatient >= 2`, else `Low Utilization`. |
| `Complexity_Category` | `01_risk_categorization.sql` | `High Complexity` if `number_diagnoses >= 8` OR `num_medications >= 15`, else `Low Complexity`. |
| `Risk_Category` | `01_risk_categorization.sql` | `High Risk` only if **both** Utilization and Complexity are High; otherwise `Low Risk`. |
| `day30_readmission` | `04_analytical_table.sql` | `Within 30 days` if `readmitted = '<30'`, else `Not within 30 days`. |

## Tables

- **`diabetes.staging_diabetic_data`** — raw/staged source data.
- **`diabetes.encounter_analysis`** — permanent table with all raw fields plus the three derived categories and `day30_readmission`; one row per `encounter_id`. Built and validated in `04_analytical_table.sql`.
- **`diabetes.encounter_risk_profile`**, **`diabetes.follow_up`** — supplementary tables joined in `03_joins.sql` to demonstrate inner/left join logic and follow-up availability.
