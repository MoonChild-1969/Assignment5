-- 1. Containers of antibiotics currently in stock
SELECT SUM(quantityOnHand) AS antibioticContainers
FROM item
WHERE itemDescription LIKE '%antibiotics%';

-- 2. Volunteers with a phone number starting with a digit other than 2
--    and a last name other than Jones
SELECT DISTINCT volunteerName
FROM volunteer
WHERE volunteerTelephone NOT LIKE '2%'
  AND (' ' || TRIM(volunteerName)) NOT LIKE '% Jones';

-- 3. Volunteers assigned to transporting tasks
SELECT DISTINCT v.volunteerName
FROM volunteer AS v
JOIN assignment AS a
    ON a.volunteerId = v.volunteerId
JOIN task AS t
    ON t.taskCode = a.taskCode
JOIN task_type AS tt
    ON tt.taskTypeId = t.taskTypeId
WHERE tt.taskTypeName = 'transporting';

-- 4. Tasks with no volunteer assignments
SELECT DISTINCT t.taskDescription
FROM task AS t
LEFT JOIN assignment AS a
    ON a.taskCode = t.taskCode
WHERE a.volunteerId IS NULL;

-- 5. Package types that contain some kind of bottle
SELECT DISTINCT pt.packageTypeName
FROM package_type AS pt
JOIN package AS p
    ON p.packageTypeId = pt.packageTypeId
JOIN package_contents AS pc
    ON pc.packageId = p.packageId
JOIN item AS i
    ON i.itemId = pc.itemId
WHERE i.itemDescription LIKE '%bottle%';

-- 6. Items that are not in any package
SELECT DISTINCT i.itemDescription
FROM item AS i
LEFT JOIN package_contents AS pc
    ON pc.itemId = i.itemId
WHERE pc.packageId IS NULL;

-- 7. Tasks assigned to volunteers who live in New Jersey
SELECT DISTINCT t.taskDescription
FROM task AS t
JOIN assignment AS a
    ON a.taskCode = t.taskCode
JOIN volunteer AS v
    ON v.volunteerId = a.volunteerId
WHERE TRIM(v.volunteerAddress) LIKE '% NJ';

-- 8. Volunteers who began an assignment in the first half of 2021
SELECT DISTINCT v.volunteerName
FROM volunteer AS v
JOIN assignment AS a
    ON a.volunteerId = v.volunteerId
WHERE a.startDateTime >= '2021-01-01'
  AND a.startDateTime < '2021-07-01';

-- 9. Volunteers assigned to tasks that packed spam
SELECT DISTINCT v.volunteerName
FROM volunteer AS v
JOIN assignment AS a
    ON a.volunteerId = v.volunteerId
JOIN package AS p
    ON p.taskCode = a.taskCode
JOIN package_contents AS pc
    ON pc.packageId = p.packageId
JOIN item AS i
    ON i.itemId = pc.itemId
WHERE i.itemDescription LIKE '%spam%';

-- 10. Items worth exactly $100 within a single package
SELECT DISTINCT i.itemDescription
FROM item AS i
JOIN package_contents AS pc
    ON pc.itemId = i.itemId
WHERE pc.itemQuantity * i.itemValue = 100;

-- 11. Number of distinct volunteers assigned to each task status
SELECT ts.taskStatusName,
       COUNT(DISTINCT a.volunteerId) AS volunteerCount
FROM task_status AS ts
LEFT JOIN task AS t
    ON t.taskStatusId = ts.taskStatusId
LEFT JOIN assignment AS a
    ON a.taskCode = t.taskCode
GROUP BY ts.taskStatusId, ts.taskStatusName
ORDER BY volunteerCount DESC;

-- 12. Task with the greatest combined package weight
SELECT p.taskCode,
       SUM(p.packageWeight) AS totalWeight
FROM package AS p
GROUP BY p.taskCode
ORDER BY totalWeight DESC, p.taskCode
LIMIT 1;

-- 13. Number of tasks with a type other than packing
SELECT COUNT(*) AS taskCount
FROM task AS t
JOIN task_type AS tt
    ON tt.taskTypeId = t.taskTypeId
WHERE tt.taskTypeName <> 'packing';

-- 14. Packed items associated with fewer than three distinct volunteers
SELECT DISTINCT i.itemDescription
FROM item AS i
JOIN package_contents AS pc
    ON pc.itemId = i.itemId
JOIN package AS p
    ON p.packageId = pc.packageId
LEFT JOIN assignment AS a
    ON a.taskCode = p.taskCode
GROUP BY i.itemId, i.itemDescription
HAVING COUNT(DISTINCT a.volunteerId) < 3;

-- 15. Packages whose contents are worth more than $100
SELECT pc.packageId,
       SUM(pc.itemQuantity * i.itemValue) AS totalValue
FROM package_contents AS pc
JOIN item AS i
    ON pc.itemId = i.itemId
GROUP BY pc.packageId
HAVING SUM(pc.itemQuantity * i.itemValue) > 100
ORDER BY totalValue ASC;

