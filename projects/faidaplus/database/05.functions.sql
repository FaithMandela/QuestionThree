CREATE OR REPLACE FUNCTION generate_points(varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	rec						RECORD;
	v_period				varchar(7);
	v_period_id				integer;
	v_org_id				integer;
	v_entity_id				integer;
	v_points				real;
	v_points_id				integer;
	v_amount				real;
	msg 					varchar(120);
BEGIN

	v_period_id = $1::integer;
	SELECT to_char(start_date, 'mmyyyy') INTO v_period 
	FROM periods WHERE period_id = v_period_id AND closed = false;
	IF(v_period IS NULL)THEN RAISE EXCEPTION 'Period is closed'; END IF;

	FOR rec IN SELECT pcc, son, ticketperiod, totalsegs
	FROM t_sonsegs WHERE (ticketperiod = v_period) LOOP

		IF(1<= rec.totalsegs::integer AND rec.totalsegs::integer <=250 ) THEN
			v_amount := 12;
			v_points := rec.totalsegs * 12 ;
		END IF;

		IF(251>= rec.totalsegs::integer AND rec.total_segs::integer <=500) THEN
			v_amount := 16;
			v_points := rec.totalsegs * 16 ;
		END IF;

		IF(rec.totalsegs::integer >=501 ) THEN
			v_amount := 20;
			v_points := rec.totalsegs * 20 ;
		END IF;
		
		SELECT orgs.org_id, entitys.entity_id INTO v_org_id, v_entity_id
		FROM orgs INNER JOIN entitys ON orgs.org_id = entitys.org_id
		WHERE (entitys.is_active = true) AND (orgs.pcc = rec.pcc) AND (entitys.son = rec.son);
		IF(v_entity_id is null)THEN v_entity_id := 0; v_org_id := 0; END IF;

		SELECT points_id INTO v_points_id
		FROM points WHERE (period_id = v_period_id) AND (entity_id = v_entity_id)
			AND (pcc = rec.pcc) AND (son = rec.son);

		IF(v_points_id is null)THEN
			INSERT INTO points (period, period_id, entity_id, pcc, son, segments, amount, points)
			VALUES (v_period, v_period_id, v_entity_id, rec.pcc, rec.son, rec.total_segs, v_amount, v_points);
		ELSE
			UPDATE points SET segments = rec.total_segs, amount = v_amount, points = v_points
			WHERE points_id = v_points_id;
		END IF;
	END LOOP;

	IF(rec IS NULL)THEN 
		msg := 'There are no segments for this month'; 
	ELSE
		msg := 'Points computed';
	END IF;
	
 
	RETURN msg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_bonus(varchar(12), varchar(12), varchar(12)) RETURNS varchar(120) AS $$
DECLARE
	rec						RECORD;
	v_period_bonus_ps		real;
	v_period_bonus_amount	real;
	v_pcc_bonus_ps			real;
	v_pcc_bonus_amount		real;
	v_son_bonus_ps			real;
	v_son_bonus_amount		real;
	v_bonus					real;
	msg 					varchar(120);
BEGIN


	SELECT percentage, amount INTO v_period_bonus_ps, v_period_bonus_amount
	FROM bonus
	WHERE (period_id = $1::integer) AND (is_active = true) AND (approve_status = 'Approved');
	IF(v_period_bonus_ps is null)THEN v_period_bonus_ps := 0; END IF;
	IF(v_period_bonus_amount is null)THEN v_period_bonus_amount := 0; END IF;


	FOR rec IN SELECT points_id, entity_id, period_id, pcc, son, segments, amount, points, bonus
	FROM points WHERE (period_id = $1::integer) LOOP

		SELECT percentage, amount INTO v_pcc_bonus_ps, v_pcc_bonus_amount
		FROM bonus
		WHERE (pcc = rec.pcc) AND (is_active = true) AND (approve_status = 'Approved')
			AND (start_date <= current_date) AND ((end_date is null) OR (end_date >= current_date));
		IF(v_pcc_bonus_ps is null)THEN v_pcc_bonus_ps := 0; END IF;
		IF(v_pcc_bonus_amount is null)THEN v_pcc_bonus_amount := 0; END IF;

		SELECT percentage, amount INTO v_son_bonus_ps, v_son_bonus_amount
		FROM bonus
		WHERE (consultant_id = rec.entity_id) AND (is_active = true) AND (approve_status = 'Approved')
			AND (start_date <= current_date) AND ((end_date is null) OR (end_date >= current_date));
		IF(v_son_bonus_ps is null)THEN v_son_bonus_ps := 0; END IF;
		IF(v_son_bonus_amount is null)THEN v_son_bonus_amount := 0; END IF;

		v_bonus := (rec.points * v_period_bonus_ps / 100) + (rec.points * v_period_bonus_amount);
		v_bonus := v_bonus + (rec.points * v_pcc_bonus_ps / 100) + (rec.points * v_pcc_bonus_amount);
		v_bonus := v_bonus + (rec.points * v_son_bonus_ps / 100) + (rec.points * v_son_bonus_amount);

		UPDATE points SET bonus = v_bonus WHERE points_id = rec.points_id;

	END LOOP;

	msg := 'Bonus computed';
	RETURN msg;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION upd_orders_status(varchar(12), varchar(12), varchar(12),varchar(12))	RETURNS varchar(120) AS $BODY$
DECLARE
	msg 		varchar(20);
	details 	text;
BEGIN

	IF ($3::integer = 1) THEN
		UPDATE orders SET order_status = 'Awaiting Collection' WHERE order_id = $1::integer;
		details :='Your Order is ready for collection';
	END IF;

	IF ($3::integer = 2) THEN
		UPDATE orders SET order_status = 'Collected' WHERE order_id = $1::integer;
		details := 'Your Order has been collected';
	END IF;

	IF ($3::integer = 3) THEN
		UPDATE orders SET order_status = 'Closed' WHERE order_id = $1::integer;
	END IF;

	INSERT INTO sys_emailed (table_id, sys_email_id, table_name, email_type, org_id,narrative)
	VALUES ($1::integer,4 ,'orders', 1, 0,details);
	RETURN 'Successfully Updated';
END;
$BODY$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION ins_applicants()  RETURNS trigger AS $BODY$
DECLARE
	rec 			RECORD;
	v_entity_id		integer;
BEGIN
	IF (TG_OP = 'INSERT') THEN
		SELECT entity_id INTO v_entity_id
		FROM entitys
		WHERE (trim(lower(user_name)) = trim(lower(NEW.applicant_email)));

		IF(v_entity_id is null)THEN
			RAISE EXCEPTION 'The username exists use a different one or reset password for the current one';
		END IF;
	END IF;
	RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER ins_applicants BEFORE INSERT OR UPDATE ON applicants
FOR EACH ROW  EXECUTE PROCEDURE ins_applicants();

CREATE OR REPLACE FUNCTION upd_applicants(varchar(12), varchar(12), varchar(12),varchar(12)) RETURNS varchar(120) AS $BODY$
DECLARE
	ps				varchar(16);
	v_pcc 			varchar(4);
	rec 			RECORD;
	app				RECORD;
	msg				varchar(120);
	myid 			integer;
BEGIN

	IF ($3::integer = 1) THEN
		ps := 'Approved';
		SELECT * INTO app FROM applicants WHERE applicant_id = $1::integer;
		SELECT org_id INTO rec FROM orgs WHERE (pcc = app.pseudo_code);

		IF(rec IS NULL)THEN
			RAISE EXCEPTION 'Pseudo Code Does not Exist';
		END IF;

		UPDATE applicants SET status = ps , org_id = rec.org_id,approve_status = ps WHERE applicant_id = $1::integer ;
		INSERT INTO entitys (org_id, entity_type_id,entity_name, user_name,primary_email, son,function_role,is_active,birth_date)
		VALUES (rec.org_id, 0, app.son,lower(app.applicant_email),lower(app.applicant_email),app.son, 'consultant',true,app.consultant_dob) returning entity_id INTO myid;
		msg := 'Consultant account has been activated';
		INSERT INTO sys_emailed (sys_email_id, table_id, table_name)
		VALUES (2, myid , 'entitys');
	END IF;

	IF ($3::integer = 2) THEN
		ps := 'Rejected';
		UPDATE applicants SET status = ps , approved = false WHERE applicant_id = $1::integer ;
		msg := 'Applicant Rejected';
		INSERT INTO sys_emailed (sys_email_id, table_id, table_name)
		VALUES (3, $1::integer , 'applicants');
	END IF;

	RETURN msg;
END;
$BODY$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION getbalance(integer) RETURNS real AS $$
	SELECT COALESCE(sum(dr - cr), 0)
	FROM vw_son_statement
	WHERE entity_id = $1;
$$ LANGUAGE sql;


CREATE SEQUENCE batch_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1;

CREATE OR REPLACE FUNCTION upd_orders_batch(varchar(20),varchar(20),varchar(20),varchar(20)) RETURNS varchar(120) AS $BODY$
DECLARE
	v_batch  	integer;
	msg 		varchar(50);
BEGIN
	IF ($3::integer = 1) THEN
		v_batch := (SELECT last_value FROM batch_id_seq) ;
		UPDATE orders SET batch_no = v_batch,batch_date = now() WHERE order_id = $1::integer;
		msg := 'Orders Batched Successfully';
	END IF;

	IF($3::integer = 2)THEN
		v_batch :=nextval('batch_id_seq');
		msg := 'Batch Closed';
	END IF;

	RETURN msg;
END;
$BODY$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION close_batch_seq()  RETURNS integer AS $BODY$
DECLARE
	v_batch  integer;
BEGIN
	v_batch := nextval('batch_id_seq');
	RETURN v_batch;
END;

$BODY$ LANGUAGE plpgsql ;

CREATE OR REPLACE FUNCTION getBirthday() RETURNS bigint AS $BODY$
	SELECT  count(entity_id)
	FROM vw_entitys WHERE to_char(birth_date, 'dd-mm') = to_char(CURRENT_DATE,'dd-mm');
$BODY$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getBatch_no() RETURNS bigint AS $BODY$
	SELECT last_value FROM batch_id_seq;
$BODY$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION son_segments( varchar(7), varchar(4))  RETURNS numeric AS $BODY$
	SELECT COALESCE(SUM(total_segs),0.0)  FROM vw_son_segs WHERE son = $1 AND pcc = $2;
$BODY$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION ins_orders() RETURNS trigger AS $BODY$
DECLARE
	v_order integer;
BEGIN
	INSERT INTO sys_emailed (sys_email_id, table_id, table_name,narrative)
	VALUES (4, NEW.order_id , 'orders','We have received your order and its under process');
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER ins_orders AFTER INSERT ON orders
FOR EACH ROW EXECUTE PROCEDURE ins_orders();

CREATE OR REPLACE FUNCTION ins_order_details() RETURNS trigger AS $BODY$
DECLARE
	v_order integer;
BEGIN
	IF (NEW.order_details_id IS NULL) THEN
		UPDATE order_details SET order_id=t.id
		FROM (select orders.order_id AS id FROM orders WHERE orders.order_id = NEW.order_id)AS t ;
	END IF;
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER ins_order_details AFTER INSERT ON order_details
FOR EACH ROW EXECUTE PROCEDURE ins_order_details();


CREATE OR REPLACE FUNCTION ins_orgs() RETURNS trigger AS $$
BEGIN
	NEW.pcc = trim(upper(NEW.pcc));
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ins_orgs BEFORE INSERT OR UPDATE ON orgs
    FOR EACH ROW EXECUTE PROCEDURE ins_orgs();

ALTER TABLE orgs ADD CONSTRAINT orgs_pcc_unique UNIQUE (pcc);

CREATE OR REPLACE FUNCTION upd_entitys() RETURNS trigger AS $$
BEGIN

	IF((OLD.change_pcc <> NEW.change_pcc) or (OLD.change_son <> NEW.change_son))THEN
		INSERT INTO change_pccs (entity_id, son, pcc, change_son, change_pcc)
		VALUES (NEW.entity_id, NEW.son, NEW.pcc, NEW.change_son, NEW.change_pcc);
 	END IF;
 	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER upd_entitys BEFORE UPDATE ON entitys
    FOR EACH ROW EXECUTE PROCEDURE upd_entitys();
    
CREATE OR REPLACE FUNCTION upd_change_pccs() RETURNS trigger AS $$
DECLARE
	v_org_id				integer;
	v_entity_id				integer;
BEGIN

	IF((OLD.approve_status = 'Completed') AND (NEW.approve_status = 'Approved'))THEN
		SELECT orgs.org_id INTO v_org_id
		FROM orgs WHERE (orgs.pcc = NEW.change_pcc);
		IF((NEW.change_pcc is null) or (v_org_id is null))THEN RAISE EXCEPTION 'No Travel Agency with new PCC'; END IF;
	
		SELECT entity_id INTO v_entity_id
		FROM entitys
		WHERE (org_id = v_org_id) AND (entitys.son = NEW.change_son);
		IF(v_entity_id is not null)THEN RAISE EXCEPTION 'A consultant with that SON already exists'; END IF;
		
		UPDATE entitys SET org_id = v_org_id, pcc = NEW.change_pcc, son = NEW.change_son
		WHERE entity_id = v_entity_id;
 	END IF;
 	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER upd_change_pccs BEFORE UPDATE ON change_pccs
    FOR EACH ROW EXECUTE PROCEDURE upd_change_pccs();
