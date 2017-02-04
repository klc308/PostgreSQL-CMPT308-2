-- Kathy Coomes - Lab 4 - SQL subqueries

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