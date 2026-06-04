create schema if not exists business_center;
set search_path to business_center;

drop table if exists attendance cascade;
drop table if exists employee_equipment cascade;
drop table if exists equipment cascade;
drop table if exists lease_contract cascade;
drop table if exists tenant_company cascade;
drop table if exists employee_position cascade;
drop table if exists position cascade;
drop table if exists office_room cascade;
drop table if exists employee cascade;
drop table if exists department cascade;


create table if not exists department (
    department_id serial primary key,
    department_name varchar(100) not null unique,
    floor_number int not null check (floor_number >= 0),
    office_phone varchar(25)
);

create table if not exists employee (
    employee_id serial primary key,
    full_name varchar(150) not null,
    group_name varchar(20) not null default 'ПО-1-24',
    email varchar(120) not null unique,
    phone_number varchar(25),
    address varchar(150) not null,
    gender varchar(10) not null check (gender in ('M', 'F', 'Other')),
    salary numeric(10,2) not null check (salary >= 0),
    hire_date date not null check (hire_date > date '2026-01-01'),
    status varchar(20) not null default 'active'
        check (status in ('active', 'inactive', 'vacation')),
    department_id int not null references department(department_id) on delete restrict
);

create table if not exists office_room (
    room_id serial primary key,
    room_number varchar(20) not null unique,
    floor_number int not null check (floor_number >= 0),
    room_area numeric(6,2) not null check (room_area >= 0),
    monthly_price numeric(10,2) not null check (monthly_price >= 0),
    status varchar(20) not null default 'available'
        check (status in ('available', 'rented', 'maintenance')),
    department_id int references department(department_id) on delete set null
);

create table if not exists position (
    position_id serial primary key,
    position_name varchar(100) not null unique,
    minimum_salary numeric(10,2) not null check (minimum_salary >= 0)
);

create table if not exists employee_position (
    employee_id int not null references employee(employee_id) on delete cascade,
    position_id int not null references position(position_id) on delete restrict,
    start_date date not null check (start_date > date '2026-01-01'),
    primary key (employee_id, position_id)
);

create table if not exists tenant_company (
    tenant_company_id serial primary key,
    company_name varchar(120) not null unique,
    bin varchar(12) not null unique,
    contact_person varchar(120) not null,
    contact_phone varchar(25) not null,
    business_type varchar(50) not null
        check (business_type in ('IT', 'Education', 'Retail', 'Finance', 'Consulting'))
);

create table if not exists lease_contract (
    contract_id serial primary key,
    tenant_company_id int not null references tenant_company(tenant_company_id) on delete restrict,
    room_id int not null references office_room(room_id) on delete restrict,
    manager_employee_id int not null references employee(employee_id) on delete restrict,
    start_date date not null check (start_date > date '2026-01-01'),
    end_date date not null,
    monthly_rent numeric(10,2) not null check (monthly_rent >= 0),
    deposit numeric(10,2) not null check (deposit >= 0),
    total_contract_value numeric(12,2)
        generated always as (monthly_rent * 12 + deposit) stored,
    status varchar(20) not null default 'active'
        check (status in ('active', 'finished', 'cancelled')),
    check (end_date > start_date)
);

create table if not exists equipment (
    equipment_id serial primary key,
    equipment_name varchar(100) not null,
    serial_number varchar(50) not null unique,
    purchase_price numeric(10,2) not null check (purchase_price >= 0),
    purchase_date date not null check (purchase_date > date '2026-01-01'),
    status varchar(20) not null default 'available'
        check (status in ('available', 'assigned', 'repair'))
);

create table if not exists employee_equipment (
    employee_id int not null references employee(employee_id) on delete cascade,
    equipment_id int not null references equipment(equipment_id) on delete restrict,
    given_date date not null check (given_date > date '2026-01-01'),
    primary key (employee_id, equipment_id)
);

create table if not exists attendance (
    attendance_id serial primary key,
    employee_id int not null references employee(employee_id) on delete cascade,
    work_date date not null check (work_date > date '2026-01-01'),
    attendance_status varchar(20) not null
        check (attendance_status in ('present', 'absent', 'late', 'vacation')),
    hours_worked numeric(4,2) not null check (hours_worked >= 0)
);


ALTER TABLE employee
ADD COLUMN IF NOT EXISTS emergency_contact VARCHAR(120);

alter table employee alter column phone_number type varchar(30);


alter table tenant_company add column registration_address varchar(150);

  
alter table office_room alter column status set default 'available';


alter table department rename column office_phone to department_phone;


alter table equipment add column temporary_note varchar(100);
alter table equipment drop column temporary_note;



truncate table
    attendance,
    employee_equipment,
    equipment,
    lease_contract,
    tenant_company,
    employee_position,
    position,
    office_room,
    employee,
    department
restart identity cascade;

insert into department (department_name, floor_number, department_phone)
values
('Administration', 1, '+77122010001'),
('Security', 1, '+77122010002'),
('Finance', 2, '+77122010003'),
('Tenant Relations', 2, '+77122010004'),
('Technical Service', 3, '+77122010005');

insert into position (position_name, minimum_salary)
values
('Business Center Manager', 550000),
('Tenant Relations Specialist', 380000),
('Accountant', 420000),
('Security Officer', 330000),
('Technical Support Specialist', 360000);

insert into employee
(full_name, email, phone_number, address, gender, salary, hire_date, status, department_id, emergency_contact)
values

('Аманбай Айкен Ақылбекқызы',
'aiken.amanbay@bc.kz',
'+77010000001',
'Abay Avenue 12, Atyrau',
'F',380000,'2026-02-09','active',
(select department_id from department where department_name='Administration'),
'+77019990001'),

('Әміржанқызы Асылай',
'asilay.amirzhankyzy@bc.kz',
'+77010000002',
'Satbayev Street 25, Atyrau',
'F',360000,'2026-02-15','active',
(select department_id from department where department_name='Tenant Relations'),
'+77019990002'),

('Балғабай Әсел Болатбекқызы',
'assel.balgabai@bc.kz',
'+77010000003',
'Makhambet Street 45, Atyrau',
'F',410000,'2026-03-01','active',
(select department_id from department where department_name='Finance'),
'+77019990003'),

('Гарифов Ильнур Маратович',
'ilnur.garifov@bc.kz',
'+77010000004',
'Azattyk Avenue 80, Atyrau',
'M',430000,'2026-03-14','active',
(select department_id from department where department_name='Technical Service'),
'+77019990004'),

('Гайниденұлы Арслан',
'arslan.gainidenuly@bc.kz',
'+77010000005',
'Qurmangazy Street 18, Atyrau',
'M',350000,'2026-04-05','active',
(select department_id from department where department_name='Security'),
'+77019990005'),

('Ерболатқызы Каусар',
'kausar.erbolatkyzy@bc.kz',
'+77010000006',
'Baimukhanov Street 33, Atyrau',
'F',370000,'2026-04-20','active',
(select department_id from department where department_name='Tenant Relations'),
'+77019990006'),

('Жұмабай Нұрдаулет Маратұлы',
'nurdaulet.zhumabai@bc.kz',
'+77010000007',
'Vladimirskaya Street 14, Atyrau',
'M',390000,'2026-05-03','active',
(select department_id from department where department_name='Technical Service'),
'+77019990007'),

('Жумакулова Асылай Маратовна',
'asilay.zhumakulova@bc.kz',
'+77010000008',
'Saryarka Avenue 20, Atyrau',
'F',370000,'2026-05-22','active',
(select department_id from department where department_name='Administration'),
'+77019990008'),

('Жұмағали Айша Қанатқызы',
'aisha.zhumagali@bc.kz',
'+77010000009',
'Beibarys Avenue 55, Atyrau',
'F',400000,'2026-06-01','active',
(select department_id from department where department_name='Finance'),
'+77019990009'),

('Игілік Көркем Нұрланқызы',
'korkem.igilik@bc.kz',
'+77010000010',
'Auezov Street 17, Atyrau',
'F',360000,'2026-06-18','active',
(select department_id from department where department_name='Tenant Relations'),
'+77019990010'),

('Курмашев Артур Берикович',
'artur.kurmashev@bc.kz',
'+77010000011',
'Kunaev Street 29, Atyrau',
'M',440000,'2026-07-04','active',
(select department_id from department where department_name='Technical Service'),
'+77019990011'),

('Қамай Арнұр Бауыржанұлы',
'arnur.kamai@bc.kz',
'+77010000012',
'Abulkhair Khan Avenue 60, Atyrau',
'M',350000,'2026-07-25','active',
(select department_id from department where department_name='Security'),
'+77019990012'),

('Қайрақбай Инабат Тимурқызы',
'inabat.kairakbai@bc.kz',
'+77010000013',
'Zhumagaliyev Street 8, Atyrau',
'F',370000,'2026-08-02','active',
(select department_id from department where department_name='Tenant Relations'),
'+77019990013'),

('Қадырғали Сымбат Ақылбекқызы',
'symbat.kadyrgali@bc.kz',
'+77010000014',
'Isatay Taymanov Avenue 44, Atyrau',
'F',410000,'2026-08-19','active',
(select department_id from department where department_name='Finance'),
'+77019990014'),

('Ли Максим Юрьевич',
'maksim.li@bc.kz',
'+77010000015',
'Qanysh Satbayev Avenue 90, Atyrau',
'M',460000,'2026-09-01','active',
(select department_id from department where department_name='Administration'),
'+77019990015'),

('Олжабаева Молдир Айдыновна',
'moldir.olzhabaeva@bc.kz',
'+77010000016',
'Pushkin Street 22, Atyrau',
'F',380000,'2026-09-15','active',
(select department_id from department where department_name='Tenant Relations'),
'+77019990016'),

('Сахташева Райхан Ербулатовна',
'raihan.sakhtasheva@bc.kz',
'+77010000017',
'Dostyk Avenue 31, Atyrau',
'F',410000,'2026-10-01','active',
(select department_id from department where department_name='Finance'),
'+77019990017'),

('Табылды Дауренбек Ерланұлы',
'daurenbek.tabyldy@bc.kz',
'+77010000018',
'Nursaya Microdistrict 7, Atyrau',
'M',390000,'2026-10-20','active',
(select department_id from department where department_name='Technical Service'),
'+77019990018'),

('Тауман Саида Руслановна',
'saida.tauman@bc.kz',
'+77010000019',
'Avangard Microdistrict 3, Atyrau',
'F',370000,'2026-11-01','active',
(select department_id from department where department_name='Administration'),
'+77019990019'),

('Тулегеновна Аружан Руфатовна',
'aruzhan.tulegenovna@bc.kz',
'+77010000020',
'Privokzalny Microdistrict 10, Atyrau',
'F',360000,'2026-11-12','active',
(select department_id from department where department_name='Tenant Relations'),
'+77019990020'),

('Хисметова Аружан Самигуллаевна',
'aruzhan.khismetova@bc.kz',
'+77010000021',
'Samal Microdistrict 15, Atyrau',
'F',400000,'2026-11-25','active',
(select department_id from department where department_name='Finance'),
'+77019990021'),

('Чигрина Диана Михаиловна',
'diana.chigrina@bc.kz',
'+77010000022',
'Tomarly Village 5, Atyrau',
'F',370000,'2026-12-05','active',
(select department_id from department where department_name='Administration'),
'+77019990022'),

('Шахмет Ақтоты Еркебуланқызы',
'aktoty.shakhmet@bc.kz',
'+77010000023',
'Balykshi Microdistrict 19, Atyrau',
'F',380000,'2026-12-20','active',
(select department_id from department where department_name='Tenant Relations'),
'+77019990023');

TRUNCATE TABLE office_room CASCADE;
INSERT INTO office_room
(room_number, floor_number, room_area, monthly_price, status, department_id)
values
('A-101', 1, 28.50, 180000, 'rented',
 (select department_id from department where department_name = 'Administration')),

('A-102', 1, 35.00, 220000, 'rented',
 (select department_id from department where department_name = 'Security')),

('B-201', 2, 42.70, 300000, 'rented',
 (select department_id from department where department_name = 'Tenant Relations')),

('B-202', 2, 55.30, 410000, 'rented',
 (select department_id from department where department_name = 'Finance')),

 ('C-301', 3, 60.00, 450000, 'available',
 (select department_id from department where department_name = 'Technical Service'));

TRUNCATE TABLE tenant_company CASCADE;
insert into tenant_company
(company_name, bin, contact_person, contact_phone, business_type, registration_address)
values
('Atyrau Digital Solutions LLP', '260201000001', 'Nurlan Karimov', '+77021110001', 'IT', 'Satbayev 10, Atyrau'),
('Caspian Learning Center LLP', '260201000002', 'Aigerim Omarova', '+77021110002', 'Education', 'Satbayev 12, Atyrau'),
('West Retail Group LLP', '260201000003', 'Marat Sadykov', '+77021110003', 'Retail', 'Satbayev 14, Atyrau'),
('Finance Pro Consulting LLP', '260201000004', 'Dana Akhmetova', '+77021110004', 'Finance', 'Satbayev 16, Atyrau'),
('Business Expert Group LLP', '260201000005', 'Timur Iskakov', '+77021110005', 'Consulting', 'Satbayev 18, Atyrau');
TRUNCATE TABLE lease_contract CASCADE;
insert into lease_contract
(tenant_company_id, room_id, manager_employee_id, start_date, end_date, monthly_rent, deposit, status)
values
(
 (select tenant_company_id from tenant_company where company_name = 'Atyrau Digital Solutions LLP'),
 (select room_id from office_room where room_number = 'A-101'),
 (select employee_id from employee where email = 'aiken.amanbay@bc.kz'),
 '2026-02-09', '2027-02-09', 180000, 180000, 'active'
),
(
 (select tenant_company_id from tenant_company where company_name = 'Caspian Learning Center LLP'),
 (select room_id from office_room where room_number = 'A-102'),
 (select employee_id from employee where email = 'asilay.amirzhankyzy@bc.kz'),
 '2026-02-09', '2027-02-09', 220000, 220000, 'active'
),
(
 (select tenant_company_id from tenant_company where company_name = 'West Retail Group LLP'),
 (select room_id from office_room where room_number = 'B-201'),
 (select employee_id from employee where email = 'inabat.kairakbai@bc.kz'),
 '2026-02-09', '2027-02-09', 300000, 300000, 'active'
),
(
 (select tenant_company_id from tenant_company where company_name = 'Finance Pro Consulting LLP'),
 (select room_id from office_room where room_number = 'B-202'),
 (select employee_id from employee where email = 'symbat.kadyrgali@bc.kz'),
 '2026-02-09', '2027-02-09', 410000, 410000, 'active'
),
(
 (select tenant_company_id from tenant_company where company_name = 'Business Expert Group LLP'),
 (select room_id from office_room where room_number = 'C-301'),
 (select employee_id from employee where email = 'maksim.li@bc.kz'),
 '2026-02-09', '2027-02-09', 450000, 450000, 'cancelled'
);
TRUNCATE TABLE employee_position CASCADE;
insert into employee_position (employee_id, position_id, start_date)
select e.employee_id, p.position_id, date '2026-02-09'
from employee e
join position p on
    (e.department_id = (select department_id from department where department_name = 'Administration')
     and p.position_name = 'Business Center Manager')
    or
    (e.department_id = (select department_id from department where department_name = 'Tenant Relations')
     and p.position_name = 'Tenant Relations Specialist')
    or
    (e.department_id = (select department_id from department where department_name = 'Finance')
     and p.position_name = 'Accountant')
    or
    (e.department_id = (select department_id from department where department_name = 'Security')
     and p.position_name = 'Security Officer')
    or
    (e.department_id = (select department_id from department where department_name = 'Technical Service')
     and p.position_name = 'Technical Support Specialist');

TRUNCATE TABLE equipment CASCADE;
insert into equipment
(equipment_name, serial_number, purchase_price, purchase_date, status)
values
('Lenovo ThinkPad Laptop', 'BC-EQ-001', 420000, '2026-02-09', 'assigned'),
('HP ProBook Laptop', 'BC-EQ-002', 390000, '2026-02-09', 'assigned'),
('Canon Office Printer', 'BC-EQ-003', 280000, '2026-02-09', 'assigned'),
('Samsung Monitor 24', 'BC-EQ-004', 125000, '2026-02-09', 'assigned'),
('Cisco Office Phone', 'BC-EQ-005', 65000, '2026-02-09', 'assigned');

);
TRUNCATE TABLE employee_equipment CASCADE;
insert into employee_equipment (employee_id, equipment_id, given_date)
values
(
 (select employee_id from employee where email = 'aiken.amanbay@bc.kz'),
 (select equipment_id from equipment where serial_number = 'BC-EQ-001'),
 '2026-02-09'
),
(
 (select employee_id from employee where email = 'assel.balgabai@bc.kz'),
 (select equipment_id from equipment where serial_number = 'BC-EQ-002'),
 '2026-02-09'
),
(
 (select employee_id from employee where email = 'ilnur.garifov@bc.kz'),
 (select equipment_id from equipment where serial_number = 'BC-EQ-003'),
 '2026-02-09'
),
(
 (select employee_id from employee where email = 'arslan.gainidenuly@bc.kz'),
 (select equipment_id from equipment where serial_number = 'BC-EQ-004'),
 '2026-02-09'
),
(
 (select employee_id from employee where email = 'maksim.li@bc.kz'),
 (select equipment_id from equipment where serial_number = 'BC-EQ-005'),
 '2026-02-09'
);
TRUNCATE TABLE attendance CASCADE;
insert into attendance (employee_id, work_date, attendance_status, hours_worked)
values
((select employee_id from employee where email = 'aiken.amanbay@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'asilay.amirzhankyzy@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'assel.balgabai@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'ilnur.garifov@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'arslan.gainidenuly@bc.kz'), '2026-02-09', 'late', 7),
((select employee_id from employee where email = 'kausar.erbolatkyzy@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'nurdaulet.zhumabai@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'asilay.zhumakulova@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'aisha.zhumagali@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'korkem.igilik@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'artur.kurmashev@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'arnur.kamai@bc.kz'), '2026-02-09', 'late', 7),
((select employee_id from employee where email = 'inabat.kairakbai@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'symbat.kadyrgali@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'maksim.li@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'moldir.olzhabaeva@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'raihan.sakhtasheva@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'daurenbek.tabyldy@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'saida.tauman@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'aruzhan.tulegenovna@bc.kz'), '2026-02-09', 'vacation', 0),
((select employee_id from employee where email = 'aruzhan.khismetova@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'diana.chigrina@bc.kz'), '2026-02-09', 'present', 8),
((select employee_id from employee where email = 'aktoty.shakhmet@bc.kz'), '2026-02-09', 'present', 8);


update employee
set salary = salary + 30000
where department_id = (
    select department_id
    from department
    where department_name = 'Technical Service'
);


update office_room r
set status = 'rented'
from lease_contract lc
where r.room_id = lc.room_id
  and lc.status = 'active';


begin;

delete from lease_contract
where status = 'cancelled'
returning contract_id, tenant_company_id, room_id, status;

rollback;

DO $$
begin
    if exists (select 1 from pg_roles where rolname = 'business_center_readonly') then
        execute 'drop owned by business_center_readonly';
        execute 'drop role business_center_readonly';
    end if;
END $$;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_roles 
        WHERE rolname = 'business_center_readonly'
    ) THEN
        EXECUTE 'DROP OWNED BY business_center_readonly';
        EXECUTE 'DROP ROLE business_center_readonly';
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_roles 
        WHERE rolname = 'business_center_writer'
    ) THEN
        EXECUTE 'DROP OWNED BY business_center_writer';
        EXECUTE 'DROP ROLE business_center_writer';
    END IF;
END $$;

CREATE ROLE business_center_readonly;
CREATE ROLE business_center_writer;

grant usage on schema business_center to business_center_readonly;
grant usage on schema business_center to business_center_writer;

grant select on all tables in schema business_center to business_center_readonly;

grant insert, update on employee to business_center_writer;

revoke update on employee from business_center_writer;	

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'business_center'
ORDER BY table_name;
