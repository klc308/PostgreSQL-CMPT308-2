-- ----------------------------------------------------------------------------------------
-- Kathy L. Coomes                                                                       --
-- Database Management Final Design Project                                              -- 
-- due date 05/02/2017                                                                   --
-- Created from class instruction by Alan Labouseur                                      --
-- Stored Procedure search_columns (see FindAlan) - created by Daniel Verite (LIne 796)  --
-- ----------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- Security restart for all roles, tables, views, and grants                             --
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

DROP ROLE IF EXISTS admin;
DROP ROLE IF EXISTS owner;
DROP ROLE IF EXISTS manager;
DROP ROLE IF EXISTS salesclerk;
  
DROP TABLE IF EXISTS People, VendorContacts, Staff, Customers, Vendors, Addresses, Products, 
	Producthistory, Inventory, Arrangements, ArrangementItems, ArrangementItemsList, 
	Orders CASCADE;

DROP VIEW IF EXISTS VendorInfo, StaffInfo, CustomerInfo, ProductInfo CASCADE;

DROP FUNCTION IF EXISTS GetArrListofItems(text, refcursor) CASCADE;
DROP FUNCTION IF EXISTS GetProductOrderList(text, refcursor) CASCADE;
DROP FUNCTION IF EXISTS AddPeople(peopleType text, peopleId text, firstName text, 
		lastName text, phone text, 
		phoneType phone, email text, addressId text, street1 text, street2 text, 
		city text, state text, zip text, dateHired date, hiredPosition pos, 
		dateLeft date, currentPosition pos, cellPhone text, vendorId text) CASCADE;
DROP FUNCTION IF EXISTS AddVendor(vendorId text, vendorName text) CASCADE; 
DROP FUNCTION IF EXISTS	AddProducts(productNew text, newVdrProdId text, vendorId text, 
	newType text, newName text, newSize text, newColor text, newQty int, 
	newCurrentCostUSD numeric, newprodDesc text, historyCostUSD numeric, 
	dateBought date, newItemId text, NewItemName text, newInvQty int) CASCADE;

DROP TYPE IF EXISTS phone, prod, pos CASCADE;

DROP TRIGGER IF EXISTS validPeopleInput ON People CASCADE;
DROP TRIGGER IF EXISTS validVendorInput ON Vendors CASCADE;

-- ----------------------------------------------------------------------------------------
-- Administrator Role - has full access                                                  --
-- ----------------------------------------------------------------------------------------
CREATE ROLE admin;
GRANT ALL ON ALL TABLES IN SCHEMA public TO admin;

-- ----------------------------------------------------------------------------------------
-- Owner Role - Owns the business, so has full access                                    --
-- ----------------------------------------------------------------------------------------
CREATE ROLE owner;
GRANT ALL ON ALL TABLES IN SCHEMA public TO owner;

-- ----------------------------------------------------------------------------------------
-- Manager Role - the manager has access to insert or update in all tables               --
-- ----------------------------------------------------------------------------------------
CREATE ROLE manager;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM manager;
GRANT ALL ON ALL TABLES IN SCHEMA public TO manager;

-- ----------------------------------------------------------------------------------------
-- Salesclerk Role - has ability to select all                                           --
-- ----------------------------------------------------------------------------------------
CREATE ROLE salesclerk;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM salesclerk;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO salesclerk;

-- ----------------------------------------------------------------------------------------	
-- ----------------------------------------------------------------------------------------
-- CREATE TYPES                                                                          --
-- ----------------------------------------------------------------------------------------	
-- ----------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------
-- phone Type - the phone type is used in the People table                               --
-- ----------------------------------------------------------------------------------------
CREATE TYPE phone as ENUM ('work', 'home', 'cell');

-- ----------------------------------------------------------------------------------------
-- product Type - used in the Product Table                                              --
-- ----------------------------------------------------------------------------------------
CREATE TYPE prod as ENUM ('flower', 'container', 'greenery', 'balloon', 'other');

-- ----------------------------------------------------------------------------------------
-- position TYPE - used in the Staff Table for hiredPosition and position                --
-- ----------------------------------------------------------------------------------------
CREATE TYPE pos as ENUM ('owner', 'arranger', 'manager', 'salesclerk');

-- ----------------------------------------------------------------------------------------			   
-- ----------------------------------------------------------------------------------------
-- CREATE TABLES                                                                         --
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------
-- People                                                                                --
-- This table keeps track of basic information that VendorContacts, Customers and Staff  --
-- have in common.                                                                       --
-- ----------------------------------------------------------------------------------------
CREATE TABLE People(
	peopleId	text	not null,
	firstName	text	not null,
	lastName	text	not null,
	phone		text,
	phoneType	phone,
	email		text,
   primary key(peopleId)
);
	
-- ----------------------------------------------------------------------------------------
-- Vendors                                                                               --
-- This table tracks Vendors from which the company buys its products.                   --
-- It creates a many to many relationship between VendorContacts and Products.           --
-- ----------------------------------------------------------------------------------------
CREATE TABLE Vendors(
	vendorId		text	not null,
	vendorName		text	not null,
   primary key(vendorId)
);

--- ---------------------------------------------------------------------------------------
-- VendorContacts                                                                        --
-- This table is an extension of the People table for Vendor Contact Information.        --
-- ----------------------------------------------------------------------------------------
CREATE TABLE VendorContacts (
	peopleId	text	not null	references People(peopleId),
	vendorId	text	not null	references Vendors(vendorId),
   primary key(peopleId, vendorId)   
);

--- ---------------------------------------------------------------------------------------
-- Staff                                                                                 --
-- This table is an extension of the People table for Staff Information.                 --
-- ----------------------------------------------------------------------------------------
CREATE TABLE Staff (
	peopleId		text	not null	references People(peopleId),
	dateHired		date	not null,
	hiredPosition	pos	 	not null,
	dateLeft		date	DEFAULT NULL,
	currentPosition	pos 	not null,
	cellPhone		text,
   primary key(peopleId)
);

-- ----------------------------------------------------------------------------------------
-- Customers                                                                             --
-- This table is an extension of the People Table for Customer Information.              --
-- ----------------------------------------------------------------------------------------
CREATE TABLE Customers (
	peopleId	text	not null	references People(peopleId),
   primary key(peopleId)
);

-- ----------------------------------------------------------------------------------------
-- Addresses                                                                             --
-- This table keeps track of the addresses of all People.                                --
-- ----------------------------------------------------------------------------------------
CREATE TABLE Addresses (
	peopleId	text	not null	references People(peopleId),
	addressId	text	not null,
	street1		text,
	street2		text,
	city		text,
	state		text,
	zip			text,	
   primary key(peopleId, addressId)
);

-- ----------------------------------------------------------------------------------------
-- Products                                                                              --
-- This table tracks current product information.                                        --
-- ----------------------------------------------------------------------------------------
CREATE TABLE Products (
	vdrProdId	text	not null	unique,	
	vendorId	text	not null	references Vendors(vendorId),
	Type		text,
	Name	   	text,
	Size		text,
	Color		text,
	Qty		int 		 CHECK (Qty >= 0),        
				-- # of items, might be sold singly, by the dozen, etc
	currentCostUSD		numeric(6,2) CHECK (currentCostUSD > 0),
	prodDesc			text,
   primary key(vdrProdId, vendorId)
);

-- -- -------------------------------------------------------------------------------------
-- ProductHistory                                                                        --
-- This table tracks the history of products: ID, cost when bought, date bought.         --
-- ----------------------------------------------------------------------------------------
CREATE TABLE ProductHistory (
	vdrProdId		text			references Products(vdrProdId),
	historyCostUSD		numeric(6,2)	not null 	CHECK (historyCostUSD > 0),
	dateBought			date 			not null,
   primary key(vdrProdId, historyCostUSD, dateBought)
);

-- ----------------------------------------------------------------------------------------
-- Arrangements                                                                          --
-- This table tracks arrangements:  ID, name, cost, and category.                        --
-- category can be any holiday, birthday, birth of a child, thank you, etc               --
-- ----------------------------------------------------------------------------------------
CREATE TABLE Arrangements(
	arrId		text			not null,
	arrName		text			not null,
	arrCostUSD	numeric	(6,2)	not null 	CHECK (arrCostUSD > 0),
	category	text			not null,
   primary key(arrId)
);

-- ----------------------------------------------------------------------------------------
-- ArrangementItems                                                                      --
-- This table gives a list of items that can be used in an arrangement.                  --
-- ----------------------------------------------------------------------------------------
CREATE TABLE ArrangementItems(
	itemId		text	not null,
	itemName	text	not null,
   primary key(itemId)
);

-- ----------------------------------------------------------------------------------------
-- ArrangementItemsList                                                                  --
-- This table brings together the arrangement and arrangementItems tables giving         --
-- the number of each item to be used in each arrangement.                               --
-- ----------------------------------------------------------------------------------------
CREATE TABLE ArrangementItemsList(
	arrId		text	not null	references Arrangements(arrId),
	itemId		text	not null	references ArrangementItems(itemId),
	itemQty		int		not null 	CHECK (itemQty >= 0),
   primary key(arrId, itemId, itemQty)
);

-- ----------------------------------------------------------------------------------------
-- Inventory                                                                             --
-- This table is a list of how many of each item the company has on hand.                --
-- ----------------------------------------------------------------------------------------
CREATE TABLE Inventory (
	vdrProdId		text	references Products(vdrProdId),
	itemId				text	references ArrangementItems(itemId),
	invQty				int   	CHECK (invQty >= 0),
   primary key(vdrProdId, itemId)
);

-- ----------------------------------------------------------------------------------------
-- Orders                                                                                --
-- This table is a list of orders of arrangements from the Customer                      --
-- ----------------------------------------------------------------------------------------
CREATE TABLE Orders (
	peopleId			text	references People(peopleId),
	arrId				text	references Arrangements(arrId),
	orderDate			date	CHECK (orderDate <= deliveryDate),   
	deliveryDate	    date	CHECK (deliveryDate >= orderDate),
	deliveryName		text,
	deliveryStreet1		text,
	deliveryStreet2		text,
	deliveryCity		text,
	customerPhone		text,
	deliveryPhone		text,
	cardScript			text	not null,		-- what to write on card
	specInstruct		text	not null DEFAULT 'none',-- special instructions for delivery
	primary key(peopleId, arrId, orderDate, deliveryDate, deliveryName)
);

-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- INSERT SAMPLE DATA                                                                    --
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

INSERT INTO People(peopleId, firstName, lastName, phone, phoneType, email)
	VALUES('people001', 'John', 'Dolan', '800-827-3665', 'work', 'floralsupply.com'),
	      ('people002', 'Michael', 'Growski', '800-773-2554', 'work', 'directfloral.com'),
		  ('people003', 'Jessica', 'Murray', '877-701-7673 - ext 5465', 'work', 'globalrose.com'),
		  ('people004', 'Jon', 'Sitzer', '845-555-5555', 'home', 'jon.sitzer34@yahoo.com'),
		  ('people005', 'Marisa', 'Sumter', '845-666-6666', 'cell', NULL),
		  ('people006', 'Mandy', 'Mishra', '845-777-7777', 'home', 'mmishra456@gmail.com'),
		  ('people011', 'Gary', 'Carney', '845-222-2222', 'home', 'gary.carney@net10.com'),
		  ('people008', 'Janice', 'Jones', '845-111-1111', 'home', 'janicejones58@yahoo.com'),
		  ('people009', 'Jane', 'Doe', '845-555-2323', 'cell', 'Jd2456@gmail.com'),
	      ('people010', 'Mary', 'Marist', '914-555-1212', 'cell', 'mmarist6486@marist.edu'),
		  ('people007', 'Alan', 'Labouseur', '845-440-1102', 'work', 'alan@labouseur.com'),
		  ('people012', 'Candie', 'Kane', '846-555-4545', 'home', 'candie.kane22@outlook.com');

INSERT INTO Vendors(vendorId, vendorName)
	VALUES ('vendor001', 'Floral Supply Wholesale'),
	       ('vendor002', 'DirectFloral.com'),
		   ('vendor003', 'GlobalRose.com'),
		   ('vendor004', 'Flowers by Alan');
		  
INSERT INTO VendorContacts(peopleId, vendorId)
	VALUES('people001', 'vendor001'),
	      ('people002', 'vendor002'),
		  ('people003', 'vendor003');
		  
INSERT INTO Staff(peopleId, dateHired, hiredPosition, dateLeft, currentPosition, cellPhone)
	VALUES('people004', '05/12/2007', 'salesclerk', NULL, 'manager', '914-555-5555'),
		  ('people005', '02/23/2015', 'salesclerk', NULL, 'salesclerk', '914-666-6666'),
		  ('people006', '01/01/2016', 'salesclerk', NULL, 'arranger', '914-777-7777'),
		  ('people011', '05/12/2007', 'owner', NULL, 'owner', '914-222-2222'),
		  ('people008', '05/12/2007', 'salesclerk', '07/30/2007', 'salesclerk', '914-111-1111');

INSERT INTO Customers(peopleId)
	VALUES('people009'),
	      ('people010'),
	      ('people007'),
	      ('people012');
		  
INSERT INTO Addresses(peopleId, addressId, street1, street2, city, state, zip)
	VALUES('people001', 'address001', NULL, '15 Applewood Drive', 'Fruit Heights', 'Utah', '84037'),
	      ('people002', 'address002', NULL, '760 Killian Road', 'Akron', 'Ohio', '44319'),
		  ('people003', 'address003', NULL, '7225 NW 25th Street', 'Miami', 'Florida', '33122'),
		  ('people004', 'address004', NULL, '456 Mantle Circle', 'Poughkeepsie', 'New York', '12601'),
		  ('people005', 'address005', NULL, '23 Alamo Road', 'Rhinebeck', 'New York', '12572-1234'),
		  ('people006', 'address006', 'Royal Crest Apartments', '22B Royal Crest Place', 'Hyde Park', 
			'New York', '12538-2256'),
		  ('people007', 'address007', 'Park Manor Apartments', '4568 Springwood Drive', 'Hyde Park', 
			'New York', '12538-4568'),
		  ('people008', 'address008', NULL, '45 Zachary Way', 'Poughkeepsie', 'New York',  '12602-4545'),
		  ('people009', 'address009', 'Cherry Condominiums', '21 Cherry Hill Road', 'Red Hook', 'New York', '12571'),
	          ('people010', 'address010', NULL, '62 Hilltop Road', 'Rhinecliff', 'New York', '12573'), 
		  ('people011', 'address011', NULL, '86B Church Street', 'Poughkeepsie', 'New York', '12602'),		  
		  ('people012', 'address012', NULL, '91-28B Main Street', 'Beacon', 'New York', '12508-1928');
		  
INSERT INTO Products(vdrProdId, vendorId, Type, Name, Size, Color, Qty, currentCostUSD, prodDesc)
	VALUES('G10026B2', 'vendor003', 'flower', 'rose', 'long stem', 'lavender', 12, 7, NULL),
	      ('C56736', 'vendor001', 'container', 'country metal pail', '6 inches tall', 'off white', 5, 12, NULL),
	      ('N674DDA', 'vendor002', 'flower', 'alstroemeria', NULL, 'white', 6, 4.50, NULL),
              ('N673GST', 'vendor002', 'flower', 'statice', NULL, 'white',  6, 3, NULL),
		  ('N675GHF', 'vendor002', 'flower', 'daisy', NULL, 'yellow', 12, 12, NULL),
		  ('S97854', 'vendor001',  'other', 'floral foam', '9in long x 4.5in wide x 3in high', 'green', 48, 25, 
					'dry brick'),
		  ('S97657', 'vendor001', 'other', 'floral tape', '110yds long x 1in wide', 'green', 6, 6.75, 'rolls'),
		  ('C56765', 'vendor001', 'container', 'its a boy wagon', '9in long x 4in wide x 4in high', 'red', 1, 9.99, 
		            'good for plant or arrangement'),
		  ('C56766', 'vendor001', 'container', 'its a girl wagon', '9in long x 4in wide x 4in high', 'red', 1, 9.99, 
		            'good for plant or arrangement'),		
		  ('G10027C3', 'vendor003', 'flower', 'rose', 'spray', 'yellow', 8, 15, '3 - 5 roses on each spray'),
		  ('N67454C3', 'vendor003', 'flower', 'gerbera', 'mini', 'red', 12, 6, NULL),
		  ('N67454G5', 'vendor003', 'flower', 'aster', NULL, 'red', 6, 9, NULL),
		  ('N675GHG', 'vendor002', 'flower', 'daisy', NULL, 'white', 12, 12, NULL),
		  ('G87463', 'vendor001', 'greenery', 'leather leaf', NULL, 'green', 100, 76, 'stems'),
		  ('G87465', 'vendor001', 'greenery', 'huckleberry', NULL, 'green', 1, 15.75, 'bunch'),
		  ('N697BHG', 'vendor002', 'flower', 'mum', 'button', 'white', 4, 3, 'spray with 4 - 5 buttons'),
		  ('N697BHR', 'vendor002', 'flower', 'mum', 'button', 'green', 4, 3, 'spray with 4 - 5 buttons'),
		  ('G10026BG', 'vendor003', 'flower', 'rose', NULL, 'orange', 4, 10, NULL), 
		  ('C78457', 'vendor001', 'container', 'vase', '7in tall', 'cobalt blue', 4, 12, NULL),
		  ('C97485', 'vendor001', 'balloon', 'balloon', 'mylar', 'silver and mixed', 25, 12.5, 'colorful HappyBirthday'),
		  ('F87467G5', 'vendor003', 'flower', 'carnation', NULL, 'red', 12, 6, NULL),
		  ('N986GKB', 'vendor002', 'flower', 'soldago', NULL, 'white', 1, 3, 'bunch'),
		  ('C86397', 'vendor001', 'container', 'vase', '5in tall', 'clear with lady bugs', 5, 15, NULL);	

INSERT INTO ProductHistory(vdrProdId, historyCostUSD, dateBought)	
	VALUES('G10026BG', 10, '02/02/16'),
		  ('C78457', 12, '02/02/16'),
	      ('N67454C3', 5, '02/02/16'),
		  ('C97485', 6, '02/02/16'),
		  ('G87465', 13.50, '02/02/16'),
		  ('S97657', 5.75, '02/02/16'),
		  ('N674DDA', 6, '02/02/16'),		  
		  ('N67454G5', 8.25, '02/15/16'),
		  ('C56736', 12, '02/15/16'),
		  ('S97854', 23, '02/15/16'),
		  ('N673GST', 3, '02/15/16'),
		  ('N675GHF', 12, '02/15/16'),	
	      ('F87467G5', 6, '05/11/16'),
		  ('G10027C3', 13, '05/11/16'),
		  ('N986GKB', 3, '05/11/16'),
		  ('C86397', 15, '05/11/16'),
		  ('N67454G5', 8.50, '06/15/16'),		  
		  ('G87463', 69, '06/15/16'),
		  ('G87465', 14.50, '06/15/16'),		  
		  ('G10026B2', 6.50, '08/11/16'),
		  ('G10027C3', 15, '09/02/16'),
		  ('G87463', 72, '09/02/16'),
		  ('S97657', 5.75, '09/02/16'),
		  ('S97854', 25, '09/02/16'),
		  ('N674DDA', 6, '09/02/16'),		  
		  ('G10026B2', 6.75, '11/11/16'),
		  ('G10027C3', 15, '11/11/16'),
		  ('N67454C3', 6, '11/11/16'),
		  ('N67454G5', 9, '11/15/16'),
		  ('G87463', 74, '12/02/16'),
		  ('C56736', 12, '12/02/16'),
		  ('N697BHG', 3, '12/02/16'),
		  ('N697BHR', 3, '12/02/16'),		  
		  ('G10026B2', 7, '04/12/17'),
		  ('G10027C3', 15, '04/12/17'),
		  ('N675GHG', 12, '04/12/17'),
		  ('G87463', 76, '04/12/17'),
		  ('G10026B2', 10, '04/12/17'),
		  ('G87465', 15.75, '04/12/17'),
		  ('C56765', 9.99, '04/12/17'),
		  ('C56766', 9.99, '04/12/17'),
		  ('S97657', 5.75, '04/12/17'),
		  ('S97854', 25, '04/12/17');
		  
INSERT INTO Arrangements(arrId, arrName, arrCostUSD, category)
	VALUES('arr001', 'Blooming Pail', 50, 'Spring'),
		  ('arr002', 'Wow Wagon - boy', 43, 'baby boy'),
		  ('arr003', 'Wow Wagon - girl', 43, 'baby girl'),
		  ('arr004', 'Fly Away Labouseur', 53, 'birthday'),
		  ('arr005', 'lovely Ladybug Bouquet', 40, 'general');
		  
INSERT INTO ArrangementItems(itemId, itemName)
	VALUES('item001', 'Country Metal Pail by Alan'),
	      ('item002', 'Lavender Roses'),
		  ('item003', 'Alstroemeria'),
		  ('item004', 'Statice'),
		  ('item005', 'Yellow Daisies'),
		  ('item006', 'Floral Foam'),
		  ('item007', 'Floral tape'),
		  ('item008', 'Its a Boy Red Wagon'),
		  ('item009', 'Yellow Spray Roses'),
		  ('item010', 'Red Mini Gerbera'),
		  ('item011', 'Asters'),
		  ('item012', 'White Daisies'),
		  ('item013', 'White Button Mums'),
		  ('item014', 'Soldago'),
		  ('item015', 'Greenery'),
		  ('item016', 'Its a Girl Red Wagon'),
		  ('item017', 'Cobalt blue vase - 8 inch'),
		  ('item018', 'Mylar Happy Birthday balloon'),
		  ('item019', 'Orange Roses'),
		  ('item020', 'Red Carnations'),
		  ('item021', 'Clear vase with ladybugs - 7inch'),
		  ('item022', 'Green button mums'),
		  ('item023', 'Huckleberry greens');
		  
INSERT INTO ArrangementItemsList(arrId, itemId, itemQty)
	VALUES('arr001', 'item001', 1),
	      ('arr001', 'item002', 8),
		  ('arr001', 'item003', 5),
		  ('arr001', 'item004', 6),
		  ('arr001', 'item005', 5),
	      ('arr001', 'item006', 1),
		  ('arr001', 'item007', 1),
		  ('arr001', 'item015', 4),
		  ('arr002', 'item005', 3),
	      ('arr002', 'item006', 1),
		  ('arr002', 'item007', 1),
		  ('arr002', 'item016', 1),
		  ('arr002', 'item009', 2),
	      ('arr002', 'item010', 3),
		  ('arr002', 'item011', 2),
		  ('arr002', 'item012', 3),
		  ('arr002', 'item013', 2),
	      ('arr002', 'item014', 4),
		  ('arr002', 'item015', 4),
		  ('arr003', 'item005', 3),
	      ('arr003', 'item006', 1),
		  ('arr003', 'item007', 1),
		  ('arr003', 'item008', 1),
		  ('arr003', 'item009', 2),
	      ('arr003', 'item010', 3),
		  ('arr003', 'item011', 2),
		  ('arr003', 'item012', 3),
		  ('arr003', 'item013', 2),
	      ('arr003', 'item014', 4),
		  ('arr003', 'item015', 4),
		  ('arr004', 'item017', 1),
		  ('arr004', 'item018', 1),
		  ('arr004', 'item019', 6),
		  ('arr004', 'item003', 6),
		  ('arr004', 'item020', 4),
		  ('arr004', 'item005', 6),
		  ('arr004', 'item004', 5),
		  ('arr004', 'item015', 4),
		  ('arr004', 'item006', 1),
		  ('arr004', 'item007', 1),
		  ('arr005', 'item021', 1),
		  ('arr005', 'item010', 4),
		  ('arr005', 'item003', 5),
		  ('arr005', 'item020', 2),
		  ('arr005', 'item012', 6),
		  ('arr005', 'item022', 2),
		  ('arr005', 'item023', 5);
		  
INSERT INTO Inventory(vdrProdId, itemId, invQty)
	VALUES('G10026B2', 'item002', 10),
	      ('C56736', 'item001', 4),
		  ('N674DDA', 'item003', 0),
		  ('N673GST', 'item004', 0),
		  ('N675GHF', 'item005', 10),
		  ('S97854', 'item006', 45),
		  ('S97657', 'item007', 6),
		  ('C56765', 'item008', 1),
		  ('C56766', 'item016', 1),		
		  ('G10027C3', 'item009', 6),
		  ('N67454C3', 'item010', 5),
		  ('N67454G5', 'item011', 2),
		  ('N675GHG', 'item012', 6),
		  ('G87463', 'item015', 52),
		  ('G87465', 'item023', 0),
		  ('N697BHG', 'item013', 20),
		  ('N697BHR', 'item022', 0),
		  ('G10026BG', 'item019', 0), 
		  ('C78457', 'item017', 2),
		  ('C97485', 'item018', 21),
		  ('F87467G5', 'item020', 0),
		  ('N986GKB', 'item014', 6),
		  ('C86397', 'item021', 3);
		  
INSERT INTO Orders(peopleId, arrId, orderDate, deliveryDate, deliveryName, deliveryStreet1, 
				   deliveryStreet2, deliverycity, customerPhone, deliveryPhone, cardScript, 
				   specInstruct)
	VALUES('people009', 'arr004', '04/21/2017', '04/22/2017', 'Jodi Walker', 
		   'Park Condos', '78 Eastwood Drive', 'Hyde Park',  '845-632-5896', '914-258-3571',
		   'Jodi - Have a Wonderful BIrthday.  We love you, Grammy and Poppy', 'none');
		  
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- VIEWS                                                                                 --
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------
-- VendorInfo - View to obtain information from our Vendors and VendorContacts,          --
-- Including their basic information from People and Addresses (has two reports)         --
-- ----------------------------------------------------------------------------------------
CREATE VIEW VendorInfo
AS
SELECT v.vendorId, v.vendorName, vc.peopleId, p.firstName, p.lastName, p.phone,
	   p.phoneType, p.email, addressID, a.street1, a.street2, a.city, a.state , a.zip
FROM Vendors v, 
     VendorContacts vc,
	 People p,
	 Addresses a
WHERE v.vendorId = vc.vendorId and
      vc.peopleId = p.peopleId and
	  p.peopleId = a.peopleId 
ORDER BY v.vendorId ASC;

-- ----------------------------------------------------------------------------------------
-- VendorInfo - View Report 1 - lists all information contained in VendorInfo            --
-- ----------------------------------------------------------------------------------------	  
SELECT * FROM VendorInfo;

-- ----------------------------------------------------------------------------------------
-- VendorInfo - View Report 2 - search VendorInfor for vendorName with only part of it   --
-- ----------------------------------------------------------------------------------------      
SELECT vendorId, vendorName, firstName, LastName, phone, email
FROM VendorInfo
WHERE vendorName Like '%Rose%';
	  
-- ----------------------------------------------------------------------------------------
-- StaffInfo - View to obtain information about our Staff                                --
-- Including their basic information from People and Addresses (has four reports)        --
-- ----------------------------------------------------------------------------------------
CREATE VIEW StaffInfo
AS
SELECT s.peopleId, s.dateHired, s.hiredPosition, s.dateLeft, s.currentPosition, s.cellPhone,
       p.firstName, p.lastName, p.phone, p.phoneType, p.email, a.addressId, a.street1, a.street2, a.city, 
	   a.state, a.zip
FROM Staff s,
	 People p,
	 Addresses a
WHERE s.peopleId = p.peopleId and
	  p.peopleId = a.peopleId 
ORDER BY s.peopleId ASC;

-- ----------------------------------------------------------------------------------------
-- StaffInfo - View Report 1 - lists all information contained in StaffInfo              --
-- ----------------------------------------------------------------------------------------   	  
SELECT * FROM StaffInfo;

-- ----------------------------------------------------------------------------------------
-- StaffInfo - View Report 2 - search for Staff when you only know part of the first name--
-- list staff info for first names that have the letters 'ma' in it                      --
-- ---------------------------------------------------------------------------------------- 
SELECT firstName, LastName, cellPhone, phone, phoneType, email
FROM StaffInfo
WHERE firstName Like 'Ma%'
ORDER BY firstName DESC;

-- ----------------------------------------------------------------------------------------
-- StaffInfo - View Report 3 - obtain list of all current Staff                          --
-- ----------------------------------------------------------------------------------------
SELECT firstName, LastName, dateHired, hiredPosition, currentPosition
FROM StaffInfo
WHERE dateLeft is Null
ORDER BY dateHired DESC;

-- ----------------------------------------------------------------------------------------
-- StaffInfo - View Report 4 - obtain list of all Staff who are no longer with the Company-
-- ----------------------------------------------------------------------------------------
SELECT firstName, LastName, dateHired, hiredPosition, currentPosition
FROM StaffInfo
WHERE dateLeft is not Null;

-- ----------------------------------------------------------------------------------------
-- CustomerInfo - View to obtain information about our Customers                         --
-- Including their basic information from People and Addresses (has two reports)         --
-- ----------------------------------------------------------------------------------------
CREATE VIEW CustomerInfo
AS
SELECT c.peopleId, p.firstName, p.lastName, p.phone, p.phoneType, p.email, a.addressId, a.street1, 
	   a.street2, a.city, a.state, a.zip
FROM Customers c,
	 People p,
	 Addresses a
WHERE c.peopleId = p.peopleId and
	  p.peopleId = a.peopleId 
ORDER BY c.peopleId ASC;

-- ----------------------------------------------------------------------------------------
-- CustomerInfo - View Report 1 - obtain list of all Customers with basic information    --
-- from People and Addresses                                                             --
-- ----------------------------------------------------------------------------------------	  
SELECT * FROM CustomerInfo;

-- ----------------------------------------------------------------------------------------
-- CustomerInfo - View Report 2 - customers by city                                      --
-- list cities that start with R                                                         --
-- ----------------------------------------------------------------------------------------
SELECT firstName, LastName, phone, phoneType, email, city
FROM CUSTOMERINFO
where city Like 'R%';

-- ----------------------------------------------------------------------------------------
-- ProductInfo - obtain list of Vendors, and products (past and current information)     --
-- Has 2 reports                                                                         --
-- ----------------------------------------------------------------------------------------
CREATE VIEW ProductInfo
AS	  
SELECT c.vendorId, c.vendorName, h.vdrProdId, p.Type, p.Name, p.Size, p.Color, p.Qty, 
	   p.currentCostUSD, p.prodDesc, h.dateBought,h.historyCostUSD
FROM Vendors c,
     Products p,
	 ProductHistory h
WHERE c.vendorId = p.vendorId and
      p.vdrProdId = h.vdrProdId;
	  
-- ----------------------------------------------------------------------------------------
-- ProductInfo - View Report 1 - All the information in ProductInfo                      --
-- ----------------------------------------------------------------------------------------
SELECT * from ProductInfo;

-- ----------------------------------------------------------------------------------------
-- ProductInfo - View Report 2 - List of History of cost and current cost for each product-                                           --
-- ----------------------------------------------------------------------------------------
SELECT vdrProdId, Name, Size, Qty, currentCostUSD, dateBought, historyCostUSD
FROM ProductInfo
ORDER BY vdrProdId, dateBought;

-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- STORED PROCEDURES                                                                     --
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------
-- GetArrListofItems - Stored Procedure - enter arrId                                    --
-- To obtain a list of items and quantities of each for that arrangement                 --
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION GetArrListofItems(TEXT, REFCURSOR) RETURNS refcursor AS
$$
DECLARE
	arrIdEntered TEXT		:= $1;
	resultset	 REFCURSOR	:= $2;
BEGIN
	OPEN resultset FOR
	  SELECT a.arrId, p.itemId, p.itemName, apl.itemQty
      FROM Arrangements a INNER JOIN ArrangementItemsList apl ON a.arrId = apl.arrId
                          INNER JOIN ArrangementItems p ON apl.itemId = p.itemId
	  WHERE a.arrId = arrIdEntered
	  ORDER BY p.itemId ASC;
	RETURN resultset;
END;
$$
LANGUAGE plpgsql;

SELECT GetArrListofItems('arr002', 'results');
FETCH all FROM results;

-- ----------------------------------------------------------------------------------------
-- GetProductOrderList - Stored Procedure - enter arrId                                  -- 
-- Receive an order for an arrangement -- obtain a list of items that need to be ordered --
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION GetProductOrderList(TEXT, REFCURSOR) RETURNS refcursor AS
$$
DECLARE
	arrIdEntered TEXT		:= $1;
	resultset	 REFCURSOR	:= $2;
BEGIN
	OPEN resultset FOR
		SELECT i.itemId, ail.itemQty, i.invQty, i.vdrProdID, v.vendorName,
		pe.firstName, pe.lastName, pe.phone
		FROM Inventory i INNER JOIN ArrangementItems ai ON i.itemId = ai.itemId
                         INNER JOIN ArrangementItemsList ail ON ail.itemId = ai.itemId
					     INNER JOIN Arrangements a ON ail.arrId = a.arrId
					     INNER JOIN Products pr ON i.vdrProdId = pr.vdrProdId
					     INNER JOIN Vendors v ON pr.vendorID = v.vendorId
					     INNER JOIN VendorContacts vc ON v.vendorId = vc.vendorId
					     INNER JOIN People pe ON vc.peopleId = pe.peopleId
	  WHERE a.arrId = arrIdEntered and i.invQty <= ail.itemQty 
	  ORDER BY i.itemId ASC;
	RETURN resultset;
END;
$$
LANGUAGE plpgsql;

SELECT GetProductOrderList('arr002', 'results2');
FETCH all FROM results2;

-- ----------------------------------------------------------------------------------------
-- AddPeople - Stored Procedure                                                          -- 
-- enter select addPeople(all info with NULL for data not needed);                       -- 
-- procedure then adds people and address information, and uses IF statements to decide  --
-- whether to enter Staff or Customer or VendorContact information                       --
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION AddPeople
	(peopleType text, peopleId text, firstName text, lastName text, phone text, 
		phoneType phone, email text, addressId text, street1 text, street2 text, city text, state text, 
		zip text, dateHired date, hiredPosition pos, dateLeft date, currentPosition pos, 
		cellPhone text, vendorId text)
RETURNS void AS
$$
BEGIN
	INSERT INTO People 
		VALUES (peopleId, firstName, lastName, phone, phoneType, email);
	INSERT INTO addresses
		VALUES(peopleId, addressId, street1, street2, city, state, zip);	
		
	IF peopleType = 'S' THEN
		INSERT INTO Staff
			VALUES(peopleId, dateHired, hiredPosition, dateLeft, currentPosition, 
				   cellPhone);
	END IF;
	
	IF peopleType = 'C' THEN
		INSERT INTO Customers
			VALUES(peopleId);
	END IF;
	
	IF peopleType = 'V' THEN
		INSERT INTO  VendorContacts
			VALUES(peopleId, vendorId);
	END IF;
END
$$
LANGUAGE plpgsql;

-- TEST DATA:
Select AddPeople('S','people013', 'Kathy', 'Coomes', '555-555-5555', 'cell', 
	            'kathy.coomes@marist.edu', 'addressId', NULL, '19 Church Street', 'Red Hook', 
				'New York', '12571', '04/30/2017', 'arranger', NULL, 'arranger', 
				'555-555-5555', NULL);
select * from StaffInfo;

Select AddPeople('C','people014', 'Jennie', 'Masters', '555-555-5555', 'home', 
	            'jennie3456@gmail.com',	'address014', NULL, '100 Main Street', 'Rhinecliff', 
				'New York', '12573', NULL, NULL, NULL, NULL, NULL, NULL);
SELECT * FROM CustomerInfo;

Select AddPeople('V', 'people025', 'George', 'Baker', '555-555-5555', 'work', 
				'george@directfloral.com', 'address025', NULL, '3657 Floral Drive', 'Pleasant Valley', 
				'New York', '12569', NULL, NULL, NULL, NULL, NULL, 'vendor002');
SELECT * FROM VendorInfo;
                                                          
-- ----------------------------------------------------------------------------------------
-- AddVendor - Stored Procedure                                                          -- 
-- enter select AddVendor(all info with NULL for data not needed)                        --   
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION AddVendor
	(vendorId text, vendorName text)
RETURNS void AS
$$
BEGIN
	INSERT INTO Vendors
		VALUES (vendorId, vendorName);
END
$$
LANGUAGE plpgsql;

-- Test Data:
SELECT AddVendor('vendor005', 'Florist ExtraOrdinary');
SELECT * FROM Vendors;

-- ----------------------------------------------------------------------------------------
-- AddProducts - Stored Procedure                                                        -- 
-- adds information to Products, ProductHistory and Inventory                            --
-- once a Product order has been received -- updates or inserts new                      --
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION AddProducts
	(productNew text, newVdrProdId text, vendorId text, newType text, 
	newName text, newSize text, newColor text, newQty int, 
	newCurrentCostUSD numeric, newprodDesc text, historyCostUSD numeric, 
	dateBought date, newItemId text, NewItemName text, newInvQty int)
RETURNS void AS
$$
BEGIN		
	IF productNew = 'Y' THEN
		INSERT INTO Products 
			VALUES (newVdrProdId, vendorId, newType, newName, newSize, newColor, 
				newQty, newCurrentCostUSD, newprodDesc);
		INSERT INTO ArrangementItems
			VALUES (newItemId, newItemName);
		INSERT INTO Inventory
			VALUES(newVdrProdId, newItemId, newInvQty);
		INSERT INTO ProductHistory
			VALUES(newVdrProdId, historyCostUSD, dateBought);	
	END IF;
	IF productNew = 'N' THEN
		UPDATE Products SET 
			Type = newType,
			Name = newName,
			Size = newSize,
			Color = newColor,
			Qty = newQty,
			currentCostUSD = newCurrentCostUSD,
			prodDesc = newprodDesc
			WHERE vdrProdId = newVdrProdId;
		INSERT INTO ProductHistory
			VALUES(newVdrProdId, historyCostUSD, dateBought);	
		UPDATE Inventory SET
			invQty = invQty + newInvQty
			WHERE vdrProdId = newVdrProdId and itemId = newItemId;
	END IF;			
END
$$
LANGUAGE plpgsql;

-- TEST DATA:
SELECT AddProducts('Y', 'G10026BH', 'vendor003', 'flower', 'rose', 'long stem', 
				   'red', 12, 15, NULL, 15, '04/30/2017', 'item034', 'red roses', 12);
SELECT * FROM Products;
SELECT * FROM ProductHistory;
SELECT * from Inventory;
SELECT * FROM ArrangementItems;

SELECT AddProducts('N', 'G10026B2', 'vendor003', 'flower', 'rose', 'long stem',
				   'lavender', 12, 15, NULL, 15, '04/30/2017', 'item002', 
				   'lavender roses', 12);
SELECT * FROM Products;
SELECT * FROM ProductHistory;
SELECT * from inventory;

-- ----------------------------------------------------------------------------------------
-- FindAlan queries using Stored Procedure search_columns                                --																
-- Finds Alan or Labouseur anywhere in the database                                      --
--                                                                                       --
--            Stored Procedure search_columns Created by Daniel Verite                   --                                            
--             Shared on Stack Overflow on 4/12/2014 under the title                     --
--          'How to search a specific value in all tables (PostgreSQL)?'                 --
--                       works in version 9.1 or newer                                   --
--                                                                                       --
-- He stated:  "Here is a pl/pgsqlfunction that locates records where any column contains-- 
-- a specific -- value.  It takes as arguments the value to search in text format, an    --
-- array of table names to search into (defaults to all tables) and an array of schema   --
-- names (public by default.  It returns a table structure with schema, name of table,   --
-- name of column and pseudo-column ctid (non-durable physical location of the row in    --
-- the table."                                                                           --
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION search_columns(
    needle text,
    haystack_tables name[] default '{}',
    haystack_schema name[] default '{public}'
)
RETURNS table(schemaname text, tablename text, columnname text, rowctid text)
AS $$
begin
  FOR schemaname,tablename,columnname IN
      SELECT c.table_schema,c.table_name,c.column_name
      FROM information_schema.columns c
      JOIN information_schema.tables t ON
        (t.table_name=c.table_name AND t.table_schema=c.table_schema)
      WHERE (c.table_name=ANY(haystack_tables) OR haystack_tables='{}')
        AND c.table_schema=ANY(haystack_schema)
        AND t.table_type='BASE TABLE'
  LOOP
    EXECUTE format('SELECT ctid FROM %I.%I WHERE cast(%I as text)=%L',
       schemaname,
       tablename,
       columnname,
       needle
    ) INTO rowctid;
    IF rowctid is not null THEN
      RETURN NEXT;
    END IF;
 END LOOP;
END;
$$ language plpgsql;

SELECT * FROM search_columns('Alan');
SELECT * FROM search_columns('Labouseur');

-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------
-- TRIGGERS                                                                              --
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------
-- validPeopleInput - Trigger  - triggers on insert or update of the People table        --                                                           -- 
-- ValidatePeopleInput - Stored Procedure - raises exception if first or last name is NULL
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ValidatePeopleInput()
RETURNS TRIGGER AS
$$
BEGIN
	IF NEW.firstName IS NULL THEN
		RAISE EXCEPTION 'firstName may not be NULL';
	END IF;	
	IF NEW.lastName IS NULL THEN
		RAISE EXCEPTION 'lastName may not be NULL';
	END IF;
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER validPeopleInput
BEFORE INSERT OR UPDATE ON People
FOR EACH ROW
EXECUTE PROCEDURE ValidatePeopleInput();

-- Test Data
-- INSERT INTO People (peopleId, firstName, lastName)
--		VALUES('people013', NULL, NULL);
-- INSERT INTO People (peopleId, firstName, lastName)
--		VALUES('people013', 'Joyce', NULL);

-- ----------------------------------------------------------------------------------------
-- validVendorInput - Trigger  - triggers on insert or update of the Vendor table        --                                                           -- 
-- ValidateVendorInput - Stored Procedure - raises exception if vendorId or vendorName is NULL
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ValidateVendorInput()
RETURNS TRIGGER AS
$$
BEGIN
	IF NEW.vendorId IS NULL THEN
		RAISE EXCEPTION 'vendorId may not be NULL';
	END IF;	
	IF NEW.vendorName IS NULL THEN
		RAISE EXCEPTION 'vendorName may not be NULL';
	END IF;
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER ValidVendorInput
BEFORE INSERT OR UPDATE ON Vendors
FOR EACH ROW
EXECUTE PROCEDURE ValidateVendorInput();

-- Test Data
-- INSERT INTO Vendors (vendorId, vendorName)
--		VALUES(NULL, 'LabouseursPlace');
-- INSERT INTO Vendors (vendorId, vendorName)
--		VALUES('vendor234', NULL);
	
-- ----------------------------------------------------------------------------------------	  
-- ----------------------------------------------------------------------------------------
-- REPORTS                                                                               --
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------
-- Reports that list all from each of the tables.                                        --         
-- ----------------------------------------------------------------------------------------

SELECT * FROM People;
SELECT * FROM Vendors;
SELECT * FROM VendorContacts;
SELECT * FROM Staff;
SELECT * FROM Customers;
SELECT * FROM Addresses;
SELECT * FROM Products;
SELECT * FROM ProductHistory;
SELECT * FROM Arrangements;
SELECT * FROM ArrangementItems;
SELECT * FROM ArrangementItemsList;
SELECT * FROM Inventory;

-- ----------------------------------------------------------------------------------------
-- ListArrItems Report                                                                   --
-- Report to obtain a list of items needed for an arrangement.                           --
-- ----------------------------------------------------------------------------------------

SELECT a.arrId, p.itemId, p.itemName, apl.itemQty
FROM Arrangements a INNER JOIN ArrangementItemsList apl ON a.arrId = apl.arrId
                    INNER JOIN ArrangementItems p ON apl.itemId = p.itemId
WHERE a.arrId = 'arr001'
ORDER BY p.itemId ASC;

-- ----------------------------------------------------------------------------------------
-- AddPeople Report - Calls the Stored Procedure AddPeople                               --
-- ----------------------------------------------------------------------------------------
-- Directions:  inside the parentheses below replace each item with actual data;
--	if you do not have any of the information type NULL with no quotes; 
-- 
-- example1:
-- SELECT AddPeople('peopleId', 'firstName', 'lastName', 'phone', 'phoneType'); 
-- example2:
-- SELECT AddPeople('peopleId', 'firstName', 'lastName', NULL, NULL); 

-- Use this below - remove the dashes first, replace the information
-- SELECT AddPeople('peopleId', 'firstName', 'lastName', 'phone', 'phoneType', 
--	'email', 'addressId', 'street1', 'street2', 'city', 'state', 'zip', dateHired, 
-- 'hiredPosition', 'dateLeft', 'currentPosition', 'cellPhone', 'vendorId');
			
-- ----------------------------------------------------------------------------------------
-- AddVendors Report - Calls the Stored Procedure AddVendors                             --
-- ----------------------------------------------------------------------------------------	
-- example:
-- Select AddVendor('vendor004', 'WonderlandFlorist.com');

-- Use this below - remove the dashes first, replace the information
-- SELECT AddPeople('vendorId', 'vendorName');

-- ----------------------------------------------------------------------------------------
-- AddProducts Report - Calls the Stored Procedure AddProducts                           --
-- ----------------------------------------------------------------------------------------	
--example1:
--SELECT AddProducts('Y', 'G10026BH', 'vendor003', 'flower', 'rose', 'long stem', 
	'red', 12, 15, NULL, 15, '04/30/2017', 'item034', 'red roses', 12);
--SELECT AddProducts('N', 'G10026B2', 'vendor003', 'flower', 'rose', 'long stem',
	'lavender', 12, 15, NULL, 15, '04/30/2017', 'item002', 'lavendsr roses', 12);

-- Use this below - remove the dashes first, replace the information
-- SELECT AddProducts('productNew', 'newVdrProdId', 'vendorId', 'newType', 'newName', 'newSize', 
-- 'newColor', 'newQty', 'newCurrentCostUSD', 'newprodDesc', 'historyCostUSD','dateBought', 'newItemId', 
-- 'newItemName', 'newInvQty');

-- ----------------------------------------------------------------------------------------
-- VendorNoContact Report - Finds Vendors who have no VendorContact                      --
-- ----------------------------------------------------------------------------------------
SELECT * 
FROM Vendors
WHERE vendorId not in 
	(SELECT	vendorId 
	 FROM VendorContacts
	)
ORDER BY vendorName;
	
-- -----------------------------------------------------------------------
-- VendorNoProducts Report - Finds Vendors who we have not ordered from  
-- -----------------------------------------------------------------------
SELECT * 
FROM Vendors
WHERE vendorId not in 
	(SELECT	vendorId 
	 FROM Products
	)
ORDER BY vendorName;

-- ----------------------------------------------------------------------------------------
-- VendorMostUsed Report - Finds Vendor who we order the most from                       --
-- ----------------------------------------------------------------------------------------
SELECT v.vendorId as "Vendor ID",
       v.vendorName as "Vendor Name",
	   count(v.vendorId) as "Product Orders Numbers"
FROM Vendors v INNER JOIN Products p ON v.vendorId = p.vendorId
               INNER JOIN ProductHistory ph ON p.vdrProdId = ph.vdrProdId
GROUP BY v.vendorId
ORDER BY count(v.vendorId) DESC
limit 1;

-- ----------------------------------------------------------------------------------------
-- FindVendorCity - Finds Vendors in a particular City                                   --
-- ----------------------------------------------------------------------------------------
SELECT v.vendorName as "Vendor Name"
FROM Vendors v
WHERE v.vendorId in
	(SELECT distinct vc.vendorId
	 FROM VendorContacts vc
	 WHERE vc.peopleId in
		(SELECT p.peopleId
		 FROM People p
		 WHERE p.peopleId in
			(SELECT a.peopleId
			 FROM Addresses a
			 WHERE a.city in ('Miami')
			 )
		)
	)
ORDER BY v.vendorName ASC;

-- ----------------------------------------------------------------------------------------
-- There are more reports attached to all the views and stored procedures                --
-- ----------------------------------------------------------------------------------------


--       Kathy L Coomes - CMPT 308 - Data Management - Instructor Alan Labouseur         --