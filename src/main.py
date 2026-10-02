import pandas as pd

from db_operations import *
from setup import get_engine

def main():
    engine = get_engine()
    # build_database("db/load_data.sql", "db/schema.sql", engine)
    load_csv_file("db/nepal_earthquake_data.csv", "earthquakes_staging", engine);
    load_csv_file("db/npl-flood-events-fao-eve.csv", "floods_staging", engine);

    print(get_tables(engine))
    print(get_columns(engine, "earthquakes_staging"))
    
    engine.dispose()  # Close the connection when done
    
if __name__ == "__main__":
    main()