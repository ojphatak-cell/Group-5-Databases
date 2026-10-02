# Group 5 — Disaster Response Database

A relational database for coordinating disaster response: affected
locations, buildings, the organizations and people involved, the
operations they run, and the field reports they file and real
earthquake and flood data per district.

## Project overview
Week 1:
Societal problem definition - `resources\Assignment 1  - Databases.pdf`

Week 2:
ERD - `resources\Group 5 - Disaster Response Coordination Database ERD.pdf`

Week 3:
Schema definition and constraints - `db\schema.sql`, `db\test_data.sql`, `src\crud.py`, 
`advanced_queries.py`

Week 4:
Stakeholder video - `resources\Disaster Response Database — Stakeholder Pitch.mp4`

Week 5:
Real data integration - `db\load_real_data.sql`, `db\nepal_earthquake_data.csv`, 
`db\npl-flood-events-fao-eve.csv`, `src\validate_data.py`

## Schema

location(location_id PK, location_name UNIQUE, region, damage_level, population, households)
organization(org_id PK, org_name, org_type, contact_info)
person(person_id PK, name, age, status)
building(building_id PK, location_id FK, building_type, damage_status)
operations(operation_id PK, org_id FK, location_id FK, operation_type, start_date, status)
report(report_id PK, person_id FK, location_id FK, report_text, reported_at, reliability_score)

earthquake_impact(location_id PK/FK, deaths_*, injured_*, govt_/public_buildings_*)      
flood_period(period_start PK, period_end)                                                    
flood_observation(location_id FK, period_start FK -> PK together, cropland_flooded_ha,
                  total_area_flooded_ha, pop_exposed)                                        
v_earthquake_impact                                                                       


## Running it

Requires Python 3, MySQL/MariaDB (8.0+ / 10.5+ for `CHECK` constraints) and:

pip install sqlalchemy pandas pymysql


1. Create a database called `floods` and set the user and password in `src/setup.py`.
2. From the repository root:


python3 src/main.py            # staging -> schema -> real data -> mock data -> 6 queries
python3 src/validate_data.py   # checks (all lines should show OK / rejected)


## Running it on MySQL

`schema.sql`, `data.sql` and `queries.sql` are plain SQL and load
into MySQL (8.0+) the same way they load into SQLite:

```bash
mysql -u <user> -p <database> < schema.sql
mysql -u <user> -p <database> < data.sql
mysql -u <user> -p <database> < queries.sql
```

## Example queries (`src/advanced_queries.py`)

1. Active operations per organization.
2. Locations whose average report reliability is below the overall average.
3. Locations with more than one Severe or Destroyed building.
4. Earthquake casualties and latest flood exposure per region *(real data)*.
5. High/Critical districts without an active operation *(real data + mock operations)*.
6. Earthquake-hit districts with the highest flood exposure in the latest period *(both datasets)*.


## Database URLs
1. https://data.humdata.org/dataset/official-figures-for-casualties-and-damage/resource/af078993-cea6-404e-9b25-04547aed9601
Publication Date: 01 May 2015
Data license: https://docs.humdata.org/about/data-licenses

2. https://data.humdata.org/dataset/fao-eve-global-flood-monitoring-system/resource/89dec06d-cab1-463f-8c6f-057edb0c8783
Publication Date: 03 April 2025
Data License: https://docs.humdata.org/about/data-licenses
