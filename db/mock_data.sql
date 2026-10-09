-- Mock data from week 3 (locations, organizations, people, buildings, operations, reports).

INSERT INTO location (location_name, region, damage_level) VALUES
('Phoksundo', 'Karnali', 'High'),
('Marpha', 'Dhawalagiri', 'Moderate'),
('Pokhara', 'Gandaki', 'Low'),
('Lang Tang', 'Bagmati', 'Critical'),
('Chukhung', 'Koshi', 'High'),
('Tamku', 'Koshi', 'None');

INSERT INTO organization (org_id, org_name, org_type, contact_info) VALUES
(1, 'GlobalGiving', 'NGO', 'contact@globalgiving.org'),
(2, 'Project Hope', 'NGO', 'contact@projecthope.org'),
(3, 'Direct Relief', 'NGO', 'contact@directrelief.org'),
(4, 'Asian Disaster Preparedness Center', 'NGO', 'contact@adpc.org'),
(5, 'Red Cross', 'Emergency Services', 'contact@redcross.org'),
(6, 'Mercy Corps', 'NGO', 'contact@mercycorps.org');

INSERT INTO person (person_id, name, age, status) VALUES
(1, 'Amara Sherpa', 34, 'Rescued'),
(2, 'Tenzin Gurung', 41, 'Deceased'),
(3, 'Nima Lama', 29, 'Injured'),
(4, 'Bimala Rai', 52, 'Rescued'),
(5, 'Kunsang Tamang', 23, 'Missing'),
(6, 'Pema Khadka', 37, 'Rescued'),
(7, 'Lhakpa Dolma', 45, 'Deceased'),
(8, 'Ramesh Thapa', 19, 'Rescued'),
(9, 'Dawa Tshering', 61, 'Injured'),
(10, 'Sita Poudel', 27, 'Rescued'),
(11, 'Karma Chhetri', 33, 'Rescued'),
(12, 'Nawang Sherpa', 48, 'Deceased'),
(13, 'Anu Karki', 31, 'Rescued'),
(14, 'Dolma Gurung', 39, 'Other'),
(15, 'Binod Shrestha', 26, 'Rescued');

INSERT INTO building (building_id, location_id, building_type, damage_status) VALUES
(1, 62, 'Hospital', 'Severe'),
(2, 62, 'Residential', 'Destroyed'),
(3, 62, 'School', 'Moderate'),
(4, 42, 'Government', 'Minor'),
(5, 42, 'Industrial', 'Severe'),
(6, 40, 'Commercial', 'Moderate'),
(7, 40, 'Residential', 'Minor'),
(8, 29, 'Industrial', 'Severe'),
(9, 29, 'Residential', 'Destroyed'),
(10, 11, 'Other', 'Undamaged'),
(11, 9, 'Hospital', 'Destroyed'),
(12, 9, 'Government', 'Moderate');

INSERT INTO operations (operation_id, org_id, location_id, operation_type, start_date, status) VALUES
(1, 1, 62, 'Rescue', '2026-08-01', 'Active'),
(2, 2, 62, 'Repair', '2026-08-02', 'Active'),
(3, 5, 62, 'Medical', '2026-08-01', 'Active'),
(4, 3, 42, 'Supply', '2026-08-03', 'Completed'),
(5, 4, 42, 'Assessment', '2026-08-04', 'Active'),
(6, 1, 29, 'Evacuation', '2026-08-02', 'Completed'),
(7, 6, 29, 'Other', '2026-08-05', 'Cancelled'),
(8, 5, 9, 'Medical', '2026-08-01', 'Active'),
(9, 2, 9, 'Rescue', '2026-08-01', 'Active'),
(10, 4, 40, 'Assessment', '2026-08-06', 'Completed'),
(11, 3, 11, 'Supply', '2026-08-07', 'Planned');

INSERT INTO report (report_id, person_id, location_id, report_text, reported_at, reliability_score) VALUES
(1, 1, 62, 'Collapsed apartment block, residents trapped in basement.', '2026-08-01 07:15:00', 0.92),
(2, 4, 62, 'Phoksundo hospital running low on generator fuel.', '2026-08-01 09:40:00', 0.85),
(3, 2, 42, 'Marpha industrial site damaged and needs emergency supplies.', '2026-08-03 14:05:00', 0.78),
(4, 6, 29, 'Lang Tang road blocked by fallen power lines near damaged homes.', '2026-08-02 11:20:00', 0.95),
(5, 9, 9, 'Tamku hospital is destroyed, injured residents need medical care.', '2026-08-01 08:00:00', 0.90),
(6, 7, 42, 'Marpha water supply contaminated near the damaged industrial site.', '2026-08-04 16:30:00', 0.70),
(7, 11, 40, 'Pokhara commercial building has minor cracks, no injuries reported.', '2026-08-05 10:10:00', 0.60),
(8, 13, 62, 'Rescue dogs located two survivors under collapsed structure.', '2026-08-01 18:45:00', 0.97),
(9, 10, 11, 'Chukhung is largely undamaged and can receive displaced families.', '2026-08-03 12:00:00', 0.65),
(10, 14, 29, 'Lang Tang residential building is unsafe, evacuation and inspection required.', '2026-08-02 13:15:00', 0.88);
