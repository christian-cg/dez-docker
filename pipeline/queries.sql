-- OLD STYLE INNER JOIN
SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
	CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropoff_loc"
FROM
	yellow_taxi_data t,
	taxi_zone_lookup zpu,
	taxi_zone_lookup zdo
WHERE
	t."PULocationID" = zpu."LocationID"
	AND t."DOLocationID" = zdo."LocationID"
LIMIT 100;


-- Explicit INNER JOIN (modern approach; clear and safer)
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropoff_loc"
FROM yellow_taxi_data t
JOIN taxi_zone_lookup zpu 
	ON t."PULocationID" = zpu."LocationID"
JOIN taxi_zone_lookup zdo 
	ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;


-- Checking for NULL Location IDs
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    "PULocationID",
    "DOLocationID"
FROM yellow_taxi_data
WHERE
    "PULocationID" IS NULL
    OR "DOLocationID" IS NULL
LIMIT 100;


-- Checking for Location IDs NOT IN zones table
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    "PULocationID",
    "DOLocationID"
FROM yellow_taxi_data
WHERE
    "DOLocationID" NOT IN (SELECT "LocationID" from taxi_zone_lookup)
    OR "PULocationID" NOT IN (SELECT "LocationID" from taxi_zone_lookup)
LIMIT 100;


-- Using LEFT, RIGHT, and FULL JOIN when some Location IDs are not in either tables

-- LEFT JOIN
DELETE FROM taxi_zone_lookup WHERE "LocationID" = 142;

SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropoff_loc"
FROM yellow_taxi_data t
LEFT JOIN
    taxi_zone_lookup zpu ON t."PULocationID" = zpu."LocationID"
JOIN
    taxi_zone_lookup zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;

--RIGHT JOIN
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropoff_loc"
FROM yellow_taxi_data t
RIGHT JOIN
    taxi_zone_lookup zpu ON t."PULocationID" = zpu."LocationID"
JOIN
    taxi_zone_lookup zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;

-- FULL JOIN
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropoff_loc"
FROM yellow_taxi_data t
FULL JOIN
    taxi_zone_lookup zpu ON t."PULocationID" = zpu."LocationID"
JOIN
    taxi_zone_lookup zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;

-- Calculate number of trips per day with GROUP BY
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1)
FROM yellow_taxi_data
GROUP BY CAST(tpep_dropoff_datetime AS DATE)
LIMIT 100;

-- Ordering by day with ORDER BY
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1)
FROM yellow_taxi_data
GROUP BY CAST(tpep_dropoff_datetime AS DATE)
ORDER BY "day" ASC
LIMIT 100;

-- Order by count
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1) AS "count"
FROM yellow_taxi_data
GROUP BY CAST(tpep_dropoff_datetime AS DATE)
ORDER BY "count" DESC
LIMIT 100;

-- Other aggregations with COUNT, MAX
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1) AS "count",
    MAX(total_amount) AS "total_amount",
    MAX(passenger_count) AS "passenger_count"
FROM yellow_taxi_data
GROUP BY CAST(tpep_dropoff_datetime AS DATE)
ORDER BY "count" DESC
LIMIT 100;

-- Grouping by multiple fields
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    "DOLocationID",
    COUNT(1) AS "count",
    MAX(total_amount) AS "total_amount",
    MAX(passenger_count) AS "passenger_count"
FROM yellow_taxi_data
GROUP BY 1, 2
ORDER BY
    "day" ASC,
    "DOLocationID" ASC
LIMIT 100;