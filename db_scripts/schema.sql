

--- TABLES With NO FOREIGN KEYS ----
CREATE TABLE "Addresses" (
  "address_id"             serial PRIMARY KEY,
  "line_1" varchar(100),
  "line_2"   varchar(100),
  "line_3"   varchar(100),
  "city"                   varchar(100) NOT NULL,
  "state_province"         varchar(100) NOT NULL,
  "country"                varchar(100) NOT NULL,
  "zip_postcode"           varchar(20) NOT NULL,
  "other_address_details"  text
);

CREATE TABLE "Customer_Status" (
  "customer_status_code"        varchar(10) PRIMARY KEY,
  "customer_status_description" varchar(100) NOT NULL
);


CREATE TABLE "Vehicles" (
  "vehicle_id"            serial PRIMARY KEY,
  "make"                  varchar(50) NOT NULL,
  "model"                 varchar(50) NOT NULL,
  "year"                  int NOT NULL,
  "registration_plate"    varchar(20) UNIQUE NOT NULL,
  "other_vehicle_details" text
  );

--- LESSION STATUS TYPES ---
--- "BOOKED" ---
---"COMP" ---
--- 
CREATE TABLE "Lesson_Status" (
  "lesson_status_code"        varchar(10)  PRIMARY KEY,
  "lesson_status_description" varchar(100) NOT NULL
);

CREATE TABLE "Payment_Methods" (
  "payment_method_code"        varchar(10)  PRIMARY KEY,
  "payment_method_description" varchar(100) NOT NULL
);

CREATE TABLE "Lesson_Types" (
  "lesson_type_id" serial PRIMARY KEY,
  "lesson_name" varchar(100) NOT NULL,
  "price" decimal(10,2) NOT NULL,
  "lesson_description" text
);
--- TABLES WITH FOREIGN KEYS---


CREATE TABLE "Staff" (
  "staff_id"             serial PRIMARY KEY,
  "staff_address_id"     int NOT NULL,
  "nickname"             varchar(50),
  "first_name"           varchar(50)  NOT NULL,
  "middle_name"          varchar(50),
  "last_name"            varchar(50)  NOT NULL,
  "date_of_birth"        date,
  "date_joined_staff"    date         NOT NULL,
  "date_left_staff"      date,
  "other_staff_details"  text,
  FOREIGN KEY ("staff_address_id")
    REFERENCES "Addresses" ("address_id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);



CREATE TABLE "Customers" (
  "customer_id"              serial PRIMARY KEY,
  "customer_address_id"      int          NOT NULL,
  "customer_status_code"     varchar(10)  NOT NULL,
  "date_became_customer"     date         NOT NULL,
  "date_of_birth"            date         NOT NULL,
  "first_name"               varchar(250) NOT NULL,
  "last_name"                varchar(250) NOT NULL,
  "email_address"            varchar(150) NOT NULL,
  "phone_number"             varchar(30)  NOT NULL,
  "cell_mobile_phone_number" varchar(30)  NOT NULL,
  "other_customer_details"   text,

  FOREIGN KEY ("customer_address_id")
    REFERENCES "Addresses" ("address_id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  FOREIGN KEY ("customer_status_code")
    REFERENCES "Customer_Status" ("customer_status_code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


CREATE TABLE "Customer_Payments" (
  "payment_id"            serial      PRIMARY KEY,
  "customer_id"           int         NOT NULL,
  "datetime_payment"      timestamptz   NOT NULL,
  "payment_method_code"   varchar(10) NOT NULL,
  "amount_payment"        decimal(10,2)     NOT NULL,
  "other_payment_details" text,

  FOREIGN KEY ("customer_id")
    REFERENCES "Customers" ("customer_id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  FOREIGN KEY ("payment_method_code")
    REFERENCES "Payment_Methods" ("payment_method_code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);



CREATE TABLE "Lessons" (
  "lesson_id" serial PRIMARY KEY,
  "lesson_type_id" int NOT NULL,
  "customer_id" int NOT NULL,
  "staff_id" int NOT NULL,
  "vehicle_id" int NOT NULL,
  "lesson_status_code" varchar(10) NOT NULL,
  "lesson_datetime" timestamptz NOT NULL,
  "price" decimal(10,2) NOT NULL,
  FOREIGN KEY ("customer_id")
    REFERENCES "Customers" ("customer_id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  FOREIGN KEY ("lesson_status_code")
    REFERENCES "Lesson_Status" ("lesson_status_code")
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  
  FOREIGN KEY ("staff_id")
    REFERENCES "Staff" ("staff_id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  
  FOREIGN KEY ("vehicle_id")
    REFERENCES "Vehicles" ("vehicle_id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  FOREIGN KEY ("lesson_type_id")
    REFERENCES "Lesson_Types" ("lesson_type_id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


