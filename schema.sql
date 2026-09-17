CREATE TABLE location (
    location_id   INTEGER PRIMARY KEY,
    location_name VARCHAR(30) NOT NULL,
    region        VARCHAR(30) NOT NULL,
    damage_level  VARCHAR(30) NOT NULL
);

CREATE TABLE organization (
    org_id       INTEGER PRIMARY KEY ,
    org_name     VARCHAR(100) NOT NULL,
    org_type     VARCHAR(50) NOT NULL,
    contact_info VARCHAR(50) NOT NULL
);

CREATE TABLE person (
    person_id INTEGER PRIMARY KEY ,
    name      VARCHAR(30) NOT NULL,
    age       INTEGER NOT NULL,
    status    VARCHAR(20) NOT NULL
);

CREATE TABLE building (
    building_id   INTEGER PRIMARY KEY,
    location_id   INTEGER REFERENCES location(location_id) NOT NULL,
    building_type VARCHAR (30) NOT NULL,
    damage_status  VARCHAR(20) NOT NULL
);

CREATE TABLE operations (
    operation_id   INTEGER PRIMARY KEY,
    org_id         INTEGER NOT NULL REFERENCES organization(org_id),
    location_id    INTEGER NOT NULL REFERENCES location(location_id),
    operation_type VARCHAR(30) NOT NULL,
    start_date     DATE NOT NULL,
    status         VARCHAR(30) NOT NULL
);

CREATE TABLE report (
    report_id          INTEGER PRIMARY KEY,
    person_id          INTEGER NOT NULL REFERENCES person(person_id),
    location_id        INTEGER NOT NULL REFERENCES location(location_id),
    report_text        VARCHAR(100) NOT NULL,
    "timestamp"        TIMESTAMP NOT NULL,
    reliability_score  REAL NOT NULL
);
