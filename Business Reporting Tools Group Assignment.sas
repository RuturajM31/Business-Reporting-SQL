libname nyc "C:\Users\pvalenciajimenez\Documents\SQL\Group Assignment\final";

/*You are a group of general airline analysts, and you want to investigate different aspects 
of delays from the different New York City airports (the data stem from 2013, but can be 
enriched with newer data). To do this, you get database comprising flight information, 
airport information, plane information, carrier information and weather information. 
Your goal is to make use of SQL for any preprocessing of the dataset */

*INFORMATIVE TABLES
*Origins;
PROC SQL;
SELECT distinct A.origin, B.lat, B.lon
FROM NYC.FLIGHTS A, NYC.AIRPORTS B
WHERE A.origin=B.faa
;
QUIT;
*Destinations;
PROC SQL;
SELECT distinct A.dest, B.lat, B.lon
FROM NYC.FLIGHTS A, NYC.AIRPORTS B
WHERE A.dest=B.faa
;
QUIT;
*ANALYSIS FLIGHTS;
*Number of flights per airline;
PROC SQL;
CREATE TABLE NYC.FLIGHTS_PER_AIRLINE AS
SELECT carrier, count(flight) as Number_Flights
FROM NYC.FLIGHTS
GROUP BY carrier
ORDER BY 2 DESC;
QUIT;
*Number of flights per airport;
PROC SQL;
CREATE TABLE NYC.FLIGHTS_PER_AIRPORT AS
SELECT origin, count(flight) as Number_Flights
FROM NYC.FLIGHTS
GROUP BY origin
ORDER BY 2 DESC;
QUIT;
*Number of flights per month;
PROC SQL;
CREATE TABLE NYC.FLIGHTS_PER_MONTH AS
SELECT
case when month=1 then 'January'
when month=2 then 'February'
when month=3 then 'March'
when month=4 then 'April'
when month=5 then 'May'
when month=6 then 'June'
when month=7 then 'July'
when month=8 then 'August'
when month=9 then 'September'
when month=10 then 'October'
when month=11 then 'November'
when month=12 then 'December'
end as Month, count(flight) as Flights
FROM NYC.FLIGHTS
GROUP BY 1
ORDER BY 1 ASC
; 
QUIT;
*CALCULATE ROUTE;
PROC SQL;
CREATE TABLE NYC.ROUTES AS
SELECT origin, origin || '-' || dest as Route
FROM NYC.FLIGHTS
;
QUIT;
*Busiest routes ;
PROC SQL;
create table NYC.ROUTE_DETAIL as
SELECT Route, count(Route) as Frequency
from NYC.ROUTES
GROUP BY Route
ORDER BY 2 DESC ;
QUIT;


* ANALYSIS USING INFO ABOUT AIRLINE, ORIGIN AND DESTINATION VS DELAYS
*Evaluating the delays for the different airlines;
*Finding the airline that had the maximum arrival delay;
proc sql;
create table nyc.max_delay_airline as
select name,avg(dep_delay) as Avg_dep_delay,avg(arr_delay) as Avg_arr_delay
from nyc.Airlines A, nyc.flights B
where A.carrier = B.carrier
AND Arr_delay > 0
group by 1
order by Avg_arr_delay desc;
quit;

*Finding the airline that arrived earlier;
proc sql;
create table nyc.fastest_airline as
select name,dep_delay,arr_delay
from nyc.Airlines A, nyc.flights B
where A.carrier = B.carrier
AND dep_delay NE .
AND arr_delay NE .
AND arr_delay < 0
order by 3;
quit;

*Checking the departure delays for airlines that arrived on time;
proc sql;
create table nyc.airlineontime as
select name,dep_delay,arr_delay
from nyc.Airlines A, nyc.flights B
where A.carrier = B.carrier
AND Arr_delay = 0
AND dep_delay > 0
group by 1;
quit;
*Evaluating the average delays for the different airlines (With origin);
PROC SQL;
CREATE TABLE NYC.AVG_DELAY_AIRLINE AS
SELECT carrier, origin, AVG(dep_delay) as Average_delay
FROM NYC.FLIGHTS
GROUP BY carrier, origin
ORDER BY 2,3 DESC;
QUIT;
*Evaluating the delays depending on the destinations;
PROC SQL;
CREATE TABLE NYC.AVG_DELAY_DEST AS
SELECT dest, avg(dep_delay) as Average_delay
FROM NYC.FLIGHTS
group by dest
order by 2 DESC;
QUIT;
*Evaluating the delays depending on the origin airports (best and worst airports);
PROC SQL;
CREATE TABLE NYC.AVG_DELAY_AIRPORT AS
SELECT origin, avg(dep_delay) as Average_delay
FROM NYC.FLIGHTS
group by origin;
QUIT;
*Evaluating the nnumber of delays for the different airlines (With origin);
PROC SQL;
CREATE TABLE NYC.COUNT_DELAY_AIRLINE AS
SELECT carrier, origin, count(dep_delay) as count_delay
FROM NYC.FLIGHTS
GROUP BY carrier, origin
ORDER BY 2,3 DESC;
QUIT;
*Evaluating the delays depending on the origin, destination and air time;
PROC SQL;
CREATE TABLE NYC.DELAY_AIRTIME AS
SELECT origin, dest, air_time, dep_delay
FROM NYC.FLIGHTS
group by origin, dest, air_time
order by 3;
QUIT;
*COMPARING TOTAL FLIGHTS VS DELAYED FLIGHTS
*By Airline;
PROC SQL;
CREATE TABLE NYC.TOTAL_VS_DELAY_AIRLINE AS
SELECT carrier, count(dep_delay) as Delays, count(flight) as Flights, count(dep_delay)/count(flight)*100 as Percent_Delays
FROM NYC.FLIGHTS
group by carrier
order by 4;
QUIT;
*By Destination;
PROC SQL;
CREATE TABLE NYC.TOTAL_VS_DELAY_DEST AS
SELECT dest, count(dep_delay) as Delays, count(flight) as Flights
FROM NYC.FLIGHTS
group by dest
order by 3;
QUIT;
*By Month;
PROC SQL;
CREATE TABLE NYC.TOTAL_VS_DELAY_MONTH AS
SELECT month, count(dep_delay) as Delays, count(flight) as Flights
FROM NYC.FLIGHTS
group by month
order by 1;
QUIT;

*ANALYSIS USING TIME VS DELAYS;
*Evaluating delays by month ;
PROC SQL;
CREATE TABLE NYC.Delay_by_month as
SELECT
case when month=1 then 'January'
when month=2 then 'February'
when month=3 then 'March'
when month=4 then 'April'
when month=5 then 'May'
when month=6 then 'June'
when month=7 then 'July'
when month=8 then 'August'
when month=9 then 'September'
when month=10 then 'October'
when month=11 then 'November'
when month=12 then 'December'
end as Month_name, AVG(dep_delay) as Average_delay
FROM NYC.FLIGHTS
GROUP BY Month_name
; 
QUIT;
*Evaluating delays by weekday;
PROC SQL;
CREATE TABLE NYC.Delay_by_weekday as
SELECT case when weekday(datepart(time_hour))=1 then 'Monday'
when weekday(datepart(time_hour))=2 then 'Tuesday'
when weekday(datepart(time_hour))=3 then 'Wednesday'
when weekday(datepart(time_hour))=4 then 'Thursday'
when weekday(datepart(time_hour))=5 then 'Friday'
when weekday(datepart(time_hour))=6 then 'Saturday'
when weekday(datepart(time_hour))=7 then 'Sunday'
end as Weekday, AVG(dep_delay) as Average_delay
FROM NYC.FLIGHTS
GROUP BY Weekday
; 
QUIT;
*Evaluating delays by hour of the day;
PROC SQL;
create table NYC.DELAY_BY_HOUR as
SELECT distinct hour, count(dep_delay) as count_delay 
FROM NYC.FLIGHTS
GROUP BY hour
ORDER BY hour
; 
QUIT;
* ANALYSIS USING INFO ABOUT PLANES VS DELAYS
*Will engine affect arrival time (for same route)?;
PROC SQL;
CREATE TABLE NYC.ENGINE1 AS
SELECT C.origin, B.engine, avg(C.air_time) AS Air_time
FROM NYC.PLANES B, NYC.FLIGHTS C
WHERE B.tailnum=C.tailnum
GROUP BY C.origin, B.engine;
QUIT;
PROC SQL;
CREATE TABLE NYC.ENGINES AS
SELECT A.Route, B.engine, avg(B.Air_time) AS Avg_Airtime
FROM NYC.ROUTES A, NYC.ENGINE1 B
WHERE A.origin=B.origin
GROUP BY A.Route, B.engine
;
QUIT;
*Will manufacturer affect arrival time (for same route)?;
PROC SQL;
CREATE TABLE NYC.MANU AS
SELECT C.origin, B.manufacturer, avg(C.air_time) AS Air_time
FROM NYC.PLANES B, NYC.FLIGHTS C
WHERE B.tailnum=C.tailnum
GROUP BY C.origin, B.manufacturer;
QUIT;
PROC SQL;
CREATE TABLE NYC.MANUFACTURER AS
SELECT A.Route, B.manufacturer, avg(B.Air_time) as Avg_Airtime
FROM NYC.ROUTES A, NYC.MANU B
WHERE A.origin=B.origin
GROUP BY A.Route, B.manufacturer
;
QUIT;
* ANALYSIS USING INFO ABOUT WEATHER VS DELAYS;
*Month with most rain in 2013;
PROC SQL;
CREATE TABLE NYC.MOST_RAIN2013 as
SELECT Month, SUM(precip) as Precipitation 
from NYC.WEATHER 
GROUP BY Month
;
QUIT;
*Average windspeed per hour of day;
PROC SQL;
CREATE TABLE NYC.WINDSPEED AS
SELECT Origin, hour, AVG(wind_speed) as Avg_Windspeed
from NYC.WEATHER
GROUP BY Origin, hour;
QUIT;
*We exported the SAS tables into CSV using the following code (only 1 example is shown):;
PROC EXPORT DATA=NYC.AIRPORTS_DETAIL   
OUTFILE='C:\Users\pvalenciajimenez\Documents\SQL\Group Assignment\Final\Calculated tables\AIRPORTS_DETAIL .CSV'
DBMS=csv REPLACE;
RUN;
