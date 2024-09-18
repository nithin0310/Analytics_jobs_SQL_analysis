/* 

Question- What skills are required for top paying DA jobs?
-Add specified skills for the top paying roles
-Why? Provides an insight into the skills job seekers need to learn for top roles

*/


WITH top_paying_jobs AS (
    SELECT 
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
FROM 
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id=company_dim.company_id
WHERE 
    job_title_short = 'Data Analyst'
    AND job_location = 'Anywhere' AND 
    salary_year_avg IS NOT NULL 
ORDER BY salary_year_avg DESC
LIMIT 10
)

SELECT  top_paying_jobs.*,
        skills  
FROM top_paying_jobs   
INNER JOIN skills_job_dim ON top_paying_jobs.job_id=skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id=skills_dim.skill_id
ORDER BY salary_year_avg DESC 

/*
SQL: 8 occurrences
Python: 7 occurrences
Tableau: 6 occurrences
The most common skills are SQL, Python, and Tableau, which suggests a strong focus on data manipulation, analysis, and visualization.
*/