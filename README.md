# Group 5 — Disaster Response Database

A relational database for coordinating disaster response: affected
locations, buildings, the organizations and people involved, the
operations they run, and the field reports they file.

## Files

| File | Purpose |
|---|---|
| `schema.sql` | Tables, primary/foreign keys, constraints, indexes |
| `data.sql` | Mock data |
| `queries.sql` | 3 advanced queries |
| `db.py` | Database connection and setup |
| `crud.py` | Add / read / update / delete functions |
| `run_demo.py` | Builds the database and demonstrates everything above |

## Schema

```
location(location_id PK, location_name, region, damage_level)
organization(org_id PK, org_name, org_type, contact_info)
person(person_id PK, name, age, status)
building(building_id PK, location_id FK -> location, building_type, damage_status)
operations(operation_id PK, org_id FK -> organization, location_id FK -> location,
           operation_type, start_date, status)
report(report_id PK, person_id FK -> person, location_id FK -> location,
       report_text, reported_at, reliability_score)
```

Enum-like columns (`org_type`, `damage_level`, `status`, `building_type`,
`damage_status`, `operation_type`) use `CHECK` constraints instead of
free text. Foreign keys use `ON DELETE RESTRICT`, so a location or
organization can't be deleted while anything still references it.

## Running it

Requires only Python 3 — no extra packages to install. The demo uses
`sqlite3` (Python's built-in database module), so it runs anywhere
Python does:

```bash
python3 run_demo.py
```

This builds `disaster_response.db` from `schema.sql` and `data.sql`,
runs a small CRUD demo, and prints the results of the 3 advanced
queries in `queries.sql`.

## Running it on MySQL

`schema.sql`, `data.sql` and `queries.sql` are plain SQL and load
into MySQL (8.0+) the same way they load into SQLite:

```bash
mysql -u <user> -p <database> < schema.sql
mysql -u <user> -p <database> < data.sql
mysql -u <user> -p <database> < queries.sql
```

## Advanced queries (`queries.sql`)

1. Number of active operations per organization.
2. Locations whose average report reliability is below the overall average.
3. Locations with more than one Severely damaged or Destroyed building.
