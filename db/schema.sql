DROP VIEW IF EXISTS v_earthquake_impact;
DROP TABLE IF EXISTS flood_observation;
DROP TABLE IF EXISTS flood_period;
DROP TABLE IF EXISTS flood_impact;
DROP TABLE IF EXISTS report;
DROP TABLE IF EXISTS operations;
DROP TABLE IF EXISTS building;
DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS organization;
DROP TABLE IF EXISTS location;

CREATE TABLE location (
    location_id   INTEGER PRIMARY KEY,
    location_name VARCHAR(30) NOT NULL,
    region        VARCHAR(30) NOT NULL,
    damage_level  VARCHAR(30) NOT NULL,
    population    INTEGER NULL,
    households    INTEGER NULL,

    CONSTRAINT uq_location_name
        UNIQUE (location_name),

    CONSTRAINT check_location_id_positive
        CHECK (location_id > 0),

    CONSTRAINT check_location_population
        CHECK (population IS NULL OR population >= 0),

    CONSTRAINT check_location_households
        CHECK (households IS NULL OR households >= 0),

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
    org_id       INTEGER PRIMARY KEY,
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
    person_id INTEGER PRIMARY KEY,
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
    location_id   INTEGER NOT NULL,
    building_type VARCHAR(30) NOT NULL,
    damage_status VARCHAR(20) NOT NULL,

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
    status         VARCHAR(30) NOT NULL,

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

-- Tables were added to hold the two real-world datasets.

CREATE TABLE flood_impact (
    flood_impact_id               INTEGER PRIMARY KEY,
    location_id                   INTEGER NOT NULL,
    deaths_female                 INTEGER NOT NULL,
    deaths_male                   INTEGER NOT NULL,
    deaths_unknown                INTEGER NOT NULL,
    injured_female                INTEGER NOT NULL,
    injured_male                  INTEGER NOT NULL,
    injured_unknown               INTEGER NOT NULL,
    govt_buildings_damaged        INTEGER NOT NULL,
    govt_buildings_part_damaged   INTEGER NOT NULL,
    public_buildings_damaged      INTEGER NOT NULL,
    public_buildings_part_damaged INTEGER NOT NULL,

    CONSTRAINT fk_earthquake_impact_location
        FOREIGN KEY (location_id)
        REFERENCES location(location_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT check_eq_counts_non_negative
        CHECK (
            deaths_female >= 0 AND deaths_male >= 0 AND deaths_unknown >= 0 AND
            injured_female >= 0 AND injured_male >= 0 AND injured_unknown >= 0 AND
            govt_buildings_damaged >= 0 AND govt_buildings_part_damaged >= 0 AND
            public_buildings_damaged >= 0 AND public_buildings_part_damaged >= 0
        )
);

-- Earthquake impact per district with totals, used by queries 4-6.
CREATE VIEW v_earthquake_impact AS
SELECT location_id,
       deaths_female, deaths_male, deaths_unknown,
       deaths_female + deaths_male + deaths_unknown       AS total_deaths,
       injured_female, injured_male, injured_unknown,
       injured_female + injured_male + injured_unknown    AS total_injured,
       govt_buildings_damaged, govt_buildings_part_damaged,
       public_buildings_damaged, public_buildings_part_damaged
FROM flood_impact;

CREATE TABLE flood_period (
    location_id  INTEGER NOT NULL,
    period_start DATE NOT NULL,
    period_end   DATE NOT NULL,

    PRIMARY KEY (location_id, period_start),

    CONSTRAINT fk_flood_period_location
        FOREIGN KEY (location_id)
        REFERENCES location(location_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT check_flood_period_order
        CHECK (period_end >= period_start),

    -- A bi-weekly period lies inside one calendar month and lasts 13-16 days.
    CONSTRAINT check_flood_period_in_month
        CHECK (YEAR(period_start) = YEAR(period_end)
           AND MONTH(period_start) = MONTH(period_end)
           AND DATEDIFF(period_end, period_start) BETWEEN 12 AND 15)
);

CREATE TABLE flood_observation (
    location_id           INTEGER NOT NULL,
    period_start          DATE NOT NULL,
    cropland_flooded_ha   INTEGER NOT NULL,
    total_area_flooded_ha INTEGER NOT NULL,
    pop_exposed           INTEGER NOT NULL,

    CONSTRAINT pk_flood_observation
        PRIMARY KEY (location_id, period_start),

    CONSTRAINT fk_flood_observation_period
        FOREIGN KEY (location_id, period_start)
        REFERENCES flood_period(location_id, period_start)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT check_flood_areas
        CHECK (cropland_flooded_ha >= 0
           AND total_area_flooded_ha >= 0
           AND cropland_flooded_ha <= total_area_flooded_ha),

    CONSTRAINT check_flood_pop_exposed
        CHECK (pop_exposed >= 0)
);

CREATE INDEX idx_building_location ON building(location_id);
CREATE INDEX idx_operations_org ON operations(org_id);
CREATE INDEX idx_operations_location ON operations(location_id);
CREATE INDEX idx_report_person ON report(person_id);
CREATE INDEX idx_report_location ON report(location_id);