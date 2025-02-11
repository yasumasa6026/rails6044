---   未使用
-- CREATE OR REPLACE VIEW public.apparatus_itms
-- AS SELECT 
--     itm.name AS itm_name,
--     itm.code AS itm_code,
--     itm.expiredate AS itm_expiredate,
--     itm.id AS itm_id,
--     itm.id,
--     classlist.code classlist_code,
--     classlist.name classlist_name,
--     itm.classlists_id AS itm_classlist_id
--    FROM itms itm,
--     classlists classlist
--   WHERE itm.classlists_id = classlist.id
--   and classlist.code = 'apparatus'
--   ;
  
 
--  select * from apparatus_itms;