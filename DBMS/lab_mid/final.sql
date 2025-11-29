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


------------------------------------------------------------- TRIGGERS -------------------------------------------------
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
