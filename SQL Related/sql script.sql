create database LILI;
use lili;

create table houseHold_tbl(
house_Id Int auto_increment primary key,
house_Name nvarchar(100) not null,
house_pic nvarchar(255),
house_address nvarchar(255) 
);

create table user_tbl (
user_Id Int auto_increment primary key,
user_Name nvarchar(100) not null,
user_role enum('AppAdminstrator','admin','user') not null,
user_password nvarchar(100) not null,
user_birthday Date not null,
user_profilePic nvarchar(255),
user_email nvarchar(100) unique not null,
user_phone nvarchar(100) unique not null,
user_Height double,
user_weight double,
user_diet enum('Vegan','Vegetarian','Keto','Gluten-Free','Paleo','Low-Carb','Dairy-Free','Low-Fat','Whole30','Halal') not null,
user_gender enum('male','female') not null,
house_Id int,
FOREIGN KEY (house_Id) REFERENCES houseHold_tbl(house_Id),
user_isLoggedIn boolean not null default true 
);

create table allergy_tbl(
allergy_Id Int auto_increment primary key,
allergy_name nvarchar(100) not null,
user_Id int,
FOREIGN KEY (user_Id) REFERENCES user_tbl(user_Id)
);

create table task_tbl(
task_Id Int auto_increment primary key,
task_title nvarchar(100) not null,
task_description nvarchar(255) ,
task_status enum('done','in progress','missed') DEFAULT 'in progress' not null,
task_deadline date ,
assigner_Id int,
assignedTo_Id int,
FOREIGN KEY (assigner_Id) REFERENCES user_tbl(user_Id),
FOREIGN KEY (assignedTo_Id) REFERENCES user_tbl(user_Id)
);

create table notification_tbl(
not_Id Int auto_increment primary key,
not_title nvarchar(100) not null,
not_body nvarchar(255) not null,
not_isRead boolean not null default false, 
not_timeStamp time not null,
user_Id int,
FOREIGN KEY (user_Id) REFERENCES user_tbl(user_Id)
);