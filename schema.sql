CREATE TABLE location (
    location_id   TEXT PRIMARY KEY,
    location_name TEXT NOT NULL,
    region        TEXT NOT NULL,
    damage_level  TEXT NOT NULL
);

CREATE TABLE organization (
    org_id       TEXT PRIMARY KEY,
    org_name     TEXT NOT NULL,
    org_type     TEXT NOT NULL,
    contact_info TEXT
);

CREATE TABLE person (
    person_id TEXT PRIMARY KEY,
    name      TEXT NOT NULL,
    age       INTEGER,
    status    TEXT NOT NULL
);

CREATE TABLE building (
    building_id   TEXT PRIMARY KEY,
    location_id   TEXT NOT NULL REFERENCES location(location_id),
    building_type TEXT NOT NULL,
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
