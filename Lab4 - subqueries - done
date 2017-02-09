-- Kathy Coomes - Lab 4 - SQL subqueries - 2/8/17

-- Number One
select city 
from agents
where aid in
     (select aid from orders
      where cid = 'c006');
     
-- Number Two     
select distinct pid
from orders
where aid in
     (select aid
      from orders
      where cid in
           (select cid
            from customers
        	where city = 'Kyoto'
           )
     )
order by pid desc;

-- Number Three
select distinct cid, 
                name
from customers
where cid in
	(select cid
     from orders
     where cid not in
     	(select cid 
     	 from orders
         where aid = 'a01'
        )
    );
     
-- Number Four 
select cid
from orders
where pid = 'p01'
	intersect
select cid
from orders
where pid = 'p07';

-- Number Five
select pid 
from products
where pid in
	(select pid 
	from orders
	where cid not in
		(select cid
   		from orders
   		where aid = 'a08'
    	)
    )
order by pid desc;

--Number Six
select name, 
       discount, 
       city
from customers
where cid in
	(select cid 
     from orders
     where aid in
       	(select aid
         from agents
         where city in ('Tokyo', 'New York')
        )
     );
     
--Number Seven
select *
from customers
where discount in
	(select discount
     from customers
     where city in ('Duluth', 'London')
    );

----------------------------------------------------------------------------------------------------
-- Check constraint
-- 	A check constraint is a referential integrity constraint for a column or multiple columns 
-- that specifies the requirement that must be met by each row in that column or columns.
-- There are good reasons/advantages for the use of check constraints:  
--	They enforce the rules and thereby integrity of the table by limiting the values that are accepted.
--	They ensure consistency for enumerated domains such as days of the week and months of the year.
--	Applications are simpler and easier to maintain and control.
-- There are also bad reasons/limitations of check constraints:
--	It takes time to perform the check constraint.
--	Because values that evaluate to False are rejected, and because null evaluates to unknown, a null
--		value may override a constraint.
--	If a condition is not False, check constrint will return True.  If a table has no rows, the check
--		constraint is considered valis and can produce unexpected results.
--	They are not validated during Delete statements.
--
-- Examples of good check constraints:
--	create table GoodOne(
--	   dayOfWeek char(10) check (dayOfWeek = 'Sunday' or dayOfWeek = 'Monday' or dayOfWeek = 'Tuesday' 
--	   or dayOfWeek = 'Wednesday' or dayOfWeek = 'Thursday' or dayOfWeek = 'Friday' 
--	   or dayOfWeek = 'Saturday')
--	);
--
--	create table GoodTwo(
--	   priceUSD numeric check (priceUSD > 0)
--	);

--Example of bad check constraints:
--	create table BadOne(
--	   integersAll int check(way too many to list)
--	);
--
--	The dayofWeek check constraint is good because it ensures that only 1 of the 7 days of the Week
-- will be allowed. Anything else will be rejected as False.  The priceUSD constraint ensures that the 
-- priceUSD must always be greater than 0, or it also will be rejected.  Checking against 7 possibilities 
-- for the dayOfWeek and checking that -1 is not greater than 0, but 1 is for priceUSD is easy and won't 
-- take too much time. 
--	Using a check constraint on something infinite like integers would cause the program to slow down
-- as it would have to check the entry against every possible integer both negative or positive.  It would
-- also be extremely difficult to list every possibility of integer and make the program extremely long. 
--	So using check constraints for choices that are finite is an advantage where trying to do so with 
-- anything that is infinite would just make things more difficult.
