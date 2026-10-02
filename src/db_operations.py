from pathlib import Path
from sqlalchemy import inspect, text

def run_sql_file(path, engine):
    # Read the SQL file, remove comments and empty lines, and split into individual statements
    lines = [l for l in Path(path).read_text().splitlines() if not l.strip().startswith("--")]
    statements = [s.strip() for s in "\n".join(lines).split(";") if s.strip()]
    with engine.begin() as connection:
        for statement in statements:
            connection.execute(text(statement))
            
def build_database(path, engine):
    # Create the tables and load the data from the SQL file
    run_sql_file("db/schema.sql", engine)
    run_sql_file(path, engine)
    
    
def get_tables(engine):
    return inspect(engine).get_table_names()

def get_columns(engine, table):
    return [c["name"] for c in inspect(engine).get_columns(table)]
 
def get_pk(engine, table):
    return inspect(engine).get_pk_constraint(table)["constrained_columns"][0]
 
def check_table(engine, table):
    if table not in get_tables(engine):
        raise ValueError(f"Unknown table: {table}")
 