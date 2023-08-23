
drop function public.func_get_name;

CREATE OR REPLACE FUNCTION public.func_get_name( objecttype varchar(19),
												 code varchar(50), 
												 email varchar(50))
 RETURNS   varchar(100)
AS 
	$$DECLARE
	gr_name varchar(100);
BEGIN	
  select  pg."name" into gr_name  from pobjgrps pg 
		inner join pobjects pj on pg.pobjects_id = pj.id
		inner join persons pr on pg.usrgrps_id  = pr.usrgrps_id 
		where pj.objecttype = $1 and  pj."code" = $2
		and pr.email = $3
		and pg.expiredate > current_date 
		and pj.expiredate > current_date 
		and pr.expiredate > current_date;
   return gr_name;
 END
$$
LANGUAGE plpgsql;

--
--select * from public.func_get_name('screen','r_prdords','system@rrrp.com');


--select pg."name"  from pobjgrps pg 
--		inner join pobjects pj on pg.pobjects_id = pj.id
--		inner join persons pr on pg.usrgrps_id  = pr.usrgrps_id 
--		where pj.objecttype = 'screen' and  pj.code = 'r_units'
--		and pr.email = 'system@rrrp.com'
--		and pg.expiredate > current_date and pj.expiredate > current_date and pr.expiredate > current_date;
--		
--	
--select * from persons; 
--
--BEGIN
--    SELECT * INTO STRICT myrec FROM emp WHERE empname = myname;
--    EXCEPTION
--        WHEN NO_DATA_FOUND THEN
--            RAISE EXCEPTION 'employee % not found', myname;
--        WHEN TOO_MANY_ROWS THEN
--            RAISE EXCEPTION 'employee % not unique', myname;
--END;
--
--CREATE FUNCTION get_userid(username text) RETURNS int
--AS $$
--#print_strict_params on
--DECLARE
--userid int;
--BEGIN
--    SELECT users.userid INTO STRICT userid
--        FROM users WHERE users.username = get_userid.username;
--    RETURN userid;
--END
--$$ LANGUAGE plpgsql;
