INSERT INTO location (location_id, location_name, region, damage_level, population, households)
SELECT
    CAST(e.DIST_ID AS UNSIGNED),
    TRIM(e.DISTRICT),
    COALESCE(p.province,
             CASE TRIM(e.DISTRICT) WHEN 'Nawalparasi' THEN 'Gandaki'
                                   WHEN 'Rukum'       THEN 'Lumbini' END),
    CASE
        WHEN e.Tot_Deaths + e.Total_Injured >= 1000 THEN 'Critical'
        WHEN e.Tot_Deaths + e.Total_Injured >= 100  THEN 'High'
        WHEN e.Tot_Deaths + e.Total_Injured >= 10   THEN 'Moderate'
        WHEN e.Tot_Deaths + e.Total_Injured >= 1    THEN 'Low'
        ELSE 'None'
    END,
    CASE WHEN TRIM(e.DISTRICT) = 'Palpa' THEN NULL ELSE CAST(e.`Total Population` AS UNSIGNED) END,
    CASE WHEN TRIM(e.DISTRICT) = 'Palpa' THEN NULL ELSE CAST(e.`Total Household`  AS UNSIGNED) END
FROM earthquakes_staging e
LEFT JOIN (SELECT TRIM(adm2_name) AS district, MAX(adm1_name) AS province
           FROM floods_staging
           GROUP BY TRIM(adm2_name)) p
       ON p.district = TRIM(e.DISTRICT)
WHERE e.DISTRICT IS NOT NULL;

INSERT INTO earthquake_impact
    (location_id, deaths_female, deaths_male, deaths_unknown,
     injured_female, injured_male, injured_unknown,
     govt_buildings_damaged, govt_buildings_part_damaged,
     public_buildings_damaged, public_buildings_part_damaged)
SELECT
    CAST(e.DIST_ID AS UNSIGNED),
    e.Death_Female, e.Death_Male, e.`Unknown`,
    e.Injured_Female, e.Injured_Male, e.`Unknown.1`,
    e.GovtBuild_Damage, e.GovtBuild_PartDamage,
    e.PublicBuild_Damage, e.PublicBuild_PartDamage
FROM earthquakes_staging e
WHERE e.DISTRICT IS NOT NULL;

CREATE TEMPORARY TABLE flood_clean AS
SELECT
    REGEXP_REPLACE(TRIM(f.adm2_name), ' (East|West)$', '') AS district,
    CASE WHEN MONTH(CAST(f.start_date AS DATE)) <> MONTH(CAST(f.end_date AS DATE))
         THEN STR_TO_DATE(CONCAT(YEAR(CAST(f.start_date AS DATE)), '-',
                                 DAY(CAST(f.start_date AS DATE)), '-',
                                 MONTH(CAST(f.start_date AS DATE))), '%Y-%m-%d')
         ELSE CAST(f.start_date AS DATE)
    END AS period_start,
    CAST(f.end_date AS DATE) AS period_end,
    f.cropland_flooded_ha, f.total_area_flooded_ha, f.pop_exposed
FROM floods_staging f;

INSERT INTO flood_period (period_start, period_end)
SELECT DISTINCT period_start, period_end FROM flood_clean;

INSERT INTO flood_observation
    (location_id, period_start, cropland_flooded_ha, total_area_flooded_ha, pop_exposed)
SELECT
    l.location_id, d.period_start,
    SUM(d.cropland_flooded_ha), SUM(d.total_area_flooded_ha), SUM(d.pop_exposed)
FROM flood_clean d
JOIN location l ON l.location_name = d.district
GROUP BY l.location_id, d.period_start;

DROP TEMPORARY TABLE flood_clean;
