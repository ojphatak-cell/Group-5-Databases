-- Staging tables for the two real-world datasets. These are temporary tables that
-- hold the raw CSV data before it is cleaned and inserted into the main tables.

DROP TEMPORARY TABLE IF EXISTS stg_earthquake;
CREATE TEMPORARY TABLE stg_earthquake (
    dist_id                   INTEGER,
    district                  VARCHAR(50),
    zone                      VARCHAR(50),
    reg_code                  VARCHAR(20),
    zone_code                 VARCHAR(20),
    ocha_pcode                VARCHAR(20),
    hlcit_code                VARCHAR(20),
    total_household           INTEGER,
    total_population          INTEGER,
    death_female              INTEGER,
    death_male                INTEGER,
    death_unknown             INTEGER,
    tot_deaths                INTEGER,
    injured_female            INTEGER,
    injured_male              INTEGER,
    injured_unknown           INTEGER,
    total_injured             INTEGER,
    govtbuild_damage          INTEGER,
    govtbuild_partdamage      INTEGER,
    publicbuild_damage        INTEGER,
    publicbuild_partdamage    INTEGER
);

DROP TEMPORARY TABLE IF EXISTS stg_flood;
CREATE TEMPORARY TABLE stg_flood (
    adm0_iso3                 VARCHAR(10),
    adm0_name                 VARCHAR(50),
    admin_level               VARCHAR(20),
    adm1_pcode                VARCHAR(20),
    adm1_name                 VARCHAR(50),
    adm2_pcode                VARCHAR(20),
    adm2_name                 VARCHAR(50),
    period_number             INTEGER,
    start_date                VARCHAR(10),
    end_date                  VARCHAR(10),
    cropland_flooded_sq_km    DECIMAL(14,4),
    cropland_flooded_ha       INTEGER,
    total_area_flooded_sq_km  DECIMAL(14,4),
    total_area_flooded_ha     INTEGER,
    perc_cropland_flooded     DOUBLE,
    perc_total_area_flooded   DOUBLE,
    pop_exposed               INTEGER
);

-- Data loading to staging tables
LOAD DATA LOCAL INFILE 'nepal_earthquake_data.csv'
INTO TABLE stg_earthquake
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(dist_id, district, zone, reg_code, zone_code, ocha_pcode, hlcit_code,
 total_household, total_population,
 death_female, death_male, death_unknown, tot_deaths,
 injured_female, injured_male, injured_unknown, total_injured,
 govtbuild_damage, govtbuild_partdamage,
 publicbuild_damage, publicbuild_partdamage,
 @skip, @skip)
SET district = TRIM(TRAILING '\r' FROM TRIM(district));

LOAD DATA LOCAL INFILE 'npl-flood-events-fao-eve.csv'
INTO TABLE stg_flood
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(adm0_iso3, adm0_name, admin_level, adm1_pcode, adm1_name, adm2_pcode,
 adm2_name, period_number, start_date, end_date,
 cropland_flooded_sq_km, cropland_flooded_ha,
 total_area_flooded_sq_km, total_area_flooded_ha,
 perc_cropland_flooded, perc_total_area_flooded, @pop_exposed)
SET adm2_name   = TRIM(adm2_name),
    pop_exposed = CAST(TRIM(TRAILING '\r' FROM @pop_exposed) AS UNSIGNED);

-- Location insertions
INSERT INTO location (location_id, location_name, region, damage_level,
                      population, households)
SELECT
    e.dist_id,
    e.district,
    CASE e.district
        WHEN 'Nawalparasi' THEN 'Gandaki/Lumbini'
        WHEN 'Rukum'       THEN 'Karnali/Lumbini'
        ELSE (SELECT MIN(f.adm1_name)
              FROM stg_flood f
              WHERE f.adm2_name = e.district)
    END,
    CASE
        WHEN e.tot_deaths = 0     THEN 'None'
        WHEN e.tot_deaths <= 10   THEN 'Low'
        WHEN e.tot_deaths <= 100  THEN 'Moderate'
        WHEN e.tot_deaths <= 1000 THEN 'High'
        ELSE 'Critical'
    END,
    e.total_population,
    e.total_household
FROM stg_earthquake e;

-- Location inserts for flood districts that do not exist in the earthquake file
INSERT INTO location (location_id, location_name, region, damage_level,
                      population, households)
SELECT
    (SELECT MAX(location_id) FROM location)
        + ROW_NUMBER() OVER (ORDER BY n.adm2_name),
    n.adm2_name,
    n.adm1_name,
    'None',
    NULL,
    NULL
FROM (
    SELECT f.adm2_name, MIN(f.adm1_name) AS adm1_name
    FROM stg_flood f
    WHERE NOT EXISTS (SELECT 1 FROM stg_earthquake e
                      WHERE e.district = f.adm2_name)
    GROUP BY f.adm2_name
) AS n;

-- Flood impact insertions
INSERT INTO flood_impact (flood_impact_id, location_id,
                          deaths_female, deaths_male, deaths_unknown,
                          injured_female, injured_male, injured_unknown,
                          govt_buildings_damaged, govt_buildings_part_damaged,
                          public_buildings_damaged, public_buildings_part_damaged)
SELECT
    e.dist_id,
    l.location_id,
    e.death_female, e.death_male, e.death_unknown,
    e.injured_female, e.injured_male, e.injured_unknown,
    e.govtbuild_damage, e.govtbuild_partdamage,
    e.publicbuild_damage, e.publicbuild_partdamage
FROM stg_earthquake e
JOIN location l ON l.location_name = e.district;

-- Flood date fix
DROP TEMPORARY TABLE IF EXISTS stg_flood_clean;
CREATE TEMPORARY TABLE stg_flood_clean AS
SELECT
    l.location_id,
    CASE
        WHEN MONTH(STR_TO_DATE(f.start_date, '%Y-%m-%d'))
          <> MONTH(STR_TO_DATE(f.end_date,   '%Y-%m-%d'))
        THEN STR_TO_DATE(f.start_date, '%Y-%d-%m')
        ELSE STR_TO_DATE(f.start_date, '%Y-%m-%d')
    END                                   AS period_start,
    STR_TO_DATE(f.end_date, '%Y-%m-%d')   AS period_end,
    f.cropland_flooded_ha,
    f.total_area_flooded_ha,
    f.pop_exposed
FROM stg_flood f
JOIN location l ON l.location_name = f.adm2_name;

-- Flood periods insertions
INSERT INTO flood_period (location_id, period_start, period_end)
SELECT DISTINCT location_id, period_start, period_end
FROM stg_flood_clean;

-- Flood observations insertions
INSERT INTO flood_observation (location_id, period_start,
                               cropland_flooded_ha, total_area_flooded_ha,
                               pop_exposed)
SELECT location_id, period_start,
       cropland_flooded_ha, total_area_flooded_ha, pop_exposed
FROM stg_flood_clean;

--  Cleanup
DROP TEMPORARY TABLE IF EXISTS stg_flood_clean;
DROP TEMPORARY TABLE IF EXISTS stg_flood;
DROP TEMPORARY TABLE IF EXISTS stg_earthquake;