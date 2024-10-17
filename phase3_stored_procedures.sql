-- CS4400: Introduction to Database Systems (Summer 2023)
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

use yellow_jacket_delivery;

/* START SUPPORTING VIEWS/PROCEDURES */
-- -------------------------------- --
/* END SUPPORTING VIEWS/PROCEDURES */
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
drop procedure if exists add_order;
delimiter //
create procedure add_order 
	(ip_username varchar(40),
    ip_order_ID varchar(40),
    ip_price dec(10, 2))

    sp_main: begin
    if ip_order_ID not in (select order_ID from order_tab) 
    then 
    insert into order_tab(order_ID, price, username)
    values(ip_order_ID, ip_price, ip_username);
    end if;
    commit;
end //
delimiter ;
    
-- -----------------------------------------------------------------------------
-- [1] add_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new employee without any designated warehouse_worker
or driver role. If they are not a new user, an employee of the delivery service cannot 
already be a contractor. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_employee;
delimiter //
create procedure add_employee (
ip_username varchar(40),
ip_tax_ID char(11),
ip_salary decimal(8,2),
ip_birthdate date,
ip_firstname varchar(100),
ip_lastname varchar(100))
sp_main: begin
	/* start variable declarations */
    
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
	IF ip_username NOT IN (
    SELECT username 
    from sys_user) THEN

		INSERT INTO sys_user(username, firstname, lastname, birthdate)
		VALUES(ip_username, ip_firstname, ip_lastname, ip_birthdate);
    
		INSERT INTO employee(tax_ID, salary, username)
		VALUES(ip_tax_ID, ip_salary, ip_username);
    
    ELSEIF ip_username NOT IN (
	SELECT username
	FROM contractor) THEN 

		INSERT INTO employee(tax_ID, salary, username)
		VALUES(ip_tax_ID, ip_salary, ip_username);
        
    END IF;
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [2] add_contractor()
-- -----------------------------------------------------------------------------
/* Add a new contractor to the system, with their company name (if specified). 
If they are not a new user, they cannot already be an employee of the delivery 
service. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_contractor;
delimiter //
create procedure add_contractor (
ip_username varchar(40),
ip_company varchar(100),
ip_birthdate date,
ip_firstname varchar(100),
ip_lastname varchar(100))
sp_main: begin
	/* start variable declarations */
    
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
    IF ip_username NOT IN (SELECT username FROM sys_user) THEN
		INSERT INTO sys_user(username, firstname, lastname, birthdate)
		VALUES(ip_username, ip_firstname, ip_lastname, ip_birthdate);
	
        INSERT INTO contractor(company, username, packer_ID)
        VALUES(ip_company, ip_username, null);
	ELSEIF ip_username NOT IN (SELECT username FROM employee) THEN
		INSERT INTO contractor(company, username, packer_ID)
        VALUES(ip_company, ip_username, null);
	END IF;
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [3] add_warehouse_worker()
-- -----------------------------------------------------------------------------
/* Add a new warehouse worker to the database, tagging them with the ID of the 
warehouse they work at. If they are not a new user, they cannot already be an 
employee of the delivery service. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_warehouse_worker;
delimiter //
create procedure add_warehouse_worker (
ip_username varchar(40),
ip_tax_ID char(11),
ip_salary decimal(8,2),
ip_warehouse_ID varchar(40),
ip_birthdate date,
ip_firstname varchar(100),
ip_lastname varchar(100))
sp_main: begin
	/* start variable declarations */
    
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
    IF ip_username NOT IN (SELECT username FROM sys_user) THEN
		INSERT INTO sys_user(username, firstname, lastname, birthdate)
		VALUES(ip_username, ip_firstname, ip_lastname, ip_birthdate);
        
        call add_employee(
        ip_username,
		ip_tax_ID,
		ip_salary,
		ip_birthdate,
		ip_firstname,
		ip_lastname);
	
        INSERT INTO warehouse_worker(tax_ID, warehouse_ID, packer_ID)
        VALUES(ip_tax_ID, ip_warehouse_ID, null);
	ELSEIF ip_username NOT IN (SELECT username FROM employee) THEN
		call add_employee(
        ip_username,
		ip_tax_ID,
		ip_salary,
		ip_birthdate,
		ip_firstname,
		ip_lastname);
        
		INSERT INTO warehouse_worker(tax_ID, warehouse_ID, packer_ID)
        VALUES(ip_tax_ID, ip_warehouse_ID, null);
	END IF;
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [4] add_driver()
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS add_driver;
DELIMITER //

CREATE PROCEDURE add_driver(
    IN ip_username VARCHAR(40),
    IN ip_tax_ID CHAR(11),
    IN ip_salary DECIMAL(8,2),
    IN ip_birthdate DATE,
    IN ip_firstname VARCHAR(100),
    IN ip_lastname VARCHAR(100),
    IN ip_experience_months INT
)
sp_main: BEGIN
    DECLARE exit handler FOR sqlexception 
    BEGIN 
        ROLLBACK; 
        RESIGNAL; 
    END;
    START TRANSACTION;

    IF ip_username NOT IN (SELECT username FROM sys_user) THEN
        INSERT INTO sys_user(username, firstname, lastname, birthdate)
        VALUES(ip_username, ip_firstname, ip_lastname, ip_birthdate);
    END IF;

    IF ip_username NOT IN (SELECT username FROM employee) THEN
        INSERT INTO employee(tax_ID, salary, username)
        VALUES(ip_tax_ID, ip_salary, ip_username);
    END IF;

    INSERT INTO driver(tax_ID, experience)
    VALUES(ip_tax_ID, ip_experience_months);

    COMMIT;
END //
DELIMITER ;

-- -----------------------------------------------------------------------------
-- [5] fire_driver()
-- -----------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS fire_driver;
DELIMITER //

CREATE PROCEDURE fire_driver(
    ip_username VARCHAR(40),
    ip_tax_ID CHAR(11)
)
sp_main: BEGIN
    DECLARE exit handler FOR sqlexception 
    BEGIN 
        ROLLBACK; 
        RESIGNAL; 
    END;
    START TRANSACTION;

    DELETE FROM driver WHERE tax_ID = ip_tax_ID;
    DELETE FROM employee WHERE tax_ID = ip_tax_ID AND 
        NOT EXISTS (SELECT 1 FROM driver WHERE tax_ID = ip_tax_ID) AND
        NOT EXISTS (SELECT 1 FROM warehouse_worker WHERE tax_ID = ip_tax_ID);

    COMMIT;
END //

DELIMITER ;



-- -----------------------------------------------------------------------------
-- [6]register_packer()
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS register_packer;
DELIMITER $$

CREATE PROCEDURE register_packer(
    IN ip_username VARCHAR(40),
    IN ip_packer_ID INT,
    IN ip_shift_start TIME,
    IN ip_shift_end TIME
)
BEGIN
    DECLARE user_exists BOOLEAN;
    DECLARE already_packer BOOLEAN;
    DECLARE packer_id_exists BOOLEAN;
    DECLARE v_tax_id VARCHAR(50);

    SET user_exists = EXISTS(SELECT 1 FROM sys_user WHERE username = ip_username);
    IF NOT user_exists THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not exist';
    END IF;

    SET already_packer = EXISTS(SELECT 1 FROM contractor WHERE username = ip_username AND packer_ID IS NOT NULL);
    IF already_packer THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is already registered as a packer';
    END IF;

    SET packer_id_exists = EXISTS(SELECT 1 FROM packer WHERE packer_ID = ip_packer_ID);
    IF packer_id_exists THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Packer ID is already used';
    END IF;

    INSERT INTO packer (packer_ID, shift_start, shift_end)
    VALUES (ip_packer_ID, ip_shift_start, ip_shift_end);


    SELECT w.tax_ID INTO v_tax_id
    FROM employee e
    JOIN warehouse_worker w ON e.tax_ID = w.tax_ID
    WHERE e.username = ip_username;

    IF EXISTS(SELECT 1 FROM contractor WHERE username = ip_username) THEN
        UPDATE contractor
        SET packer_ID = ip_packer_ID
        WHERE username = ip_username;
    ELSE
        INSERT INTO contractor (username, packer_ID)
        VALUES (ip_username, ip_packer_ID);
    END IF;
    
    IF v_tax_id IS NOT NULL THEN
        UPDATE warehouse_worker
        SET packer_ID = ip_packer_ID
        WHERE tax_ID = v_tax_id;
    END IF;

END$$

DELIMITER ;




-- -----------------------------------------------------------------------------
-- [7] add_customer()
-- -----------------------------------------------------------------------------
/* This stored procedure adds a new customer, given their username and contact 
information. Alternatively, it can also be used to add an existing user as a 
customer (since employees/contractors are allowed to be customers in our system).
If an existing user is added as a customer, you do not need to update their main 
‘user’ data. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_customer;
delimiter //
create procedure add_customer (
ip_username varchar(40),
ip_phone_number char(10),
ip_address varchar(500),
ip_birthdate date,
ip_firstname varchar(100),
ip_lastname varchar(100))
sp_main: begin
	/* start variable declarations */
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
    IF ip_username NOT IN (SELECT username FROM sys_user) THEN
		INSERT IGNORE INTO sys_user (username, firstname, lastname, birthdate)
		VALUES (ip_username, ip_firstname, ip_lastname, ip_birthdate);
	END IF;

	if ip_username not in (select username from customer)
    then 
	INSERT INTO customer (username, phone_number, address)
	VALUES (ip_username, ip_phone_number, ip_address);
    end if;
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [8] del_all_orders()
-- -----------------------------------------------------------------------------
/* This stored procedure deletes all orders for a customer. It takes the customer's 
username and deletes all orders associated with that customer. */
-- -----------------------------------------------------------------------------
drop procedure if exists del_all_orders;
delimiter //
create procedure del_all_orders(
ip_username varchar(40))
sp_main: begin
	/* start variable declarations */
    
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
    DELETE FROM order_tab WHERE username = ip_username;
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [9] add_package()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new package. The source and
 destination warehouse of a package should be on an existing route in the database,
 occurring in the same order (potentially with stops between them). Finally, if the
 packer is a warehouse worker, they must work at the source warehouse (if they are 
 a contractor, you can assume that they do.) */
-- -----------------------------------------------------------------------------
drop procedure if exists add_package;
delimiter //
create procedure add_package (
ip_package_number int,
ip_packer_ID int,
ip_order_ID varchar(40), 
ip_source_warehouse varchar(40),
ip_dest_warehouse varchar(40),
ip_package_desc varchar(500)
)
sp_main: begin
	declare is_contractor boolean;
declare is_warehouse_worker boolean;
declare route_exists boolean;
/* end variable declarations */
declare exit handler for sqlexception begin rollback;
resignal; end;
start transaction;
/* start procedure body */
IF ip_packer_ID in (select packer_ID from warehouse_worker) and ip_source_warehouse not in (
select warehouse_ID
from warehouse_worker)
then
	signal sqlstate '45000'
	set message_text = 'Packer must work at source_warehouse';
end if;

IF ip_source_warehouse in 
	(select depart
	from leg)
    and ip_dest_warehouse in
    (select arrive
    from leg)
    
Then 
	insert into package(package_number, order_ID, packer_ID, source_warehouse, dest_warehouse, package_desc)
    values(ip_package_number, ip_order_ID, ip_packer_ID, ip_source_warehouse, ip_dest_warehouse, ip_package_desc);
	
    end if;
    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [11] add_truck()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new truck in the database. A truck should have 
a unique plate_number, assigned to a route and optionally may have a fuel load,
capacity and assigned driver. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_truck;
delimiter //
create procedure add_truck (
ip_driver_ID char(11),
ip_plate_number char(7),
ip_capacity int,
ip_fuel int,
ip_route_ID varchar(40))
sp_main: begin

	
	if ip_route_ID not in (select route_ID from route) 
    then 
    insert into route(route_ID)
    values(ip_route_ID);
    
    insert into truck(plate_number, capacity, fuel, driver_ID, route_ID)
    values (ip_plate_number, ip_capacity, ip_fuel, ip_driver_ID, ip_route_ID);
    else 
    insert into truck(plate_number, capacity, fuel, driver_ID, route_ID)
    values (ip_plate_number, ip_capacity, ip_fuel, ip_driver_ID, ip_route_ID);
    
    end if;
    
    

   	commit;
end //
delimiter ;


-- -----------------------------------------------------------------------------
-- [10] update_package_truck()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the truck assignment for an existing package. A
package must be assigned to a valid truck - meaning the assigned route should
contain the source and destination warehouse, in order. If the source and 
destination warehouse are the same, the package need not be transported and thus
should not be assigned to a truck. */
-- -----------------------------------------------------------------------------
drop procedure if exists update_package_truck;
delimiter //
create procedure update_package_truck (
ip_package_number int,
ip_order_ID varchar(40),
ip_truck_ID char(7)
)
sp_main: begin
	/* start variable declarations */
	declare v_route_followed varchar(40);
     declare v_source_warehouse char(3);
     declare v_dest_warehouse char(3);

    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
	if ip_order_ID in
    (select order_ID
    from package
    where source_warehouse != dest_warehouse)
    and ip_truck_ID in (select plate_number from truck)
	then 
		update Package
		set truck_ID = ip_truck_ID
		where package_number = ip_package_number and order_ID = ip_order_ID;
	end if;
    
    
    /* end procedure body */

   	commit;
end //
delimiter ;


-- -----------------------------------------------------------------------------
-- [12] reassign_trucks()
-- -----------------------------------------------------------------------------
/* Given a routeID, reassign all trucks on that route to a new route, specified 
by new_routeID. This procedure is allowed only if there are no packages assigned
to any of the trucks. */
-- -----------------------------------------------------------------------------
drop procedure if exists reassign_trucks;
delimiter //
create procedure reassign_trucks (
ip_route_ID varchar(40),
ip_new_route_ID varchar(40))
sp_main: begin
if ip_new_route_ID in
(select route_ID from route)  -- Ensure ip_new_route_ID exists in the route table
and ip_route_ID != ip_new_route_ID
then 
    update truck
    set route_ID = ip_new_route_ID
    where route_ID = ip_route_ID;
end if;
commit;
   	commit;
end //
delimiter ;
-- -----------------------------------------------------------------------------
-- [13] start_route()
-- -----------------------------------------------------------------------------
/* This stored procedure creates the first leg of a new route. Routes in our 
system must be created in the sequential order of the legs. The first leg of the
route can be any valid leg, and it should have a sequence number of 1. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_route;
delimiter //
create procedure start_route (
ip_route_ID varchar(40), 
ip_leg_ID varchar(40))
sp_main: begin
	/* start variable declarations */
    
    /* end variable declarations */
	declare exit handler for sqlexception begin rollback; resignal; end;
   	start transaction;
	/* start procedure body */
     insert into route (route_ID)
    values (ip_route_ID);

    insert into route_leg (route_ID, leg_ID, sequence) 
    values (ip_route_ID, ip_leg_ID, 1);

    /* end procedure body */
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [14] extend_route()
-- -----------------------------------------------------------------------------
/* This stored procedure adds another leg to the end of an existing route. Routes 
must be created in the sequential order of the legs, and the route must be 
contiguous: the departure warehouse of this leg must be the same as the arrival
warehouse of the previous leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists extend_route;
delimiter //
create procedure extend_route(
ip_route_ID varchar(40), 
ip_leg_ID varchar(40)) 
sp_main: begin
	/* start variable declarations */
      declare v_last_leg varchar(40);
    declare v_last_sequence int;


    select leg_ID, sequence 
    into v_last_leg, v_last_sequence
    from route_leg
    where route_ID = ip_route_ID
    order by sequence desc
    limit 1;
if not exists (
    select 1 
    from leg last_leg
    join leg new_leg on last_leg.arrive = new_leg.depart
    where last_leg.leg_ID = v_last_leg
    and new_leg.leg_ID = ip_leg_ID
) then
    signal sqlstate '45000' set message_text = 'Departure warehouse of the new leg must match the arrival warehouse of the previous leg';
end if;
insert into route_leg (route_ID, leg_ID, sequence)
  values (ip_route_ID, ip_leg_ID, v_last_sequence + 1);



   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [15] delete_route()
-- -----------------------------------------------------------------------------
/* This stored procedure deletes a route from the database given a route ID - the
only restriction is that we can only delete a route if it is not assigned to any
truck. */
-- -----------------------------------------------------------------------------
drop procedure if exists delete_route;
delimiter //
create procedure delete_route (
ip_route_ID varchar(40))
sp_main: begin
    if ip_route_ID not in (select route_ID from truck)
    then
    delete from route_leg 
    where route_ID = ip_route_ID;
    
    delete from route 
    where route_ID = ip_route_ID;
    end if;
   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [16] add_update_leg()
-- -----------------------------------------------------------------------------
/* This stored procedure is used to create a new leg, or update an existing leg.
If an existing leg is being updated, only its legID and distance can change. With
either an insert or an update, you must ensure that all legs are symmetric in 
terms of distance - if a leg in the opposite direction exists, then update its
distance to ensure that they are equal. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_update_leg;
delimiter //
create procedure add_update_leg (
ip_leg_ID varchar(40),
ip_distance int,
ip_depart varchar(40),
ip_arrive varchar(40))
sp_main: begin
	insert into leg (leg_ID, distance, depart, arrive)
    values (ip_leg_ID, ip_distance, ip_depart, ip_arrive)
    on duplicate key update distance = values(distance), depart = values(depart), arrive = values(arrive);
    if exists (select 1 from leg where depart = ip_arrive and arrive = ip_depart) then
        update leg 
        set distance = ip_distance
        where depart = ip_arrive and arrive = ip_depart;
    end if;


   	commit;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- View 1 - route_summary
-- -----------------------------------------------------------------------------
/* This view will give a summary of every route. This will include the routeID, the 
number of legs per route, the legs of the route in sequence, the total distance of
the route, the number of trucks on this route, the plate numbers of those trucks,
and the sequence of warehouses visited by the route. */
-- -----------------------------------------------------------------------------
create or replace view route_summary as
-- remove the following line and add your solution
select leg_seq.route_ID, num_legs, leg_sequence, total_distance, num_trucks, truck_list, warehouse_sequence
from 
(select route_ID, group_concat(leg_ID order by route_leg.sequence separator ', ') as leg_sequence
from route_leg
group by route_ID
having route_ID = route_ID) leg_seq
join
(select route_ID, sum(distance) as total_distance
from route_leg rL join leg on rL.leg_ID = leg.leg_ID
group by route_ID) s
on leg_seq.route_ID = s.route_ID
join
(select route_ID, count(leg_ID) as num_legs
from route_Leg
group by route_ID) n
on s.route_ID = n.route_ID
join
(select route_ID, count(plate_number) as num_trucks
from truck  
group by route_ID) t_num
on leg_seq.route_ID = t_num.route_ID
left outer join
(select route_ID, group_concat(plate_number) as truck_list
from truck
group by route_ID
having route_ID = route_ID) t_L
on leg_seq.route_ID = t_L.route_ID
left outer join
(select route_ID, group_concat(depart_arrive_sequence order by sequence) as warehouse_sequence
from
(select route_ID, sequence, concat(depart, '->', arrive) as depart_arrive_sequence
from route_leg rL join leg l on rL.leg_ID = l.leg_ID) d_a_s
group by route_ID) w_h_sequence
on leg_seq.route_ID = w_h_sequence.route_ID
order by route_ID;

/* view statement */

-- -----------------------------------------------------------------------------
-- View 2 - package_distance
-- -----------------------------------------------------------------------------
/* This view will display the distance between the source and destination warehouse
for every package in the delivery system. You can exclude packages that have not
been assigned to a truck. The view will include the order ID, package number and
the required transport distance. */
-- -----------------------------------------------------------------------------
drop view if exists package_distance; 
CREATE VIEW package_distance AS
SELECT
    p.order_ID,
    p.package_number,
    l.distance
FROM
    package p
JOIN
    leg l
WHERE
    p.source_warehouse = l.depart AND p.dest_warehouse = l.arrive;


-- -----------------------------------------------------------------------------
-- View 3 - popular_legs
-- -----------------------------------------------------------------------------
/* Displays the legs that are shared by more than one route, allowing 
administrators to find congested portions of the network. The view should display
the departure and arrival warehouse, legID, distance and a list of the routes that
share that leg. */
-- -----------------------------------------------------------------------------
drop view if exists popular_legs;
CREATE VIEW popular_legs AS
SELECT
leg.leg_ID,
leg.depart,
leg.arrive,
Leg.distance,
GROUP_CONCAT(route.route_ID ORDER BY route.route_ID SEPARATOR ', ') AS routes
FROM
leg
JOIN
route_leg ON leg.leg_ID = route_leg.leg_ID 
JOIN
route ON route_leg.route_ID = route.route_ID 
GROUP BY
leg.leg_ID, leg.depart, leg.arrive, leg.distance
HAVING
COUNT(route.route_ID) > 1;

