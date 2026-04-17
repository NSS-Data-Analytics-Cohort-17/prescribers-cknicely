SELECT county, population, state
FROM population
JOIN fips_county
ON population.fipscounty = fips_county.fipscounty;

-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? 
-- Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count) AS total_claim_count
FROM prescription
GROUP BY npi 
ORDER BY total_claim_count DESC;
    
-- b. Repeat the above, but this time report the 
	-- nppes_provider_first_name, 
	-- nppes_provider_last_org_name,  
	-- specialty_description, 
	-- the total number of claims.;

SELECT prescription.npi, SUM(total_claim_count) AS total_claim_count,
prescriber.nppes_provider_first_name AS first_name_provider, 
prescriber.nppes_provider_last_org_name AS last_name_provider,
prescriber.specialty_description
FROM prescription
JOIN prescriber ON prescription.npi = prescriber.npi
GROUP BY prescription.npi, prescriber.nppes_provider_first_name, 
prescriber.nppes_provider_last_org_name, prescriber.specialty_description
ORDER BY total_claim_count DESC;

-- BRUCE PENDLEY with 99707 TOTAL CLAIMS

  -- a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT SUM(total_claim_count) AS total_claim_count, prescriber.specialty_description
FROM prescription 
JOIN prescriber ON prescription. npi

SELECT *
FROM prescriber;

