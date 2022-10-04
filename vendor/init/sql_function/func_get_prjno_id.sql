create or replace function func_get_prjno_id(tblname regclass,tblid numeric ,OUT rid integer)
as $func$
BEGIN	
  EXECUTE 'select id id from prjnos where prjnos_id_chil = (
			SELECT prjnos_id FROM ' || tblname::regclass ||' WHERE id = $1 )
			union 
				select prjnos_id_chil id from prjnos where prjnos_id_chil = (
			SELECT prjnos_id FROM ' || tblname::regclass ||' WHERE id = $1 )'
   INTO rid
   USING tblid;
END
$func$  LANGUAGE plpgsql;
