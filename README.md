# Group 5 — Disaster Response Database

A relational database for coordinating disaster response: affected
locations, buildings, the organizations and people involved, the
operations they run, and the field reports they file and real
earthquake and flood data per district.


## The Societal Challenge
The 2026 Nepal-Tibet floods caused massive destruction, wiping out roads, bridges, and communication networks. This makes it extremely hard to reach and rescue vulnerable people, such as riverside families and trapped workers.   

### Why Data Management Matters
When communication breaks down during a disaster, critical information goes missing and rescue efforts are severely delayed. A centralized database solves this problem. It gives emergency services and NGOs a single place to organize reliable field reports, track damage, and coordinate rescue teams efficiently.   

### Questions Our Database Answers
Our disaster response database is built to help coordinators answer these key questions during a crisis:
* What is the current status of affected people (e.g., missing, rescued, or safe)?   
* Which regions and buildings are the most severely damaged?   
* Which organizations are actively running relief operations right now?   
* How reliable are the incoming reports from people on the ground?

## Project overview
Week 1:
[Societal problem and scientific literature](resources/Assignment%1%-%Databases.pdf)

Week 2:
[ERD](resources/ERD_diagram.pdf)  and [Database Design Process](resources/Design%and%normalization.pdf)

Week 3:
Schema definition and constraints 
[Schema](db/schema.sql]), [Test data](db/mock%data.sql), [CRUD](src/crud.py), 
[Advanced queries](advanced%queries.py)

Week 4:
[Stakeholder video](resources/Stakeholder%Pitch.mp4)

Week 5:
Real data integration 
[Loading data](db/load%real%data.sql), [First dataset](db/nepal%earthquake%data.csv), [Second dataset](db/npl-flood-events-fao-eve.csv)

## Stakeholder Video
https://github.com/user-attachments/assets/b9e79c80-435c-43ea-9683-ad3898bf9d23

## Schema

location(location_id PK, location_name UNIQUE, region, damage_level, population, households)
organization(org_id PK, org_name, org_type, contact_info)
person(person_id PK, name, age, status)
building(building_id PK, location_id FK, building_type, damage_status)
operations(operation_id PK, org_id FK, location_id FK, operation_type, start_date, status)
report(report_id PK, person_id FK, location_id FK, report_text, reported_at, reliability_score)

earthquake_impact(location_id PK/FK, deaths_*, injured_*, govt_/public_buildings_*)      
flood_period(period_start PK, period_end)                                                    
flood_observation(location_id FK, period_start FK -> PK together, cropland_flooded_ha,
                  total_area_flooded_ha, pop_exposed)                                        
v_earthquake_impact                                                                       

## Running it on MySQL
Create an empty database by running this inside MySQL:
CREATE DATABASE floods;
Then clone the repository from the git repo and change the password in setup to your local MySQL password.
Then, go to main inside src/main.py and run it.

## Example queries 



| Query | Author | Question | Why / Purpose |
| :--- | :--- | :--- | :--- |
| **1** | Erik | How many operations is each organization running right now? | Coordinators can see which organizations are already stretched and which still have capacity before handing out new tasks. |
| **2** | Erik | Which locations get field reports that are less reliable than the average report? | When roads and phone lines break down, field reports are the main source of information. Places with unreliable reports need their information checked before rescuers act on it. |
| **3** | Yevhen | Which locations have more than one severely damaged or destroyed building? | Several collapsed buildings in one place means people may be trapped and roads blocked, so search and rescue and repair teams go there first. |
| **4** | Yevhen | Per province, how many people were killed or injured in the 2015 earthquake, and how many people are exposed to flooding in the latest period of the flood data? | Shows which provinces carry both a past earthquake burden and a current flood risk, which helps divide resources between provinces. |
| **5** | Ojas | Which districts are rated High or Critical but have no active operation? | This is the response gap: the places that need help most and are not getting it, so they should be first in line for new teams. |
| **6** | Ojas | Which districts that had at least 10 earthquake deaths have the most people exposed to flooding in the latest period? | Districts hit by both hazards have weakened buildings and infrastructure, so a new flood there is likely to cause more harm. |

## Limitations

- The data covers different times: the earthquake is from 2015, the floods from 2024–2026. Mock operations only run in mock locations, so Q5 lists all 10 High/Critical districts as having no active operation.
- The real data only gives totals per district, so `building`, `person` and `report` are still mock data.
- `damage_level` reflects the 2015 earthquake only. 36 districts that flood are still rated "None".
- A 0 in the earthquake file can mean "nothing happened" or "not reported". A missing row in the flood file can mean "no flooding" or "no data".
- `flood_impact` holds one earthquake, and we merged Nawalparasi and Rukum back into single districts, although Nepal now has 77.

## Future work

1. Load real operations data, such as HDX's "Who does What Where".
2. Add a `disaster_event` table so the database can hold more than one disaster.
3. Base `damage_level` on both earthquake and flood data.
4. Switch to the 77 current districts, linked to the old ones.

## Reflection

The real data needed more cleaning than we expected: swapped dates in the flood file, a copy error in Palpa's population, a death total that didn't match its parts, and districts split in one file but not the other. Loading the raw files into staging tables first and cleaning them with SQL kept every step traceable, and CHECK constraints caught errors we would not have spotted by eye.

Our biggest problems were in teamwork: older versions of files were pushed over newer ones, so fixed bugs came back.

**Next time:** pull before editing, agree on ID ranges for mock and real data early, and test the full build on an empty database before every push.

## Database URLs
1. https://data.humdata.org/dataset/official-figures-for-casualties-and-damage/resource/af078993-cea6-404e-9b25-04547aed9601
Publication Date: 01 May 2015
Data license: https://docs.humdata.org/about/data-licenses

2. https://data.humdata.org/dataset/fao-eve-global-flood-monitoring-system/resource/89dec06d-cab1-463f-8c6f-057edb0c8783
Publication Date: 03 April 2025
Data License: https://docs.humdata.org/about/data-licenses
