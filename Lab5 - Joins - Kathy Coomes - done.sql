-- Lab5 - Kathy Coomes - Joins - 2/16/17
-- --------------------------------------------------------------
--
-- Number 1 - (both ways) - Show the cities of agents booking an order
--     for a customer whose id is c006.  Use joins this time; no subqueries.
-- results will be:  New York, Tokyo, Dallas
             
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
--
-- Number 2 - Show the ids of products ordered through any agent who makes at least
--     one order for a customer in Kyoto, sorted by pid from highest to lowest.  
--     Use joins; no subqueries.
-- results should be:  p01, p03, p04, p05, p07

select distinct o1.pid
from orders o1 inner join orders o2 on o1.aid = o2.aid
               inner join customers c on o2.cid = c.cid
where c.city = 'Kyoto'               
order by o1.pid desc;
---------------------------------------------------------------
--
-- Number 3 - two ways - -- not sure if it was supposed to be just the 
--     subquery or a join with a subquery
-- Show the names of customers who have never placed an order.  
--     Use a subquery.
-- results should be:  Weyland

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
--
-- Number 4 - Show the names of customers who have nevere placed an order. 
--    Use an outer join.
-- results should be:  Weyland

select c.name
from customers c left outer join orders o on c.cid = o.cid
where o.cid is null;  

-- --------------------------------------------------------------
--
-- Number 5 - Show the names of customers who placed at least one 
--    order through an agent in their own city, along with those 
--    agent(s') names.
-- results should be:  Tiptop Otasi
--

select distinct c.name as "customer",
                a.name as "agent"
from orders o inner join customers c on o.cid = c.cid
              inner join agents a on o.aid = a.aid
where c.city = a.city
order by c.name;

-- ---------------------------------------------------------------
--
-- Number 6 - Show the names of customers and agents living in the same city,
--     along with the name of the shared city, regardless of whether or not
--     the customer has ever placed an order with that agent.
-- results should be:  Tiptop Ofasi Smith, Tyrell Smith Dallas, Allied Smith
--     Dallas, ACME Otasi Duluth

select distinct c.name as "customer",
                c.city as "customer city",
                a.name as "agent",
                a.city as "agent city"
from orders o1 inner join orders o2 on o1.cid = o2.cid
               inner join customers c on o1.cid = c.cid
               inner join agents a on o1.aid = o1.aid
where c.city = a.city
order by c.name;
  
-- -----------------------------------------------------------------

-- Number 7 - Show the name and city of customers who live in the city that
--    makes the fewest different kinds of products: (Hint:  Use count and
--    group by on the Products table.)
-- results should be:  Tiptop Duluth, ACME Duluth

-- Lab 5 - Number 7 - Kathy Coomes - 02/16/17
-- per Tien no specific method was specified

select distinct c.name,
                c.city
from customers c
where c.city =
    (select p.city
     from products p
     group by p.city
     order by count(p.city)
     limit 1
     )
order by c.name asc;

