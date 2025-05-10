-- Portfolio Project: Medical Costs Analysis
-- Dataset: medical_cost
-- Columns: id, age, sex, bmi, children, smoker, region, charges
-- Description: This dataset contains medical cost data for individuals, including demographic and health-related variables.
-- Objective: To analyze the impact of various factors on medical charges and derive actionable insights.
-- Author: Elijah Elisha Oluwafemi


-- DESCRIPTIVE ANALYSIS
-- This is a breakdown of some of the general statistic of the data.
select 
Round(MIN(AGE),2) min_age, Round(MAX(AGE),2) max_age, Round(AVG(AGE),2) avg_age, 
round(MIN(BMI),2) min_bmi, round(MAX(BMI),2)max_bmi, round(AVG(BMI),2) avg_bmi,
round(MIN(charges),2) min_charges, round(MAX(charges),2) max_charges, round(AVG(charges),2) avg_charges,
count(id) as patient_count
FROM medical_cost;

-- Explanation : The average age in this study is 39.21
-- 				 The average bmi in this study is 30.66
-- 				 The average charges in this study is 13270.42
-- 				 The number of patients in this dataset is 1338


-- GENDER BASED ANALYSIS
-- checking for the average medical cost disparity between both genders

SELECT sex, ROUND(avg(charges),2) AS average_med_cost
FROM medical_cost
group by sex;

-- 	Explanation: The medical cost on average for males is higher than that of females, with males being 13956.75 in
--    			 comparison to females being 12569.58



-- AGE CHARGES ANALYSIS
-- checking for the effect of various age groups in correspondence to their medical charges 

SELECT *,
CASE
	WHEN AGE BETWEEN 18 AND 19 THEN 'teenagers 19-20'
    WHEN AGE BETWEEN 20 AND 29 THEN 'young adults 20-29'
    WHEN AGE BETWEEN 30 AND 39 THEN 'mid aged 30-39'
    WHEN AGE BETWEEN 40 AND 49 THEN 'adults 40-49'
	WHEN AGE BETWEEN 50 AND 59 THEN 'old 50-59'
    WHEN AGE > 60 THEN 'senior'
END AS age_grouping
from medical_cost;

-- we can't directly query off of the age_grouping column because its a derived column, so we need to 
-- recreate a new table, then insert the new derived column into the new table

CREATE TABLE `medical_cost_2` (
  `Id` int DEFAULT NULL,
  `age` int DEFAULT NULL,
  `sex` text,
  `bmi` double DEFAULT NULL,
  `children` int DEFAULT NULL,
  `smoker` text,
  `region` text,
  `charges` double DEFAULT NULL,
  `age_groupings` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO medical_cost_2
(select *,
CASE
	WHEN AGE BETWEEN 18 AND 19 THEN 'teenagers 19-20'
    WHEN AGE BETWEEN 20 AND 29 THEN 'young adults 20-29'
    WHEN AGE BETWEEN 30 AND 39 THEN 'mid aged 30-39'
    WHEN AGE BETWEEN 40 AND 49 THEN 'adults 40-49'
	WHEN AGE BETWEEN 50 AND 59 THEN 'old 50-59'
    WHEN AGE >= 60 THEN 'senior'
END AS age_grouping
from medical_cost) ;

SELECT age_groupings, ROUND(avg(charges),2) as Average_med_cost
FROM medical_cost_2 
GROUP BY age_groupings
ORDER BY 2 DESC;

 -- Explanation: The average medical cost rises with respect to the patients age, 
 -- the older the patient the higher the medical bills
 
 -- AGE & SMOKING STATUS IN RELATIONSHIP TO MEDICAL BILLS
 
SELECT age_groupings, ROUND(avg(charges),2) as Average_med_cost
FROM medical_cost_2 
WHERE smoker = 'yes'
GROUP BY age_groupings
ORDER BY 2 desc;


SELECT age_groupings, ROUND(avg(charges),2) as Average_med_cost
FROM medical_cost_2 
WHERE smoker = 'no'
GROUP BY age_groupings
ORDER BY 2 desc;

-- Explanation: The smoking demographic medicals bills compared to the non smoking demographic is higher with about 58%			
 
-- BMI VS CHARGES
-- How does BMI affect individuals medical cost
-- we would create a new column to classify the new bmi then in order to query that new column, we would create a new statement


 CREATE TABLE `medical_cost_bmi` (
  `Id` int DEFAULT NULL,
  `age` int DEFAULT NULL,
  `sex` text,
  `bmi` double DEFAULT NULL,
  `children` int DEFAULT NULL,
  `smoker` text,
  `region` text,
  `charges` double DEFAULT NULL,
  `bmi_class` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

    insert into medical_cost_bmi
	select *,
	CASE
		WHEN BMI < 18.5 THEN 'underweight'
		WHEN BMI BETWEEN 18.5 AND 24.999 THEN 'normal weight'
		WHEN BMI BETWEEN 25.0 AND 29.999 THEN 'over weight'
		WHEN BMI BETWEEN 25.0 AND 29.999 THEN 'over weight'
		WHEN BMI BETWEEN 30.0 AND 34.999 THEN 'moderate obesity'
		WHEN BMI BETWEEN 35.0 AND 39.999 THEN 'severe obesity'
		WHEN BMI >= 40 THEN 'morbid'
    END AS bmi_class
    from medical_cost ;
    
Select bmi_class, ROUND(avg(charges),2) as average_med_cost, COUNT(ID)
from medical_cost_bmi
group by bmi_class
ORDER BY 2 DESC;
   
-- Explanation: The body mass index can also be a contributing factor to medical charges, we can see that
-- severe obesity and morbid bmi are topping the list, the higher the bmi, the higher the medical bills
 
-- AGE & BMI VS MEDICAL CHARGES
-- A combined analysis of age and BMI can help you understand if age and BMI together contribute significantly to medical charges.
-- putting their smoking habits into consideration

-- i had to join two derived tables in order to successfully carry out this query, the age_grouping and the bmi_class column were sourced from their various tables

select mc2.age_groupings, mcbmi.bmi_class,mc2.smoker, round(avg(mc2.charges)) med_bills
from medical_cost_2 as mc2
join medical_cost_bmi as mcbmi
on mc2.id=mcbmi.id
where mc2.smoker='yes'
group by mc2.age_groupings, mcbmi.bmi_class
order by 4 desc
limit 5;
    
-- Explanation : Looking at the top 5 most expensive medical charges across both smoking categories, those who are advanced in their years (50 - 65 years) and suffer 
-- 				 from extremely high BMI's tend to pay more in medical charges, however on an average smokers tend to pay about 52% more than what non-smokers pay.

    
-- SMOKERS VS NON SMOKERS ANALYSIS
-- we want to query the medical cost disparity between smokers and non-smokers
    
-- number of smokers per age groupings
		select age_groupings, count(id)
		from medical_cost_2
        where smoker = 'no' 
        group by age_groupings
        order by 2 desc;

-- Explanation: Non-smokers are numbered at 1064, while smokers are 274 in total. the 40-49 age group have the highest number of smokers, while the 50-59
-- 				age group have the highest number of non-smokers
        
-- CATEGORIZING SMOKERS BY GENDER AGAINST THEIR MEDICAL BILLS
    select sex, smoker, round(avg(charges), 2) avg_med_cost, count(id)
    from medical_cost
    group by smoker, sex
    order by 3 desc;
 
 -- Explanation: Smokers have highe medicals bills than non smokers, with male smokers having the highest medical bills by 33,042.01
    

--  EFFECTS OF SMOKING VS THE AVERAGE COST OF MEDICAL BILLS
-- note: 13270 is the average medical charge for all patients as highlighted in the descriptive statistics

select round(avg(charges))
from medical_cost
where charges > 13270 and smoker='no';

select round(avg(charges))
from medical_cost
where charges > 13270 and smoker='no';
 
 -- Explanation: Non-Smokers surpassed the average medical bill by about 50%, while the smokers surpassed the average by 142%
  
-- IMPACT OF CHILDREN ON MEDICAL COSTS
-- we have created 2 extra tables before where we generated inputs for age groups and bmi classes,
-- we would be joining those two tables and querying off them

select children, round(avg(charges),2) as avg_med_cost,count(id)
from
(select mc2.id, mc2.age, mc2.sex, mc2.bmi, mc2.children, mc2.smoker, mc2.region, mc2.charges, mc2.age_groupings, mcbmi.bmi_class
from medical_cost_2 as mc2
join medical_cost_bmi as mcbmi
on mc2.id = mcbmi.id) as joined_table
group by children
order by 3 desc;

-- PATIENTS WITH NO KIDS
select children, round(avg(charges),2) as avg_med_cost,count(id)
from
(select mc2.id, mc2.age, mc2.sex, mc2.bmi, mc2.children, mc2.smoker, mc2.region, mc2.charges, mc2.age_groupings, mcbmi.bmi_class
from medical_cost_2 as mc2
join medical_cost_bmi as mcbmi
on mc2.id = mcbmi.id) as joined_table
where children = 0
group by children
order by 2;

-- PATIENTS WITH KIDS
select children, round(avg(charges),2) as avg_med_cost, count(id)
from
(select mc2.id, mc2.age, mc2.sex, mc2.bmi, mc2.children, mc2.smoker, mc2.region, mc2.charges, mc2.age_groupings, mcbmi.bmi_class
from medical_cost_2 as mc2
join medical_cost_bmi as mcbmi
on mc2.id = mcbmi.id) as joined_table
where children > 1
group by children
order by 2 desc;

-- Explanation: Patients without kids pay significantly lower medical bills compared to those with kids


-- REGION VS CHARGES
-- We are average medical charges based on various region

select region, round(avg(charges)) as avg_med_charges
from medical_cost
group by region
order by 2 desc;

-- Explanation: The southeast is the region with the highest medical bills, 


-- SMOKERS VS REGION 
-- rating smokers based on region in case that is a factor
select region, count(smoker)
from medical_cost
group by region 
order by 2 desc;

-- the south east has the highest number of smokers and that is where we find the highest average medical bills


-- AVERAGE AGE RANGE RELATIONSHIP WITH THE BODY MASS INDEX
select bmi_class, round(avg(age))
from medical_cost_bmi
group by bmi_class
order by 2 desc;

-- Explanation: Patients who suffer fom severe or morbid obesity often times, start losing themselves, in other words, stop caring about their weight at about 40 years

--  SMOKERS, BMI VS CHARGES
-- ranking smokers/non-smokers BMI's against the average medical cost

select bmi_class, smoker, round(avg(charges)), count(id)
from medical_cost_bmi
where smoker = 'yes'
group by bmi_class
order by 3 desc;


select bmi_class, smoker, round(avg(charges)), count(id)
from medical_cost_bmi
where smoker = 'no'
group by bmi_class
order by 3 desc;

-- we can see that smokers with higher BMI tend to pay more for medical bills on average, while non-smokers pay less. the difference in medical bills is about 59.6%


-- AGE GROUPINGS PER REGION

select age_groupings,count(age_groupings), region
from medical_cost_2
group by region, age_groupings
order by 2 desc

-- Explanation: The Southeast has the most oldest people with 31 senior patients and most youngest patients with 40 teenage patients and also the southeast has the most patients
-- 				with 364 patients.
