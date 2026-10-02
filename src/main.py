import pandas as pd

from db_operations import *
from setup import get_engine

def main():
    engine = get_engine()
    build_database("db/test_data.sql", engine)

    engine.dispose()  # Close the connection when done
    
if __name__ == "__main__":
    main()