CREATE TABLE location (
    location_id   TEXT PRIMARY KEY,
    location_name TEXT NOT NULL,
    region        TEXT NOT NULL,
    damage_level  TEXT NOT NULL
);

CREATE TABLE organization (
    org_id       INTEGER PRIMARY KEY ,
    org_name     VARCHAR(100),
    org_type     VARCHAR(50),
    contact_info VARCHAR(50)
);

CREATE TABLE person (
    person_id INTEGER PRIMARY KEY ,
    name      VARCHAR(30),
    age       INTEGER,
    status    VARCHAR(20)
);

CREATE TABLE building (
    building_id   INTEGER PRIMARY KEY,
    location_id   INTEGER REFERENCES location(location_id),
    building_type  NOT NULL,
    damage_status TEXT NOT NULL
);

CREATE TABLE operations (
    operation_id   TEXT PRIMARY KEY,
    org_id         TEXT NOT NULL REFERENCES organization(org_id),
    location_id    TEXT NOT NULL REFERENCES location(location_id),
    operation_type TEXT NOT NULL,
    start_date     DATE NOT NULL,
    status         TEXT NOT NULL
);

CREATE TABLE report (
    report_id          TEXT PRIMARY KEY,
    person_id          TEXT NOT NULL REFERENCES person(person_id),
    location_id        TEXT NOT NULL REFERENCES location(location_id),
    report_text        TEXT NOT NULL,
    "timestamp"        TIMESTAMP NOT NULL,
    reliability_score  REAL NOT NULL
);
