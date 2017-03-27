-- ----------------------------------------------
-- Eon Movie Database
-- Let's find the NEW BOND
-- Created from specifications given in CMPT 308 (Lab 8) by instructor Alan Labouseur
-- Author Kathy Coomes March 25, 2017
-- ----------------------------------------------
-- People
-- ----------------------------------------------

CREATE TABLE People(
	peopleID	text    not null    unique,
	firstName	text 	not null,
	lastName	text,
	street		text	not null,
	city		text	not null,
	stateProvince	text	not null,
	country		text	not null,
	zip			text,
  primary key(peopleID)
);

-- ----------------------------------------------
-- Spouses
-- ----------------------------------------------
CREATE TABLE Spouses(
	peopleID	text	not null	references People(peopleID),
	spouseID	text	not null    unique,
	firstName   text,
    lastName    text,
	spouseNum   int,
   primary key(peopleID, spouseID) 
);

-- ----------------------------------------------
-- Movies
-- ----------------------------------------------
CREATE TABLE Movies(
	movieID		text	not null    unique,
	title		text	not null,
	yearReleased	int,
	mpaaNum			int,
	domesticBoxOfficeSalesUSD	numeric(9,0),
	foreignBoxOfficeSalesUSD	numeric(9,0),
	dvdBluRaySalesUSD			numeric(9,0),
   primary key(movieID)
);

-- ----------------------------------------------
-- Actors
-- ----------------------------------------------
CREATE TABLE Actors(
	peopleID	text	not null	references People(peopleID),
	actorID		text	not null    unique,
	birthDate	text,
	hairColor	text,
	eyeColor	text,
	heightInches	text,
	weightPounds	text,
	favColor	text,	
	sagDate		text,
   primary key(peopleID,actorID)
);

-- ----------------------------------------------
-- FilmSchools
-- ----------------------------------------------
CREATE TABLE FilmSchools(
	filmSchoolID	text	not null    unique,
	name			text,
   primary key(filmSchoolID)
);

-- ----------------------------------------------
-- Directors
-- ----------------------------------------------
CREATE TABLE Directors(
	peopleID	text	not null	references People(peopleID),
	directorID	text	not null    unique,	
	filmSchoolID	text			references FilmSchools(filmSchoolID),
	dgaDate		text,
	favLensMaker	text,
  primary key(peopleID, directorID)
);

-- ----------------------------------------------
-- MovieActors
-- ----------------------------------------------
CREATE TABLE MovieActors(
	actorID		text	not null	references Actors(actorID),
	movieID		text	not null	references Movies(movieID),
   primary key(actorID, movieID)
);
 
-- ----------------------------------------------
-- MovieDirectors
-- ----------------------------------------------
CREATE TABLE MovieDirectors(
	directorID	text	not null	references Directors(directorID),
	movieID		text	not null	references Movies(movieID),
   primary key(directorID, movieID)
);

-- ----------------------------------------------
INSERT INTO People (peopleID, firstName, lastName, street, city, stateProvince, country, zip )
	VALUES('p001','Sean', 'Connery', '10 Waterloo Place', 'Edinburgh', 'Scotland', 'United Kingdom', 'EH1 3BG'),
		  ('p002','Roger', 'Moore', '23 Trafalgar Square', 'London', 'England', 'United Kingdon', 'WC2N 5DU'),		  
		  ('p300', 'Guy', 'Hamilton', '662-Placa de Cort', 'Majorca', 'Balearic Islands', 'Spain', '07001'),
		  ('p301', 'Terence', 'Young', '768 Rue Jean de Riouffe', 'Cannes', 'Alpes-Maritimes', 'France', '06400'),
		  ('p302', 'Lewis', 'Gilbert', '16 Wimbledon Park', 'London', 'England', 'United Kingdom', 'WC2N 5DU'),
		  ('p303', 'John', 'Glen', '77 Thames Avenue', 'Sunbury-on-Thames', 'England', 'United Kingdom', 'TW16 7AR'),
		  ('p304', 'Irvin', 'Kershner', '123 Rodeo Drive', 'Los Angeles', 'California', 'USA', '90210'),
		  ('p305', 'Matthew', 'Vaughn', '34 Nottinghill Road', 'London', 'England', 'United Kingdom', 'WC2N'),
		  ('p005', 'Michael', 'Fassbender', '78 Krieg Tower', 'Heidelberg', 'Baden-Wurtemberg', 'West Germany', '79110'),
		  ('p006', 'Tom', 'Hardy', '8769 Queen Caroline Street', 'Hammersmith', 'England', 'United Kingdom', 'W6 9QH'),
		  ('p007', 'Nicholas', 'Hoult', '99 London Road', 'Wokingham', 'England', 'United Kingdom', 'RG40 1RD'),
		  ('p306', 'Christopher', 'Nolan', '456 Crescent Round', 'London', 'England', 'United Kingdom', 'WC2N'),
		  ('p008', 'Tom', 'Hiddleston', '987 Golding Drive', 'Westminster', 'England', 'United Kingdom', 'SW1E 6QW'),
		  ('p009', 'Henry', 'Cavill', '678 Island Drive', 'St. Helier', 'Jersey', 'Channel Islands', 'JE2 9TP'),
		  ('p307', 'Joss', 'Whedon', '1000 Park Avenue', 'New York City', 'New York', 'USA', '12345'),
		  ('p308', 'Zack', 'Snyder', '55 Bay Drive', 'Green Bay', 'Wisconsin', 'USA', '75895') ;
		  
INSERT INTO Spouses (peopleID, spouseID, firstName, lastName, spouseNum)
	VALUES('p001', 's001', 'Michelene', 'Roquebrune', 2),
	      ('p001', 's002', 'Diane', 'Cilento', 1),
		  ('p300', 's003', 'Naomi', 'Chance', 1),
		  ('p300', 's004', 'Kerima', 'Hamilton', 2), 
		  ('p301', 's005', 'Sabine', 'Sun',1),
		  ('p301', 's009', 'Dorothea', 'Bennett', 2),
		  ('p302', 's011', 'Hylda', 'Tafler', 1),
		  ('p305', 's006', 'Claudia', 'Schiffer', 1),
		  ('p306', 's007', 'Emma', 'Thompson', 1),
		  ('p307', 's008', 'Kai', 'Cole', 1),
		  ('p308', 's012', 'Denise', 'Snyder', 1),
		  ('p308', 's010', 'Deborah', 'Snyder', 2),
		  ('p002', 's016', 'doorn', 'van Steyn', 1),
		  ('p002', 's013', 'Dorothy', 'Squires', 2),
		  ('p002', 's014', 'Luisa', 'Mattioli', 3),
		  ('p002', 's015', 'Kristina', 'Tholstrup', 4);	

INSERT INTO Movies (movieID, title, yearReleased, MPAAnum, domesticBoxOfficeSalesUSD, foreignBoxOfficeSalesUSD, dvdBluRaySalesUSD)
	VALUES('m001', 'Dr. No', 1962, 20322, 16067035, 43500000, 57899749),
		  ('m002', 'From Russia With Love', 1963, 20568, 24796765, 54100000, 58899749),
		  ('m003', 'Moonraker', 1979, 25614, 70308099, 140000000, 59899749),
          ('m004', 'Octopussy', 1983, 27025, 67893619, 119600000, 60899749),
		  ('m005', 'Goldfinger', 1964, 20808, 51081062, 73800000, 61899749),
		  ('m006', 'Thunderball', 1965, NULL, 63595658, 77600000, 62899749),
		  ('m007', 'You Only Live Twice', 1967, 21666, 43084787, 68500000, 63899749),
		  ('m008', 'Diamonds Are Forever', 1971, 23067, 43819547, 72200000, 64899749),
		  ('m009', 'Never Say Never Again', 1983, 27151, 55432841, 104600000, 65899749),
		  ('m010', 'X-Men:  First Class', 2011, 46663, 146408305, 207215819, 66899749),
		  ('m011', 'Inception', 2011, 46101, 292576195, 825532764, 161049602),
		  ('m012', 'The Avengers', 2012, 47486, 623357910, 86200000, 234002894),
		  ('m013', 'Man of Steel', 2013, 48169, 291045548, 377000000, 110592670);		  
		  
INSERT INTO Actors (actorID, peopleID, birthDate, hairColor, eyeColor, heightInches, weightPounds, favColor, sagDate)
	VALUES('a001', 'p001', '08-25-1930', 'grey', 'dark brown', 74, 164, 'green', '01-01-1962'),
		  ('a002', 'p002', '10-14-1927', 'grey', 'dark brown', 73, 163, 'blue', '01-01-1956'),
		  ('a003', 'p005', '02-02-1977', 'light brown', 'blue', 72, 168, 'black', '01-01-2009'),
		  ('a006', 'p006', '09-15-1977', 'brown', 'green', 70, 189, 'black', '01-01-2008'),
		  ('a007', 'p007', '12-07-1989', 'dark brown', 'blue', 75, 185, 'blue', '01-01-2007'),
		  ('a008', 'p008', '02-09-1981', 'brown', 'blue', 74, 182, 'yellow', '01-01-2006'),
		  ('a009', 'p009', '05-05-1983', 'dark brown', 'light blue', 73, 202, 'black', '01-01-2006');
		  
INSERT INTO FilmSchools (filmSchoolID, name)
    VALUES('f001', 'School of Hard Knocks'),
          ('f002', 'US Air Corps Film'),
          ('f003', NULL),
		  ('f004', 'United States Information Service'),
		  ('f005', 'University College of London');		  

INSERT INTO Directors (directorID, peopleID, filmSchoolID, dgaDate, favLensMaker )
	VALUES('d001', 'p300', 'f001', '01-01-1963', 'Panavision'),
	      ('d002', 'p301', 'f001', '01-01-1962', 'CinemaScope'),
		  ('d003', 'p302', 'f002', '01-01-1979', 'Kodak'),
		  ('d004', 'p303', 'f003', '01-01-1980', 'IMAX'),
		  ('d005', 'p304', 'f004', '01-01-1958', 'Leica'),
		  ('d006', 'p305', 'f001', '01-01-1996', 'Vivitar'),
		  ('d007', 'p306', 'f005', '01-01-1999', 'Ross'),
		  ('d008', 'p307', 'f001', '01-01-1998', 'Pentax'),
		  ('d009', 'p308', 'f001', '01-01-2001', 'Nikon');

INSERT INTO MovieActors (actorID, movieID)
	VALUES('a001', 'm001'),
	      ('a001', 'm002'),
		  ('a002', 'm003'),
		  ('a002', 'm004'),
		  ('a001', 'm005'),
		  ('a001', 'm006'),
		  ('a001', 'm007'),
		  ('a001', 'm008'),
		  ('a001', 'm009'),
		  ('a003', 'm010'),
		  ('a006', 'm011'),
		  ('a007', 'm010'),
		  ('a008', 'm012'),
		  ('a009', 'm013');
		  
INSERT INTO MovieDirectors (directorID, movieID)
	VALUES('d002', 'm001'),
		  ('d001', 'm002'),
		  ('d003', 'm003'),
		  ('d004', 'm004'),
		  ('d001', 'm005'),
		  ('d002', 'm006'),
		  ('d003', 'm007'),
		  ('d001', 'm008'),
		  ('d005', 'm009'),
		  ('d006', 'm010'),
		  ('d007', 'm011'),
		  ('d008', 'm012'),
		  ('d009', 'm013');


select p1.firstName,
       p1.lastName
from People p1                                  
where p1.peopleID in
    (select d.peopleID
     from Directors d                  
     where d.directorID in
        (select y.directorID
         from MovieDirectors y        
         where y.movieID in
            (select x.movieID
             from MovieActors x      
             where x.actorID in
                (select a.actorID               
                 from Actors a
                 where a.peopleID in
                    (select p2.peopleID			
                     from People p2
                     where p2.firstName = 'Sean' and p2.lastName = 'Connery'
                     )
                 )
             )
         )
     )
     
 