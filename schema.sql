CREATE TABLE location (
    location_id   INTEGER PRIMARY KEY,
    location_name VARCHAR(30) NOT NULL,
    region        VARCHAR(30) NOT NULL,
    damage_level  VARCHAR(30) NOT NULL,

    CONSTRAINT check_location_id_positive
        CHECK (location_id > 0),

    CONSTRAINT check_location_damage_level
        CHECK (damage_level IN (
            'None',
            'Low',
            'Moderate',
            'High',
            'Critical'
        ))
);

CREATE TABLE organization (
    org_id       INTEGER PRIMARY KEY ,
    org_name     VARCHAR(100) NOT NULL UNIQUE,
    org_type     VARCHAR(50) NOT NULL,
    contact_info VARCHAR(50) NOT NULL,

    CONSTRAINT check_org_id_positive
        CHECK (org_id > 0),

    CONSTRAINT check_org_type
        CHECK (org_type IN (
            'Government',
            'NGO',
            'Military',
            'Medical',
            'Emergency Services',
            'Private',
            'Other'
        ))
);

CREATE TABLE person (
    person_id INTEGER PRIMARY KEY ,
    name      VARCHAR(30) NOT NULL,
    age       INTEGER NOT NULL,
    status    VARCHAR(20) NOT NULL,

    CONSTRAINT check_person_id_positive
        CHECK (person_id > 0),

    CONSTRAINT check_person_age
        CHECK (age >= 0 AND age <= 123),

    CONSTRAINT check_person_status
        CHECK (status IN (
            'Missing',
            'Injured',
            'Deceased',
            'Rescued',
            'Other'
        ))
);

CREATE TABLE building (
    building_id   INTEGER PRIMARY KEY,
    location_id   INTEGER  NOT NULL,
    building_type VARCHAR (30) NOT NULL,
    damage_status  VARCHAR(20) NOT NULL,

    CONSTRAINT fk_building_location
        FOREIGN KEY (location_id)
        REFERENCES location(location_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT check_building_id_positive
        CHECK (building_id > 0),

    CONSTRAINT check_building_type
        CHECK (building_type IN (
            'Residential',
            'Commercial',
            'Industrial',
            'Hospital',
            'School',
            'Government',
            'Other'
        )),
    CONSTRAINT check_building_damage_status
        CHECK (damage_status IN (
            'Undamaged',
            'Minor',
            'Moderate',
            'Severe',
            'Destroyed'
        ))
);

CREATE TABLE operations (
    operation_id   INTEGER PRIMARY KEY,
    org_id         INTEGER NOT NULL,
    location_id    INTEGER NOT NULL,
    operation_type VARCHAR(30) NOT NULL,
    start_date     DATE NOT NULL,
    status         VARCHAR(30),

    CONSTRAINT fk_operation_organization
        FOREIGN KEY (org_id)
        REFERENCES organization(org_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_operation_location
        FOREIGN KEY (location_id)
        REFERENCES location(location_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT check_operation_id_positive
        CHECK (operation_id > 0),

    CONSTRAINT check_operation_type
        CHECK (operation_type IN (
            'Rescue',
            'Evacuation',
            'Medical',
            'Supply',
            'Repair',
            'Assessment',
            'Other'
        )),

    CONSTRAINT check_operation_status
        CHECK (status IN (
            'Planned',
            'Active',
            'Completed',
            'Cancelled'
        ))

);

CREATE TABLE report (
    report_id          INTEGER PRIMARY KEY,
    person_id          INTEGER NOT NULL,
    location_id        INTEGER NOT NULL,
    report_text        VARCHAR(100) NOT NULL,
    reported_at        TIMESTAMP NOT NULL,
    reliability_score  REAL NOT NULL,

    CONSTRAINT fk_report_person
        FOREIGN KEY (person_id)
        REFERENCES person(person_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_report_location
        FOREIGN KEY (location_id)
        REFERENCES location(location_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT check_report_id_positive
        CHECK (report_id > 0),

    CONSTRAINT check_reliability_score
        CHECK (reliability_score >= 0.0 AND reliability_score <= 1.0),

    CONSTRAINT check_report_text_not_empty
        CHECK (LENGTH(TRIM(report_text)) > 0)
);
