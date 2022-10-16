/** Create a schema for the raw files to be imported**/
USE [Ayogu_Database]
GO

DROP SCHEMA IF EXISTS [Crimes]
GO
CREATE SCHEMA [Crimes]

/*Alter table to add geography column and also separate Area from LSOA code*/
alter table dbo.greater_manchester_street
ADD [GeoLocation] GEOGRAPHY
GO


UPDATE dbo.greater_manchester_street
SET [GeoLocation] = geography::Point(latitude, longitude, 4326)
WHERE [longitude] IS NOT NULL
AND [latitude] IS NOT NULL
AND CAST(latitude AS decimal(10, 6)) BETWEEN -90 AND 90
AND CAST(longitude AS decimal(10, 6)) BETWEEN -90 AND 90

go
alter table dbo.greater_manchester_street
ADD LSOA_Area nvarchar (100)
GO
UPDATE dbo.greater_manchester_street
SET LSOA_Area = SUBSTRING([lsoa name],1,(LEN([lsoa name])-5))

/*Create Table for Persons (Population))*/
Drop Table if exists Crimes.Allpersons
SELECT
[Area Codes],
[LA (2019 boundaries)],
LSOA,
[All Ages] as Population_Count
INTO Crimes.AllPersons
FROM dbo.Mid_2018_Persons


/*Create View after joining Great_Manchester_Street and Allpersons*/
DROP VIEW IF EXISTS Crimes.vCrimeAndPopulation
go
CREATE VIEW Crimes.vCrimeAndPopulation AS
SELECT a.[Crime ID] as Crime_ID, a.[LSOA_Area] as LSOA_Area, a.[LSOA code] as LSOA_code, a. [LSOA Name] as LSOA_Name, a.[Month], a.GeoLocation, 
a.Longitude, a.Latitude, a.[Location], a.[Crime type] as Crime_Type, a.[Last outcome category] as Last_Outcome_Category, b.[Population_Count]
FROM dbo.Greater_Manchester_Street a
JOIN Crimes.AllPersons b
ON a.[LSOA code] = b.[Area Codes]


/*Create View for Crime Count with GeoLocation*/
create or alter view Crimes.vName_geo_crimecount as
select LSOA_Area, avg(longitude) as [avg_longitude], avg(latitude) as [avg_latitude], count(LSOA_name) as Crime_count
from Crimes.vCrimeAndPopulation
group by lsoa_Area
go
select * from Crimes.vName_geo_crimecount


/*Stored procedure to get the crime count per month*/
DROP PROCEDURE IF EXISTS Crimes.spColumncountGroup
go
CREATE PROCEDURE Crimes.spColumncountGroup 
	@column nvarchar(100)	
AS 
BEGIN
	DECLARE @query nvarchar(max)
	SET @query = 
		'create or ALTER view Crimes.[vFinal'+@column+'Count] as
		select TOP 20 ['+@column+'], count(['+@column+']) as [Crime_Count]
		from Crimes.vCrimeAndPopulation
		group by ['+@column+']
		order by [Month]'
	exec sp_executesql @query
END
go
EXEC Crimes.spColumncountGroup 'Month'
go
select * from Crimes.vFinalMonthCount


/*Stored Procedure to create view, select column and return count, Crime Type column selected*/
DROP PROCEDURE IF EXISTS Crimes.spColumncountGroup
go
CREATE PROCEDURE Crimes.spColumncountGroup 
	@column nvarchar(100)	
AS 
BEGIN
	DECLARE @query nvarchar(max)
	SET @query = 
		'create or ALTER view Crimes.[vFinal'+@column+'Count] as
		select TOP 20 ['+@column+'], count(['+@column+']) as [Crime_Count]
		from Crimes.vCrimeAndPopulation
		group by ['+@column+']
		order by [Crime_Count] desc'
	exec sp_executesql @query
END
go
EXEC Crimes.spColumncountGroup 'Crime_Type'
go
select * from crimes.[vFinalCrime_Typecount]

/*Exec stored procedure for Lsoa_name, create view and get count*/
EXEC Crimes.spColumncountGroup 'LSOA_Name'
go
select * from crimes.[vFinalLSOA_Namecount]


/*get area crimes per 1000 people*/
create or alter view crimes.vLsoa_namePopulation as
select distinct lsoa_name, population_count
from Crimes.vCrimeAndPopulation

go

Create or Alter view Crimes.vLSOAareaNameCrimeAvg as
select SUBSTRING(a.lsoa_name,1,(LEN(a.lsoa_name)-5)) AS [LSOA_Area], a.Lsoa_name As LSOA_Name, a.crime_count as Crime_count, b.population_count as population_count,
cast((Crime_count/population_count)*1000 as decimal(8,3)) as Crime_per_1000_people
from crimes.[vFinalLSOA_Namecount] a
join crimes.vLsoa_namePopulation b 
On a.Lsoa_name = b.Lsoa_name

go

select top 20 LSOA_Area, sum(Crime_count) as Total_crime_count, sum(population_count) as Total_population_count,
cast((sum(Crime_count)*1000/sum(population_count))as decimal(8,3)) as [Average Crime/1000 People by area]
from Crimes.vLSOAareaNameCrimeAvg
group by LSOA_Area
order by [Average Crime/1000 People by area] desc


/*get vehicle crimes count in Greater Manchester*/
CREATE OR ALTER VIEW Crimes.vVehicleCrimeManchester as
select * from Crimes.vCrimeAndPopulation
where crime_type = 'Vehicle Crime'
go
select * from Crimes.vVehicleCrimeManchester


/*Function to select area and crime type*/
create or alter function Crimes.antiSocial(
@area nvarchar(50),
@crime nvarchar(100)
)
returns table as
return
	select LSOA_Area, GeoLocation, Longitude, Latitude, Crime_Type
	from Crimes.vCrimeAndPopulation
	Where LSOA_Area = @area and Crime_Type = @crime


/*View for Anti-social behaviour crimes in Salford*/
CREATE OR ALTER VIEW Crimes.vAntiSocial as
select * from Crimes.antiSocial('Salford', 'Anti-social behaviour')
go
select * from Crimes.vAntiSocial
