CREATE SCHEMA snowflake;

-- creating disease_type_dim table in snowflake schema

CREATE TABLE  snowflake.disease_type_dim
(   
	disease_code_dim_id int GENERATED ALWAYS AS IDENTITY PRIMARY key,
    disease_type_code character(5)  not null UNIQUE ,
    disease_type_description character varying(500)
    
);

-- creating disease_dim table in snowflake schema

CREATE TABLE snowflake.disease_dim
(
    disease_dim_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ,
    disease_id integer not null unique,
    disease_name character varying(100),
    disease_type_cd character(5),
    CONSTRAINT disease_dim_pkey PRIMARY KEY (disease_dim_id),
    CONSTRAINT disease_type_fkey FOREIGN KEY (disease_type_cd)
        REFERENCES snowflake.disease_type_dim (disease_type_code)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
select * from snowflake.disease_dim

--creating race_disease_propensity_dim table in snowflake schema

CREATE TABLE snowflake.race_disease_propensity_dim
(
	race_disease_dim_id int GENERATED ALWAYS AS IDENTITY PRIMARY key,
    race_code character varying(5),
    disease_id integer NOT NULL,
    propensity_value integer
    
);

-- creating location_dim table in snowflake schema

CREATE TABLE  snowflake.location_dim
(   
	location_dim_id int GENERATED ALWAYS AS IDENTITY PRIMARY key,
    location_id integer NOT NULL UNIQUE,
    city_name character varying(100) ,
    state_province_name character varying(100),
    country_name character varying(100) ,
    developing_flag character(1) 
    
);

-- creating race_dim table in snowflake schema

CREATE TABLE snowflake.race_dim
(   race_code_dim_id int GENERATED ALWAYS AS IDENTITY PRIMARY key, 
    race_code character(5) not null UNIQUE ,
    race_description character varying(500) 
   
);

-- creating person_dim table in snowflake schema

CREATE TABLE IF NOT EXISTS snowflake.person_dim
(
    person_dim_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ,
    person_id integer NOT NULL,
    last_name character varying(50) ,
    first_name character varying(100) ,
    gender character(1),
    primary_location_id integer,
    race_cd character(5) ,
    disease_id integer,
    CONSTRAINT person_dim_pkey PRIMARY KEY (person_dim_id),
    CONSTRAINT disease_race_fkey FOREIGN KEY (disease_id)
        REFERENCES snowflake.race_disease_propensity_dim (race_disease_dim_id) 
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT location_type_fkey FOREIGN KEY (primary_location_id)
        REFERENCES snowflake.location_dim (location_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT race_cd_fkey FOREIGN KEY (race_cd)
        REFERENCES snowflake.race_dim (race_code)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);


-- creating medicine_disease_dim table in snowflake schema

CREATE TABLE snowflake.medicine_disease_dim
(
    medicine_dim_id int GENERATED ALWAYS AS IDENTITY PRIMARY key ,
    medicine_id integer ,
    disease_id integer
    
);


-- creating medicine_dim table in snowflake schema

CREATE TABLE IF NOT EXISTS snowflake.medicine_dim
(
    medicine_dim_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ,
    medicine_id integer not null unique,
    standard_industry_num character varying(30) ,
    medicine_name character varying(200) ,
    company character varying(150) ,
    active_ingredient_name character varying(200),
    CONSTRAINT medicine_dim_pkey PRIMARY KEY (medicine_dim_id),
    CONSTRAINT company_name_fkey FOREIGN KEY (company)
        REFERENCES snowflake.medicine_company_dim (company_name) 
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT medicine_id_fkey FOREIGN KEY (medicine_id)
        REFERENCES snowflake.medicine_disease_dim (medicine_dim_id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

/* Some of the alter statements to add and drop foreign key constraint

-- Altering medicine_dim table in snowflake to add foreign_key constraint
	
alter table snowflake.medicine_dim add constraint medicine_id_fkey 
     FOREIGN KEY (medicine_dim_id)
        REFERENCES snowflake.medicine_disease_dim (medicine_dim_id) ;

 alter table snowflake.medicine_dim add      
    CONSTRAINT company_name_fkey FOREIGN KEY (company)
        REFERENCES snowflake.medicine_company_dim (company_name) ;

alter table snowflake.medicine_dim add CONSTRAINT medecine_disease_fkey FOREIGN KEY (disease_id)
        REFERENCES snowflake.medicine_effective_disease_dim (disease_id); */


-- creating medicine_company_dim table in snowflake schema

CREATE TABLE snowflake.medicine_company_dim
(   
	company_dim_id int GENERATED ALWAYS AS IDENTITY PRIMARY key,
    company_name character varying(200) not null unique,
    address character varying(250),
    contact_number character varying(30)
    
);

-- creating disease_fact table in snowflake schema

CREATE TABLE  snowflake.disease_fact
(
    person_dim_id integer,
    disease_dim_id integer,
    medicine_dim_id integer,
    disease_start_date date,
    disease_end_date date,
    patient_date_of_birth date,
    patient_disease_severity_value integer,
    disease_intensity_level_qty integer,
    medicine_effectiveness_percentage double precision,
    country_wealth_number integer,
    CONSTRAINT disease_dim_id_fkey FOREIGN KEY (disease_dim_id)
        REFERENCES snowflake.disease_dim (disease_dim_id) 
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT medicine_dim_id_fkey FOREIGN KEY (medicine_dim_id)
        REFERENCES snowflake.medicine_dim (medicine_dim_id) 
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT person_dim_id_fkey FOREIGN KEY (person_dim_id)
        REFERENCES snowflake.person_dim (person_dim_id) 
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

Loading the data ETL (or ELT) process
/* Inserting data into snowflake dimension table using select subquery into insert statement.
This process is also know ETL or ELT to move data from OLTP to Snowflake Schema(Datawarehouse) */

-- Insert Data into Snowflake.disease_type_dim dimenstional table

insert into snowflake.disease_type_dim (disease_type_code, disease_type_description)
   select disease_type_code, disease_type_description from public.disease_type;
   
-- Insert Data into Snowflake.disease_dim dimenstional table
   
insert into snowflake.disease_dim(disease_id, disease_name,disease_type_cd)
	  select disease_id, disease_name,disease_type_cd
	  from public.disease;

-- Insert Data into Snowflake.race_dim dimenstional table

insert into snowflake.race_dim(race_code, race_description)
    select race_code, race_description from public.race;
	
-- Insert Data into Snowflake.race_disease_propensity_dim dimenstional table
 	
insert into snowflake.race_disease_propensity_dim (race_code, disease_id, propensity_value)
    select race_code, disease_id, propensity_value from public.race_disease_propensity ; 


---- Insert Data into Snowflake.location_dim dimenstional table

insert into snowflake.location_dim(location_id, city_name, state_province_name, 
           country_name, developing_flag)
           select location_id, city_name, state_province_name, country_name, developing_flag
	       from public."location" ;
		   
	
-- Inserting data into person_dim dimensional table	

insert into snowflake.person_dim (person_id, last_name,first_name,gender,primary_location_id,race_cd,
disease_id)								  
select p.person_id, p.last_name,p.first_name,p.gender,p.primary_location_id,p.race_cd,dp.disease_id
from public.person p inner join public.diseased_patient dp on
p.person_id = dp.person_id ;
			


-- Insert Data into Snowflake.medicine_disease_dim dimenstional table
		   
insert into snowflake.medicine_disease_dim(medicine_id,disease_id)
           select medicine_id,disease_id from public.indication ;		   
	
-- Inserting data into medicine_company_dim

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
          ('McNeil Consumer Healthcare', '9704 Huntmaster Rd', +13473998637);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
        ('Drisdol', '21110 Dwyer Ct', +15566670722);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
		 ('Motrin', '9101 Warfield Rd', +13498995561);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
         ('Synthroid','8531 Plum Creek Dr', +19992323990);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
        ('Prinivil', '7913 Windsor Knoll Ln', +18823207159);

insert into snowflake. medicine_company_dim(Company_name, Address, Contact_Number) Values
        ('Norvasc', '8301 Lando Ct', +18462650161);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
       ('Deltasone', '20931 Goshen Rd', +18428171239);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
      ('Adderall', '21313 Bourdeaux Pl', +18298215889);


insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
     ('Ventolin HFA', '8630 Lochaven Dr', +17692842317);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
     ('Xanax', '22100 Creekview Dr', +17013723020);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
     ('Flexeril', '21020 Brink Ct', +16595107237);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
     ('Zithromax Z-Pak', '8401 Warfield Rd', +16426991951);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
    ('Neurontin', '22101 Goshen School Rd', +16301267038);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
     ('Keflex', '21536 Quick Fox Ln', +16167941966);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
     ('Zyrtec', '8504 Churchill Downs Rd', +15855864871);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
    ('Microzide', '21624 Goshen Oaks Rd', +15326349557);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
    ('Glucophage', '7921 Windsor Knoll Ln', +15060994723);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
    ('Lipitor', '20601 Miracle Dr', +14548303184);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
      ('Augmentin', '20812 Apollo Ln', +14528786671);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
       ('D3-50', '22105 Creekview Dr', +14418232107);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
     ('Tessalon Perles', '8813 Goshen Mill Ct', +14418232107);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
     ('Cozaar', '9 Foxlair Ct', +14060034724);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
	('Toprol XL', '9137 Goshen Valley Dr', +13846228768);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
    ('Desyrel', '8508 Plum Creek Dr', +13846228768);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
    ('Klonopin', '9117 Goshen Valley Dr', +13815450810);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
   ('Ambien', '22713 Robin Ct', +13676834865);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
   ('Diflucan', '8505 Churchill Downs Rd', +13596259824);
   
insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
   ('Flagyl', '22308 Bertie Farm Ct', +13423322614);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
   ('Lasix', '22521 Sweetleaf Ln', +13351514273);

insert into snowflake.medicine_company_dim(Company_name, Address, Contact_Number) Values
   ('ferrous sulfate', '21628 Goshen Oaks Rd', +13278483984);
   

-- Insert Data into Snowflake.medicine_dim dimenstional table
		   		   
    insert into snowflake.medicine_dim(medicine_id , standard_industry_num , medicine_name ,
    company,active_ingredient_name )  
	select  medicine_id , standard_industry_num ,  medicine_name , company,
    active_ingredient_name from public.medicine limit 25  ;


-- Inserting data into Disease_fact Table 

 insert into snowflake.disease_fact( person_dim_id, disease_dim_id, medicine_dim_id,
								  disease_start_date, disease_end_date, patient_date_of_birth,
								  patient_disease_severity_value, disease_intensity_level_qty,
								  medicine_effectiveness_percentage,  country_wealth_number)														  
          select p.person_id, d.disease_id, m.medicine_id,
	      dp.start_date,  dp.end_date, p.date_of_birth,
		  dp.severity_value, d.intensity_level_qty, i.effectiveness_percent, l.wealth_rank_number
		  from public.diseased_patient dp 
          inner join public.person p on dp.person_id = p.person_id
          inner join public.disease d on dp.disease_id = d.disease_id
		  inner join public.indication i ON i.disease_id = d.disease_id
		  inner join public.medicine m ON m.medicine_id = i.medicine_id															  
		  inner join public."location" l ON l.location_id = p.primary_location_id 														 
		  where m.medicine_id < 26;	
		  
-- Querying Disease_fact table

select * from snowflake.disease_fact order by 1,2,3

-- Interesting analyses that can be generate from snowflake schema

/* To get a list of all the locations in the location_dim table, 
along with the number of people living in each location*/

SELECT l.city_name, l.state_province_name, l.country_name, 
COUNT(p.person_dim_id) AS num_people
FROM snowflake.location_dim l
LEFT JOIN snowflake.person_dim p
ON l.location_id = p.primary_location_id
GROUP BY l.city_name, l.state_province_name, l.country_name;


/* List of all the medicines in the medicine_dim table, along with the names of the companies that 
manufacture them.*/

SELECT m.medicine_name, mc.company_name
FROM snowflake.medicine_dim m
INNER JOIN snowflake.medicine_company_dim mc
ON m.company = mc.company_name;


/*. List of all the racial groups in the race_dim table, along with their propensity values for a specific disease*/

SELECT r.race_code,  rd.propensity_value
FROM snowflake.race_dim r
INNER JOIN snowflake.race_disease_propensity_dim rd
ON r.race_code = rd.race_code
WHERE rd.disease_id = 1;

-- To get the top 10 diseases by total cases, with their respective disease types:

SELECT d.disease_id, d.disease_type_cd, d.disease_name, COUNT(*) AS total_cases
FROM snowflake.disease_fact df inner join snowflake.disease_dim d 
ON df.disease_dim_id = d.disease_dim_id
GROUP BY d.disease_id, d.disease_name, d.disease_type_cd
ORDER BY total_cases DESC
LIMIT 10

-- To get the total number of cases of each disease, grouped by location and year:

SELECT l.country_name,  COUNT(*) AS total_cases
FROM snowflake.location_dim l inner join snowflake.person_dim p on l.location_id = p.primary_location_id
 inner join snowflake.disease_fact df ON df.person_dim_id = p.person_dim_id
 group by l.country_name
 
/* The query will provide a summary of the diseases and medicines that are being used by people, grouped by gender and organized by the disease, medicine, and company */
 
SELECT p.gender, COUNT(d.disease_id) AS total_diseases, d.disease_name, m.medicine_name,
mcd.company_name, mcd.contact_number
FROM snowflake.person_dim p
JOIN snowflake.disease_dim d ON p.disease_id = d.disease_dim_id
JOIN snowflake.medicine_disease_dim md ON d.disease_dim_id = md.disease_id
JOIN snowflake.medicine_dim m ON md.medicine_id = m.medicine_dim_id
JOIN snowflake.medicine_company_dim mcd ON m.company = mcd.company_name
GROUP BY p.gender, d.disease_name, m.medicine_name, mcd.company_name, mcd.contact_number;

-- Created a view named "disease_medicine_view" for the above select statement

CREATE VIEW disease_medicine_view AS
SELECT p.gender, COUNT(d.disease_id) AS total_diseases, d.disease_name, m.medicine_name,
mcd.company_name, mcd.contact_number
FROM snowflake.person_dim p
JOIN snowflake.disease_dim d ON p.disease_id = d.disease_dim_id
JOIN snowflake.medicine_disease_dim md ON d.disease_dim_id = md.disease_id
JOIN snowflake.medicine_dim m ON md.medicine_id = m.medicine_dim_id
JOIN snowflake.medicine_company_dim mcd ON m.company = mcd.company_name
GROUP BY p.gender, d.disease_name, m.medicine_name, mcd.company_name, mcd.contact_number;

Select * from disease_medicine_view;
