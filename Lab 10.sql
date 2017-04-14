Kathy Coomes - Lab 10 - sql

-- -------------------------------------
-- Number 1
-- -------------------------------------

create or replace function PreReqsFor(int, REFCURSOR) returns refcursor as 
$$
declare
   courseEntered int       := $1;
   resultset   REFCURSOR := $2;
begin
   open resultset for 
      select num, name, credits
      from   prerequisites p inner join courses c on p.preReqNum = c.num
       where  p.courseNum = courseEntered;
   return resultset;
end;
$$ 
language plpgsql;

select PreReqsFor(499, 'results');
Fetch all from results;

-- -------------------------------------
-- Number 2
-- -------------------------------------

create or replace function IsPreReqsFor(int, REFCURSOR) returns refcursor as 
$$
declare
   courseEntered int       := $1;
   resultset   REFCURSOR := $2;
begin
   open resultset for 
      select num, name, credits
      from   prerequisites p inner join courses c on p.courseNum = c.num
       where  p.preReqNum = courseEntered;
   return resultset;
end;
$$ 
language plpgsql;

select IsPreReqsFor(120, 'results');
Fetch all from results;