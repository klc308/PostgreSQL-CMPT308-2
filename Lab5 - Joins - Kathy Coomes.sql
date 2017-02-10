--Lab5 - Kathy Coomes - Joins - 2/9/17
----------------------------------------------------------
--Number 1 - (2 ways)
              
select agents.city
from agents,
     customers,
     orders
where orders.cid = customers.cid
  and orders.aid = agents.aid
  and customers.cid = 'c006';
---------------------------------
select agents.city
from agents inner join orders on orders.aid = agents.aid
            inner join customers on orders.cid = customers.cid
where customers.cid = 'c006';
---------------------------------------------------------------