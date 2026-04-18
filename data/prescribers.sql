-- SELECT county, population, state
-- FROM population
-- JOIN fips_county
-- ON population.fipscounty = fips_county.fipscounty;

-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? 
-- Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count) AS total_claim_count
FROM prescription
GROUP BY npi 
ORDER BY total_claim_count DESC;

-- answer = prescriber npi 1881634483 with 99707 total claims

    
-- 1b. Repeat the above, but this time report the 
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

  -- 2a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT SUM(total_claim_count) AS total_claim_count, prescriber.specialty_description
FROM prescription 
JOIN prescriber ON prescription.npi = prescriber.npi
GROUP BY prescriber.specialty_description
ORDER BY total_claim_count DESC;

-- answer: Family Practice = 9,752,347 total claims

  -- 2b. Which specialty had the most total number of claims for opioids?

-- SELECT * 
-- FROM drug
-- WHERE opioid_drug_flag = 'Y';

-- SELECT *
-- FROM prescriber;

SELECT  specialty_description, SUM(total_claim_count) AS total_claim_count, opioid_drug_flag
FROM prescriber
JOIN prescription ON prescriber.npi = prescription.npi
JOIN drug ON prescription.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description, opioid_drug_flag
ORDER BY total_claim_count DESC;

-- nurse practitioner had the highest number of claims w/ an opioid drug flag


-- 3a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, total_drug_cost
FROM drug
JOIN prescription ON drug.drug_name = prescription.drug_name
ORDER BY total_drug_cost DESC;

-- answer = $347,480.86


-- 3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, ROUND((SUM(total_drug_cost) * 1.0 / NULLIF(SUM(total_day_supply), 0)), 2) AS cost_per_day
FROM drug
JOIN prescription ON drug.drug_name = prescription.drug_name
GROUP BY generic_name
ORDER BY cost_per_day DESC;

-- 4a. For each drug in the drug table, return the drug name and then a column named 
-- 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', 
-- says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', 
-- and says 'neither' for all other drugs.
-- **Hint:** You may want to use a CASE expression for this. 
-- See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 

SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type
FROM drug;


--  4b. Building off of the query you wrote for part a, 
-- 	determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
-- 	Hint: Format the total costs as MONEY for easier comparision.

SELECT drug.drug_name, total_drug_cost,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'neither'
END AS drug_type
FROM drug
JOIN prescription ON drug.drug_name = prescription.drug_name;

-- 5.a. How many CBSAs are in Tennessee? 
-- **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT(cbsa), fips_county.state
FROM cbsa
JOIN fips_county 
ON cbsa.fipscounty = fips_county.fipscounty
WHERE state = 'TN'
GROUP BY fips_county.state;



--     b. Which cbsa has the largest combined population? 

SELECT cbsa, fips_county.state, population
FROM cbsa
JOIN fips_county 
ON cbsa.fipscounty = fips_county.fipscounty
JOIN population 
ON fips_county.fipscounty = population.fipscounty 
WHERE state = 'TN'
ORDER BY population DESC;

-- answer, largest: "32820"	"TN"	937847
-- answer, smallest: csba=32820,
				  -- state=TN,
			      -- popuation=937847

-- Which has the smallest? 				  

SELECT cbsa, fips_county.state, population
FROM cbsa
JOIN fips_county 
ON cbsa.fipscounty = fips_county.fipscounty
JOIN population 
ON fips_county.fipscounty = population.fipscounty 
WHERE state = 'TN'
ORDER BY population ASC;

-- answer, smallest: csba=34980,
				  -- state=TN,
			      -- popuation=8773


-- --     c. What is the largest (in terms of population) county which is not included in a CBSA?
-- Report the county name and population.

6. 
 --    a. Find all rows in the prescription table where total_claims is at least 3000. 
	-- Report the drug_name and the total_claim_count.

	SELECT drug_name, total_claim_count AS total_claims
	FROM prescription
	WHERE total_claim_count >= 3000;

 --    b. For each instance that you found in part a, 
	-- add a column that indicates whether the drug is an opioid.

	SELECT prescription.drug_name, 
		   prescription.total_claim_count AS total_claims, 
		   CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		   ELSE 'not_opioid'
		   END AS is_opioid
	FROM prescription
	JOIN drug ON prescription.drug_name = drug.drug_name
	WHERE total_claim_count >= 3000;

 --    c. Add another column to you answer from the previous part which gives the 
	-- prescriber first and last name associated with each row.
	
	SELECT prescription.drug_name, 
		   SUM(prescription.total_claim_count) AS total_claims, 
		   CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		   ELSE 'not_opioid'
		   END AS is_opioid, 
		   prescriber.nppes_provider_first_name AS first_name_provider,
		   prescriber.nppes_provider_last_org_name AS last_name_provider
	FROM prescription
	JOIN drug ON prescription.drug_name = drug.drug_name
	JOIN prescriber ON prescription.npi = prescriber.npi
	WHERE total_claim_count >= 3000
	GROUP BY prescription.drug_name, 
	drug.opioid_drug_flag,
	prescriber.nppes_provider_first_name, 
	prescriber.nppes_provider_last_org_name
	ORDER BY total_claims DESC;

--  7. The goal of this exercise is to generate a full list of 
-- all pain management specialists in Nashville 
-- and the number of claims they had for each opioid. 
-- **Hint:** The results from all 3 parts will have 637 rows.

  -- a. First, create a list of all npi/drug_name combinations for pain management specialists 
-- (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), 
-- where the drug is an opioid (opiod_drug_flag = 'Y'). 
-- **Warning:** Double-check your query before running it. 
-- You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT prescriber.npi, prescriber.nppes_provider_city AS city, prescriber.specialty_description
FROM prescriber
CROSS JOIN drug
WHERE prescriber.specialty_description = 'Pain Management'
  AND prescriber.nppes_provider_city = 'NASHVILLE'
  AND drug.opioid_drug_flag = 'Y';

--  b. Next, report the number of claims per drug per prescriber. 
-- Be sure to include all combinations, whether or not the prescriber had any claims. 
-- You should report the npi, the drug name, and the number of claims (total_claim_count)

SELECT prescriber.npi, prescription.drug_name, 
    
--  c. Finally, if you have not done so already, 
-- fill in any missing values for total_claim_count with 0. 
-- Hint - Google the COALESCE function.


