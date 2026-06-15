DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
--- Tables With No Foreign KEYS ---
CREATE TABLE "Customer_Status" (
  "customer_status_code"        varchar(10) PRIMARY KEY,
  "customer_status_description" varchar(100) NOT NULL
);

CREATE TABLE "Payment_Methods" (
  "payment_method_code"        varchar(10) PRIMARY KEY,
  "payment_method_description" varchar(100) NOT NULL
);

CREATE TABLE "Lesson_Status" (
  "lesson_status_code"        varchar(10) PRIMARY KEY,
  "lesson_status_description" varchar(100) NOT NULL
);

CREATE TABLE "Addresses" (
  "address_id"             serial PRIMARY KEY,
  "line_1"                 varchar(100) NOT NULL,
  "line_2"                 varchar(100),
  "line_3"                 varchar(100),
  "city"                   varchar(100) NOT NULL,
  "state_province"         varchar(100) NOT NULL,
  "country"                varchar(100) NOT NULL,
  "zip_postcode"           varchar(20) NOT NULL,
  "other_address_details"  text 
);

CREATE TABLE "Vehicles" (
  "vehicle_id"      serial PRIMARY KEY,
  "vehicle_details" text NOT NULL
);

CREATE TABLE "Lesson_Types" (
  "lesson_type_id"        serial PRIMARY KEY,
  "lesson_standard_price" decimal(10,2) NOT NULL CHECK (lesson_standard_price >= 0),
  --- Ensures lessons are 15 minutes increments
  "duration_minutes"      int NOT NULL CHECK (duration_minutes % 15 = 0 AND duration_minutes > 0),
  "lesson_details"        text NOT NULL
);

--- CoreTables With Foreign Keys  ---


CREATE TABLE "Staff" (
  "staff_id"            serial PRIMARY KEY,
  "staff_address_id"    int UNIQUE NOT NULL, 
  "nickname"            varchar(50),
  "first_name"          varchar(50) NOT NULL,
  "middle_name"         varchar(50),
  "last_name"           varchar(50) NOT NULL,
  "date_of_birth"       date,
  "date_joined_staff"   date NOT NULL,
  "date_left_staff"     date,
  "other_staff_details" text,
  
  FOREIGN KEY ("staff_address_id") 
     REFERENCES "Addresses" ("address_id")
     ON DELETE RESTRICT 
     ON UPDATE CASCADE
);

CREATE TABLE "Customers" (
  "customer_id"              serial PRIMARY KEY,
  "customer_address_id"      int UNIQUE NOT NULL, 
  "customer_status_code"     varchar(10) NOT NULL, 
  "date_became_customer"     date NOT NULL,
  "date_of_birth"            date NOT NULL,
  "first_name"               varchar(100) NOT NULL,
  "last_name"                varchar(100) NOT NULL,
  "amount_outstanding"       decimal(10,2) DEFAULT 0.00 CHECK (amount_outstanding >=0),
  "email_address"            varchar(150) NOT NULL,
  "phone_number"             varchar(30),
  "cell_mobile_phone_number" varchar(30),
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

CREATE TABLE "Lessons" (
  "lesson_id"            serial PRIMARY KEY,
  "customer_id"          int NOT NULL, 
  "lesson_status_code"   varchar(10) NOT NULL, 
  "staff_id"             int, 
  "vehicle_id"           int NOT NULL, 
  "lesson_date"          date NOT NULL,
  "lesson_time"          time NOT NULL,
  "price"                decimal(10,2) NOT NULL  CHECK (price >= 0),
  "lesson_type_id"       int NOT NULL,
  "other_lesson_details" text,

  FOREIGN KEY ("customer_id") 
    REFERENCES "Customers" ("customer_id")
    ON DELETE CASCADE 
    ON UPDATE CASCADE,
    
  FOREIGN KEY ("lesson_status_code") 
    REFERENCES "Lesson_Status" ("lesson_status_code")
    ON DELETE RESTRICT 
    ON UPDATE CASCADE,
    
  FOREIGN KEY ("staff_id") 
    REFERENCES "Staff" ("staff_id")
    ON DELETE SET NULL 
    ON UPDATE CASCADE,
    
  FOREIGN KEY ("vehicle_id") 
    REFERENCES "Vehicles" ("vehicle_id")
    ON DELETE RESTRICT 
    ON UPDATE CASCADE,
 
  FOREIGN KEY ("lesson_type_id") 
    REFERENCES "Lesson_Types" ("lesson_type_id")
    ON DELETE RESTRICT 
    ON UPDATE CASCADE,

  --- Ensures lessons start on 15 minute incremetns and 0 seconds
  CONSTRAINT chk_time_granularity 
  CHECK (
  --- Minutes must be exactly on the 15-minute mark
  EXTRACT(MINUTE FROM lesson_time) IN (0, 15, 30, 45)
  AND 
  --- Seconds must be completely zeroed out
  EXTRACT(SECOND FROM lesson_time) = 0)
);

CREATE TABLE "Customer_Payments" (
  "customer_id"           int NOT NULL, 
  "datetime_payment"      timestamptz NOT NULL,
  "payment_method_code"   varchar(10) NOT NULL, 
  "amount_payment"        decimal(10,2) NOT NULL,
  "other_payment_details" text,

  PRIMARY KEY ("customer_id", "datetime_payment"),

  FOREIGN KEY ("customer_id") 
    REFERENCES "Customers" ("customer_id")
    ON DELETE CASCADE 
    ON UPDATE CASCADE,
    
  FOREIGN KEY ("payment_method_code") 
    REFERENCES "Payment_Methods" ("payment_method_code")
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
);