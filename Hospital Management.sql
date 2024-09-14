create database hospital_management;
use hospital_management;

create table patients (
patient_id int auto_increment primary key,
patient_name varchar(40) not null,
dob date not null,
phone char(10) not null,
address varchar(100) not null);

insert into patients (patient_name,dob,phone,address) values
('John Doe', '1990-05-15', '9876543210', '123 Elm St, Springfield, IL'),
('Jane Smith', '1985-11-23', '9123456789', '456 Oak St, Metropolis, IL'),
('Michael Johnson', '1978-02-28', '9988776655', '789 Maple Ave, Gotham, NY'),
('Emily Davis', '1992-08-07', '9234567890', '321 Pine St, Smallville, KS'),
('Robert Brown', '1980-12-14', '9345678901', '654 Birch Ln, Star City, CA'),
('Linda Williams', '1995-07-19', '9456789012', '987 Cedar St, Central City, CO'),
('David Jones', '1988-03-30', '9567890123', '258 Spruce Rd, Coast City, FL'),
('Susan Wilson', '1975-09-05', '9678901234', '741 Palm Dr, Keystone City, PA'),
('James Miller', '1993-01-21', '9789012345', '852 Oakwood St, Blüdhaven, NJ'),
('Patricia Taylor', '1982-04-10', '9890123456', '963 Willow Ct, Midway City, OH');							


create table doctors (
doctor_id int primary key,
doctor_name varchar(50) not null,
phone char(10) not null,
spetialization varchar(30) not null);


insert into doctors (doctor_id,doctor_name,phone,spetialization) values
(1, 'Dr. Alice Green', '5551234567', 'Cardiologist'),
(2, 'Dr. Bob Brown', '5552345678', 'Neurologist'),
(3, 'Dr. Carol White', '5553456789', 'Orthopedic Surgeon'),
(4, 'Dr. David Black', '5554567890', 'Pediatrician'),
(5, 'Dr. Emily Harris', '5555678901', 'Oncologist'),
(6, 'Dr. Frank Wilson', '5556789012', 'Dermatologist'),
(7, 'Dr. Grace Lee', '5557890123', 'Gastroenterologist'),
(8, 'Dr. Henry Clark', '5558901234', 'Endocrinologist'),
(9, 'Dr. Irene Young', '5559012345', 'Psychiatrist'),
(10, 'Dr. John Adams', '5550123456', 'Urologist');


create table rooms(
room_no int primary key,
room_type varchar(20) not null,
room_floor int not null,
room_status enum('available','reserved') not null);

insert into rooms(room_no, room_type,room_floor,room_status) values
(101, 'Single', 1, 'Available'),
(102, 'Single', 1, 'Available'),
(103, 'Double', 1, 'Available'),
(104, 'Double', 1, 'Available'),
(105, 'Suite', 1, 'Available'),
(106, 'Suite', 1, 'Available'),
(107, 'Single', 2, 'Available'),
(108, 'Single', 2, 'Available'),
(109, 'Double', 2, 'Available'),
(110, 'Double', 2, 'Available'),
(111, 'Suite', 2, 'Available'),
(112, 'Suite', 2, 'Available'),
(113, 'Single', 3, 'Available'),
(114, 'Double', 3, 'Available'),
(115, 'Suite', 3, 'Available');


create table admission (
admission_id int auto_increment primary key,
patient_id int,
room_no int,
admission_date date not null,
foreign key (patient_id) references patients(patient_id),
foreign key (room_no) references rooms(room_no));




create table discharge (
discharge_id int auto_increment primary key,
patient_id int,
doctor_id int,
discharge_date date,
room_no int,
foreign key (patient_id) references patients(patient_id),
foreign key (doctor_id) references doctors(doctor_id),
foreign key (room_no) references rooms(room_no));




delimiter &&
create procedure admit_patient (x_patientId int,x_roomno int, x_AdmissionDate date)
begin
    if exists
		(select 1 from admission where patient_id = x_patientId or room_no = x_roomno) then
        signal sqlstate '45000'
        set message_text = 'Duplicate entry! Maybe patient already admitted or room is reserved.';
	else
		insert into admission (patient_id, room_no,admission_date) values
		(x_patientId,x_roomno, x_AdmissionDate);

        
		update rooms set room_status = 'reserved'
		where room_no = x_roomno;
	end if;
end &&
delimiter ;

call admit_patient(2,113,'2024-09-04'); -- for new patient addmissions.



delimiter &&
create procedure discharge_patient
(y_roomno int,
y_patientid int,
y_doctorid int,
y_dischargedate date)

begin
    if exists
		(select 1 from discharge where patient_id = y_patientid or room_no = y_roomno) then
		signal sqlstate '45000'
		set message_text = 'This entry already exixts, duplicate entry can not be stored';
	else
		insert into discharge(patient_id, doctor_id, discharge_date, room_no)
		values (y_patientid, y_doctorid, y_dischargedate,y_roomno);
    
		update rooms set room_status = 'available'
		where room_no = y_roomno;
    end if;
end &&
delimiter ;


call discharge_patient (108,1,5,'2024-09-04'); -- for discharge patients.
