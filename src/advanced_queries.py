from sqlalchemy import text

# QUERY 1
def get_active_operations_per_organization(engine):
    with engine.connect() as conn:
        result = conn.execute(
            text("""
                SELECT org.org_name,
                COUNT(*)
                AS active_operations
                FROM organization org 
                JOIN operations op 
                ON op.org_id = org.org_id 
                WHERE op.status = 'Active' 
                GROUP BY org.org_name 
                ORDER BY active_operations DESC;
            """)
        )

        print("\n=== Active operations per organization ===")
        for row in result: 
            print(row)

# QUERY 2
def get_locations_with_below_average_reliability(engine):
    with engine.connect() as conn:
        result = conn.execute(
            text("""
                SELECT loc.location_name,
                ROUND(AVG(r.reliability_score), 2) 
                AS avg_reliability 
                FROM location loc 
                JOIN report r 
                ON r.location_id = loc.location_id 
                GROUP BY loc.location_name 
                HAVING AVG(r.reliability_score) < ( 
                    SELECT AVG(reliability_score) 
                    FROM report 
                ) 
                ORDER BY avg_reliability; 
            """)
        )

        print("\n=== Locations with below-average reliability ===")
        for row in result:
            print(row)
            
# QUERY 3
def get_locations_with_multiple_damaged_buildings(engine):
    with engine.connect() as conn:
        result = conn.execute(
            text("""
                SELECT loc.location_name, COUNT(*) AS damaged_buildings
                FROM location loc
                JOIN building b ON b.location_id = loc.location_id
                WHERE b.damage_status IN ('Severe', 'Destroyed')
                GROUP BY loc.location_name
                HAVING COUNT(*) > 1;
            """)
        )

        print("\n=== Locations with multiple damaged buildings ===")
        for row in result:
            print(row)

# QUERY 4
def get_casualties_and_flood_exposure_per_region(engine):
    # One row per province: 2015 earthquake casualties and the people exposed
    # to flooding in the most recent bi-weekly period of the flood data.
    with engine.connect() as conn:
        result = conn.execute(
            text("""
                SELECT loc.region,
                       COUNT(*)                        AS districts,
                       SUM(v.total_deaths)             AS eq_deaths,
                       SUM(v.total_injured)            AS eq_injured,
                       COALESCE(SUM(f.pop_exposed), 0) AS people_exposed_to_flood
                FROM location loc
                JOIN v_earthquake_impact v ON v.location_id = loc.location_id
                LEFT JOIN flood_observation f
                       ON f.location_id = loc.location_id
                      AND f.period_start = (SELECT MAX(period_start)
                                            FROM flood_observation)
                GROUP BY loc.region
                ORDER BY eq_deaths DESC;
            """)
        )

        print("\n=== Earthquake casualties and latest flood exposure per region ===")
        for row in result:
            print(row)

# QUERY 5
def get_high_damage_locations_without_active_operation(engine):
    # Response gap: districts rated High/Critical that have no Active operation.
    with engine.connect() as conn:
        result = conn.execute(
            text("""
                SELECT loc.location_name, loc.damage_level, v.total_deaths
                FROM location loc
                JOIN v_earthquake_impact v ON v.location_id = loc.location_id
                WHERE loc.damage_level IN ('High', 'Critical')
                  AND NOT EXISTS (
                      SELECT 1 FROM operations op
                      WHERE op.location_id = loc.location_id
                        AND op.status = 'Active')
                ORDER BY v.total_deaths DESC;
            """)
        )

        print("\n=== High/Critical locations without an active operation ===")
        for row in result:
            print(row)

# QUERY 6
def get_districts_hit_by_both_hazards(engine):
    # Districts with at least 10 earthquake deaths that are also among the
    # most flood-exposed in the latest period (both datasets combined).
    with engine.connect() as conn:
        result = conn.execute(
            text("""
                SELECT loc.location_name, v.total_deaths,
                       f.total_area_flooded_ha, f.pop_exposed
                FROM location loc
                JOIN v_earthquake_impact v ON v.location_id = loc.location_id
                JOIN flood_observation f ON f.location_id = loc.location_id
                WHERE v.total_deaths >= 10
                  AND f.period_start = (SELECT MAX(period_start)
                                        FROM flood_observation)
                ORDER BY f.pop_exposed DESC
                LIMIT 5;
            """)
        )

        print("\n=== Earthquake-hit districts with highest flood exposure (latest period) ===")
        for row in result:
            print(row)
