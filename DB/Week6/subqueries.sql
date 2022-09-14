/*
subquery: (1) a query nested within another query, such as select, insert, update or delete
		  (2) nested within another subquery
          
subquery can be used in anywhere but must be closed in parentheses
*/
select emp_lname, emp_fname
from emp
where emp_num in (
			select emp_num from employee
);

# where subquery
# use comparison operators =,>,< to compare a single value rturned by the subquery
select p_code, p_descript
from product
where p_price = (
		select max(p_price) from product
);

# in and not in subqueries
# more than one value returned by the subquery
select cus_lname,cus_fname
from customer
where cus_code in (
		select distinct cus_code from invoice
);

# from subquery
# derived table must have a name
select min(items), max(items), round(avg(items),2)
from (
	select inv_number, sum(line_number) as items
	from line
	group by inv_number
    ) as lineitems;
    
# derived tables: must have an alias name so you can reference its name later 
select column_list
from (
		select column_list from table_1
) derived_table_name
where derived_table_name.c1 >0;

select p_code,p_descript,total
from (
	select p_code, sum(line_price * line_units) total
	from
	line inner join invoice using (inv_number)
	group by p_code
	order by total desc
	limit 3
) top3
inner join product using(p_code);

# uses cte, common table expression: a named temporary result set that exists only within the execution of a single SQL
# not stored as an object and last only during the execution of a query
# can be self-referencing (a recursive cte) and referenced multiple times
# 
with cte_name (column_list) as (
	query
)
select * from cte_name;

with top3 as
(
	select p_code, sum(line_price * line_units) total
	from
	line inner join invoice using (inv_number)
	group by p_code
	order by total desc
	limit 3
)
select p_code,p_descript, total
from top3 inner join product using (p_code)
;

with vendorFL as (
	select v_code
	from vendor
	where v_state = 'FL'
),
productFL as (
	select p_code, p_qoh*p_price cost
	from product inner join vendorFL using (v_code)
) 
select
max(cost)
from productFL;



#
select cus_level, count(cus_level) as groupCount
from
(
	select cus_code, sum(line_price * line_units) total,
	(case
		when sum(line_price * line_units) < 100 then 'level1'
		when sum(line_price * line_units) between 100 and 200 then 'level2'
		when sum(line_price * line_units) > 200 then 'level3'
	end) cus_level
	from line inner join invoice using (inv_number)
	group by cus_code
) cusGroup
group by cus_level;



# correlated subquery
# subquery not independent
# the inner query uses the data from the outer query
# a correlated subquery is evaluated once for each row in the outer query
select inv_number, p_code, line_units
from line louter
where louter.line_units > (
		select avg(line_units) from line linner where linner.p_code = louter.p_code
);


# exists and not exists subquery: returns a boolean value of TRUE or FALSE
# 
select cus_code, cus_lname, cus_fname
from customer
where exists (
		select inv_number, sum(line_price * line_units) total
		from
		line inner join invoice using (inv_number)
        where cus_code = customer.cus_code
		group by inv_number
		having total > 200
);

select cus_code, cus_balance
from customer
where exists (
		select 1 from invoice
        where invoice.cus_code = customer.cus_code
);

update customer
set
cus_balance = cus_balance + 10
where exists (
		select 1 from invoice
		where invoice.cus_code = customer.cus_code
);

# archive customers who don't have any sales in a seperate table
create table customers_archive
like customer;

insert into customers_archive
select *
from customer
where not exists (
		select 1 from invoice
		where invoice.cus_code = customer.cus_code
);

delete from customer
where exists (
		select 1 from customers_archive a
        where a.cus_code = customer.cus_code
);

select * from customer;
# exists v.s. in operators
# if the subquery contains a large volume of data, use exists
# but be faster if the result set returned from subquery is very small
select cus_code, cus_lname, cus_fname
from customer
where cus_code in (
		select cus_code from invoice
);

select cus_code, cus_lname, cus_fname
from customer
where exists (
		select 1 from invoice
        where invoice.cus_code = customer.cus_code
);
