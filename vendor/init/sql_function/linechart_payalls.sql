 DROP FUNCTION  IF EXISTS public.linechart_payalls();
CREATE OR REPLACE FUNCTION public.linechart_payalls()
 RETURNS TABLE(payall_amt_sch numeric,payall_amt numeric, payall_cash numeric,
 				payall_duedate date , 
 				loca_code_payment character varying,loca_name_payment character varying,
 				crr_code_payment  character varying ,crr_name_payment character varying,
 				id numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN
	RETURN QUERY
		 	EXECUTE 'select (payall_amt_sch) payall_amt_sch , (payall_amt) payall_amt,(payall_cash) payall_cash,
					 cast(payall_duedate as date) payall_duedate,
					 loca.code loca_code_payment ,loca.name loca_name_payment,
					crr.code crr_code_payment ,crr.name crr_name_payment,
					loca.payments_id id
				from (
						select  (paysch.amt_sch - COALESCE(func_ord_amt_bal(''payschs'',paysch.id),0)) payall_amt_sch,0 payall_amt,0 payall_cash,
								duedate payall_duedate,payments_id,crrs_id from payschs paysch
							union
						select  0 payall_amt_sch, (payord.amt - COALESCE(func_ord_amt_bal(''payords'',payord.id),0))  payall_amt, 0 payall_cash,
								duedate payall_duedate,payments_id,crrs_id from payords payord
							union
						select 0 payall_amt_sch , 0 payall_amt ,(payact.cash - COALESCE(func_ord_amt_bal(''payacts'' ,payact.id),0))  payall_cash,
								 duedate payall_duedate,payments_id,crrs_id from payacts payact
					)  payall 
				inner join (select loca.code,loca.name,mst.id payments_id from payments mst
							inner join locas loca on loca.id = mst.locas_id_payment) loca
						on loca.payments_id = payall.payments_id
				inner join crrs crr	on crr.id = payall.crrs_id'
;
END
;
$function$


DROP TABLE IF EXISTS sio.sio_linechart_payalls;

CREATE TABLE sio.sio_linechart_payalls (
	sio_id numeric(22) NOT NULL,
	sio_user_code numeric(22) NULL,
	sio_term_id varchar(30) NULL,
	sio_session_id numeric(22) NULL,
	sio_command_response bpchar(1) NULL,
	sio_session_counter numeric(22) NULL,
	sio_classname varchar(50) NULL,
	sio_viewname varchar(30) NULL,
	sio_code varchar(30) NULL,
	sio_strsql varchar(4000) NULL,
	sio_totalcount numeric(22) NULL,
	sio_recordcount numeric(22) NULL,
	payall_duedate   date NULL,
	loca_code_payment  varchar(50) NULL,
	loca_name_payment  varchar(100) NULL,
	crr_code_payment  varchar(50) NULL,
	crr_name_payment  varchar(100) NULL,
	payall_amt_sch numeric(22,6) NULL,
	payall_amt numeric(22,6) NULL,
	payall_cash numeric(22,6) NULL,
	sio_start_record numeric(22) NULL,
	sio_end_record numeric(22) NULL,
	sio_sord varchar(256) NULL,
	sio_search varchar(10) NULL,
	sio_sidx varchar(256) NULL,
	sio_errline varchar(4000) NULL,
	sio_org_tblname varchar(30) NULL,
	sio_org_tblid numeric(22) NULL,
	sio_add_time date NULL,
	sio_replay_time date NULL,
	sio_result_f bpchar(1) NULL,
	sio_message_code bpchar(10) NULL,
	sio_message_contents varchar(4000) NULL,
	sio_chk_done bpchar(1) NULL,
	CONSTRAINT sio_linechart_payalls_id_pk PRIMARY KEY (sio_id)
);
CREATE INDEX sio_linechart_payalls_uk1 ON sio.sio_linechart_payalls USING btree (sio_id);


 drop sequence  if exists sio.sio_linechart_payalls_seq ;
 create sequence sio.sio_linechart_payalls_seq ;



select sum(payall_amt_sch) payall_amt_sch,sum(payall_amt) payall_amt,sum(payall_cash) payall_cash,
			to_char(payall_duedate,'yy-ww') from linechart_payalls() group by to_char(payall_duedate,'yy-ww');