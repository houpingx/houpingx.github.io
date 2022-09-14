#View
select cus_code, inv_number, inv_date
from customer inner join invoice using (cus_code);
# save the query in the database server, attached it a name
# this named query is called view
create or replace view customerHistory
as
select cus_code, inv_number, inv_date
from customer inner join invoice using (cus_code)
order by cus_code desc
;
create or replace view customerHistory (
customerCode, invoiveNumber, invoiceDate
)
as
select cus_code, inv_number, inv_date
from customer inner join invoice using (cus_code)
order by cus_code desc
;
select * from customerHistory
order by inv_number desc;
# the view not physically store the data
# virtual table: when you select From view, it goes to implement the underlying qury
# create a view based on a select statement that retrieves data from one or more tables
# advantages: simplify complex query (frequently used)
# make the business logic consistent (store the calculation and hide the complexity)
# add extra security layers
# enable backward compatibility: normalize current tables but not affect tha applications that
# use the current table
create [or replace] view [db_name.]view_name [(column_list)]
as
select-statement;
# order by
# mysql allows you to use the order by clause in the select statement
# but ignores it if you select from the view with a query that has its own order by clause;
# create a simple view
create view invoiceSales as
select inv_number, sum(line_units * line_price) as sales
from invoice inner join line using (inv_number)
group by inv_number
order by sales desc
;
select * from invoiceSales;
show tables;
# create a view based on another view
create view invoiceSales100
as
select inv_number, round(sales, 3) as sales
from invoiceSales
where sales > 100
;
select * from invoiceSales100;
# create a view with join
create or replace view customerInvoice
as
select cus_code, concat_ws(' ', cus_fname, cus_lname) as name,
inv_number, sum(line_units * line_price) as sales
from invoice inner join line using (inv_number) join customer using (cus_code)
group by inv_number
order by sales desc
;
select * from customerInvoice;
# create a view with subquery
create or replace view aboveAverage
as
select p_code, p_descript, p_price
from product
where p_price > (
select avg(p_price) from product
)
order by p_price desc
;
select * from aboveAverage;
# create a updatable views
# views not only query-able but also updatable
# ue the insert or update to insert or update rows pf the base table through the updatable view
# use delete to remove rows of the underlying table through the view
create or replace view customerBasic
as
select cus_code, cus_fname, cus_lname, cus_phone
from customer
;
select * from customerBasic;
update customerBasic
set cus_phone = '297-0000'
where cus_code = 10016;
select * from customerBasic;
select * from customer;
# remove rows
delete from customerBasic
where cus_code = 10016;
select * from customerBasic;
# with check option in view
# create a view to reveal the partial data of a table, however, a simple view
# is updatable therefore it is possible to update the data which is not visible through the view
# this update makes the view inconsistent
# with check option prevents a view from updating or inserting rows that are not visible
# through it
# whenever you update or insert a row of the base tables through a view, mysql ensures that
the
# indert or update operation is conformed with the definion of the view
create [or replace] view view_name
as
select-statement
with check option
;
select * from employee;
create or replace view emp615
as
select * from employee where emp_areacode = '615'
with check option
;
select * from emp615;
insert into emp615
values (202,'Mr.','Aa','Bb','I','1970-06-18','1989-04-14','19','720','345-0000');
# local vs cascaded check option
# with check option allows to check ensure that the rows that are being changed are
# conformable to the definition of the view
# view can created based on other views, mysql also checks the rules in the dependent views
# for data consistency
# cascaded
create table t1 (c int);
create or replace view v1
as
select c from t1 where c>10;
insert into v1(c) values (5);
create or replace view v2
as
select c from v1
with cascaded check option;
insert into v2(c) values (5);
create or replace view v3
as
select c from v2 where c< 20;
insert into v3(c) values (8);
insert into v3(c) values (30);

# local
create view v2 as
select c from v1
with local check option;

insert into v2(c) values (5);

insert into v3(c) values (8);

# stored procedure
select cus_code,cus_lname,cus_fname,cus_areacode
from customer
order by cus_fname,cus_lname;
# save this query for later execution, use stored procedure
delimiter $$
create procedure customerinfo()
begin
	select cus_code,cus_lname,cus_fname,cus_areacode
	from customer
	order by cus_fname,cus_lname;
end$$
delimiter ;

# stored procedure is a segment of declarative sql statements that stored inside the mysql server
call customerinfo();

# the first time you invoke a stored procedure, mysql looks up for the name in the db category
# compiles the stored procedure's code, place it in the cache, and execure the stored procedure
# if you invoke the same stored procedure int he same session again, mysql just execute the stored
# procedure from the cache without having to recomplie it

# stored procedure can have parameters: in, out, inout parameters
# contain control flow statement, if, case, loop
# can call other stored procedures or stored functions, allowing you to modulize your code

# advantages:
# reduce network traffic: network traffice between applications and mysql server,
# only sending the name and parameters of the stored procedure
# centralize business logic in DB: reusable by multiple applications
#more secure

# delimiter: change the default myswl delimiter by using the delimiter commnad
# a stored procedure consists of multiple statements separated by a semicolon (;)
# if you use a mysql client program to define a stored procedure that contains semicolon characters
# myswl client program will not treat the whole stored procedure as a single statement, but multiple statements
#therefore, you need to redefine the delimiter temporaraily so that you can pass the whole stored 
# procedure to the serve as a single statement
delimiter //
select * from customer //
delimiter ;

# stored procedure syntax
delimiter $$
create procedure sp_name()
begin

end $$
delimiter ;
# first, change the default delimiter to $$
# second, use (;) in the body and $$ after the end keyword to end the stored procedure
# third, change the default delimiter back to a semicolon (;)

create procedure sp_name(parameter_list)
begin
	statements
end $$

# first, specify the name of the stored procedure that you want to create after the create procedure keywords
# second, specify a list of comma-separated parameters for the stored procedure in parentheses after the 
# procedure name
# third, write the code between the begin-end block.
call sp_name(argument_list);

# sp parameters: in, out, and inout
# in: calling the program has to pass an argument to the stored procedure
# in is protected. even you change the valye of the IN parameter inside the stored procedure
# its orifinal value is unchanged after the stored procedure ends. the sp only works on the copy of the In parameter
# out: can be changed inside the stored procedure and its new value is passed back to the calling program
# inout: a combination of in and out parameters

# [in | out | inout] parameter_name datatype[(length)]
# 1. specify the parameter mode
# 2. specify the name of parameter
# 3. specify the daype and maximum length of the parameter

# in
delimiter $$
create procedure customerAreacode( in areacode varchar(3) )
begin
	select * from customer where cus_areacode = areacode;
end $$
delimiter ;

call customerAreacode('615');

# out
delimiter $$
create procedure cusAreacodeCount( in areacode varchar(3), out areacount int )
begin
	select count(*) into areacount
    from customer
    where cus_areacode = areacode;
end $$
delimiter ;

call cusAreacodeCount('615',@area615count);
select @area615count;
# find the number, pass a session variable @area615count to receive the return

#inout
delimiter $$
create procedure setCounter (inout counter int, in step int)
begin
	set counter = counter + step;
end $$
delimiter ;

set @counter = 1;
call setCounter(@counter, 1);
select @counter;

# stored procedure variables
# a variable is a named object whose value can change during the sp execution
# use the variables in sp to hold immediate results. these vairables are local to the stored procedure
# before using a variable you must declare it
# declaring variables
declare variable_name datatype(size) [default default_value];

declare sale dec(10,2) default 0.0;

declare x, y int default 0;

# assigning variables
set variable_name = value;
declare total int default 0;
set total = 10;

declare productCount int default 0;
select count(*) into productCount from products;

# variable scopes
/*
a variable has its own scope that defines its lifetime. If you declare a variable inside a stp, it will be out of scope when the end
statement of sp reaches.
when you declare a variable inside the block begin-end, it will be out of scope if the end is reached.
mysql allows you to declare two or more variables that share the same name in different scopes.
*/
delimiter $$
create procedure getInvoiceNum ()
begin
	declare invoiceNumber int default 0;
    select count(*) into invoiceNumber from invoice;
    select invoiceNumber;
end $$
delimiter ;
call getInvoiceNum();


# If statement
/*
use if statement to execute a block of sql code based on a specified condition
1. if-then statement
2. if-then-else statement
3. if-then-elseif-else statement
*/

#-- if-then statement
if condition then
	statement;
end if;
# first, specificy a condition to execute the code between the if-then and end-if. 
# if the condition evaluates to TRUE, the statements between if-then and end if will execute
# otherwise, the control is passed to the next statement following the end if
# second, specify the code that will execute if the condition evaluates to TRUE

delimiter $$
create procedure customerLevel(
	in customerCode int,
    out customerLevel varchar(20) )
begin
	declare credit decimal(10,2) default 0;
    select cus_balance into credit from customer
    where cus_code = customerCOde;
    
    if credit > 200 then
		set customerLevel = 'VIP';
	end if;
end $$
delimiter ;
# the sp accepts two parameters customerCode and customerLevel
# first, select cus_balance of the customer specified by the customerCode from customer table
# and store it in the local variable credit
# then, set the value for the out parameter customerLevel to vip if the credit greater than 200

select * from customer;

call customerLevel(10012,@customerLevel);
select @customerLevel;

#-- if-then-else statement
drop procedure customerLevel;
delimiter $$
create procedure customerLevel(
	in customerCode int,
    out customerLevel varchar(20) )
begin
	declare credit decimal(10,2) default 0;
    select cus_balance into credit from customer
    where cus_code = customerCOde;
    
    if credit > 200 then
		set customerLevel = 'VIP';
	else
		set customerLevel = 'Regular';
	end if;
end $$
delimiter ;

call customerLevel(10010,@customerLevel);
select @customerLevel;

#- if-then-elseif-else statement
drop procedure customerLevel;
delimiter $$
create procedure customerLevel(
	in customerCode int,
    out customerLevel varchar(20) )
begin
	declare credit decimal(10,2) default 0;
    select cus_balance into credit from customer
    where cus_code = customerCOde;
    
    if credit > 500 then
		set customerLevel = 'VIP';
	elseif credit between 200 and 500 then
		set customerLevel = 'Next VIP';
	else
		set customerLevel = 'Regular';
	end if;
end $$
delimiter ;

call customerLevel(10018,@customerLevel);
select @customerLevel;
select * from customer;

# case statement
/*
case statement to construct conditional statements in sp. The case statements make the code more readable and efficient
1. simple case
2. searched case
*/
#-- simple case statement, syntax
case case_value
	when when_value1 then statements
    when when_value2 then statements
    ...
    [else else-statements]
end case;
/*
In this syntax, the simple case statement sequentially compares the case_value is with the when_value1, when_value2 ...
until if finds one is equal. When the case finds a case_value equal to a when_value, it executes statement in the 
corresponding then clause

if case cannot find any when_value equal to the case_value, it executes the else-statements in the else clause if the else caluse is available

when the else caluse does not exist and the case cannot find any when_value equal to the case_value, it issues an error
- to avoid the error when the case_value does not equal any when_value, you can use an empty begin end block in the else caluse 
case case_value
	when when_value1 then ...
    when when_value2 then ...
    else
		begin
		end;
end case;
*/

select * from customer;
delimiter $$
create procedure customerDeliver(
	in customerCode int,
    out deliverVendor varchar(20) )
begin
	declare customerAreacode varchar(20);
    select cus_areacode into customerAreacode from customer
    where cus_code = customerCode;
    
    case customerAreacode
		when '615' then
			set deliverVendor = 'UPS';
		when '713' then
			set deliverVendor = 'USPS';
		else
			set deliverVendor = 'Fedex';
	end case;
end $$
delimiter ;

call customerDeliver(10011,@delivery);
select @delivery;

#- searched case statement
/*
the simple case only allows you to compare a value with a set of distinct values

to perform more complex matches such as ranges, use the searched case statement. The searched case statement is equivalent to the if statement,
however, it's much more readable than the if statement.

case
	when search_condition1 then statements
    when search_condition2 then statements
    ...
    [else else-statement]
end case;

In this syntax, searched case evaluates each search_condition in the when clause until it finds a condition that evaluates to TRUE.
then it executes the corresponding then clause statements.

If no search_condition evaluates to TRUE, the case will execute else-statements in the else caluse if an else clause is available

mysql does not allow you to have empty statements in the then or else clause. if you don't want to handle the logic in the else
clause while preventing mysql from raising an error in case no search_condition is true, use begin end block
*/
select * from employee;
delimiter $$
create procedure employeeWorkingExperience(
	in employeeNumber int,
    out workingExperience varchar(20) )
begin
	declare workingYear varchar(20);
    select timestampdiff(year,emp_hire_date,now()) into workingYear from employee
    where emp_num = employeeNumber;
    
    case
		when workingYear  = 0 then
			set workingExperience = 'Entry-level';
		when workingYear>=1 and workingYear <3 then
			set workingExperience = 'Intermediate';
		when workingYear >=3 and workingYear < 5 then
			set workingExperience = 'Mid-level';
		else
			set workingExperience = 'Senior';
	end case;
end $$
delimiter ;


call employeeWorkingExperience(101,@workExperience);
select @workExperience;

/*
both if and case statements allow you to execure a block of code based on a specific condition. Choosing between if or case sometimes is just a matter
of personal preference. Guidelines:
1. a simple case statement is more readable and efficient then an if statement when you compare a single expression against a range of unique values
2. when you check complex expression based on multiple values, if statement is easier to understand
if you use the case statement, you have to make sure that a least one of the case condition is matched. Otherwise, define an error handler
3. In some case you can use both if and case to make the code more readable and efficient
*/


# loop statement
/*
loop statement allows you to execute one or more statement repeatedly

[begin_label:] loop
	statement_list
end loop [end_label]

loop executes the statement_list repeatedly. The statement_list may have one or more statements, each
terminated by a semicolon statement delimiter

you terminate the loop when a condition is statisfied by using the leave statement
[label:] loop
	...
    -- terminate the loop
    if condition then
		leave [label];
	end if;
    ...
end loop;
(works like the break, immediately exists the loop)
*/
drop procedure fibonacci;
delimiter $$
create procedure fibonacci (
	in n int,
    out out_fib int)
begin
	declare m int default 0;
    declare k int default 1;
    declare i int;
    declare tmp int;
    set m = 0;
    set k = 1;
    set i = 1;
    loop_label: loop
		if i > n then
			leave loop_label;
		end if;
        set tmp = m+k;
        set m = k;
        set k = tmp;
        set i = i + 1;
	end loop;
    set out_fib = m;
end $$
delimiter ;
call fibonacci(10,@tenthFib);
select @tenthFib;

/* while statement
while loop executes a block of code repeatedly as long as a condition is true

[begin_label:] while search_condition do
	statement_list
end while [end_label]
first, specify a search condition after the while keyword
the while checks the search_condition at the beginning of each iteration
if the search condition evaluate to true, the while executes the statement_list as long as the search_condition is true
the while loop is called a pretest loop because it checks the search_condition before the statement_list executes.
Second, specify one ore more statements that will execute between the do and end while keywords
third, specify optional label for the while statement at the beginning and end of the loop cnstruct
*/

delimiter $$
create procedure fibonacciWhile (
	in n int, out out_fib int)
begin
	declare m int default 0;
    declare k int default 1;
    declare i int;
    declare tmp int;
    set m = 0;
    set k = 1;
    set i = 1;
    while (i<=n) do
		set tmp = m+k;
        set m = k;
        set k = tmp;
        set i = i + 1;
	end while;
    set out_fib = m;
end $$
delimiter ;
call fibonacciWhile(10,@tenthFib);
select @tenthFib;

/* repeat loop
the repeat statement executes one or more statements until a search condition is true

[begin_label:] repeat
	statement_list
until search_contion
end repeat [end_label]

the repeat checks the search_condition after the execution of statement, therefore, the statement_list always
executes a least once. This is why repeat is also known as a post-test loop

*/
delimiter $$
create procedure fibonacciRepeat (
	in n int, out out_fib int)
begin
	declare m int default 0;
    declare k int default 1;
    declare i int;
    declare tmp int;
    set m = 0;
    set k = 1;
    set i = 1;
    repeat
		set tmp = m+k;
        set m = k;
        set k = tmp;
        set i = i + 1;
	until i > n
    end repeat;
    set out_fib = m;
end $$
delimiter ;
call fibonacciRepeat(10,@tenthFib);
select @tenthFib;

# -- leave statement
/*
leave statement exist the flow control that has a given label
leavel label;

in this syntax, you specify the label of the block that you want to exit after the leave keyword
*/
#- leave statement to exit a stored procedure
# if the label is the outermost of the sp or function block, leave terminates the sp or function
/*
create procedure sp_name ()
sp: begin
	if conditon then
		leave sp;
	end if;
    -- other statement
end $$
*/

delimiter $$
create procedure customerBalanceUpdate (in customerCode int)
sp: begin
		declare invoiceCount int;
        declare spending decimal(10,2);
        
        select count(*) into invoiceCount from invoice
        where cus_code = customerCode;
        
        if invoiceCount = 0 then
			leave sp;
		end if;
        select sum(line_price*line_units) into spending
        from line inner join invoice using (inv_number)
		where cus_code = customerCode;
        update customer
        set cus_balance = cus_balance - spending
        where cus_code = customerCode;
	end $$
delimiter ;
call customerBalanceUpdate (10014);
call customerBalanceUpdate (10013);


/* cursor
to handle a result set inside a stored procedure, use a cursor.
A cursor allos you to iterate a set of rows returned by a query and process each row individually

mysql cursor is read-only, non-scrollable, and asensitive
read-only: cannot update data in the underlying table through the cursor
non-scallable: can only fetch rows in the order determined by the select-statmen. cannot fetch rows in the reversed order, cannot skip rows or jump 
to a specific row
asensitive: point to the actual data (faster) any change that made to the data from other connections will affect the data
that is being used by an asensitive cursor. 
*/

delimiter $$
create procedure customerNameList ( inout namelist varchar(200) )
begin
	declare finished int default 0;
    declare fullname varchar(100) default "";
    -- declare cursor for customer name
    /*
    cursor declaration must be after any variable declaration
    custor must always associate with a select statement
    */
    declare curName cursor for select concat_ws(' ',cus_fname,cus_lname) from customer;
    -- declare not found handler
    declare continue handler for not found set finished = 1;
    -- the finished is a variable to indicate that the cursor has reached the end of the result set
    -- the handler declaration must appear after variable and cursor declaration inside the sp
    open curName;
    -- initializes the result set for the cursor, must call the open statement before fetching rows from the result set
    getName: loop
			fetch curName into fullname;
            if finished = 1 then
				leave getName;
			end if;
            -- build name list
            set namelist = concat_ws(';',fullname, namelist);
	end loop getName;
    close curName;
end $$
delimiter ;
set @namelist = "";
call customerNameList(@namelist);
select @namelist;


#- stored function
/*
a stored function is a special kind stored procedure that returns a single value
*/
/*
delimiter $$
create function function_name (param1, param2, ...)
returns datatype
[not] deterministic
begin
	statement_list
end $$
delimiter ;
*/
delimiter $$
create function customerLevel (credit decimal(10,2) )
returns varchar(20)
deterministic
begin
	declare customerLevel varchar(20);
    
    if credit > 500 then
		set customerLevel = 'VIP';
	elseif credit between 200 and 500 then
		set customerLevel = 'Next VIP';
	else
		set customerLevel = 'Regular';
	end if;
    return (customerLevel);
end $$
delimiter ;

select cus_code,customerLevel(cus_balance)
from customer order by cus_code;


#- calling a stored function in a stored procedure
drop procedure customerLevel;
delimiter $$
create procedure customerLevel(
	in customerCode int,
    out customerLevel varchar(20) )
begin
	declare credit decimal(10,2) default 0;
    
    select cus_balance into credit from customer
    where cus_code = customerCOde;
    
    -- call the function
    set customerLevel = customerLevel(credit);
end $$
delimiter ;

call customerLevel(10018,@customerLevel);
select @customerLevel;



/* triggers
a trigger is a stored program invoked automatically in response to an event such as insert, update, or delete
that occurs in the associated table

mysql supports triggers that are invoked in response to the insert, update, or delete

row-level trigger is activated for each row that is inserted, updated, or deleted. FOr instance, if a table has 100 rows insrted, update,
deleted, the rigger is automatically invoked 100 times for the 100 rows affected

advantages:
1. check the integrity of data
handle errors from the db layer
give an alternative way to run scheduled tasks
useful for auditing the data changes 

*/
-- create trigger statement
/*
create trigger trigger_name
{before | after} {insert | update | delete }
on table_name for each row
trigger_body;

the trigger body can access the values of the column being affected by the DML statement. 
To distinguish between the value of column before and after, the DML has fired, you use new and old modifier

for instance, if you update the column description, in the trigger body, you can access the value of the description
before the update old.description and the new value new.description
*/

-- create a tabel to keep the changes to the employee
CREATE TABLE employees_audit (
    id INT AUTO_INCREMENT PRIMARY KEY,
    emp_num INT NOT NULL,
    emp_lname VARCHAR(50) NOT NULL,
    emp_fname VARCHAR(50) NOT NULL,
    c_date DATETIME DEFAULT NULL,
    action VARCHAR(50) DEFAULT NULL
);

CREATE TRIGGER before_employee_update 
    BEFORE UPDATE ON employee
    FOR EACH ROW 
 INSERT INTO employees_audit
 SET action = 'update',
     emp_num = OLD.emp_num,
     emp_lname = OLD.emp_lname,
     emp_fname = old.emp_fname,
     c_date = NOW();

select * from employee;
update employee
set emp_lname = 'Xiao'
where emp_num = 101;

select * from employees_audit;


# before insert
/*
CREATE TRIGGER trigger_name
    BEFORE INSERT
    ON table_name FOR EACH ROW
trigger_body;

if you have multiple statements in the trigger_body, use begin-end and change the delimiter
DELIMITER $$

CREATE TRIGGER trigger_name
    BEFORE INSERT
    ON table_name FOR EACH ROW
BEGIN
    -- statements
END$$    

DELIMITER ;
*/

DROP TABLE IF EXISTS WorkCenters;

CREATE TABLE WorkCenters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL
);

DROP TABLE IF EXISTS WorkCenterStats;

CREATE TABLE WorkCenterStats(
    totalCapacity INT NOT NULL
);

DELIMITER $$

CREATE TRIGGER before_workcenters_insert
BEFORE INSERT
ON WorkCenters FOR EACH ROW
BEGIN
    DECLARE rowcount INT;
    
    SELECT COUNT(*) 
    INTO rowcount
    FROM WorkCenterStats;
    
    IF rowcount > 0 THEN
        UPDATE WorkCenterStats
        SET totalCapacity = totalCapacity + new.capacity;
    ELSE
        INSERT INTO WorkCenterStats(totalCapacity)
        VALUES(new.capacity);
    END IF; 

END $$

DELIMITER ;

INSERT INTO WorkCenters(name, capacity)
VALUES('Mold Machine',100);
SELECT * FROM WorkCenterStats; 

INSERT INTO WorkCenters(name, capacity)
VALUES('Packing',200);
SELECT * FROM WorkCenterStats;

-- after insert
DROP TABLE IF EXISTS members;

CREATE TABLE members (
    id INT AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    birthDate DATE,
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS reminders;

CREATE TABLE reminders (
    id INT AUTO_INCREMENT,
    memberId INT,
    message VARCHAR(255) NOT NULL,
    PRIMARY KEY (id , memberId)
);

DELIMITER $$

CREATE TRIGGER after_members_insert
AFTER INSERT
ON members FOR EACH ROW
BEGIN
    IF NEW.birthDate IS NULL THEN
        INSERT INTO reminders(memberId, message)
        VALUES(new.id,CONCAT('Hi ', NEW.name, ', please update your date of birth.'));
    END IF;
END$$

DELIMITER ;

INSERT INTO members(name, email, birthDate)
VALUES
    ('John Doe', 'john.doe@example.com', NULL),
    ('Jane Doe', 'jane.doe@example.com','2000-01-01');
SELECT * FROM members;
SELECT * FROM reminders;

-- before update
DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
    id INT AUTO_INCREMENT,
    product VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    fiscalYear SMALLINT NOT NULL,
    fiscalMonth TINYINT NOT NULL,
    CHECK(fiscalMonth >= 1 AND fiscalMonth <= 12),
    CHECK(fiscalYear BETWEEN 2000 and 2050),
    CHECK (quantity >=0),
    UNIQUE(product, fiscalYear, fiscalMonth),
    PRIMARY KEY(id)
);
INSERT INTO sales(product, quantity, fiscalYear, fiscalMonth)
VALUES
    ('2003 Harley-Davidson Eagle Drag Bike',120, 2020,1),
    ('1969 Corvair Monza', 150,2020,1),
    ('1970 Plymouth Hemi Cuda', 200,2020,1);
DELIMITER $$

CREATE TRIGGER before_sales_update
BEFORE UPDATE
ON sales FOR EACH ROW
BEGIN
    DECLARE errorMessage VARCHAR(255);
    SET errorMessage = CONCAT('The new quantity ',
                        NEW.quantity,
                        ' cannot be 3 times greater than the current quantity ',
                        OLD.quantity);
                        
    IF new.quantity > old.quantity * 3 THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
    END IF;
END $$

DELIMITER ;
UPDATE sales 
SET quantity = 150
WHERE id = 1;

-- after update
DROP TABLE IF EXISTS Sales;

CREATE TABLE Sales (
    id INT AUTO_INCREMENT,
    product VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    fiscalYear SMALLINT NOT NULL,
    fiscalMonth TINYINT NOT NULL,
    CHECK(fiscalMonth >= 1 AND fiscalMonth <= 12),
    CHECK(fiscalYear BETWEEN 2000 and 2050),
    CHECK (quantity >=0),
    UNIQUE(product, fiscalYear, fiscalMonth),
    PRIMARY KEY(id)
);

INSERT INTO Sales(product, quantity, fiscalYear, fiscalMonth)
VALUES
    ('2001 Ferrari Enzo',140, 2021,1),
    ('1998 Chrysler Plymouth Prowler', 110,2021,1),
    ('1913 Ford Model T Speedster', 120,2021,1);
DROP TABLE IF EXISTS SalesChanges;

CREATE TABLE SalesChanges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    salesId INT,
    beforeQuantity INT,
    afterQuantity INT,
    changedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER after_sales_update
AFTER UPDATE
ON sales FOR EACH ROW
BEGIN
    IF OLD.quantity <> new.quantity THEN
        INSERT INTO SalesChanges(salesId,beforeQuantity, afterQuantity)
        VALUES(old.id, old.quantity, new.quantity);
    END IF;
END$$

DELIMITER ;




-- before delete


-- afte delete



