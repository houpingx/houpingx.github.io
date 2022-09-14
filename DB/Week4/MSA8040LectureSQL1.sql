/* drop a database if exists */
drop database if exists saleco;

/* create a database with name 'saleco' */
create database saleco;

/* switch to the saleco database */
use saleco;

# delete saleco
drop database saleco;

# display all relations in saleco
show tables;

# create a relation customer
create table customer(
	cus_code int,
    cus_lname varchar(15),
    cus_fname varchar(15),
    cus_initial varchar(15),
    cus_areacode varchar(3),
    cus_phone varchar(8),
    cus_balance decimal(10,2)
);
/* display relation schema */
desc customer;

/* drop a relation, customer, deleting both data and schema */
drop table customer;

# if you only need to delete data, use 'delete'
delete from customer;

/*--------------------------*/
# use 'alter' to modify relations
alter table customer add cus_dob date;
alter table customer drop column cus_dob;
alter table customer modify column cus_areacode int;

/*-----------------------*/
# adding or deleting tuples
insert into customer(cus_code, cus_lname, cus_fname, cus_initial, cus_areacode, cus_phone, cus_balance)
value (100, 'Smith', 'James', 'I', '706', '777-7777',100.0);

# safe update model issue
set sql_safe_updates = 0;
delete from customer 
where customer.cus_lname='Smith';

select * from customer;

/*-------------------*/
# not null
create table customer2(
	cus_code int not null,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3),
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null
);
insert into customer2(cus_code, cus_lname, cus_fname, cus_initial, cus_areacode, cus_phone, cus_balance)
value (null, 'Smith2', 'James2', 'I', '706', '777-7777',100.0);
insert into customer2(cus_code, cus_lname, cus_fname, cus_initial, cus_areacode, cus_phone, cus_balance)
value (100, 'Smith2', 'James2', 'I', '706', '777-7777',100.0);

# alter relation to add 'not null' constraint
alter table customer2 modify cus_phone varchar(15) not null;

# unique
create table customer3(
	cus_code int not null unique,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3),
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null
);
create table customer3(
	cus_code int not null,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3),
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null,
    unique (cus_code)
);

create table customer3(
	cus_code int not null,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3),
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null,
    constraint unique_code unique (cus_code)
);
alter table customer3 add unique(cus_phone);
alter table customer3 add constraint unique_phone unique (cus_phone);
alter table customer3 drop constraint unique_phone;
desc customer3;

# primary key
create table customer4(
	cus_code int not null,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3),
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null,
    primary key (cus_code)
);
create table customer4(
	cus_code int not null,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3),
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null,
    constraint pk_cus primary key (cus_code)
);
create table customer4(
	cus_code int not null,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3),
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null,
    constraint pk_cus primary key (cus_lname, cus_fname, cus_phone)
);

alter table customer3 add primary key (cus_code);
alter table customer3 add constraint pk_cus primary key (cus_lanme, cus_fname, cus_phone);
alter table customer3 drop primary key;
alter table customer3 drop constraint pk_cus;

# foreign key
create table customer5(
	cus_code int not null,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3),
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null,
    constraint pk_cus primary key (cus_code)
);
create table invoice5(
	inv_number int auto_increment,
    cus_code int not null,
    inv_date datetime,
    primary key (inv_number),
    foreign key (cus_code) references customer5 (cus_code)
);

alter table invoice add foreign key (cus_code) references customer4 (cus_code);
alter table invoice add constraint fk_cus foreign key (cus_code) references customer4 (cus_code);
alter table invoice drop foreign key fk_cus;

# referential integrity
desc customer5;
desc invoice5;
create table invoice5(
	inv_number int auto_increment,
    cus_code int not null,
    inv_date datetime,
    primary key (inv_number),
    foreign key (cus_code) references customer5 (cus_code)
    on delete cascade
);
insert into customer5
value (100, 'Smith5', 'James5', 'I', '706', '777-7777',100.0);
insert into invoice5 values(1001,100,now());

delete from customer5;
select * from invoice5;

# check
create table customer6(
	cus_code int not null,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3),
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null,
    primary key (cus_code),
    check (cus_balance >0)
);
insert into customer6
value (100, 'Smith6', 'James6', 'I', '706', '777-7777',-100.0);

create table customer7(
	cus_code int not null,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3),
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null,
    primary key (cus_code),
    constraint chk_customer check (cus_balance > 0 and cus_areacode = '615')
);
insert into customer7
value (100, 'Smith6', 'James6', 'I', '706', '777-7777',100.0);

alter table customer6 add check (cus_balance > 0);
alter table customer6 add constraint chk_customer check (cus_balance > 0 and cus_area = '615');
alter table customer6 drop constraint chk_customer;

# default
create table customer6(
	cus_code int not null auto_increment,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3) default '615',
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null,
    primary key (cus_code)
);

alter table customer6 alter cus_areacode set default '615';
alter table customer6 alter cus_areacode drop default;


# index
insert into customer value (100, 'Smith', 'James', 'I', '706', '777-7777',100.0),
(101, 'Smith1', 'James1', 'I', '706', '777-7777',100.0),
(102, 'Smith1', 'James1', 'I', '706', '777-7777',100.0),
(103, 'Smith2', 'James2', 'I', '706', '777-7777',100.0),
(104, 'Smith3', 'James3', 'I', '706', '777-7777',100.0),
(105, 'Smith4', 'James4', 'I', '706', '777-7777',100.0),
(106, 'Smith5', 'James6', 'I', '706', '777-7777',100.0),
(107, 'Smith6', 'James6', 'I', '706', '777-7777',100.0),
(108, 'Smith6', 'James6', 'I', '706', '777-7777',100.0),
(109, 'Smith6', 'James6', 'I', '706', '777-7777',100.0)
;

describe select * from customer where cus_lname = 'Smith1';
create index cus_name on customer (cus_lname);
describe select * from customer where cus_lname = 'Smith1';
create index cus_fullname on customer (cus_lname, cus_fname);
create unique index cus_name on customer (cus_lname);
alter table customer drop index cus_name;
select * from customer;

select found_rows();

# auto increment
create table customer7(
	cus_code int not null auto_increment,
    cus_lname varchar(15) not null,
    cus_fname varchar(15) not null,
    cus_initial varchar(15),
    cus_areacode varchar(3) default '615',
    cus_phone varchar(8),
    cus_balance decimal(10,2) not null,
    primary key (cus_code)
);

set global auto_increment_increment = 1;
alter table customer auto_increment = 1000;
















