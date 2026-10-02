import pandas as pd

from db_operations import *
from setup import get_engine
from advanced_queries import *

def main():
    engine = get_engine()

    # 1. Staging: raw CSVs are loaded 1:1, no cleaning
    load_csv_file("db/nepal_earthquake_data.csv", "earthquakes_staging", engine)
    load_csv_file("db/npl-flood-events-fao-eve.csv", "floods_staging", engine)

    # 2. Normalized schema, then real data (cleaned from staging), then mock data
    load_sql_file("db/schema.sql", engine)
    load_sql_file("db/load_real_data.sql", engine)
    load_sql_file("db/test_data.sql", engine)

    print(get_tables(engine))

    # 3. Example queries (1-3 from week 3, 4-6 use the real-world data)
    get_active_operations_per_organization(engine)
    get_locations_with_below_average_reliability(engine)
    get_locations_with_multiple_damaged_buildings(engine)
    get_casualties_and_flood_exposure_per_region(engine)
    get_high_damage_locations_without_active_operation(engine)
    get_districts_hit_by_both_hazards(engine)

    engine.dispose()  # Close the connection when done
    
if __name__ == "__main__":
    main()