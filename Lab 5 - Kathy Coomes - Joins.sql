-- Lab5 - Kathy Coomes - Joins - 2/16/17
-- --------------------------------------------------------
-- Number 1 - (both ways)
              
select agents.city
from agents,
     customers,
     orders
where orders.cid = customers.cid
  and orders.aid = agents.aid
  and customers.cid = 'c006';
-- ---
select agents.city
from agents inner join orders on orders.aid = agents.aid
            inner join customers on orders.cid = customers.cid
where customers.cid = 'c006';

-- -------------------------------------------------------------
-- Number 2

select distinct o1.pid
from orders o1 inner join orders o2 on o1.aid = o2.aid
               inner join customers c on o2.cid = c.cid
where c.city = 'Kyoto'               
order by o1.pid desc;
---------------------------------------------------------------

-- Number 3 - two ways 
-- not sure if it was supposed to be just the subquery or a join with a subquery

select customers.name
from customers 
where customers.cid not in
    (select orders.cid
     from orders
     );    
     
select customers.name
from customers left outer join orders on customers.cid = orders.cid
where customers.cid not in
    (select orders.cid
     from orders
     );

-- --------------------------------------------------------------

-- Number 4   

select c.name
from customers c left outer join orders o on c.cid = o.cid
where o.cid is null;  

-- --------------------------------------------------------------

-- Number 5