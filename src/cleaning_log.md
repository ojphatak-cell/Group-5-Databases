## 2. Cleaning log

### 2.1 How is missing data reported?

| Dataset | Finding | Treatment |
|---|---|---|
| A | `Displaced_Females` and `Displaced_Males` are empty (blank) in all rows. In Humla, `Displaced_Females` holds a stray line break. | Columns not loaded. |
| A | Counts are never blank; "nothing happened" and "not reported" are both `0` (many remote districts are all zeros). | Loaded as 0. Cannot be distinguished, noted as a limitation. |
| A | The Palpa row has exactly the same households and population as Nawalparasi (128,793 / 643,508). This is a copy error: the two districts are very different in size. | Palpa population and households set to NULL (the schema allows NULL). |
| B | No blank cells. Missing data is shown by **absent rows**: a district only has a row in periods where flooding was detected (minimum flooded area is 1 ha). | Absent row = "no flooding detected" (our assumption, not stated by the source). Not filled with zeros. |
| B | Period 36 (2025-06-16 to 2025-06-30) is absent for **all** districts, which is more likely a gap in the file than "no flooding anywhere". | Kept as missing. Queries must not treat it as zero. |

### 2.2 How are dates formatted?

| Dataset | Finding | Treatment |
|---|---|---|
| A | No date column. The event date (25 April 2015) only exists in the HDX metadata. `ZONE_CODE` values such as `1/1/0524` look like dates and would be converted by spreadsheet software. | Date taken from metadata. Zone code not loaded. |
| B | ISO format `YYYY-MM-DD`, but day and month are **swapped** in `start_date` for 8 periods (518 rows). Example: period 13 has start `2024-01-07` and end `2024-07-15`; the real start is 2024-07-01. | If `MONTH(start) <> MONTH(end)`, month and day of `start_date` are swapped back (`load_real_data.sql`, step 3). A CHECK constraint on `flood_period` now rejects any period that crosses a month. |

### 2.3 Are there duplicate records?

| Dataset | Finding | Treatment |
|---|---|---|
| A | No duplicate rows or `DIST_ID`. The Palpa/Nawalparasi duplicated values are described above. The totals row (district empty) repeats information held in the district rows. | Totals row excluded and used only to check the loaded sums (`validate_data.py`, section 1). |
| B | No duplicate rows and no duplicate (`adm2_pcode`, `start_date`). After mapping East/West halves to their parent district there are intentional duplicate keys. | Halves summed (see 2.4). 2,896 raw rows become 2,823; totals of flooded hectares (6,332,148) and exposed people (15,840,626) are identical before and after. |

### 2.4 Are there inconsistent naming conventions?

| Finding | Treatment |
|---|---|
| A uses the old 14 **zones** (e.g. Mechi, Koshi, Bagmati) and B uses the 7 **provinces** (Koshi, Madhesh, Bagmati…). "Koshi" means a different area in each file. | `location.region` = province, taken from B. Zones not loaded. |
| A has 75 districts, B has 77. Nawalparasi and Rukum are split into "East"/"West" in B. | B rows are summed into the parent district. The province of the larger part (by area implied by the flooded percentage) is used: Nawalparasi → Gandaki, Rukum → Lumbini. |
| Different code systems (A: `E-MEC-01`, B: `NP0775`); the files cannot be joined on code. | Joined on district name. All 73 unchanged names match exactly (also in spelling, e.g. `Chitawan`). |
| Column names: A mixes styles (`Total Household`, `Death_Female`, `GovtBuild_Damage`) and has two columns called `Unknown`; B is `snake_case`. | Renamed to one convention in the new tables (`deaths_unknown`, `injured_unknown`, `govt_buildings_damaged`…). |
| B starts with a UTF-8 byte-order mark; A uses Windows line endings (and a quoted line break inside one cell), B uses Unix line endings. | Handled by pandas when loading staging. |
| `DIST_ID` order differs from `HLCIT_CODE` order in several rows (e.g. 12/13, 37–41). | `DIST_ID` used as `location_id`; no data change. |
| "GovtBuild_Damage" vs "GovtBuild_PartDamage" is not defined in the file. | Interpreted as fully damaged vs partly damaged (assumption). |
