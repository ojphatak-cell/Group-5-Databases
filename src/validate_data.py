
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError
from setup import get_engine

engine = get_engine()

def scalar(sql):
    with engine.connect() as c:
        return c.execute(text(sql)).scalar()

# 1.
print("== 1. Reconciliation staging -> normalized tables ==")
checks = [
    ("earthquake districts (staging minus blank row = location)",
     "SELECT COUNT(*) FROM earthquakes_staging WHERE DISTRICT IS NOT NULL",
     "SELECT COUNT(*) FROM location"),
    ("flooded hectares total",
     "SELECT SUM(total_area_flooded_ha) FROM floods_staging",
     "SELECT SUM(total_area_flooded_ha) FROM flood_observation"),
    ("people exposed total",
     "SELECT SUM(pop_exposed) FROM floods_staging",
     "SELECT SUM(pop_exposed) FROM flood_observation"),
    ("deaths female: district rows vs totals row in source file",
     "SELECT Death_Female FROM earthquakes_staging WHERE DISTRICT IS NULL",
     "SELECT SUM(deaths_female) FROM earthquake_impact"),
    ("deaths male: district rows vs totals row in source file",
     "SELECT Death_Male FROM earthquakes_staging WHERE DISTRICT IS NULL",
     "SELECT SUM(deaths_male) FROM earthquake_impact"),
    ("injured (female+male+unknown): totals row components vs district rows",
     "SELECT Injured_Female+Injured_Male+`Unknown.1` FROM earthquakes_staging WHERE DISTRICT IS NULL",
     "SELECT SUM(total_injured) FROM v_earthquake_impact"),
    ("govt buildings damaged: totals row vs district rows",
     "SELECT GovtBuild_Damage FROM earthquakes_staging WHERE DISTRICT IS NULL",
     "SELECT SUM(govt_buildings_damaged) FROM earthquake_impact"),
]
for name, a, b in checks:
    x, y = scalar(a), scalar(b)
    print(f"  {'OK ' if x == y else 'DIFF'} {name}: {x} vs {y}")

# 2. Constraints reject bad data
print("\n== 2. Constraint tests (each statement must be rejected) ==")
bad = [
    ("duplicate location_name",
     "INSERT INTO location VALUES (900,'Dolpa','Karnali','None',NULL,NULL)"),
    ("negative population",
     "INSERT INTO location VALUES (900,'Testville','Karnali','None',-5,NULL)"),
    ("invalid damage_level",
     "INSERT INTO location VALUES (900,'Testville','Karnali','Huge',NULL,NULL)"),
    ("earthquake_impact for unknown location (FK)",
     "INSERT INTO earthquake_impact VALUES (900,0,0,0,0,0,0,0,0,0,0)"),
    ("negative death count",
     "INSERT INTO earthquake_impact VALUES (1,-1,0,0,0,0,0,0,0,0,0)"),
    ("flood period with swapped day/month (raw-data bug)",
     "INSERT INTO flood_period VALUES ('2024-01-07','2024-07-15')"),
    ("flood period end before start",
     "INSERT INTO flood_period VALUES ('2030-01-16','2030-01-01')"),
    ("observation for unknown period (FK)",
     "INSERT INTO flood_observation VALUES (1,'1999-01-01',0,0,0)"),
    ("cropland flooded > total flooded",
     "INSERT INTO flood_observation VALUES (1,'2026-07-01',500,100,0)"),
    ("duplicate (location, period) observation",
     "INSERT INTO flood_observation SELECT * FROM flood_observation LIMIT 1"),
    ("delete a district that still has data (ON DELETE RESTRICT)",
     "DELETE FROM location WHERE location_name = 'Dolpa'"),
]
for name, sql in bad:
    try:
        with engine.begin() as c:
            c.execute(text(sql))
        print(f"  FAIL accepted: {name}")
    except DBAPIError as e:
        print(f"  OK   rejected: {name}")

# 3. Functional dependency checks
print("\n== 3. Functional dependencies / redundancy in the RAW files and the new tables ==")
print("   (for 'FD' rows: 0 violations = the dependency HOLDS, i.e. the column is redundant or transitive)")
fds = [
    ("FD   RAW earthquake: ZONE -> ZONE_CODE",
     "SELECT COUNT(*) FROM (SELECT ZONE FROM earthquakes_staging WHERE ZONE IS NOT NULL GROUP BY ZONE HAVING COUNT(DISTINCT ZONE_CODE)>1) t"),
    ("FD   RAW earthquake: ZONE_CODE -> REG_CODE",
     "SELECT COUNT(*) FROM (SELECT ZONE_CODE FROM earthquakes_staging WHERE ZONE_CODE IS NOT NULL GROUP BY ZONE_CODE HAVING COUNT(DISTINCT REG_CODE)>1) t"),
    ("FD   RAW flood: adm2_pcode -> adm2_name",
     "SELECT COUNT(*) FROM (SELECT adm2_pcode FROM floods_staging GROUP BY adm2_pcode HAVING COUNT(DISTINCT adm2_name)>1) t"),
    ("FD   RAW flood: adm2_pcode -> adm1_pcode",
     "SELECT COUNT(*) FROM (SELECT adm2_pcode FROM floods_staging GROUP BY adm2_pcode HAVING COUNT(DISTINCT adm1_pcode)>1) t"),
    ("FD   RAW flood: adm1_pcode -> adm1_name",
     "SELECT COUNT(*) FROM (SELECT adm1_pcode FROM floods_staging GROUP BY adm1_pcode HAVING COUNT(DISTINCT adm1_name)>1) t"),
    ("FD   RAW flood: period_number -> start_date, end_date",
     "SELECT COUNT(*) FROM (SELECT period_number FROM floods_staging GROUP BY period_number HAVING COUNT(DISTINCT start_date, end_date)>1) t"),
    ("FD   NEW flood_period: period_start -> period_end (now in its own table)",
     "SELECT COUNT(*) FROM (SELECT period_start FROM flood_period GROUP BY period_start HAVING COUNT(DISTINCT period_end)>1) t"),
    ("ROWS RAW earthquake where Tot_Deaths <> F+M+Unknown (derived column wrong)",
     "SELECT COUNT(*) FROM earthquakes_staging WHERE DISTRICT IS NOT NULL AND Tot_Deaths <> Death_Female+Death_Male+`Unknown`"),
    ("ROWS RAW earthquake where Total_Injured <> F+M+Unknown (derived column wrong)",
     "SELECT COUNT(*) FROM earthquakes_staging WHERE DISTRICT IS NOT NULL AND Total_Injured <> Injured_Female+Injured_Male+`Unknown.1`"),
    ("ROWS RAW flood where cropland_flooded_ha <> sq_km*100 (duplicate unit column)",
     "SELECT COUNT(*) FROM floods_staging WHERE ABS(cropland_flooded_ha - cropland_flooded_sq_km*100) > 1"),
    ("ROWS RAW flood where start_date is in a different month than end_date",
     "SELECT COUNT(*) FROM floods_staging WHERE MONTH(CAST(start_date AS DATE)) <> MONTH(CAST(end_date AS DATE))"),
    ("ROWS NEW flood_period with start/end in different months",
     "SELECT COUNT(*) FROM flood_period WHERE MONTH(period_start) <> MONTH(period_end)"),
]
for name, sql in fds:
    print(f"  {scalar(sql):>3}  {name}")

# NF check of derived column location.damage_level
print("\n== 4. location.damage_level vs earthquake casualties (should be 0 mismatches) ==")
print("  mismatches:", scalar("""
    SELECT COUNT(*) FROM location l JOIN v_earthquake_impact v USING (location_id)
    WHERE l.damage_level <> CASE
        WHEN v.total_deaths + v.total_injured >= 1000 THEN 'Critical'
        WHEN v.total_deaths + v.total_injured >= 100 THEN 'High'
        WHEN v.total_deaths + v.total_injured >= 10 THEN 'Moderate'
        WHEN v.total_deaths + v.total_injured >= 1 THEN 'Low' ELSE 'None' END"""))
engine.dispose()
