----- Kathy Coomes - 1/29/17 - Lab3 - SQL queries- submission -----

select ordNumber, totalUSD from Orders;

select name, city from Agents where name = 'Smith';

select pid, name, priceUSD from Products where quantity > 200100;

select name, city from Customers where city = 'Duluth';

select name from Agents where city not in ('New York', 'Duluth');

select * from Products where (city not in ('Dallas', 'Duluth') and priceUSD >= 1.00);

select * from Orders where month in ('Feb', 'May');

select * from Orders where month = 'Feb' and totalUSD >= 600;

select * from Orders where cid = 'c005';
