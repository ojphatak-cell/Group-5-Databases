# CREATE

def add_person(engine, person_id, name, age, status): 
    with engine.begin() as conn:
        conn.execute(
            text(""" 
                INSERT INTO person (person_id, name, age, status) 
                VALUES (:person_id, :name, :age, :status) 
            """),
            { 
                "person_id": person_id,
                "name": name,
                "age": age,
                "status": status,
            } 
        )
        
def add_report(
    engine,
    report_id,
    person_id,
    location_id,
    report_text,
    reported_at,
    reliability_score
):
    with engine.begin() as conn:
        conn.execute(
            text("""
                INSERT INTO report ( 
                    report_id,
                    person_id,
                    location_id,
                    report_text,
                    reported_at,
                    reliability_score
                ) 
                VALUES (
                    :report_id,
                    :person_id,
                    :location_id,
                    :report_text,
                    :reported_at,
                    :reliability_score
                ) 
            """), 
            { 
                "report_id": report_id,
                "person_id": person_id,
                "location_id": location_id,
                "report_text": report_text,
                "reported_at": reported_at,
                "reliability_score": reliability_score
            } 
        )


# READ

def get_person(engine, person_id): 
    with engine.connect() as conn: 
        result = conn.execute( 
            text(""" SELECT * FROM person WHERE person_id = :person_id """), 
            {"person_id": person_id} 
        ) 
    return result.mappings().first()

def list_operations_by_location(engine, location_id): 
    with engine.connect() as conn: 
        result = conn.execute( 
            text(""" SELECT * FROM operations WHERE location_id = :location_id """), 
            {"location_id": location_id} 
        ) 
    return result.mappings().all()


# UPDATE

def update_person_status(engine, person_id, status): 
    with engine.begin() as conn: 
        conn.execute( 
            text(""" UPDATE person SET status = :status WHERE person_id = :person_id """), 
            { 
                "status": status, 
                "person_id": person_id, 
            } 
        )
        

def update_operation_status(engine, operation_id, status):
    with engine.begin() as conn:
        conn.execute( \
            text(""" UPDATE operations SET status = :status WHERE operation_id = :operation_id """),
            { 
                "status": status,
                "operation_id": operation_id,
            }
        )
        
def update_building_damage(engine, building_id, damage_status):
    with engine.begin() as conn:
        conn.execute(
            text(""" UPDATE building SET damage_status = :damage_status WHERE building_id = :building_id """),
            { 
                "damage_status": damage_status,
                "building_id": building_id,
            }
        )
        
        
# DELETE

def delete_report(engine, report_id): 
    with engine.begin() as conn: 
        conn.execute( 
            text(""" DELETE FROM report WHERE report_id = :report_id """), 
            {"report_id": report_id} 
        )
        
def delete_person(engine, person_id):
    with engine.begin() as conn:
        conn.execute(
            text(""" DELETE FROM person WHERE person_id = :person_id """),
            {
                "person_id": person_id
            }
        )