-- select all the employees whose salary is greater than the avg salary
select * from employees;
select avg(salary) from employees;
select * from employees where salary > (select avg(salary) from employees);

-- Scalar sub query
-- returns always just one row and one column
--like the above one
select e.* from employees e join (select avg(salary)sal from employees) avg_sal
on e.salary > avg_sal.sal;

-- multiple row subquery 
--1. if a subquery returns multiple rows and multiple columns
--2. if a subquery returns only 1 column and multiple rows
--Q. Find the employees who earn the highest salary in ech department
select dept_id, max(salary) from employees group by(dept_id);
select e.emp_name, e.salary, d.dept_name from employees e join departments d on e.dept_id = d.dept_id where (e.dept_id, e.salary) in (select dept_id, max(salary) from employees group by(dept_id));

--same query using no join:
select e.emp_id, e.emp_name, e.salary, 
(select d.dept_name from departments d where e.dept_id = d.dept_id) dept_name
from employees e 
where(e.dept_id, e.salary) in (select dept_id, max(salary) from employees group by(dept_id));

-- single column and multiple row subquery:
--Q: find the department who does not have any employee
select distinct dept_id from employees;
select dept_id, dept_name from departments where dept_id not in
(select distinct dept_id from employees);

-- Correlated subqueries:
-- a subquery related to the outer query
--Q: Find the employees in each department who earn more than the average salary in that department
select avg(salary) as avg_salary from employees group by(dept_id);
select e.* from employees e where e.salary > 
(select avg(salary) as avg_salary from employees where dept_id = e.dept_id);
-- same thing using JOIN
select e.* from employees e 
join(select dept_id, avg(salary) as avg_salary from employees group by(dept_id)) avg_table
on e.dept_id = avg_table.dept_id
where e.salary > avg_table.avg_salary;

--Q: find departments who do not have any employees using the correlated queries
select 1 from employees where dept_id = 3;

select d.* from departments d 
where not exists (select 1 from employees e where e.dept_id = d.dept_id);

--using join for the same thing
select d.*, e.* from departments d left join employees e on d.dept_id = e.dept_id where e.emp_id is NULL;

-- using subquery in select clause
--Q: fetch all employee details and add remakrs to those employees who earn more than the avg pay
select e.*, case when e.salary > (select avg(salary) from employees)
            then 'Higher than average'
            else null
            end
            as remarks 
from employees e; -- not recommended

--alternative:
select e.*, case when e.salary > avg_sal.sal
            then 'Higher than average'
            else null
            end
            as remarks 
from employees e cross join (select avg(salary) sal from employees) avg_sal;

--select query in the having clause:
-- HAVING claused only used with aggregate functions and with group by(or even without it), 
-- where is used without group by 
--Q: Find departments where the average salary is above 5000:
-- with group by function
select dept_id, avg(salary) as avg_salary
from employees group by(dept_id)
having avg(salary) > 5000;

--without group by:
--Q: Check if the total salary of all employees is above 100000:
select sum(salary) as total_salary from employees having sum(salary) > 10000;
-- Having clause with a subquery
--Q: Find the stores who have sold more units than the average units sold by all stores(justto see the syntax, not a part of my real db)
select store_name, sum(quantity) 
from sales
group by(store_name) 
having sum(quantity) > (select avg(quantity) from sales);


-- INSERT using subqueries
--Q: insert data to employee history table. Make sure not to insert duplicate records
insert into employee_history
select e.id, e,name, d.dept_name, e.salary, d.location
from employees e join departments d on e.dept_id = d.dept_id
where not exists(
                select 1 from employee_history eh where eh.emp_id = e.emp_id
);

-- UPDATE using subqueries
--Q: Give 10% increment to all employees in Bangalore location based on the max salary
--  earned by an employee in each department. Only consider employees in employee_history table
update employee e
set salary = (select max(salary) + (max(salary) * 0.1) from employee_history eh where eh.dept_name = e.dept_name)
where e.dept_name in (select dept_name from departments where location = 'Bangalore')
and e.emp_id in (select emp_id from employee_history);
 
 
--DELETE using subqueries:
--Q: Delete all departments who donot have any employees
delete from departments where dept_id in 
(
select dept_id from departments d where not exists(
select 1 from employees  e where e.dept_id = d.dept_id
)
);
select * from employees;
select * from departments;

-------------------------------------------------------------PRACTICE------------------------------------------------------------
--Select EMPLOYEE_ID, FIRST_NAME, SALARY from EMPLOYEES where salary greater than or equal to
--10000 and less than or equal to 12000
SELECT emp_id, emp_name, salary 
FROM employees
WHERE salary BETWEEN 10000 AND 12000;

select * from employees 
where emp_name like '_a%';

select * from employees order by(salary) desc;

select * from employees;
select * from employees where salary < any(select salary from employees where job_id = 'PU_CLERK');
--selecting the employees whose salary is greater than PU clerks and they are not PU clerks themselves
select first_name, last_name, salary, job_id 
from employees
where salary > all(
                   select salary from employees
                   where job_id = 'PU_CLERK') 
                   and job_id <> 'PU_CLERK';
                   
select * from jobs;

select salary from (
select salary from employees order by salary desc
) where rownum <= 5;

select * from departments;
select * from locations;
select * from regions;

SELECT
e.employee_id,
e.first_name,
e.last_name,
(SELECT job_title FROM jobs WHERE job_id = e.job_id) AS job_title,
(SELECT department_name FROM departments WHERE department_id = e.department_id)
AS department_name,
(SELECT city FROM locations WHERE location_id = d.location_id) AS
department_location,
(SELECT region_name FROM regions WHERE region_id = r.region_id) AS region_name
FROM
employees e,
departments d,
locations l,
regions r
WHERE
e.department_id = d.department_id
AND d.location_id = l.location_id;

SELECT
  e.employee_id,
  e.first_name,
  e.last_name,
  j.job_title,
  d.department_name,
  l.city AS department_location,
  r.region_name
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
JOIN regions r ON region_id = r.region_id;


--------------------------------------------self-join------------------------------------
--employees and managers who are in the same table
--fetch all the employees along with their managers
select e.emp_name, e.emp_id, m.emp_name as manager_name, m.emp_id as manager_id
from employees e
join employees m on e.emp_id = m.emp_id;

--Finding Pairs of Employees in Same Department
select e1.emp_name as employee, e2.emp_name as colleague
from employees e1 
inner join employees e2
on e1.dept_id = e2.dept_id
and e1.emp_id <> e2.emp_id
and e1.emp_id < e2.emp_id; --- for unique pair only(eliminating duplication)

-----------------------------------------------------------------------------MID fall23(A)---------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--1.
select e.first_name, e.last_name, jh.department_id, jh.start_date, jh.end_date
from employees e 
join job_history jh
on e.employee_id = jh.employee_id
where e.employee_id in(
                        select employee_id 
                        from job_history
                        group by employee_id having (count(distinct department_id) > 1)
                        )
;
--2.
update employees e
set d.department_id = (select d.department_id from departments d join locations l on d.location_id = d.location_id where l.state_province = 'Texas')
where e.department_id is NULL;
--3.
SELECT department_id, SUM(salary) AS total_salary, COUNT(*) AS num_employees
FROM employees
GROUP BY department_id
ORDER BY total_salary DESC;
--4.
select * from (
select e.employee_id,
       e.first_name,
       e.last_name,
       e.hire_date,
       months_between(sysdate, e.hire_date) as tenure_period
       from employees e
       order by(e.hire_date)
)
where rownum <= 10;
--5.
select * from employees 
where (salary+(salary*0.2)) < 3000;
--6.
select d.department_id, d.department_name, e.first_name as manager, e.salary, l.city
from departments d join employees e on d.manager_id = e.employee_id
join locations l on d.location_id = l.location_id;
--7.
select * from employees where salary between (select min(salary) from emlployees) and 2500;
--8.
select * from employees e1 where salary > 0.5*(select sum(salary) from employees e2 where e1.department_id = e2.department_id group by department_id);
--9.
SELECT e.first_name || ' ' || e.last_name AS full_name,
       j.job_title,
       e.hire_date,
       jh.start_date,
       jh.end_date
FROM employees e
LEFT JOIN (
    SELECT employee_id, start_date, end_date
    FROM job_history jh1
    WHERE start_date = (
        SELECT MAX(jh2.start_date)
        FROM job_history jh2
        WHERE jh2.employee_id = jh1.employee_id
    )
) jh
ON e.employee_id = jh.employee_id
JOIN jobs j 
  ON e.job_id = j.job_id
WHERE e.commission_pct IS NULL;

--10.
SELECT l.state_province, 
       SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d ON d.department_id = e.department_id
JOIN locations l ON l.location_id = d.location_id
WHERE l.state_province LIKE '_a%' 
GROUP BY l.state_province;
------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------MID fall23(B)---------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--1. Write a query to determine the total count of employees categorized by country and city.
select * from locations;
select * from countries;

SELECT c.country_name,
       l.city,
       COUNT(e.employee_id) AS total_employees
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
JOIN countries c ON l.country_id = c.country_id
GROUP BY c.country_name, l.city;

--2. Write a query to calculate the count of employees in each region.
select * from regions;
select * from locations;
SELECT r.region_name, 
       COUNT(e.employee_id) AS employee_count
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
JOIN countries c ON l.country_id = c.country_id
JOIN regions r ON c.region_id = r.region_id
GROUP BY r.region_name;
--3. Write a query to compute the average tenure period for each department from the job_history table.
select * from job_history;
select d.department_name, round(avg(months_between(jh.end_date, jh.start_date)), 2) as avg_tenure from job_history jh
join departments d on jh.department_id = d.department_id
group by department_name;

--4. Write a query to identify the state with the fewest employees.
select * from locations;
select * from(
    select l.state_province from locations l
    join departments d on d.location_id = l.location_id
    join employees e on e.department_id = d.department_id
    order by(e.employee_id) asc
) where rownum = 1;

--5. Write a query to retrieve information about the five least senior employees, along with their respective supervisor’s contact details.
select * from
    (SELECT e.employee_id,
           e.first_name || ' ' || e.last_name AS employee_name,
           e.hire_date,
           m.first_name || ' ' || m.last_name AS manager_name,
           m.email AS manager_email,
           m.phone_number AS manager_phone
    FROM employees e
    LEFT JOIN employees m 
           ON e.manager_id = m.employee_id
    ORDER BY e.hire_date DESC)
where rownum <= 5;

--6. Write a query to retrieve details of all employees where the difference between their salary and the maximum salary of employees residing in Japan is 
--   greater than 5000.
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.salary,
       (SELECT MAX(e2.salary)
        FROM employees e2
        JOIN departments d2 ON e2.department_id = d2.department_id
        JOIN locations l2 ON d2.location_id = l2.location_id
        JOIN countries c2 ON l2.country_id = c2.country_id
        WHERE c2.country_name = 'Japan') AS max_salary_in_japan
FROM employees e
WHERE ( (SELECT MAX(e2.salary)
         FROM employees e2
         JOIN departments d2 ON e2.department_id = d2.department_id
         JOIN locations l2 ON d2.location_id = l2.location_id
         JOIN countries c2 ON l2.country_id = c2.country_id
         WHERE c2.country_name = 'Japan') - e.salary ) > 5000;
         
--7. Write a query to identify employees who have worked in only one department, displaying their start and end dates with the department id.
select e.first_name || ' ' || e.last_name as employee_name,
jh.start_date, jh.end_date, jh.department_id from employees e
join job_history jh on jh.employee_id = e.employee_id
where e.employee_id in(
    select employee_id from job_history group by employee_id 
    having count(distinct department_id) = 1
);

--8. Write a query to calculate the total and average salaries for employees in each state.
select l.state_province, sum(e.salary) as total_sal, avg(e.salary) as avg_sal
from employees e 
join departments d on e.department_id = d.department_id
join locations l on d.location_id = d.location_id
group by l.state_province;

--9. Write a query to retrieve details of employees that were part of the company for over a period of more than 6 months, 
--   had a minimum salary in range of 4000–10000, and belonged to department no 90.
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.hire_date,
       e.salary,
       e.department_id
FROM employees e
WHERE MONTHS_BETWEEN(SYSDATE, e.hire_date) > 6
  AND e.salary BETWEEN 4000 AND 10000
  AND e.department_id = 90;
  
--10. Write a query to determine which state has the highest number of employees.
SELECT state_province, employee_count
FROM (
    SELECT l.state_province,
           COUNT(e.employee_id) AS employee_count
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    GROUP BY l.state_province
    ORDER BY COUNT(e.employee_id) DESC
)
WHERE ROWNUM = 1;


