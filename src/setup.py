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
    password   = "password",    # replace with your password
    host       = "localhost",       # replace with your host
    port       = 3306,              # replace with your port, example port for MySQL and MariaDB.
    database   = "sakila"           # replace with your database name
)

engine = create_engine(connection_url)

##Other ports for different DBMS; check documnetation of the DBMS as well!:
## PostgreSQL: 5432 
## SQL Server: 1433
## Oracle: 1521
## MariaDB: 3306 (same as MySQL)
## SQLite: No port needed (file-based database)

# %%
# --- BASIC QUERY + DISPLAY ---
df = pd.read_sql("SELECT * FROM actor LIMIT 10;", engine)
print(df)

# %%
# --- DML EXAMPLE (INSERT/UPDATE/DELETE) ---
# For write operations, use execute() instead of pd.read_sql()
# connection.execute() in SQLAlchemy expects an executable SQLAlchemy object. Therefore, wrap the string with text():
with engine.connect() as connection:
    connection.execute(text("UPDATE actor SET first_name = 'PENNY' WHERE actor_id = 1;"))
    connection.commit()

# %%
# --- CLOSE CONNECTION ---
engine.dispose()