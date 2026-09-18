-- 1. Number of active operations per organization
SELECT org.org_name, COUNT(*) AS active_operations
FROM organization org
JOIN operations op ON op.org_id = org.org_id
WHERE op.status = 'Active'
GROUP BY org.org_name
ORDER BY active_operations DESC;

-- 2. Locations where the average report reliability is below the overall average
SELECT loc.location_name, ROUND(AVG(r.reliability_score), 2) AS avg_reliability
FROM location loc
JOIN report r ON r.location_id = loc.location_id
GROUP BY loc.location_name
HAVING AVG(r.reliability_score) < (SELECT AVG(reliability_score) FROM report)
ORDER BY avg_reliability;

-- 3. Locations with more than one building in Severe or Destroyed condition
SELECT loc.location_name, COUNT(*) AS damaged_buildings
FROM location loc
JOIN building b ON b.location_id = loc.location_id
WHERE b.damage_status IN ('Severe', 'Destroyed')
GROUP BY loc.location_name
HAVING COUNT(*) > 1;
