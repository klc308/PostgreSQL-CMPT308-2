--Lab 6 - Kathy Coomes -

-- 1. (2/17/17) 
-- Display the name and city of customers who live in any city that makes
-- the most different kinds of products. (There are two cities that make 
-- the most different -- products. Return the name and city of customers 
-- from either one of those.)

select c.name,
       c.city
from customers c
where c.city =
   (select p.city
    from products p
    group by p.city
    order by count(p.city) desc
    limit 1
    )
limit 1;

-- --------------------------------------------------------------------------
-- 2. (2/17/17) 
-- Display the names of products whose priceUSD is strictly above the average
-- priceUSD, in reverse-alphabetical order.

select name
from products
where priceUSD >
    (select avg(priceUSD)
    from products)
order by name desc;

-- --------------------------------------------------------------------------
-- 3. (2/18/17) 
-- Display the customer name, pid ordered, and the total for all orders, 
-- sorted by total from low to high.

select c.name,
       o.pid,
       o.totalUSD
from orders o inner join customers c on o.cid = c.cid
order by o.totalUSD asc;

-- --------------------------------------------------------------------------
-- 4. (2/23/17)
-- Display all customer names (in alphabetical order) and their total ordered,
-- and nothing more. Use coalesce to avoid showing NULLs.

select coalesce(c.name, 'N/A'),
       coalesce(sum(o.totalUSD), 0) as "custTotalUSD"
from customers c left outer join orders o on c.cid = o.cid
group by c.name
order by c.name;

-- --------------------------------------------------------------------------
-- 5. (2/23/17) 
-- Display the names of all customers who bought products from agents based 
-- in Newark along with the names of the products they ordered, and the names
-- of the agents who sold it to them.

select c.name,
       p.name,
       a.name
from customers c inner join orders o on c.cid = o.cid
                 inner join products p on o.pid = p.pid
                 inner join agents a on o.aid = a.aid
where a.city = 'Newark';

-- --------------------------------------------------------------------------
-- 6. (2/23/17)
-- Write a query to check the accuracy of the totalUSD column in the Orders 
-- table. This means calculating Orders.totalUSD from data in other tables 
-- and comparing values to the values in Orders.totalUSD. Display all rows in
--  Orders where Orders.totalUSD is incorrect, if any.

select o.*,
	sum((p.priceUSD * o.qty) - c.discount)
from orders o inner join products p on o.pid = p.pid
              inner join customers c on o.cid = c.cid
group by o.ordNumber, p.priceUSD, o.qty, c.discount 
having sum((p.priceUSD * o.qty) - c.discount) <> o.totalUSD
order by o.ordNumber ASC;

-- --------------------------------------------------------------------------
-- 7. What’s the difference between a LEFT OUTER JOIN and a RIGHT OUTER JOIN? 
-- Give example queries in SQL to demonstrate. 
-- (Feel free to use the CAP database to make your points here.)

     -- With a left outer join, everything from the left table is displayed 
	 -- along with any match from the right table.  If there is no match in 
	 -- the right table, then it is null (or in my case empty).  
	 -- example:  Weyland did not buy anything so the p.name is empty.
     

select c.name,
       p.name
from customers c left outer join orders o on c.cid = o.cid
                 left outer join products p on o.pid = p.pid;
                 
     -- With a right outer join, it is the opposite.  Everything from the right 
     -- table is displayed along with any match from the left table.  If there is 
     -- no match in the left table, then it -- is null (or again for me empty). 
	 -- example:  No one bought the eraser, so the c.name is empty.

select c.name,
       p.name
from customers c right outer join orders o on c.cid = o.cid
                 right outer join products p on o.pid = p.pid;








