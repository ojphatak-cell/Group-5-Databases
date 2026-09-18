# Handles the database connection and loading .sql files.
# Uses sqlite3 (Python standard library, no install needed) so the
# project runs anywhere. schema.sql, data.sql and queries.sql are
# plain SQL and also run unchanged on MySQL 8+.

import sqlite3

DB_FILE = "disaster_response.db"


def connect(db_file=DB_FILE):
    conn = sqlite3.connect(db_file)
    conn.execute("PRAGMA foreign_keys = ON")  # sqlite3-only, not needed on MySQL
    conn.row_factory = sqlite3.Row
    return conn


def run_sql_file(conn, path):
    with open(path, encoding="utf-8") as f:
        conn.executescript(f.read())
    conn.commit()


def build_database(conn):
    run_sql_file(conn, "schema.sql")
    run_sql_file(conn, "data.sql")
