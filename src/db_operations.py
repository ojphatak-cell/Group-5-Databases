from pathlib import Path
import pandas as pd
from sqlalchemy import inspect, text

def load_sql_file(path, engine):
    # Read the SQL file, remove comments and empty lines, and split into individual statements
    lines = [l for l in Path(path).read_text().splitlines() if not l.strip().startswith("--")]
    statements = [s.strip() for s in "\n".join(lines).split(";") if s.strip()]
    with engine.begin() as connection:
        for statement in statements:
            connection.execute(text(statement))
            
def load_csv_file(path, table, engine):
    data = pd.read_csv(path)

    data.to_sql(
        table,
        engine,
        if_exists="replace",
        index=False
    )
                  
def run_queries(path, engine):
    # Read the SQL file, remove comments, and run each query, returning all results
    lines = [l for l in Path(path).read_text().splitlines() if not l.strip().startswith("--")]
    statements = [s.strip() for s in "\n".join(lines).split(";") if s.strip()]
    results = []
    with engine.connect() as connection:
        for statement in statements:
            rows = connection.execute(text(statement)).fetchall()
            results.append(rows)
    return results
            
def build_database(path, schema, engine):
    # Create the tables and load the data from the SQL file
    load_sql_file(schema, engine)
    load_sql_file(path, engine)
    
    
def get_tables(engine):
    return inspect(engine).get_table_names()

def get_columns(engine, table):
    return [c["name"] for c in inspect(engine).get_columns(table)]
 
def get_pk(engine, table):
    return inspect(engine).get_pk_constraint(table)["constrained_columns"][0]
 
def check_table(engine, table):
    if table not in get_tables(engine):
        raise ValueError(f"Unknown table: {table}")
 