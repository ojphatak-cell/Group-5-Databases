-- Loads the two real-world datasets into location, flood_impact,
-- flood_period and flood_observation.
--
-- Run after schema.sql. The raw CSVs must already be in the staging tables
-- earthquakes_staging and floods_staging (main.py creates them with pandas,
-- 1:1 copies of the files, with the original column names).
--
-- Every cleaning rule below is described in src/cleaning_log.md.
-- Note: load_sql_file() splits this file on semicolons, so comments must
-- not contain one.


-- 1. location: one row per district of the earthquake file (75 rows)
--    location_id  = DIST_ID
--    region       = province, taken from the flood file (log 2.4)
--                   Nawalparasi and Rukum are split in the flood file, so
--                   they get the province of their larger part (log 2.4)
--    damage_level = from the earthquake death toll:
--                   0 None, 1-10 Low, 11-100 Moderate, 101-1000 High,
--                   more than 1000 Critical
--    Palpa population and households are NULL, copy error (log 2.1)
--    A totals row (empty district name) is skipped if present (log 2.3)
INSERT INTO location (location_id, location_name, region, damage_level,
                      population, households)
SELECT
    e.DIST_ID,
    TRIM(e.DISTRICT),
    CASE TRIM(e.DISTRICT)
        WHEN 'Nawalparasi' THEN 'Gandaki'
        WHEN 'Rukum'       THEN 'Lumbini'
        ELSE (SELECT MIN(f.adm1_name)
              FROM floods_staging f
              WHERE TRIM(f.adm2_name) = TRIM(e.DISTRICT))
    END,
    CASE
        WHEN e.Tot_Deaths = 0     THEN 'None'
        WHEN e.Tot_Deaths <= 10   THEN 'Low'
        WHEN e.Tot_Deaths <= 100  THEN 'Moderate'
        WHEN e.Tot_Deaths <= 1000 THEN 'High'
        ELSE 'Critical'
    END,
    CASE WHEN TRIM(e.DISTRICT) = 'Palpa' THEN NULL ELSE e.`Total Population` END,
    CASE WHEN TRIM(e.DISTRICT) = 'Palpa' THEN NULL ELSE e.`Total Household`  END
FROM earthquakes_staging e
WHERE e.DISTRICT IS NOT NULL
  AND TRIM(e.DISTRICT) <> '';


-- 2. flood_impact: earthquake casualties and building damage per district.
--    The file has two columns called Unknown. pandas renames the second one
--    (the injured one) to Unknown.1
INSERT INTO flood_impact (flood_impact_id, location_id,
                          deaths_female, deaths_male, deaths_unknown,
                          injured_female, injured_male, injured_unknown,
                          govt_buildings_damaged, govt_buildings_part_damaged,
                          public_buildings_damaged, public_buildings_part_damaged)
SELECT
    l.location_id,
    l.location_id,
    e.Death_Female, e.Death_Male, e.`Unknown`,
    e.Injured_Female, e.Injured_Male, e.`Unknown.1`,
    e.GovtBuild_Damage, e.GovtBuild_PartDamage,
    e.PublicBuild_Damage, e.PublicBuild_PartDamage
FROM earthquakes_staging e
JOIN location l ON l.location_name = TRIM(e.DISTRICT);


-- 3. Cleaned flood rows, one per district per period.
--    a) start_date has day and month swapped in 518 rows. These are exactly
--       the rows where start and end month differ, so those are re-read as
--       YYYY-DD-MM (log 2.2).
--    b) Nawalparasi East/West and Rukum East/West are mapped to their parent
--       district and summed, so 2896 raw rows become 2823 (log 2.3, 2.4).
DROP TEMPORARY TABLE IF EXISTS flood_clean;

CREATE TEMPORARY TABLE flood_clean AS
SELECT
    l.location_id,
    x.period_start,
    x.period_end,
    SUM(x.cropland_flooded_ha)   AS cropland_flooded_ha,
    SUM(x.total_area_flooded_ha) AS total_area_flooded_ha,
    SUM(x.pop_exposed)           AS pop_exposed
FROM (
    SELECT
        CASE
            WHEN TRIM(f.adm2_name) LIKE 'Nawalparasi %' THEN 'Nawalparasi'
            WHEN TRIM(f.adm2_name) LIKE 'Rukum %'       THEN 'Rukum'
            ELSE TRIM(f.adm2_name)
        END AS district,
        CASE
            WHEN MONTH(STR_TO_DATE(f.start_date, '%Y-%m-%d'))
              <> MONTH(STR_TO_DATE(f.end_date,   '%Y-%m-%d'))
            THEN STR_TO_DATE(f.start_date, '%Y-%d-%m')
            ELSE STR_TO_DATE(f.start_date, '%Y-%m-%d')
        END AS period_start,
        STR_TO_DATE(f.end_date, '%Y-%m-%d') AS period_end,
        f.cropland_flooded_ha,
        f.total_area_flooded_ha,
        f.pop_exposed
    FROM floods_staging f
) AS x
JOIN location l ON l.location_name = x.district
GROUP BY l.location_id, x.period_start, x.period_end;


-- 4. flood_period
INSERT INTO flood_period (location_id, period_start, period_end)
SELECT location_id, period_start, period_end
FROM flood_clean;


-- 5. flood_observation
INSERT INTO flood_observation (location_id, period_start,
                               cropland_flooded_ha, total_area_flooded_ha,
                               pop_exposed)
SELECT location_id, period_start,
       cropland_flooded_ha, total_area_flooded_ha, pop_exposed
FROM flood_clean;


DROP TEMPORARY TABLE IF EXISTS flood_clean;