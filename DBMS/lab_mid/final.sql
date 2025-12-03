------------------------------------------------------------------------------------------------- SQL commands -------------------------------------------------------------------------------------
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




----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------PL-SQL---------------------------------------------------------------------------------------------------
set serveroutput on;
declare
sec_name varchar2(20) := 'Sec-A';
course_name varchar2(20) := 'DBS lab';

begin
dbms_output.put_line('This is '|| sec_name || ' and the course is ' || course_name);

end;

declare
a integer := 10;
b integer := 20;
c integer;
d real;

begin
c := a + b;
dbms_output.put_line('Value of c is '||c);

d := 70.0/30.0;
dbms_output.put_line('Value of d is '||d);

end;

----------------------- GLOBAl vs LOCAL variables ---------------------------------------------
declare
num1 NUMBER := 95;
num2 NUMBER := 85;

begin
dbms_output.put_line('Outer number 1: '||num1);
dbms_output.put_line('Outer number 2: '||num2);

    declare
    num1 NUMBER := 95;
    num2 NUMBER := 85;
    
    begin
    dbms_output.put_line('Inner number 1: '||num1);
    dbms_output.put_line('Inner number 2: '||num2);
    
    end;
end;

declare
e_id employees.employee_id%TYPE;
e_name employees.first_name%TYPE;
e_lname employees.last_name%TYPE;
d_name departments.department_name%TYPE;

begin
select employee_id, first_name, last_name, department_name 
into e_id, e_name, e_lname, d_name
from employees
join departments using(department_id)
where employee_id = 100;

dbms_output.put_line('ID: '||e_id ||' full name: '||e_name||' '||e_lname||' in department: '||d_name);

end;

--------------------------------------- VIEWS -----------------------------------
create or replace view simple_employee_view as
select e.employee_id, e.first_name, e.last_name, e.email, e.salary, d.department_name
from employees e 
join departments d 
on e.department_id = d.department_id;
select * from simple_employee_view;

------------------------------------- FUNCTIONS ---------------------------------
create or replace function calculateBonus(dept_id NUMBER)
return NUMBER
is total_salary number;

begin
select sum(salary) into total_salary
from employees
where department_id = dept_id;
total_salary := total_salary + (total_salary*0.1);
return total_salary;

end;

DECLARE
    dept_bonus NUMBER;
BEGIN
    -- Call the function and store the result in a variable
    dept_bonus := calculateBonus(100);

    -- Print the result
    DBMS_OUTPUT.PUT_LINE('Total Salary with Bonus for Dept 100: ' || dept_bonus);
END;

----------------------------- STORED PROCEDURE -------------------------------------
create or replace procedure insert_data(
street_address in varchar2,
postal_code in varchar2 default null,
city in varchar2,
state_province in varchar2,
country_id in char
)
is location_id NUMBER;

begin
select count(*) into location_id from locations;
location_id := location_id + 1;

insert into locations(location_id, street_address, postal_code, city, state_province, country_id)
values(location_id, street_address, postal_code, city, state_province, country_id);

end;
/

BEGIN
    Insert_Data('123 Main St', '12345', 'Karachi', 'Sindh', 'PK');
END;
/


--------------------------------------------IMPLICIT-CURSOR------------------------------------------------

declare
cursor emp_cur is
select employee_id, first_name, salary
from employees
where department_id = 90;

v_id employees.employee_id%TYPE;
v_name employees.first_name%TYPE;
v_sal employees.salary%TYPE;

begin
open emp_cur;

loop
    fetch emp_cur into v_id, v_name, v_sal;
    exit when emp_cur%NOTFOUND;
    
    dbms_output.put_line('Employee: ' || v_name ||
                             ', Salary: ' || v_sal);
    end loop;
    
close emp_cur;

end;
/

BEGIN
    FOR C IN (SELECT EMPLOYEE_ID, FIRST_NAME, SALARY
              FROM employees
              WHERE department_id = 90)
    LOOP
        dbms_output.put_line(
            'Salary for ' || C.first_name || ' is ' || C.salary
        );
    END LOOP;
END;

------------------------ IF- statement---------------------------
declare
e_sal employees.salary%TYPE;

begin
select salary into e_sal from employees where employee_id = 100;

if e_sal > 5000 then
    dbms_output.put_line('Employees salary is greater than 5000');
    end if;
    
end;
/


DECLARE
    e_sal employees.salary%TYPE;
BEGIN
    SELECT salary INTO e_sal FROM employees WHERE employee_id = 100;

    IF e_sal >= 5000 THEN
        DBMS_OUTPUT.PUT_LINE('Salary is high: ' || e_sal);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Salary is low: ' || e_sal);
    END IF;
END;
/


DECLARE
    e_sal employees.salary%TYPE;
BEGIN
    SELECT salary INTO e_sal FROM employees WHERE employee_id = 100;

    IF e_sal > 20000 THEN
        DBMS_OUTPUT.PUT_LINE('Salary is very high: ' || e_sal);
    ELSIF e_sal > 10000 THEN
        DBMS_OUTPUT.PUT_LINE('Salary is moderate: ' || e_sal);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Salary is low: ' || e_sal);
    END IF;
END;
/

----------------------------------- CASE STATEMENT(simple) --------------------------------------------
declare
e_did employees.department_id%TYPE;
e_sal employees.salary%TYPE;

begin
select department_id, salary into e_did, e_sal
from employees where employee_id = 100;

case e_did
     when 10 then
            DBMS_OUTPUT.PUT_LINE('Department 10: Salary is ' || e_sal);
        WHEN 20 THEN
            DBMS_OUTPUT.PUT_LINE('Department 20: Salary is ' || e_sal);
        WHEN 30 THEN
            DBMS_OUTPUT.PUT_LINE('Department 30: Salary is ' || e_sal);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Other department: Salary is ' || e_sal);
    END CASE;
END;
/       


----------------------------------------- SEARCHED CASE STATEMENT ---------------------------------------
declare
e_sal employees.salary%TYPE;

begin
select salary into e_sal from employees where employee_id = 100;

case
    when e_sal > 20000 then
        DBMS_OUTPUT.PUT_LINE('Very High Salary');
    when e_sal between 10000 and 20000 then
        DBMS_OUTPUT.PUT_LINE('Moderate Salary');
    else
        DBMS_OUTPUT.PUT_LINE('Low Salary');
end case;
end;
/

---------------------------------FOR LOOP------------------------------------
begin
for i in 1..5 loop
    dbms_output.put_line('iteration number: '||i);
    end loop;
end;
/

-- while loop
declare
i number :=1;
begin
while i <= 5 loop
    dbms_output.put_line('iteration number: '||i);
    i := i+1;
end loop;
end;
/

-- cursor loop
BEGIN
    FOR emp_rec IN (SELECT employee_id, first_name, salary FROM employees WHERE department_id = 90) LOOP
        DBMS_OUTPUT.PUT_LINE('Employee: ' || emp_rec.first_name || ', Salary: ' || emp_rec.salary);
    END LOOP;
END;
/

create or replace type employee_type as object(
emp_id number,
emp_name varchar(20),
hire_date date,
member function year_of_service return number
);
/

create or replace type body employee_type as 
member function year_of_service return number is
begin
    return trunc(MONTHS_BETWEEN(sysate, hire_date)/12);
end;
end;

create table employees_data of employee_type(
    primary key(emp_id)
);

insert into employees_data values (1, employees(3,'Aqsa', DATE '2023-8-13'));
insert into employees_data values (employees_type(4, 'Amna', DATE '2024-01-13'));

SELECT e.emp_id, e.emp_name, e.hire_date
FROM employees_data e;

SELECT * FROM employees_data;

SELECT e.emp_name,
       e.year_of_service() AS years_with_company
FROM employees_data e;

declare 
employee employee_type;

begin
employee := employee_type(34, 'Adina Faraz', DATE '2018-03-10');

dbms_output.put_line('Name: '||employee.emp_name);
dbms_output.put_line('Years of service: '||employee.year_of_service());

end;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------ TRIGGERS ----------------------------------------------------------------------------------------------
create or replace trigger insert_data
before insert on student
for each row
begin
if :new.faculty_id is null then
:new.faculty_id := 1;
end if;
end;
-- faculty_id is missing → trigger sets it to 1.
insert into student(student_id, student_name) values (112, 'Kinza');


--before update trigger -> auto calculate yearly salary
create or replace trigger calculate_yearly_salary
before update on student
for each row
begin
:new.y_pay := :new.h_pay * 1920;
end;

-- before delete->prevent deletion
create or replace trigger prevent_record
before delete on student
for each row 
begin
if :old.student_name = 'sana' then
    RAISE_APPLICATION_ERROR(-20001, 'Cannot delete the user, student_name is Sana');
    end if;
end;
/

delete from student where student_name = 'sana';
-- delete function will not be performed becuase of the trigger

---- AFTER INSERT TRIGGER
create table student_logs(
    student_id int,
    student_name varchar(20),
    inserted_by varchar(20),
    inserted_on date
);


DROP TABLE student CASCADE CONSTRAINTS;

CREATE TABLE student (
    student_id      NUMBER PRIMARY KEY,
    student_name    VARCHAR2(50),
    faculty_id      NUMBER,
    h_pay           NUMBER,      -- hourly pay
    y_pay           NUMBER       -- yearly pay (calculated by trigger)
);
INSERT INTO student VALUES (101, 'Ali',     2, 200, NULL);
INSERT INTO student VALUES (102, 'Sana',    3, 180, NULL);
INSERT INTO student VALUES (103, 'Hamza',   1, 220, NULL);
INSERT INTO student VALUES (104, 'Aqsa',    NULL, 250, NULL);

---- AFTER INSERT TRIGGER
create table student_logs(
    student_id int,
    student_name varchar(20),
    inserted_by varchar(20),
    inserted_on date
);

CREATE OR REPLACE TRIGGER after_ins
AFTER INSERT ON student
FOR EACH ROW
BEGIN
    INSERT INTO student_logs
    (student_id, student_name, inserted_by, inserted_on)
    VALUES
    (:NEW.student_id,
     :NEW.student_name,
     SYS_CONTEXT('USERENV','SESSION_USER'),
     SYSDATE);
END;
/

INSERT INTO student VALUES (150, 'Ayan',     4, 600, NULL);
select * from student_logs;

-------------------------------------- BEFORE DROP (DDL trigger to stop tble drops) -----------------------------------------------------

create or replace trigger prevent_table
before drop on database
begin
    raise_application_error(-20000, 'Can not drop object');
end;
/

drop table student;

-- Schema-Level DDL Audit Trigger (Log CREATE/DROP Events)
create table schema_audit(
    ddl_date date,
    ddl_user varchar(15),
    object_created varchar(15),
    object_name varchar(15),
    ddl_operation varchar(15)
);

create or replace trigger hr_audit_tr
after ddl on schema
begin
    insert into schema_audit values (
        sysdate,
        sys_context('userenv', 'current_user'),
        ora_dict_obj_type,
        ora_dict_obj_name,
        ora_sysevent
    );
end;
/

create table ddl2_check(h_name varchar2(20));

select * from schema_audit;
create or replace view emp_view as
select emp_id, emp_name from employees;

create or replace trigger view_insert
instead of insert on emp_view
for each row
begin
    insert into employees(emp_id, emp_name)
    values(:new.emp_id, :new.emp_name);
end;
/

-- Lab -09 (Triggers in PL-SQL)
CREATE OR REPLACE TRIGGER validate_email
BEFORE INSERT ON student
FOR EACH ROW
BEGIN
   IF NOT REGEXP_LIKE(:NEW.email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid Email Format');
   END IF;
END;
/
CREATE TABLE system_logs (
    message VARCHAR2(100),
    log_time DATE
);

CREATE OR REPLACE TRIGGER startup_log
AFTER STARTUP ON DATABASE
BEGIN
    INSERT INTO system_logs VALUES ('Database started at', SYSDATE);
END;
/
create or replace view emp_view as
select emp_id, emp_name from employees;

create or replace trigger view_insert
instead of insert on emp_view
for each row
begin
    insert into employees(emp_id, emp_name)
    values(:new.emp_id, :new.emp_name);
end;
/

-- Lab -09 (Triggers in PL-SQL)
CREATE OR REPLACE TRIGGER validate_email
BEFORE INSERT ON student
FOR EACH ROW
BEGIN
   IF NOT REGEXP_LIKE(:NEW.email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid Email Format');
   END IF;
END;
/
CREATE TABLE system_logs (
    message VARCHAR2(100),
    log_time DATE
);

CREATE OR REPLACE TRIGGER startup_log
AFTER STARTUP ON DATABASE
BEGIN
    INSERT INTO system_logs VALUES ('Database started at', SYSDATE);
END;
/

CREATE OR REPLACE TRIGGER tr_superheroes
BEFORE INSERT OR DELETE OR UPDATE ON superheroes
FOR EACH ROW
ENABLE
DECLARE
v_user VARCHAR2(15);
BEGIN
SELECT
user INTO v_user FROM dual;
IF INSERTING THEN
DBMS_OUTPUT.PUT_LINE('one line inserted by '||v_user);
ELSIF DELETING THEN
DBMS_OUTPUT.PUT_LINE('one line Deleted by '||v_user);
ELSIF UPDATING THEN
DBMS_OUTPUT.PUT_LINE('one line Updated by '||v_user);
END IF;
END;

/

CREATE TABLE sh_audit (
    new_name   VARCHAR2(100),
    old_name   VARCHAR2(100),
    user_name  VARCHAR2(30),
    entry_date VARCHAR2(30),
    operation  VARCHAR2(10)
);

CREATE OR REPLACE TRIGGER superheroes_audit
BEFORE INSERT OR DELETE OR UPDATE ON superheroes
FOR EACH ROW
DECLARE
    v_user VARCHAR2(30);
    v_date VARCHAR2(30);
BEGIN
    SELECT user, TO_CHAR(sysdate, 'DD/MON/YYYY HH24:MI:SS') 
    INTO v_user, v_date
    FROM dual;

    IF INSERTING THEN
        INSERT INTO sh_audit (new_name, old_name, user_name, entry_date, operation)
        VALUES (:NEW.SH_NAME, NULL, v_user, v_date, 'Insert');
    ELSIF DELETING THEN
        INSERT INTO sh_audit (new_name, old_name, user_name, entry_date, operation)
        VALUES (NULL, :OLD.SH_NAME, v_user, v_date, 'Delete');
    ELSIF UPDATING THEN
        INSERT INTO sh_audit (new_name, old_name, user_name, entry_date, operation)
        VALUES (:NEW.SH_NAME, :OLD.SH_NAME, v_user, v_date, 'Update');
    END IF;
END;
/
-- Datbase event triggers: (logon/logoff, startup/shutdown)
create or replace trigger hr_logon_audit
after logon on schema
begin
    insert into hr_event_audit values(
        'LOGON', sysdate, to_char(sysdate, 'hh24:mi:ss'), NULL, NULL
    );
    
end;
/

CREATE OR REPLACE TRIGGER log_off_audit
BEFORE LOGOFF ON SCHEMA
BEGIN
    INSERT INTO hr_evnt_audit VALUES('LOGOFF', NULL, NULL, SYSDATE, TO_CHAR(sysdate,'hh24:mi:ss'));
END;
/


create or replace trigger startup_audit
after startup on database
begin
    insert into startup_audit 
    values('STARTUP', sysdate, to_char(sysdate,'hh24:mi:ss'));
end;
/
create or replace trigger shutdown_audit
before shutdown on database
begin
    insert into shutdown_audit
    values('SHUTDOWN', sysdate, to_char(sysdate,'hh24:mi:ss'));
end;
/

CREATE TABLE trainer(full_name VARCHAR2(20));
CREATE TABLE subject(subject_name VARCHAR2(15));

CREATE VIEW db_lab_09_view AS
SELECT full_name, subject_name FROM trainer, subject;

CREATE OR REPLACE TRIGGER tr_Io_Insert
INSTEAD OF INSERT ON db_lab_09_view
FOR EACH ROW
BEGIN
    INSERT INTO trainer(full_name) VALUES(:NEW.full_name);
    INSERT INTO subject(subject_name) VALUES(:NEW.subject_name);
END;
/
CREATE OR REPLACE TRIGGER io_update
INSTEAD OF UPDATE ON db_lab_09_view
FOR EACH ROW
BEGIN
    UPDATE trainer SET full_name = :NEW.full_name WHERE full_name = :OLD.full_name;
    UPDATE subject SET subject_name = :NEW.subject_name WHERE subject_name = :OLD.subject_name;
END;
/
CREATE OR REPLACE TRIGGER io_delete
INSTEAD OF DELETE ON db_lab_09_view
FOR EACH ROW
BEGIN
    DELETE FROM trainer WHERE full_name = :OLD.full_name;
    DELETE FROM subject WHERE subject_name = :OLD.subject_name;
END;
/
-------------------------------------------------------------------------------- TRANSACTIONS ------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create table worker(
    worker_id number primary key,
    worker_name varchar2(50),
    salary number
);

insert into worker values(1, 'amir', 5000);

select * from worker;

update worker set salary = 50000 where worker_id = 1;
commit;
rollback;

set transaction name 'testing';

insert into worker values(2, 'Muneeb', 2000);
savepoint sp1;

UPDATE worker SET salary = 6000 WHERE worker_name='Muneeb';
SAVEPOINT sp2;

select * from worker;

rollback to savepoint sp1;

commit;

set autocommit on;

INSERT INTO worker VALUES (3, 'FAST-NU', 5000);

rollback;

set autocommit off;

rollback;



-----------------------------------------------Scenario 1-----------------------------------------
-- 1. Product table
CREATE TABLE product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- 2. Inventory table
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    stock INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- 3. Orders table
CREATE or replace table orders (
    order_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

start transaction;

insert into product values (101, 'Laptop', 1200);

savepoint product_added;

insert into inverntory values(product_id, stock);
savepoint inventory_added;

declare
orderqty int;

begin
set orderqty := 60;

update inventory
set stock = stock = orderqty
where product_id = 101;

if (select stock from inventory where product_id = 101) < 0 then
    rollback to savepoint inventory_added
else
    INSERT INTO orders(order_id, product_id, quantity)
    VALUES (1001, 101, order_quantity);
commit;
end if;
end;

---------------------------------------------------------------scenario: ATM transactions -----------------------------------------------------------------------------
-- Enable output to see messages
SET SERVEROUTPUT ON;

-- Assume customer table exists:
-- customer(customer_id, name, balance)
-- Assume atm_transaction table exists:
-- atm_transaction(transaction_id, customer_id, amount, transaction_type, transaction_date)

-- Insert a sample customer if not exists
INSERT INTO customer (customer_id, name, balance)
VALUES (101, 'Alice', 1000);

COMMIT;

-- Withdrawal PL/SQL block
DECLARE
    v_customer_id   NUMBER := 101;       -- Customer ID
    v_withdraw_amt  NUMBER := 500;       -- Amount to withdraw
    v_balance       NUMBER;              -- Current balance
BEGIN
    -- Step 1: Get current balance
    SELECT balance 
    INTO v_balance
    FROM customer
    WHERE customer_id = v_customer_id;

    -- Step 2: Check if balance is sufficient
    IF v_balance < v_withdraw_amt THEN
        DBMS_OUTPUT.PUT_LINE('Insufficient balance. Transaction cancelled.');
    ELSE
        -- Step 3: Deduct money from customer
        UPDATE customer
        SET balance = balance - v_withdraw_amt
        WHERE customer_id = v_customer_id;

        -- Savepoint after deduction
        SAVEPOINT money_deducted;

        -- Step 4: Log transaction
        INSERT INTO atm_transaction(transaction_id, customer_id, amount, transaction_type, transaction_date)
        VALUES (1, v_customer_id, v_withdraw_amt, 'withdraw', SYSDATE);

        -- Savepoint after logging
        SAVEPOINT transaction_logged;

        -- Step 5: Commit transaction
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Withdrawal successful!');
    END IF;
END;
/
------------------------------------------------------------------------MONGODB-----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
--create database
use SchoolDB

--create collections
db.createCollection("Students")
db.createCollection("Courses")

-- Insert documents into Students
db.Students.insertMany([
  {
    _id: 1,
    name: "Alice",
    age: 20,
    scores: { math: 85, science: 90 }
  },
  {
    _id: 2,
    name: "Bob",
    age: 22,
    scores: { math: 78, science: 82 }
  },
  {
    _id: 3,
    name: "Charlie",
    age: 21,
    scores: { math: 92, science: 88 }
  },
  {
    _id: 4,
    name: "Daisy",
    age: 23,
    scores: { math: 68, science: 74 }
  }
]);

-- Insert documents into Courses
db.Courses.insertMany([
  {
    _id: 101,
    courseName: "Mathematics",
    instructor: "Dr. Smith",
    studentsEnrolled: [1, 2, 3]
  },
  {
    _id: 102,
    courseName: "Science",
    instructor: "Dr. Adams",
    studentsEnrolled: [2, 3, 4]
  }
]);


-- a) Student where math score ≥ 85 AND age < 22
db.Students.findOne({
  "scores.math": { $gte: 85 },
  age: { $lt: 22 }
})

-- b) Course where studentsEnrolled includes 3 AND instructor is “Dr. Adams”
db.Courses.findOne({
  studentsEnrolled: 3,
  instructor: "Dr. Adams"
})


-- a) Students with math ≥ 80 AND science < 90
db.Students.find({
  "scores.math": { $gte: 80 },
  "scores.science": { $lt: 90 }
})

-- b) Students age ≤ 23 OR math score ≥ 85
db.Students.find({
  $or: [
    { age: { $lte: 23 } },
    { "scores.math": { $gte: 85 } }
  ]
})

-- c) Students with science ≥ 80 AND (math < 75 OR age > 22)
db.Students.find({
  "scores.science": { $gte: 80 },
  $or: [
    { "scores.math": { $lt: 75 } },
    { age: { $gt: 22 } }
  ]
})

-- Increase Bob’s science score if math ≥ 75
db.Students.updateOne(
  { name: "Bob", "scores.math": { $gte: 75 } },
  { $inc: { "scores.science": 1 } }
)


-- Increase math score by 5 for students with science < 80 AND age > 22
db.Students.updateMany(
  {
    "scores.science": { $lt: 80 },
    age: { $gt: 22 }
  },
  {
    $inc: { "scores.math": 5 }
  }
)

-- Remove student Daisy whose science ≤ 80
db.Students.deleteOne({
  name: "Daisy",
  "scores.science": { $lte: 80 }
})

-- Remove courses where studentsEnrolled includes 2 OR instructor is “Dr. Smith”
db.Courses.deleteMany({
  $or: [
    { studentsEnrolled: 2 },
    { instructor: "Dr. Smith" }
  ]
})


-- Drop Students collection
db.Students.drop()

-- Drop Courses collection
db.Courses.drop()


-- Delete SchoolDB database
use admin
db.getSiblingDB("SchoolDB").dropDatabase()

db.getSiblingDB("SchoolDB").dropDatabase()
db.books.countDocuments()
db.books.countDocuments({ &quot;publication_year&quot;: { &quot;$gt&quot;: 2000 } });
db.books.find().sort({ &quot;publication_year&quot;: 1 });
db.books.find().sort({ &quot;publication_year&quot;: -1, &quot;title&quot;: 1 });
db.books.find().limit(5);
db.books.find().skip(3);
db.books.find().skip(5).limit(5);
-- Aggregate functions:
Find the Average Publication Year of All Books
db.books.aggregate([
  { 
    "$group": { 
      "_id": null, 
      "avgPublicationYear": { "$avg": "$publication_year" } 
    } 
  }
])

Group by Genre and Count Books in Each Genre
db.books.aggregate([
  { 
    "$group": { 
      "_id": "$genre", 
      "count": { "$sum": 1 } 
    } 
  }
])


Sort Genres by Number of Books in Descending Order
db.books.aggregate([
  { 
    "$group": { 
      "_id": "$genre", 
      "count": { "$sum": 1 } 
    } 
  },
  { 
    "$sort": { "count": -1 } 
  }
])


Return Only Title and Author
db.books.find({}, { "title": 1, "author": 1, "_id": 0 })
    
Exclude ISBN Field
db.books.find({}, { "ISBN": 0 })

Create a Text Index
db.books.createIndex({ "title": "text", "author": "text" })
Creates a text index on title and author for performing text searches.

Search for Books with the Word "Road" in Title or Author
db.books.find({ "$text": { "$search": "Road" } })

Find Books with Titles Starting with "The"
db.books.find({ "title": { "$regex": "^The", "$options": "i" } })

Find Books by Authors with Last Name "Lee"
db.books.find({ "author": { "$regex": "Lee$", "$options": "i" } })

Increase the Rating of All Books by 1
db.books.updateMany({}, { "$inc": { "rating": 1 } })

Decrease the Publication Year by 5 for a Specific Book
db.books.updateOne({ "title": "1984" }, { "$inc": { "publication_year": -5 } })

Find a Book by Title and Update Its Genre
db.books.findOneAndUpdate(
  { "title": "The Great Gatsby" },
  { "$set": { "genre": "Classic" } },
  { "returnNewDocument": true }
);


Find a Book by Title and Delete It
db.books.findOneAndDelete({ "title": "The Great Gatsby" });


-------------------------------paper ques:02 (triggers) --------------------------------
create or replace trigger prevent_negative_values
before insert or update on products
for each row
declare
    old_stock NUMBER;
begin
    if :NEW.price <= 0 or :NEW.stock_quantity <= 0 then
        raise_application_error(-20001, 'Product price or quantity can not be negative or 0');
        
    end if;
    
    if :NEW.stock_quantity < 5 then
        raise_application_error(-20002, 'The product is going out of stock');
    end if;
    
    if updating then
        old_stock := :OLD.stock_quantity ;
        if :NEW.stock_quantity < (old_stock *0.5) then
           RAISE_APPLICATION_ERROR(-20003,
                'Stock reduction exceeds allowed limit (50%)');
        end if;
    end if;
    
    if inserting then
        :new.subtotal := :new.price * :new.stock_quantity;
    elsif updating then
        if new.subtotal <> old.subtotal then
            RAISE_APPLICATION_ERROR(-20004,
                'This field cannot be updated manually');
        end if;
        :new.subtotal := :new.price * :new.stock_quantity;
        
    end if;
    
    if inserting then
        :new.created_by := USER;
    end if;
    
    if updating then
        :new.updated_by := USER;
    end if;
    
    :new.last_updated := sysdate;
    
end;
----------------------------------------------------------- Ques: 03 --------------------------------------------------------------------------
-- 1. Create object type ORDER_ITEM (named as per requirement, not product_type)
CREATE OR REPLACE TYPE ORDER_ITEM AS OBJECT(
    item_name VARCHAR2(50),
    quantity NUMBER,
    price FLOAT,
    
    -- Member function to calculate total cost with discount
    MEMBER FUNCTION total_cost RETURN FLOAT
);
/

-- 2. Create type body for ORDER_ITEM
CREATE OR REPLACE TYPE BODY ORDER_ITEM AS 
    MEMBER FUNCTION total_cost RETURN FLOAT IS
        v_total FLOAT;
    BEGIN
        -- Calculate base cost
        v_total := self.quantity * self.price;
        
        -- Apply 5% discount if quantity > 5
        IF self.quantity > 5 THEN
            v_total := v_total * 0.95; -- 5% discount
        END IF;
        
        RETURN v_total;
    END;
END;
/

-- 3. Create object table to store multiple order items
CREATE TABLE order_items_table OF ORDER_ITEM;

-- Insert sample data (corrected INSERT statements)
INSERT INTO order_items_table VALUES (ORDER_ITEM('chocolate', 10, 100));
INSERT INTO order_items_table VALUES (ORDER_ITEM('biscuit', 2, 30));
INSERT INTO order_items_table VALUES (ORDER_ITEM('toffees', 15, 5));

-- 4. PL/SQL block to process orders
declare     
    v_price float;
    v_highest float:=0;
    
begin
    for order_rec in (select * from order_items_table) loop
        v_price := order_rec.total_cost();
        
        if v_price > v_highest then
            v_highest := v_price;
        end if;
        
    end loop;
end;


-------------------------------------------------------------------ppr mongodb questin ------------------------------------------------------
--employees wihtout bonus
db.employees.find({ 
    bonus: { $eq: 0 } 
}).pretty();


-- Top 3 Highest-Paid HR Employees
db.employees.find({ 
    department: "HR" 
}).sort({ 
    salary: -1 
}).limit(3).pretty();

-- Increase Salary by 10% for Recent Active
db.employees.updateMany(
    { 
        lastActive: { 
            $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) 
        } 
    },
    { 
        $mul: { salary: 1.10 } 
    }
);

-- Total Spending Per Customer
db.orders.aggregate([
    {
        $group: {
            _id: "$customerName",
            totalSpent: { $sum: "$totalAmount" },
            orderCount: { $sum: 1 }
        }
    },
    {
        $sort: { totalSpent: -1 }
    }
]);

-- Customers with More Than 5 Orders
db.orders.aggregate([
    {
        $group: {
            _id: "$customerName",
            orderCount: { $sum: 1 }
        }
    },
    {
        $match: { 
            orderCount: { $gt: 5 } 
        }
    },
    {
        $project: {
            customerName: "$_id",
            orderCount: 1,
            _id: 0
        }
    }
]);

-- Orders with Items Priced Over 50,000
db.orders.find({ 
    "items.price": { $gt: 50000 } 
}).pretty();

-- Most Frequently Purchased Product
db.orders.aggregate([
    { 
        $unwind: "$items" 
    },
    {
        $group: {
            _id: "$items.product",
            totalQuantity: { $sum: "$items.qty" },
            timesOrdered: { $sum: 1 }
        }
    },
    { 
        $sort: { totalQuantity: -1 } 
    },
    { 
        $limit: 1 
    },
    {
        $project: {
            product: "$_id",
            totalQuantity: 1,
            timesOrdered: 1,
            _id: 0
        }
    }
]);

-- Employees Whose Name Starts with A or M
db.employees.find({
    $or: [
        { name: { $regex: '^A', $options: 'i' } },
        { name: { $regex: '^M', $options: 'i' } }
    ]
}).pretty();


--  Year-Wise Total Revenue
db.orders.aggregate([
    {
        $group: {
            _id: { 
                year: { $year: "$orderDate" } 
            },
            yearlyRevenue: { 
                $sum: "$totalAmount" 
            },
            totalOrders: { 
                $sum: 1 
            }
        }
    },
    { 
        $sort: { "_id.year": 1 } 
    },
    {
        $project: {
            year: "$_id.year",
            yearlyRevenue: 1,
            totalOrders: 1,
            _id: 0
        }
    }
]);
