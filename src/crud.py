# CREATE

def add_person(conn, person_id, name, age, status):
    conn.execute(
        "INSERT INTO person (person_id, name, age, status) VALUES (?, ?, ?, ?)",
        (person_id, name, age, status),
    )
    conn.commit()


def add_report(conn, report_id, person_id, location_id, report_text, reported_at, reliability_score):
    conn.execute(
        "INSERT INTO report (report_id, person_id, location_id, report_text, reported_at, reliability_score) "
        "VALUES (?, ?, ?, ?, ?, ?)",
        (report_id, person_id, location_id, report_text, reported_at, reliability_score),
    )
    conn.commit()


# READ

def get_person(conn, person_id):
    return conn.execute("SELECT * FROM person WHERE person_id = ?", (person_id,)).fetchone()


def list_operations_by_location(conn, location_id):
    return conn.execute(
        "SELECT * FROM operations WHERE location_id = ?", (location_id,)
    ).fetchall()


# UPDATE

def update_person_status(conn, person_id, status):
    conn.execute(
        "UPDATE person SET status = ? WHERE person_id = ?", (status, person_id)
    )
    conn.commit()


def update_operation_status(conn, operation_id, status):
    conn.execute(
        "UPDATE operations SET status = ? WHERE operation_id = ?", (status, operation_id)
    )
    conn.commit()


def update_building_damage(conn, building_id, damage_status):
    conn.execute(
        "UPDATE building SET damage_status = ? WHERE building_id = ?",
        (damage_status, building_id),
    )
    conn.commit()


# DELETE

def delete_report(conn, report_id):
    conn.execute("DELETE FROM report WHERE report_id = ?", (report_id,))
    conn.commit()


def delete_person(conn, person_id):
    conn.execute("DELETE FROM person WHERE person_id = ?", (person_id,))
    conn.commit()
