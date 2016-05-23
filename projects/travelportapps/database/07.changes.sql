ALTER TABLE passengers ADD COLUMN departure_country character varying(50);
ALTER TABLE passengers ADD COLUMN reason_for_travel text;
ALTER TABLE passengers ADD COLUMN postal_code character varying(50);
ALTER TABLE passengers ADD COLUMN expiry_date character varying(20);
ALTER TABLE passengers ADD COLUMN physical_address text;

DROP view vw_passengers;
CREATE OR REPLACE VIEW vw_passengers AS
SELECT orgs.org_id,  orgs.org_name,  vw_rates.rate_type_id,  vw_rates.rate_type_name,  vw_rate_types.rate_category_name,
  vw_rates.rate_id,  passengers.days_from,  passengers.days_to,  passengers.corporate_rate_id,
  vw_rates.standard_rate,  vw_rates.north_america_rate,  passengers.approved,  passengers.entity_id,
  passengers.countries,  passengers.passenger_id,  passengers.passenger_name,  passengers.passenger_mobile,
  passengers.passenger_email,  passengers.passenger_age,  passengers.days_covered,  passengers.nok_name,
  passengers.nok_mobile,  passengers.passenger_id_no,  passengers.nok_national_id,  passengers.cover_amount,
  passengers.totalAmount_covered,  passengers.is_north_america,  passengers.details,  passengers.passenger_dob,
  passengers.policy_number,  entitys.entity_name,  passengers.destown,  sys_countrys.sys_country_name,
  passengers.approved_date,  passengers.corporate_id,  passengers.pin_no, passengers.reason_for_travel,
  passengers.departure_country
 FROM passengers
   JOIN orgs ON passengers.org_id = orgs.org_id
   JOIN vw_rates ON passengers.rate_id = vw_rates.rate_id
   JOIN vw_rate_types ON vw_rates.rate_type_id = vw_rate_types.rate_type_id
   JOIN entitys ON passengers.entity_id = entitys.entity_id
   JOIN sys_countrys ON passengers.sys_country_id = sys_countrys.sys_country_id;


CREATE TABLE policy_members (
    policy_member_id    serial primary key,
    passenger_id        integer references passengers,
    org_id              integer,
    entity_id           integer,
    member_name         character varying(50),
    passport_number     character varying(50),
    pin_number          character varying(50),
    phone_number        character varying(20),
    primary_email       character varying(50),
    policy_number       character varying(50),
    rate_id             integer,
    amount_covered      real,
    totalamount_covered real,
    age                 integer,
    passenger_dob       date
);
CREATE INDEX policy_members_passenger_id ON passengers (passenger_id);


CREATE OR REPLACE VIEW vw_policy_members AS
SELECT
    p.policy_member_id, p.passenger_id, p.org_id, p.entity_id, p.member_name, p.passport_number, p.pin_number,
    p.phone_number,  p.primary_email, p.rate_id, p.amount_covered, p.totalamount_covered, p.age,
    p.passenger_dob, a.countries,a.policy_number, a.destown, a.sys_country_name, a.reason_for_travel,
    a.departure_country, a.entity_name, a.days_from, a.days_to, a.rate_type_id, a.approved_date
    FROM  policy_members p
    JOIN vw_passengers a ON p.passenger_id = a.passenger_id ;
