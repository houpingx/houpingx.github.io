/* select */
/* Question 1: list all product and its description */
select P_CODE,P_DESCRIPT from PRODUCT;

/* Question 2: for each product, show the final price after discount, if it has one */
select P_CODE, P_PRICE*(1-P_DISCOUNT) as F_PRICE from PRODUCT;

/* Question 3: list all customer with purchase history*/
select distinct CUS_CODE from INVOICE;
/* Question 4: count the number of such customers and rename the columns as ' customer numer' */
select count(distinct CUS_CODE) as 'Customer Number' from INVOICE;


/* where */
/* Question 5: For all products provided by vendor 21344, show their descriptions, prices and quantity of hand. */
select P_DESCRIPT,P_QOH,P_PRICE,V_CODE
from PRODUCT
where V_CODE = 21344;

/* Question 6: list the table contents for either the V_CODE = 21344 or the V_CODE = 24228*/
select P_DESCRIPT,P_QOH,P_PRICE,V_CODE from PRODUCT 
where V_CODE = 21344 or V_CODE = 24228;

/* Question 7: list products for either whose prices is greater than $100 and P_QOH is less than 20*/
select P_DESCRIPT,P_QOH,P_PRICE,V_CODE from PRODUCT 
where P_PRICE > 100 and P_QOH < 20;

/* Question 8: list of products for which the vendor code is not 21344*/
select * from PRODUCT
where not (V_CODE=21344);

/* Question 9: list the product information by price in ascending order*/
select P_CODE,P_DESCRIPT,P_QOH,P_PRICE
from PRODUCT
order by P_PRICE;

/* Question 10: list the information for the most expensive product */
select P_CODE,P_DESCRIPT,P_QOH,P_PRICE
from PRODUCT
order by P_PRICE desc
limit 1;


/* aggregation */
/* Questionc11: a tally of the number of products*/
select count(P_CODE) from PRODUCT;

/* Questionc12: how many different vendors are in the product*/
select count(distinct V_CODE) as 'count distinct' from PRODUCT;

/* Question 13: what is the maximum and minimum price of products*/
select min(P_PRICE) as minprice, max(P_PRICE) as maxprice from PRODUCT;

/* Question 14: list the most expensive product*/
select P_DESCRIPT,P_CODE from PRODUCT
where P_PRICE = (select max(P_PRICE) from PRODUCT);

/* Question 15: what is the average price of products */
select avg(P_PRICE) as avgprice from PRODUCT;

/* Question 16: list the product whose price larger than average*/
select P_DESCRIPT,P_CODE from PRODUCT
where P_PRICE > (select avg(P_PRICE) from PRODUCT);

/* group by */
/* Question 17: average price of the products provided by each vendor*/
select V_CODE,avg(P_PRICE) as avgprice
from PRODUCT
group by V_CODE;

/* Question 18: Besides average price, we also want to know the number of products provided by each vendor?*/

/* Question 19: list the number of products in the inventory supplied by each vendor?*/
select V_CODE,count(P_CODE) as NUMPRODS from PRODUCT
group by V_CODE
having avg(P_PRICE) < 10
order by V_CODE;

/* like */
/* Question 20: list all vendor rows for contacts whose last names begin with ‘smith’*/
select V_NAME,V_CONTACT,V_AREACODE,V_PHONE
from VENDOR
where V_CONTACT like 'Smith%';

select V_NAME,V_CONTACT,V_AREACODE,V_PHONE
from VENDOR
where regexp_like (V_CONTACT, 'Smith');


/* Question 21: list all products whose prices are between $50 and $100*/
select * from PRODUCT
where P_PRICE between 50.00 and 100.00;

/* Question 22: list the table contents for either the V_CODE = 21344 or the V_CODE = 24228*/
select * from PRODUCT
where V_CODE in (21344,24288);

/* Question 23: list all records for which V_CODE is NULL*/
select P_CODE,P_DESCRIPT,V_CODE
from PRODUCT
where V_CODE is null;


/* join */
/* Question 24: List Customers’ code and their last name, along with their invoice numbers and date */
select CUS_CODE,CUS_LNAME,INV_NUMBER,INV_DATE
from CUSTOMER natural join INVOICE;

/* Question 25: List details about each invoice, including the product code, product description, units, and prices.*/
select INV_NUMBER,P_CODE,P_DESCRIPT,LINE_UNITS,LINE_PRICE
from INVOICE natural join LINE natural join PRODUCT;

/* Question 26: List Customers’ code and their last name, along with their invoice numbers and date */
/* uses 'using' or 'on' keywords */
select CUS_CODE,CUS_LNAME,INV_NUMBER,INV_DATE
from CUSTOMER join INVOICE using (CUS_CODE);

select CUSTOMER.CUS_CODE,CUS_LNAME,INV_NUMBER,INV_DATE
from CUSTOMER join INVOICE on CUSTOMER.CUS_CODE=INVOICE.CUS_CODE;

/* Question 27: List details about each invoice, including the product code, product description, units, and prices.*/

/* Question 28: For all products, list their product code, vendor code (if it has one) , and vendor name (if it has one) */
select P_CODE,PRODUCT.V_CODE,V_NAME
from PRODUCT left join VENDOR on PRODUCT.V_CODE=VENDOR.V_CODE;

/* Question 29: For all vendors, list their vendor code, and its product code (if it has one) */
select P_CODE,PRODUCT.V_CODE,V_NAME
from PRODUCT right join VENDOR on PRODUCT.V_CODE=VENDOR.V_CODE;

/* Question 30: For all invoices, identify who purchase what product and the product’s details, like price and units */
select * from INVOICE cross join LINE;

/* Question 31: list all employees with their managers’ names */
select E.EMP_NUM,E.EMP_LNAME,E.EMP_MGR,M.EMP_LNAME
from EMP E join EMP M on E.EMP_MGR=M.EMP_NUM;


/* union v.s. union all*/
/* Question 32: list all distinct customers from both CUSTOMER and CUSTOMER2 */
select * from CUSTOMER
union
select * from CUSTOMER2;

/* Question 33: list all customers from both CUSTOMER and CUSTOMER2 */
select * from CUSTOMER
union all
select * from CUSTOMER2;


/* having */
/* Question 34: List all products with a total quantity sold greater than the average quantity sold? */
select P_CODE, sum(LINE_UNITS) as TOTALUNITS
from LINE
group by P_CODE
having sum(LINE_UNITS) > (select avg(LINE_UNITS) from LINE); 


/* exist */
/* Question 35: list customers who have invoice record */
select distinct CUS_CODE from CUSTOMER
where exists (select * from INVOICE
				where INVOICE.CUS_CODE = CUSTOMER.CUS_CODE);

/* Question 36: list customers who doesn't have invoice record */                
select distinct CUS_CODE from CUSTOMER
where not exists (select * from INVOICE
				where INVOICE.CUS_CODE = CUSTOMER.CUS_CODE);

/* any or all*/
/* Question 37: which products cost more than all individual products provided by vendors from Florida? */
select P_CODE,P_QOH*P_PRICE as TOTALVALUE
from PRODUCT
where P_QOH*P_PRICE > all (select P_QOH*P_PRICE 
					from PRODUCT 
					where V_CODE in (select V_CODE from VENDOR where V_STATE = 'FL'));

select P_CODE,P_QOH*P_PRICE as TOTALVALUE
from PRODUCT
where P_QOH*P_PRICE > any (select P_QOH*P_PRICE 
					from PRODUCT 
					where V_CODE in (select V_CODE from VENDOR where V_STATE = 'FL'));

/* case */
/* Question 38: list all product code, quantity of hand, and a flag case where
	when P_QOH > 30 then 'The quantity is greater than 30'
    when P_QOH = 30 then 'The quantity is 30'
    else 'The quantity is under 30'
    */
select P_CODE,P_QOH,
(case
	when P_QOH > 30 then 'The quantity is greater than 30'
    when P_QOH = 30 then 'The quantity is 30'
    else 'The quantity is under 30'
end)
from PRODUCT;

/* Question 39: order the product by V_CODE; however, if V_CODE is null, then order by discount */
select P_CODE,P_DESCRIPT,P_DISCOUNT,V_CODE
from PRODUCT
order by
(case
	when V_CODE is null then P_DISCOUNT
    else V_CODE
end);


/* ifnull and coalesce */
/* Question 40: list the total price = p_price * p_qoh for all product */
select P_CODE,P_QOH*P_PRICE as 'Total Price' from PRODUCT;
select P_CODE,ifnull(P_QOH,0)*P_PRICE as 'Total Price' from PRODUCT;
select P_CODE,coalesce(P_QOH,0)*P_PRICE as 'Total Price' from PRODUCT;

