/*Q2*/
SELECT
    VehicleClass,
    Transmission,
    ROUND(AVG(EngineSize_L),2) AS AvgEngineSize,
    ROUND(AVG(FuelConsumptionCity_L_100km),2) AS AvgFuelConsumptionCity,
    ROUND(AVG(FuelConsumptionHwy_L_100km),2) AS AvgFuelConsumptionHighway,
    ROUND(AVG(CO2Emissions_g_km),2) AS AvgCO2Emissions
FROM
    co2_emissions_canada
GROUP BY
    VehicleClass,
    Transmission
ORDER BY
    VehicleClass,
    Transmission;


/*Q3*/
SELECT ZIP, EVNetwork, DateLastConfirmed from ev_stations_v1
WHERE RIGHT(DateLastConfirmed,4) BETWEEN 2010 AND 2022
GROUP BY ZIP, EVNetwork,DateLastConfirmed
ORDER BY ZIP, EVNetwork;

/*Q5*/
SELECT 
    State, Model, COUNT(*) AS total_tesla_cars
FROM
    electric_vehicle_population
WHERE
    Make = 'Tesla'
GROUP BY State , Model
ORDER BY total_tesla_cars DESC;

/*Q6*/
# For each electric vehicle type and each clean alternative fuel vehicle eligibility, display the average electric range value.
SELECT 
    ElectricVehicleType,
    CleanAlternativeFuelVehicleEligibility,
    ROUND(AVG(ElectricRange),2)
FROM
    electric_vehicle_population
GROUP BY ElectricVehicleType, CleanAlternativeFuelVehicleEligibility
ORDER by ElectricVehicleType, CleanAlternativeFuelVehicleEligibility;


/*Q8i*/
-- Create temporary tables to store counts -- 
CREATE TEMPORARY TABLE temp_electric_vehicle_counts  AS
SELECT State, COUNT(VIN) AS Number_of_electricvehicles
FROM electric_vehicle_population
GROUP BY State;

CREATE TEMPORARY TABLE temp_ev_station_counts AS
SELECT State, COUNT(DISTINCT StationName) AS Number_of_EVStations
FROM ev_stations_v1
GROUP BY State;

-- Join the temporary tables and calculate the ratio --
CREATE TEMPORARY TABLE temp_result AS
SELECT
    evc.State,
    evc.Number_of_electricvehicles,
    esc.Number_of_EVStations,
    ROUND(evc.Number_of_electricvehicles / esc.Number_of_EVStations,4) AS Ratio_of_vehiclestation_State
FROM
    temp_electric_vehicle_counts evc
JOIN
    temp_ev_station_counts esc
ON
    evc.State = esc.State;

-- Retrieve data from the temp_result table --
SELECT * FROM temp_result
ORDER BY Ratio_of_vehiclestation_State DESC;

-- this is to drop the temporary table --
DROP TEMPORARY TABLE IF EXISTS temp_electric_vehicle_counts;
DROP TEMPORARY TABLE IF EXISTS temp_ev_station_counts;
DROP TEMPORARY TABLE IF EXISTS temp_result;

/*Q8ii*/
-- Create temporary tables to store counts --
CREATE TEMPORARY TABLE temp_electric_vehicle_counts2 AS
SELECT PostalCode, COUNT(VIN) AS Number_of_electricvehicles
FROM electric_vehicle_population
GROUP BY PostalCode;

CREATE TEMPORARY TABLE temp_ev_station_counts2 AS
SELECT ZIP, COUNT(DISTINCT StationName) AS Number_of_EVStations
FROM ev_stations_v1
GROUP BY ZIP;

CREATE TEMPORARY TABLE temp_result2 AS
SELECT
    evc2.PostalCode,
    evc2.Number_of_electricvehicles,
    esc2.Number_of_EVStations,
    ROUND(evc2.Number_of_electricvehicles / esc2.Number_of_EVStations,4) AS Ratio_of_vehiclestation_ZIP
FROM
    temp_electric_vehicle_counts2 evc2
JOIN
    temp_ev_station_counts2 esc2
ON
    evc2.PostalCode = esc2.ZIP;

-- Retrieve data from the temporary table --
SELECT * FROM temp_result2
ORDER BY Ratio_of_vehiclestation_ZIP DESC;

-- Drop the Temporary Tables --
DROP TEMPORARY TABLE IF EXISTS temp_electric_vehicle_counts2;
DROP TEMPORARY TABLE IF EXISTS temp_ev_station_counts2;
DROP TEMPORARY TABLE IF EXISTS temp_result2;

/*Q9*/
SELECT 
    naicsDescription,
    CAST(SUM(TotalEmissions_TON) AS DECIMAL(10, 2)) AS TotalEmissions_TON
FROM (
    SELECT
        naicsDescription,
        CASE
            WHEN emissionsUom = 'LB' THEN ROUND(SUM(totalEmissions) / 2000, 2)
            WHEN emissionsUom = 'TON' THEN ROUND(SUM(totalEmissions), 2)
            ELSE ROUND(SUM(totalEmissions), 2)
        END AS TotalEmissions_TON
    FROM nei_2017_full_data
    WHERE naicsDescription LIKE '%auto%' OR naicsDescription LIKE '%motor%'
    GROUP BY naicsDescription, emissionsUom
) AS subquery
GROUP BY naicsDescription;

/*Q11*/
SELECT VehicleClass, ROUND(AVG(CO2Emissions_g_km),4) AS Average_CO2emission_by_vehicleclass FROM co2_emissions_canada
GROUP BY VehicleClass
ORDER BY Average_CO2emission_by_vehicleclass DESC;

SELECT Make, VehicleClass, ROUND(AVG(CO2Emissions_g_km),4) AS Average_CO2emission_by_make_and_vehicleclass FROM co2_emissions_canada
GROUP BY Make, VehicleClass
ORDER BY Average_CO2emission_by_make_and_vehicleclass DESC;

SELECT Make, ElectricVehicleType, COUNT(ElectricVehicleType) AS Number_of_ElectricVehicleType FROM electric_vehicle_population
GROUP BY Make, ElectricVehicleType
ORDER BY Number_of_ElectricVehicleType;

SELECT 
    Make, 
    ElectricVehicleType,
    COUNT(CASE WHEN CleanAlternativeFuelVehicleEligibility = 'Clean Alternative Fuel Vehicle Eligible' THEN 1 ELSE NULL END) AS Number_of_EligibleCleanAlternatives 
FROM electric_vehicle_population
GROUP BY Make, ElectricVehicleType
ORDER BY Number_of_EligibleCleanAlternatives DESC;

/*Q11*/
SELECT Make, ROUND(SUM(FuelConsumptionCity_L_100km),2),ROUND(SUM(FuelConsumptionHwy_L_100km),2), ROUND(SUM(FuelConsumptionComb_L_100km),2), ROUND(SUM(FuelConsumptionComb_mpg),2) FROM co2_emissions_canada
GROUP BY Make;

/*Q12*/
SELECT
    evp.ElectricVehicleType,
    AVG(ec.CO2Emissions_g_km) AS Avg_CO2_Emissions_basedonVehicleType
FROM
    co2_emissions_canada ec
INNER JOIN
    electric_vehicle_population evp ON ec.Model = evp.Model
WHERE evp.State = 'CA' AND ec.Make = evp.Make
GROUP BY
    evp.ElectricVehicleType;
