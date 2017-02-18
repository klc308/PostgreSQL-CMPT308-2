-- Lab 6 - Kathy Coomes 
-- ------------------------------------
-- Number 1 - 2/17/17

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

-- ------------------------------------
-- Number 2 - 2/17/17

select name
from products
where priceUSD >
    (select avg(priceUSD)
    from products)
order by name desc;

-- ------------------------------------
-- Number 3 - 