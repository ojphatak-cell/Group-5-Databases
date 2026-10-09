## 2. Cleaning log

**Dataset A** – `nepal_earthquake_data.csv`: 2015 earthquake casualties and damage, 75 districts.
**Dataset B** – `npl-flood-events-fao-eve.csv`: flooding per district per two-week period, July 2024 – July 2026, 2,896 rows.

All cleaning happens in `db/load_real_data.sql`. The raw CSVs are first copied unchanged into staging tables.

### 2.1 Missing data

| Data | Problem | What we did |
|---|---|---|
| A | `Displaced_Females` and `Displaced_Males` are empty in every row. | Not loaded. |
| A | A count of `0` can mean "nothing happened" or "not reported". | Loaded as `0`. Noted as a limitation. |
| A | Palpa has the exact same population and households as Nawalparasi, a copy error. | Palpa's population and households set to `NULL`. |
| B | A district only has a row when flooding was found, so a missing row means "no flooding". | Missing rows are not filled with zeros. |
| B | Period 36 (16–30 June 2025) is missing for every district, which looks like a gap in the file. | Left missing. Queries must not read it as zero flooding. |

### 2.2 Dates

| Data | Problem | What we did |
|---|---|---|
| A | No date column. The earthquake date (25 April 2015) is only in the dataset's description. | Taken from the description. |
| B | In 518 rows, day and month are swapped in `start_date`. For example, `2024-01-07` with end date `2024-07-15` really means 1 July 2024. | When start and end fall in different months, the start date's day and month are swapped back. A `CHECK` on `flood_period` rejects any period that crosses a month. |

### 2.3 Duplicates

| Data | Problem | What we did |
|---|---|---|
| A, B | No duplicate rows or IDs. | Nothing needed. |
| B | After joining the East/West halves of a district (see 2.4), the same district and period appear twice. | The two halves are added together, so 2,896 rows become 2,823. Totals stay the same: 6,332,148 ha flooded, 15,840,626 people exposed. |

### 2.4 Naming and consistency

| Problem | What we did |
|---|---|
| A uses the old 14 zones, B uses the current 7 provinces. "Koshi" means a different area in each. | `location.region` is the province from B. Zones are not loaded. |
| A has 75 districts, B has 77: Nawalparasi and Rukum are split into East and West in B. | B's halves are added into the parent district. Region is the province of the larger half: Nawalparasi → Gandaki, Rukum → Lumbini. |
| The files use different district codes, so they can't be joined on code. | Joined on district name. All 73 other names match exactly. |
| Column names mix styles in A (`Total Household`, `Death_Female`) and A has two columns both called `Unknown`. | Renamed to one style in our tables (`deaths_unknown`, `injured_unknown`, …). |
| Lalitpur's `Tot_Deaths` is 176, but its female + male + unknown deaths add up to 177. | We store the parts and compute the total (177). The national total becomes 8,713 instead of 8,712. |
| A does not explain `GovtBuild_Damage` vs `GovtBuild_PartDamage`. | Assumed to mean fully vs partly damaged. |
