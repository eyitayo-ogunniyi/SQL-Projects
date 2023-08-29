-- creating a table for the 12 datasets
CREATE TABLE cyclistic_trip (
	ride_id	varchar(50),
	rideable_type varchar(20),
	started_at timestamp,
	ended_at timestamp,
	start_station_name varchar(100),
	start_station_id varchar(50),
	end_station_name varchar(100),
	end_station_id	varchar(50),
	start_lat numeric,	
	start_lng numeric,
	end_lat	numeric,
	end_lng numeric,	
	member_casual varchar(50)
)


-- inserting all datasets
INSERT INTO cyclistic_trip
SELECT *
FROM cyclistic_trip_202207
UNION ALL
SELECT *
FROM cyclistic_trip_202208
UNION ALL
SELECT *
FROM cyclistic_trip_202209
UNION ALL
SELECT *
FROM cyclistic_trip_202210
UNION ALL
SELECT *
FROM cyclistic_trip_202211
UNION ALL
SELECT *
FROM cyclistic_trip_202212
UNION ALL
SELECT *
FROM cyclistic_trip_202301
UNION ALL
SELECT *
FROM cyclistic_trip_202302
UNION ALL
SELECT *
FROM cyclistic_trip_202303
UNION ALL
SELECT *
FROM cyclistic_trip_202304
UNION ALL
SELECT *
FROM cyclistic_trip_202305
UNION ALL
SELECT *
FROM cyclistic_trip_202306;


-- selecting all dataset
SELECT * 
FROM public.cyclistic_trip

-- DATA CLEANING
-- removing columns not needed for tha analysis
ALTER TABLE public.cyclistic_trip
DROP COLUMN start_station_id;

ALTER TABLE public.cyclistic_trip
DROP COLUMN end_station_id;

ALTER TABLE public.cyclistic_trip
DROP COLUMN start_lat;

ALTER TABLE public.cyclistic_trip
DROP COLUMN start_lng;

ALTER TABLE public.cyclistic_trip
DROP COLUMN end_lat;

ALTER TABLE public.cyclistic_trip
DROP COLUMN end_lng;

-- checking for duplicate
SELECT distinct ride_id
FROM public.cyclistic_trip;

SELECT ride_id, count(*)
FROM public.cyclistic_trip
GROUP BY ride_id
HAVING count(*) > 1;

-- checking for nulls
SELECT *
FROM public.cyclistic_trip
WHERE started_at IS NULL
	OR	ended_at IS NULL;
	
SELECT *
FROM public.cyclistic_trip
WHERE start_station_name IS NULL
	OR end_station_name IS NULL;
	
-- removing records with no station names
DELETE FROM public.cyclistic_trip
WHERE start_station_name IS NULL;

DELETE FROM public.cyclistic_trip	
WHERE end_station_name IS NULL;
	
-- checking for errors in user and bike types
SELECT distinct rideable_type
FROM public.cyclistic_trip;

SELECT distinct member_casual
FROM public.cyclistic_trip;
 
-- checking distinct station names	
SELECT 
	count(distinct(start_station_name)),
	count(distinct(end_station_name))
FROM public.cyclistic_trip;

SELECT 
	distinct(start_station_name)
FROM public.cyclistic_trip;

SELECT 
 distinct(end_station_name)
FROM public.cyclistic_trip;


-- DATA MANIPULATION

-- Creating new columns
-- calculating ride_length
ALTER TABLE public.cyclistic_trip
ADD ride_length interval;

UPDATE public.cyclistic_trip
SET ride_length = AGE(ended_at, started_at);

-- creating ride minute column
ALTER TABLE public.cyclistic_trip
ADD ride_min numeric;

UPDATE public.cyclistic_trip
SET ride_min = TRUNC(EXTRACT(EPOCH from ride_length)/60)

-- Creating a column for the time of the day
ALTER TABLE public.cyclistic_trip
ADD time_of_day numeric;

UPDATE public.cyclistic_trip
SET time_of_day = EXTRACT(hour from started_at);

-- creating a column for day of the week each ride started
ALTER TABLE public.cyclistic_trip
ADD day_of_week text;

UPDATE public.cyclistic_trip
SET day_of_week = to_char(started_at, 'Dy')

-- creating the year/month column
ALTER TABLE public.cyclistic_trip
ADD ride_year_month text;
	
UPDATE public.cyclistic_trip
SET ride_year_month = to_char(started_at, 'YYYY-MM');

-- Exploring total ride min and length
SELECT min(ride_min),
	max(ride_min),
	avg(ride_min)
FROM public.cyclistic_trip;

SELECT min(ride_length),
	max(ride_length),
	avg(ride_length)
FROM public.cyclistic_trip;

-- removing rows with negative ride minutes and length
DELETE FROM public.cyclistic_trip
WHERE ended_at < started_at

-- removing rows with trip duration less than one minutes
DELETE FROM public.cyclistic_trip
WHERE ride_min < 1;


-- ANALYSIS
-- count of rides per users
SELECT member_casual, 
	count(ride_id)
FROM public.cyclistic_trip
GROUP BY member_casual;

-- avg ride length for users
SELECT member_casual, 
	avg(ride_length) avg_ride_length, 
	round(avg(ride_min), 2) avg_ride_min
FROM public.cyclistic_trip
GROUP BY member_casual;

-- types of ride per users
SELECT rideable_type, member_casual,
	count(ride_id) trips
FROM public.cyclistic_trip
GROUP BY rideable_type, member_casual
ORDER BY trips DESC;

-- checking details about docked bikes
SELECT day_of_week, count(*)
FROM public.cyclistic_trip
WHERE rideable_type = 'docked_bike'
GROUP BY day_of_week;

SELECT time_of_day, count(*)
FROM public.cyclistic_trip
WHERE rideable_type = 'docked_bike'
GROUP BY time_of_day;

-- number of rides per users by day of week
SELECT member_casual, day_of_week,
	count(ride_id) trips
FROM public.cyclistic_trip
GROUP BY member_casual, day_of_week
ORDER BY member_casual, trips DESC;

-- avg ride length for users by days
SELECT member_casual, day_of_week,
	avg(ride_length) avg_ride_length, 
	round(avg(ride_min), 2) avg_ride_min
FROM public.cyclistic_trip
GROUP BY member_casual, day_of_week
ORDER BY member_casual, avg_ride_min DESC;

-- no of trips per time of the day
SELECT member_casual, time_of_day,
	count(ride_id) trips
FROM public.cyclistic_trip
GROUP BY member_casual, time_of_day
ORDER BY member_casual, trips DESC;

-- no of trips per month
SELECT member_casual, ride_year_month,
	count(ride_id) trips
FROM public.cyclistic_trip 
GROUP BY member_casual, ride_year_month
ORDER BY member_casual, trips DESC;

-- number of rides per start stations
SELECT start_station_name,
	count(ride_id) trips
FROM public.cyclistic_trip
WHERE member_casual = 'member'
GROUP BY start_station_name
ORDER BY trips DESC
LIMIT 20;

SELECT start_station_name,
	count(ride_id) trips
FROM public.cyclistic_trip
WHERE member_casual = 'casual'
GROUP BY start_station_name
ORDER BY trips DESC
LIMIT 20;

-- top 10 end stations per rides
SELECT end_station_name,
	count(ride_id) trips
FROM public.cyclistic_trip
WHERE member_casual = 'casual'
GROUP BY end_station_name
ORDER BY trips DESC
LIMIT 10;

SELECT end_station_name,
	count(ride_id) trips
FROM public.cyclistic_trip
WHERE member_casual = 'member'
GROUP BY end_station_name
ORDER BY trips DESC
LIMIT 10;