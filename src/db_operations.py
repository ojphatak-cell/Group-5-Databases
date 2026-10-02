## Required libraries (install from terminal before running this script!)
## pip install sqlalchemy pandas pymysql

## Note, this example should work for diverse DBMS.
## If you're working with MySQL specifically, you can also use:
## Terminal
## pip install mysql-connector-python

# db_connection.py
import sqlalchemy ###Or: #### import mysql.connector
import pandas as pd
import pymysql # Driver to connect to MySQL, alternatives: mysqlclient, mysql-connector-python.

from sqlalchemy import create_engine, text 
from sqlalchemy.engine import URL

# --- CONNECTION SETUP ---
connection_url = URL.create(
    drivername = "mysql+pymysql",   # change for different DBMS
    username   = "root",            # replace with your username
    password   = "O023BAv06amzO",    # replace with your password
    host       = "localhost",       # replace with your host
    port       = 3306,              # replace with your port, example port for MySQL and MariaDB.
    database   = "floods"           # replace with your database name
)

engine = create_engine(connection_url)

##Other ports for different DBMS; check documnetation of the DBMS as well!:
## PostgreSQL: 5432 
## SQL Server: 1433
## Oracle: 1521
## MariaDB: 3306 (same as MySQL)
## SQLite: No port needed (file-based database)

def run_sql_file(path):
    """Execute all SQL statements inside a .sql file."""
    with open(path, encoding="utf-8") as f:
        sql_script = f.read()

    # MySQL cannot execute multiple statements at once unless split manually
    statements = sql_script.split(";")

    with engine.connect() as conn:
        for stmt in statements:
            stmt = stmt.strip()
            if stmt:
                conn.execute(text(stmt))
        conn.commit()


def build_database():
    """Create tables and load initial data."""
    run_sql_file("schema.sql")
    run_sql_file("data.sql")