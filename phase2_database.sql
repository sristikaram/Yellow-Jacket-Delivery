-- Yellow Jacket Delivery Project Database 

set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

drop database if exists yellow_jacket_delivery;
create database if not exists yellow_jacket_delivery;
use yellow_jacket_delivery;

CREATE TABLE `User` (
    username VARCHAR(40) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    birthdate DATE,
    PRIMARY KEY (username)
);
CREATE TABLE Customer (
    username VARCHAR(40) NOT NULL,
    phone_number VARCHAR(40),
    address VARCHAR(500),
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES User(username)
);
CREATE TABLE Employee (
    username VARCHAR(40) NOT NULL,
    taxID CHAR(11) NOT NULL,  
    salary DECIMAL(10, 2),
    PRIMARY KEY (taxID),
    FOREIGN KEY (username) REFERENCES User(username)
);
CREATE TABLE Route (
    routeID VARCHAR(40) NOT NULL,
    PRIMARY KEY (routeID)
);
CREATE TABLE Truck (
    plate_number CHAR(7) NOT NULL, 
    capacity INT,
    fuel INT,
    route_followed VARCHAR(40),
    PRIMARY KEY (plate_number),
    FOREIGN KEY (route_followed) REFERENCES Route(routeID)
);
CREATE TABLE Driver (
    taxID CHAR(11) NOT NULL,
    experience INT,  
    plate_no CHAR(7),
    PRIMARY KEY (taxID),
    FOREIGN KEY (taxID) REFERENCES Employee(taxID),
    FOREIGN KEY (plate_no) REFERENCES Truck(plate_number)
);
CREATE TABLE Packer ( 
    packer_ID INT,
    shift_start TIME,
    shift_end TIME,
    PRIMARY KEY (packer_ID)
);
CREATE TABLE Warehouse (
    warehouse_ID CHAR(3) NOT NULL,
    x_coordinate DECIMAL(10, 3),
    y_coordinate DECIMAL(10, 3),
    PRIMARY KEY (warehouse_ID)
);
CREATE TABLE Warehouse_Worker ( 
    taxID CHAR(11) NOT NULL,
    warehouse_identifier  CHAR(3),
    packer_identifier INT,
    shift_start TIME,
    shift_end TIME,
    PRIMARY KEY (taxID),
    FOREIGN KEY (taxID) REFERENCES Employee(TaxID),
    FOREIGN KEY (packer_identifier) REFERENCES Packer(packer_id),
    FOREIGN KEY (warehouse_identifier) REFERENCES Warehouse(warehouse_ID)
);
CREATE TABLE Contractor ( -- MAY NEED EDITS
    username VARCHAR(40) NOT NULL,
    company VARCHAR(100),
    shift_start_time TIME,
    shift_end_time TIME,
    packer_identifier INT,
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES User(username),
    FOREIGN KEY (packer_identifier) REFERENCES Packer(packer_ID)    
);
CREATE TABLE `Order` (
    orderID VARCHAR(40),
    customer_identifier VARCHAR(40) NOT NULL,
    price DECIMAL(10, 2),
    PRIMARY KEY (orderID),
    FOREIGN KEY (customer_identifier) REFERENCES Customer(username)
);
CREATE TABLE Package (
    package_number INT,
    order_identifier VARCHAR(40),
    `description` VARCHAR(500),
    packer_identifier INT,
    source CHAR(3),
    destination CHAR(3),
    truck_identifier CHAR(7),
    PRIMARY KEY (package_number, order_identifier),
    FOREIGN KEY (order_identifier) REFERENCES `Order`(orderID),
    FOREIGN KEY (source) REFERENCES Warehouse(warehouse_ID),
    FOREIGN KEY (destination) REFERENCES Warehouse(warehouse_ID),
    FOREIGN KEY (packer_identifier) REFERENCES Packer(packer_ID),
	FOREIGN KEY (truck_identifier) REFERENCES Truck(plate_number)
);
CREATE TABLE Leg (
    legID VARCHAR(6),
    distance INT,
    departure CHAR(3),
    arrival CHAR(3),
    PRIMARY KEY (legID),
    FOREIGN KEY (departure) REFERENCES Warehouse(warehouse_ID),
    FOREIGN KEY (arrival) REFERENCES Warehouse(warehouse_ID)
);
CREATE TABLE Contain (
	sequence INT,
    route_identifier VARCHAR(40), 
    leg_identifier VARCHAR(6),
    FOREIGN KEY (route_identifier) REFERENCES Route(routeID),
	FOREIGN KEY (leg_identifier) REFERENCES Leg(legID)
    );

   -- INSERT STATEMENTS
   
INSERT INTO `User`(username, first_name, last_name, birthdate) 
VALUES
('bsummers4', 'Brie', 'Summers', '1976-02-09'),
('eross10', 'Erica', 'Ross', '1975-04-02'),
('lrodriguez5', 'Lina', 'Rodriguez', '1975-04-02'),
('rlopez6', 'Radish', 'Lopez', '1999-09-03'),
('agarcia7', 'Alejandro', 'Garcia', '1966-10-29'),
('awilson5', 'Aaron', 'Wilson', '1963-11-11'),
('ckann5', 'Carrot', 'Kann', '1972-09-01'),
('csoares8', 'Claire', 'Soares', '1965-09-03'),
('echarles19', 'Ella', 'Charles', '1974-05-06'),
('fprefontaine6', 'Ford', 'Prefontaine', '1961-01-28'),
('hstark16', 'Harmon', 'Stark', '1971-10-27'),
('mrobot1', 'Mister', 'Robot', '1988-11-02'),
('mrobot2', 'Mister', 'Robot', '1988-11-02'), 
('tmccall5', 'Trey', 'McCall', '1973-03-19'),
('cjordan5', 'Clark', 'Jordan', '1966-06-05'),
('jstone5', 'Jared', 'Stone', '1961-01-06'),
('sprince6', 'Sarah', 'Prince', '1968-06-15'),
('sreynolds7', 'Sophia', 'Reynolds', '1990-03-21'),
('jwalker8', 'Jessica', 'Walker', '1985-09-12'),
('amiller10', 'Andrew', 'Miller', '1978-11-08'),
('bsmith9', 'Brian', 'Smith', '1992-04-25'),
('owest2', 'Olivia', 'Stone', '1979-03-17'),
('sknight7', 'Samuel', 'Knight', '1995-12-03'),
('smarlow8', 'Sophia', 'Marlow', '1984-07-09'),
('elicruz0', 'Elijah', 'Cruz', '1990-02-28'),
('mrams6', 'Mia', 'Ramsey', '1978-09-14'),
('lgreen3', 'Lucas', 'Greene', '1961-01-07');

INSERT INTO Customer (username, phone_number, address)
VALUES
('bsummers4', '1112345675', '5105 Dragon Star Circle'),
('eross10', '1145234675', '22 Peachtree Street'),
('lrodriguez5', '4857363289', '360 Corkscrew Circle'),
('rlopez6', '4372385443', '8 Queens Route'),
('cjordan5', '4029624583', '77 Infinite Stars Road'),
('jstone5', '1234567983', '101 Five Finger Way'),
('sprince6', '3949302942', '22 Peachtree Street'), -- Duplicate address with 'eross10'
('sreynolds7', '9593028492', '123 Oak Avenue'),
('jwalker8', '4893205843', '567 Maple Lane'),
('amiller10', '9320571145', '321 Oak Street'),
('bsmith9', '9502049587', '789 Elm Street');


INSERT INTO Employee (username, taxID, salary)
VALUES
('bsummers4', '000-00-0000', 35000),
('eross10', '444-44-4444', 61000),
('lrodriguez5', '222-22-2222', 58000),
('rlopez6', '123-58-1321', 64000),
('agarcia7', '999-99-9999', 41000),
('awilson5', '111-11-1111', 46000),
('ckann5', '640-81-2357', 46000),
('csoares8', '888-88-8888', 57000),
('echarles19', '777-77-7777', 27000),
('fprefontaine6', '121-21-2121', 20000),
('hstark16', '555-55-5555', 59000),
('mrobot1', '101-01-0101', 38000),
('mrobot2', '010-10-1010', 38000),
('tmccall5', '333-33-3333', 33000);

INSERT INTO Route (routeID)
VALUES
('circle_east_coast'),
('circle_west_coast'),
('northeastbound_multistop'),
('eastbound_nonstop'),
('eastbound_southern'), 
('local_texas');


INSERT INTO  Truck (plate_number, capacity, fuel, route_followed)
VALUES
('TCK-123', 23, 150, 'circle_east_coast'),
('BIG-IG7', 13, 100, 'circle_west_coast'),
('HUL-678', 45, 200, 'northeastbound_multistop'),
('HWY-RV3', 60, 250, 'eastbound_nonstop'),
('HAU-247', 80, 300, 'eastbound_southern'),
('HBD-789', 100, 250, 'local_texas');

INSERT INTO Driver (taxID, experience, plate_no)
VALUES
('444-44-4444', 15, 'TCK-123'),
('888-88-8888', 28, 'BIG-IG7'),
('121-21-2121', 23, 'HUL-678'),
('555-55-5555', 2, 'HWY-RV3'),
('101-01-0101', 9, 'HAU-247'),
('010-10-1010', 28, 'HBD-789');


INSERT INTO  Packer ( packer_ID, shift_start, shift_end)
VALUES
(0, '09:00', '17:00'),
(1, '09:00', '17:00'),
(2, '10:00', '18:00'),
(3, '11:00', '19:00'),
(4, '12:00', '20:00'),
(5, '13:00', '21:00'),
(6, '14:00', '22:00'),
(7, '15:00', '23:00'),
(8, '16:00', '00:00'),
(9, '17:00', '01:00'),
(10, '18:00', '02:00'),
(11, '19:00', '03:00'),
(12, '20:00', '04:00');

INSERT INTO Warehouse (warehouse_ID, x_coordinate, y_coordinate)
VALUES
('ATL', 33.749, -84.388),
('LAX', 33.941, 118.408),
('SEA', 47.609, -122.333),
('ORD', 41.974, -87.907),
('IAH', 29.99, -95.336),
('JFK', 40.641, -73.778),
('IAD', 38.944, 77.455),
('ISP', 40.795, -73.1),
('BFI', 47.537, -122.309),
('DCA', 48.324, -34.232),
('DAL', 34.323, 68.374),
('DFW', 89.434, -98.434),
('HOU', 48.453, -34.764);

INSERT INTO Warehouse_Worker (taxID, warehouse_identifier, packer_identifier, shift_start, shift_end)
VALUES
('000-00-0000', 'ATL', 0, '09:00', '17:00'),
('222-22-2222', 'LAX', 1, '09:00', '17:00'), 
('123-58-1321', 'DFW', 2, '10:00', '18:00'),
('999-99-9999', 'SEA', 3, '11:00', '19:00'),
('111-11-1111', 'IAH', 4, '12:00', '20:00'),
('640-81-2357', 'ISP', 5, '13:00', '21:00'),
('777-77-7777', 'LAX', 6, '14:00', '22:00');

INSERT INTO Contractor (username, company, shift_start_time, shift_end_time, packer_identifier)
VALUES
('owest2', 'RapidRoute', '15:00', '23:00', 7),
('sknight7', 'ZoomDelivery', '16:00', '00:00', 8),
('smarlow8', 'DashDispatch', '17:00', '01:00', 9),
('elicruz0', 'LightningLogistics', '18:00', '02:00', 10),
('mrams6', 'FastTrack Freight', '19:00', '03:00', 11),
('lgreen3', 'TurboTrans', '20:00', '04:00', 12);

INSERT INTO `Order` (orderID, customer_identifier, price)
VALUES
('HXLPQD3TN', 'bsummers4', 99.96),
('GWRJFZK9S', 'eross10', 55.00),
('AIPJW5OMX', 'cjordan5', 198.00),
('SQO8VYHRE', 'jstone5', 34.60),
('FVAJXHPN6', 'sreynolds7', 148.84),
('GTR62941', 'sreynolds7', 75.80), 
('YRBOE2ICQ', 'jwalker8', 79.98),
('LKP43790', 'jwalker8', 89.50), 
('WT4UNLMP', 'amiller10', 227.52),
('ZCQJVKIR0', 'bsmith9', 22.00);

INSERT INTO Package (package_number, order_identifier, `description`, packer_identifier, `source`, destination, truck_identifier)
VALUES
(1, 'HXLPQD3TN', 'A set of glow-in-the-dark toothpaste and a banana-scented floss.', 0, 'ATL', 'ORD', 'TCK-123'),
(2, 'HXLPQD3TN', 'A bundle of unicorn-shaped cereal, rainbow-flavored milk, and a marshmallow dispenser.', 1, 'LAX', 'DFW', 'BIG-IG7'),
(1, 'GWRJFZK9S', 'A pair of bacon-scented socks, a pickle-shaped pillow, and a bacon-scented candle.', 2, 'SEA', 'ORD', 'HUL-678'),
(2, 'GWRJFZK9S', 'A portable disco ball, a unicorn-shaped piñata, and a collection of party hats.', 3, 'LAX', 'DFW', 'BIG-IG7'),
(3, 'GWRJFZK9S', 'A set of alien-themed cookie cutters, edible glitter, and a spaceship-shaped cake mold.', 4, 'IAD', 'IAD', NULL),
(1, 'AIPJW5OMX', 'A pack of insect-flavored lollipops, a cricket protein energy bar, and a bug-shaped gummy candy.', 5, 'SEA', 'JFK', 'HWY-RV3'),
(2, 'AIPJW5OMX', 'A bacon-scented toothbrush, a pizza-scented air freshener, and a burger-shaped stress ball.', 6, 'SEA', 'JFK', 'HWY-RV3'), 
(1, 'SQO8VYHRE', 'A pair of mermaid-themed slippers, a unicorn onesie, and a fluffy unicorn plush toy.', 7, 'LAX', 'DFW', 'HAU-247'),
(1, 'FVAJXHPN6', 'A set of googly eyes stickers, a squirrel-shaped dashboard ornament, and a pack of whimsical car air fresheners.', 8, 'DAL', 'HOU', 'HBD-789'),
(2, 'FVAJXHPN6', 'Order: A jar of bacon-flavored toothpaste, a pickle-flavored lip balm, and a sushi-shaped hand cream.', 9, 'DFW', 'ATL', 'HAU-247'), 
(1, 'YRBOE2ICQ', 'A bundle of dinosaur-shaped pasta, a spaghetti-twirling fork, and a dinosaur-shaped pasta strainer.', 10, 'LAX', 'DFW', 'HAU-247'), 
(2, 'YRBOE2ICQ', 'A pack of cat-shaped sticky notes, a llama-shaped tape dispenser, and a sloth-themed desk organizer.', 11, 'IAH', 'DAL', 'HBD-789'), 
(1, 'WT4UNLMP', 'A set of rainbow-colored shoelaces, a glow-in-the-dark shoe polish, and a pair of unicorn shoe charms.', 12, 'ISP', 'ISP', NULL),
(1, 'ZCQJVKIR0', 'A pair of mustache-shaped sunglasses, a pineapple-shaped umbrella, and a watermelon-shaped beach towel where it gets lighter as more night gets dark.', NULL, 'ORD', 'DCA', 'HUL-678'),
(2, 'ZCQJVKIR0', 'A bundle of alien-themed washi tape, a glow-in-the-dark pen, and a UFO-shaped pencil case.', NULL, 'DFW', 'ATL', 'HAU-247'), 
(3, 'ZCQJVKIR0', 'A pack of unicorn-themed band-aids, a bacon-scented hand sanitizer, and a rainbow-colored first aid kit.', NULL, 'ORD', 'DCA', 'TCK-123'), 
(1, 'LKP43790', 'A set of galaxy-themed sticky notes, a constellation-patterned journal, and a space shuttle-shaped pencil sharpener.', NULL, 'IAH', 'HOU', 'HBD-789'), 
(1, 'GTR62941', 'A pack of dinosaur-themed erasers, a T-rex-shaped pencil topper, and a volcano-shaped pencil holder.', NULL, 'SEA', 'JFK', 'HUL-678'); 

INSERT INTO Leg (legID, distance, departure, arrival)
VALUES
('leg_4', 600, 'ATL', 'ORD'),
('leg_18', 1200, 'LAX', 'DFW'),
('leg_24', 1800, 'SEA', 'ORD'),
('leg_23', 2400, 'SEA', 'JFK'),
('leg_12', 200, 'IAH', 'DAL'),
('leg_20', 600, 'ORD', 'DCA'), 
('leg_10', 800, 'DFW', 'ORD'),
('leg_9', 800, 'DFW', 'ATL'),
('leg_6', 200, 'DAL', 'HOU'),
('leg_7', 600, 'DCA', 'ATL'),
('leg_22', 800, 'ORD', 'LAX'),
('leg_8', 200, 'DCA', 'JFK'),
('leg_1', 600, 'ATL', 'IAD'),
('leg_11', 600, 'IAD', 'ORD'),
('leg_13', 1400, 'IAH', 'LAX'),
('leg_15', 800, 'JFK', 'ATL'),
('leg_2', 600, 'ATL', 'IAH'),
('leg_5', 1000, 'BFI', 'LAX');


INSERT INTO Contain (sequence, route_identifier, leg_identifier)
VALUES 
(1, 'circle_east_coast', 'leg_4'),
(1, 'circle_west_coast', 'leg_18'),
(1, 'northeastbound_multistop', 'leg_24'),
(1, 'eastbound_nonstop', 'leg_23'),
(1, 'eastbound_southern', 'leg_18'), 
(1, 'local_texas', 'leg_12'),
(2, 'circle_east_coast', 'leg_20'),
(2, 'circle_west_coast', 'leg_10'),
(2, 'northeastbound_multistop', 'leg_20'), 
(2, 'eastbound_southern', 'leg_9'),
(2, 'local_texas', 'leg_6'),
(3, 'circle_east_coast', 'leg_7'),
(3, 'circle_west_coast', 'leg_22'),
(3, 'northeastbound_multistop', 'leg_8'),
(3, 'eastbound_southern', 'leg_1'),
(1, NULL, 'leg_11'),
(1, NULL, 'leg_13'),
(1, NULL, 'leg_15'),
(1, NULL, 'leg_2'),
(1, NULL, 'leg_5');
