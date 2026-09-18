INSERT INTO location (location_id, location_name, region, damage_level) VALUES
(1, 'Phoksundo', 'Karnali', 'High'),
(2, 'Marpha', 'Dhawalagiri', 'Moderate'),
(3, 'Pokhara', 'Gandaki', 'Low'),
(4, 'Lang Tang', 'Bagmati', 'Critical'),
(5, 'Chukhung', 'Koshi', 'High'),
(6, 'Tamku', 'Koshi', 'None');

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
(1, 1, 'Hospital', 'Severe'),
(2, 1, 'Residential', 'Destroyed'),
(3, 1, 'School', 'Moderate'),
(4, 2, 'Government', 'Minor'),
(5, 2, 'Industrial', 'Severe'),
(6, 3, 'Commercial', 'Moderate'),
(7, 3, 'Residential', 'Minor'),
(8, 4, 'Industrial', 'Severe'),
(9, 4, 'Residential', 'Destroyed'),
(10, 5, 'Other', 'Undamaged'),
(11, 6, 'Hospital', 'Destroyed'),
(12, 6, 'Government', 'Moderate');

INSERT INTO operations (operation_id, org_id, location_id, operation_type, start_date, status) VALUES
(1, 1, 1, 'Rescue', '2026-08-01', 'Active'),
(2, 2, 1, 'Repair', '2026-08-02', 'Active'),
(3, 5, 1, 'Medical', '2026-08-01', 'Active'),
(4, 3, 2, 'Supply', '2026-08-03', 'Completed'),
(5, 4, 2, 'Assessment', '2026-08-04', 'Active'),
(6, 1, 4, 'Evacuation', '2026-08-02', 'Completed'),
(7, 6, 4, 'Other', '2026-08-05', 'Cancelled'),
(8, 5, 6, 'Medical', '2026-08-01', 'Active'),
(9, 2, 6, 'Rescue', '2026-08-01', 'Active'),
(10, 4, 3, 'Assessment', '2026-08-06', 'Completed'),
(11, 3, 5, 'Supply', '2026-08-07', 'Planned');

INSERT INTO report (report_id, person_id, location_id, report_text, reported_at, reliability_score) VALUES
(1, 1, 1, 'Collapsed apartment block, residents trapped in basement.', '2026-08-01 07:15:00', 0.92),
(2, 4, 1, 'Phoksundo hospital running low on generator fuel.', '2026-08-01 09:40:00', 0.85),
(3, 2, 2, 'Marpha industrial site damaged and needs emergency supplies.', '2026-08-03 14:05:00', 0.78),
(4, 6, 4, 'Lang Tang road blocked by fallen power lines near damaged homes.', '2026-08-02 11:20:00', 0.95),
(5, 9, 6, 'Tamku hospital is destroyed, injured residents need medical care.', '2026-08-01 08:00:00', 0.90),
(6, 7, 2, 'Marpha water supply contaminated near the damaged industrial site.', '2026-08-04 16:30:00', 0.70),
(7, 11, 3, 'Pokhara commercial building has minor cracks, no injuries reported.', '2026-08-05 10:10:00', 0.60),
(8, 13, 1, 'Rescue dogs located two survivors under collapsed structure.', '2026-08-01 18:45:00', 0.97),
(9, 10, 5, 'Chukhung is largely undamaged and can receive displaced families.', '2026-08-03 12:00:00', 0.65),
(10, 14, 4, 'Lang Tang residential building is unsafe, evacuation and inspection required.', '2026-08-02 13:15:00', 0.88);