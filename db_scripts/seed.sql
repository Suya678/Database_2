-- Wipe everything (if you want a clean reload)
TRUNCATE "Customer_Payments", "Lessons", "Customers", "Staff", 
        "Vehicles", "Lesson_Types", "Addresses", 
        "Lesson_Status", "Payment_Methods", "Customer_Status"
        RESTART IDENTITY CASCADE;

INSERT INTO "Customer_Status" VALUES
  ('ACTIVE',    'Can book lessons'),
  ('SUSPENDED', 'Cannot book new lessons');

INSERT INTO "Payment_Methods" ("payment_method_code", "payment_method_description") VALUES
  ('CC',    'Credit Card'),
  ('CASH',  'Cash'),
  ('DEBIT', 'Debit Card'),
  ('ETRAN', 'E-Transfer');

INSERT INTO "Lesson_Status" ("lesson_status_code", "lesson_status_description") VALUES
  ('BOOKED', 'Lesson scheduled but not yet occurred'),
  ('COMP',   'Lesson completed successfully'),
  ('CANC',   'Lesson cancelled by customer or staff');

INSERT INTO "Addresses" ("line_1", "line_2", "line_3", "city", "state_province", "country", "zip_postcode", "other_address_details") VALUES
  -- Staff addresses (IDs 1-10)
  ('4825 Mount Royal Gate SW', NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T3E 6K6', 'Staff Address'),
  ('123 17 Ave SW',           'Apt 4B', NULL, 'Calgary', 'Alberta', 'Canada', 'T2S 0A1', 'Staff Address'),
  ('456 Bow Trail SW',         NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T3C 2E4', 'Staff Address'),
  ('789 Macleod Trail SE',     'Suite 100', NULL, 'Calgary', 'Alberta', 'Canada', 'T2G 2M1', 'Staff Address'),
  ('101 Kensington Rd NW',     NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T2N 3P8', 'Staff Address'),
  ('2200 Edmonton Trail NE',   NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T2E 3M2', 'Staff Address'),
  ('1450 Memorial Dr NW',      'Unit 7', NULL, 'Calgary', 'Alberta', 'Canada', 'T2N 3E4', 'Staff Address'),
  ('3030 17 Ave SE',           NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T2A 0R5', 'Staff Address'),
  ('612 4 St NE',              NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T2E 3S5', 'Staff Address'),
  ('918 Northmount Dr NW',     NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T2K 3J5', 'Staff Address'),

  -- Customer addresses (IDs 11-20)
  ('202 Crowchild Trail NW',   NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T2M 4S6', 'Customer Address'),
  ('888 8 Ave SW',             'Unit 12', NULL, 'Calgary', 'Alberta', 'Canada', 'T2P 1B3', 'Customer Address'),
  ('333 14 St NW',             NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T2N 1Z7', 'Customer Address'),
  ('999 Heritage Dr SW',       NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T2V 2X7', 'Customer Address'),
  ('555 11 Ave SW',            'Apt 2', NULL, 'Calgary', 'Alberta', 'Canada', 'T2R 0E4', 'Customer Address'),
  ('77 Panatella Blvd NW',     NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T3K 0M1', 'Customer Address'),
  ('414 Cranston Dr SE',       'Unit 305', NULL, 'Calgary', 'Alberta', 'Canada', 'T3M 0J3', 'Customer Address'),
  ('1818 Tuscany Hills Dr NW', NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T3L 2L2', 'Customer Address'),
  ('221 Auburn Bay Blvd SE',   NULL, NULL, 'Calgary', 'Alberta', 'Canada', 'T3M 1P4', 'Customer Address'),
  ('660 Sage Hill Grove NW',   'Apt 11', NULL, 'Calgary', 'Alberta', 'Canada', 'T3R 0S5', 'Customer Address');

INSERT INTO "Vehicles" ("vehicle_details") VALUES
  ('2023 Toyota Corolla - License: AB-1234 - Dual Controls'),
  ('2022 Honda Civic - License: AB-5678 - Dual Controls'),
  ('2024 Mazda 3 - License: AB-9012 - Dual Controls'),
  ('2021 Hyundai Elantra - License: AB-3456 - Dual Controls'),
  ('2023 Kia Forte - License: AB-7890 - Dual Controls'),
  ('2024 Nissan Sentra - License: AB-2345 - Dual Controls'),
  ('2022 Volkswagen Jetta - License: AB-6789 - Dual Controls'),
  ('2023 Subaru Impreza - License: AB-0123 - Dual Controls - AWD'),
  ('2024 Chevrolet Cruze - License: AB-4567 - Dual Controls'),
  ('2021 Ford Focus - License: AB-8901 - Dual Controls - Manual');

INSERT INTO "Lesson_Types" ("lesson_standard_price", "duration_minutes", "lesson_details") VALUES
  (80.00,  60,  'Standard 1-Hour City Driving Practice'),
  (120.00, 90,  '1.5-Hour Highway and Merge Training'),
  (150.00, 120, '2-Hour Winter Driving & Skid Control'),
  (60.00,  45,  '45-Minute Brush-Up Session'),
  (200.00, 120, 'Comprehensive Road Test Prep Package'),
  (90.00,  60,  '1-Hour Parallel Parking & Maneuvers'),
  (110.00, 75,  '1.25-Hour Defensive Driving Course'),
  (130.00, 90,  '1.5-Hour Nighttime Driving Practice'),
  (75.00,  60,  '1-Hour Manual Transmission Basics'),
  (140.00, 105, '1.75-Hour Rural & Country Roads');

INSERT INTO "Staff" ("staff_address_id", "nickname", "first_name", "middle_name", "last_name", "date_of_birth", "date_joined_staff", "date_left_staff", "other_staff_details") VALUES
  (1,  'John',  'Doe',     NULL, 'Boy',       '1995-04-12', '2022-01-15', NULL, 'Senior Instructor'),
  (2,  'Evan',   'Evan',      NULL, 'AA',     '1998-08-22', '2023-03-01', NULL, 'Specializes in manual transmission'),
  (3,  'Kev',    'Kevin',     NULL, 'Oneal',         '1997-11-05', '2024-06-10', NULL, 'Weekend instructor'),
  (4,  NULL,     'Marcus',    'J',  'Tremblay',   '1985-02-14', '2019-09-01', NULL, 'Lead Examiner'),
  (5,  'Sam',    'Samantha',  NULL, 'Carter',     '1990-07-30', '2025-01-10', NULL, NULL),
  (6,  'Priya',  'Priya',     NULL, 'Sharma',     '1992-03-18', '2021-11-08', NULL, 'Bilingual: English/Hindi'),
  (7,  NULL,     'Tomasz',    NULL, 'Kowalski',   '1988-06-25', '2020-04-22', NULL, 'Highway specialist'),
  (8,  'Jay',    'Jayden',    'A',  'MacIntyre',  '1996-10-09', '2023-08-14', NULL, NULL),
  (9,  'Mei',    'Mei-Lin',   NULL, 'Chen',       '1993-12-03', '2022-05-30', NULL, 'Winter driving expert'),
  (10, NULL,     'Daniel',    NULL, 'Okonkwo',    '1989-09-17', '2024-02-05', NULL, 'Defensive driving certified');

INSERT INTO "Customers" ("customer_address_id", "customer_status_code", "date_became_customer", "date_of_birth", "first_name", "last_name", "amount_outstanding", "email_address", "phone_number", "cell_mobile_phone_number", "other_customer_details") VALUES
  (11, 'ACTIVE',    '2026-05-01', '2008-02-14', 'Jarod',    'Smith',     0.00, 'jarod.s@example.com',    '403-555-0101', '403-555-0102', 'Nervous driver'),
  (12, 'ACTIVE',    '2026-05-15', '2007-09-30', 'Sarah',    'Connor',    0.00, 'sarah.c@example.com',    '403-555-0201', '403-555-0202', NULL),
  (13, 'SUSPENDED', '2026-06-01', '2005-12-01', 'Dinesh',   'Kumar',     0.00, 'dinesh.k@example.com',   '403-555-0301', '403-555-0302', NULL),
  (14, 'ACTIVE',    '2026-06-10', '2009-01-15', 'Mia',      'Wong',      0.00, 'mia.w@example.com',      '403-555-0401', '403-555-0402', NULL),
  (15, 'SUSPENDED', '2025-10-01', '2006-05-22', 'Liam',     'MacDonald', 0.00, 'liam.m@example.com',     '403-555-0501', '403-555-0502', NULL),
  (16, 'ACTIVE',    '2026-03-20', '2007-04-08', 'Aaliyah',  'Johnson',   0.00, 'aaliyah.j@example.com',  '403-555-0601', '403-555-0602', 'Prefers female instructors'),
  (17, 'ACTIVE',    '2026-04-12', '2008-08-19', 'Mateo',    'Garcia',    0.00, 'mateo.g@example.com',    '403-555-0701', '403-555-0702', NULL),
  (18, 'ACTIVE',    '2026-02-28', '2006-11-11', 'Hannah',   'Stewart',   0.00, 'hannah.s@example.com',   '403-555-0801', '403-555-0802', 'Road test scheduled July'),
  (19, 'ACTIVE',    '2026-05-25', '2009-06-04', 'Noah',     'Patel',     0.00, 'noah.p@example.com',     '403-555-0901', '403-555-0902', NULL),
  (20, 'ACTIVE',    '2026-01-15', '2005-03-27', 'Emma',     'Lévesque',  0.00, 'emma.l@example.com',     '403-555-1001', '403-555-1002', 'Refresher after long break');

INSERT INTO "Lessons" ("customer_id", "lesson_status_code", "staff_id", "vehicle_id", "lesson_date", "lesson_time", "price", "lesson_type_id", "other_lesson_details") VALUES
  -- Completed lessons
  (1,  'COMP', 1,  1,  '2026-05-12', '09:00:00', 80.00,  1, 'Great parallel parking'),
  (2,  'COMP', 2,  2,  '2026-05-18', '10:30:00', 120.00, 2, 'Highway merging needs work'),
  (3,  'COMP', 3,  3,  '2026-05-22', '13:15:00', 150.00, 3, 'Skid pad practice'),
  (5,  'COMP', 4,  4,  '2026-05-25', '14:00:00', 200.00, 5, 'Final review before exam'),
  (6,  'COMP', 6,  5,  '2026-05-28', '11:00:00', 90.00,  6, 'Excellent maneuvers'),
  (7,  'COMP', 7,  6,  '2026-06-01', '15:45:00', 110.00, 7, 'Defensive driving completed'),
  (10, 'COMP', 9,  7,  '2026-06-03', '09:15:00', 75.00,  9, 'First manual lesson, doing well'),
  (8,  'COMP', 8,  8,  '2026-06-05', '10:00:00', 130.00, 8, 'Nighttime confidence improving'),
  (9,  'COMP', 10, 9,  '2026-06-08', '13:30:00', 140.00, 10, 'Rural roads practice'),
  
  -- Booked
  (1,  'BOOKED', 1,  1,  '2026-06-20', '09:00:00', 80.00,  1, NULL),
  (2,  'BOOKED', 2,  2,  '2026-06-22', '14:15:00', 120.00, 2, 'Highway practice'),
  (4,  'BOOKED', 5,  5,  '2026-06-24', '10:30:00', 90.00,  6, NULL),
  (9,  'BOOKED', 6,  3,  '2026-06-25', '11:45:00', 80.00,  1, NULL),
  (6,  'BOOKED', 7,  4,  '2026-06-26', '13:00:00', 110.00, 7, NULL),
  
  -- Cancelled
  (4,  'CANC', 4, 4, '2026-06-14', '13:00:00', 60.00, 4, 'Customer sick');

INSERT INTO "Customer_Payments" ("customer_id", "datetime_payment", "payment_method_code", "amount_payment", "other_payment_details") VALUES
  (1, '2026-05-12 10:05:00-06', 'CC',    80.00,   'Paid in full after lesson'),
  (2, '2026-05-18 11:40:00-06', 'DEBIT', 50.00,   'Partial payment'),         
  (3, '2026-05-22 15:20:00-06', 'CASH',  100.00,  'Partial payment'),         
  (5, '2026-05-25 17:00:00-06', 'DEBIT', 200.00,  'Paid ahead of exam'),
  (6, '2026-05-28 12:10:00-06', 'CC',    90.00,   'Paid in full'),
  (7, '2026-06-01 17:05:00-06', 'ETRAN', 60.00,   'Partial payment'),         
  (10,'2026-06-03 10:20:00-06', 'CC',    100.00,  'Overpayment'),
  (10,'2026-06-03 14:30:00-06', 'CC',    -25.00,  'Refund of overpayment'),
  (8, '2026-06-05 11:15:00-06', 'CASH',  130.00,  'Paid after lesson'),
  (9, '2026-06-08 14:45:00-06', 'DEBIT', 200.00,  'Overpayment for next lesson'); 
