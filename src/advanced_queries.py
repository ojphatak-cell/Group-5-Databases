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