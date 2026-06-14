
-- ── Reference tables ────────────────────────────────────────
INSERT INTO "Customer_Status" (customer_status_code, customer_status_description) VALUES
  ('GOOD',    'Dummy description'),
  ('REGULAR', 'Dummy description'),
  ('BAD',     'Dummy description');

INSERT INTO "Lesson_Status" (lesson_status_code, lesson_status_description) VALUES
  ('BOOKED', 'Lesson booked and scheduled'),
  ('INPROG', 'Lesson currently in progress'),
  ('COMP',   'Lesson completed'),
  ('CANC',   'Lesson cancelled');

INSERT INTO "Payment_Methods" (payment_method_code, payment_method_description) VALUES
  ('CASH', 'Cash'),
  ('DEB',  'Debit Card'),
  ('CRED', 'Credit Card');

INSERT INTO "Lesson_Types" (lesson_name, price, lesson_description) VALUES
  ('BEGINNER',     45.00, 'Focused on basic car control and parking'),
  ('INTERMEDIATE', 45.00, 'General road driving skills'),
  ('ADVANCED',     45.00, 'Focused on highway driving'),
  ('LEARNER',      60.00, 'Preparation for the learner permit test');

-- ── Addresses ────────────────────────────────────────────────────────
INSERT INTO "Addresses" (line_1, city, state_province, country, zip_postcode) VALUES
  ('12 Maple St',    'Calgary', 'Alberta', 'Canada', 'T2P 1A1'),
  ('34 Oak Ave',     'Calgary', 'Alberta', 'Canada', 'T2P 2B2'),
  ('56 Pine Rd',     'Calgary', 'Alberta', 'Canada', 'T2P 3C3'),
  ('78 Elm St',      'Calgary', 'Alberta', 'Canada', 'T2P 4D4'),
  ('90 Birch Blvd',  'Calgary', 'Alberta', 'Canada', 'T2P 5E5'),
  ('11 Cedar Lane',  'Calgary', 'Alberta', 'Canada', 'T2P 6F6'),
  ('22 Spruce Cres', 'Calgary', 'Alberta', 'Canada', 'T2P 7G7');

-- ── Staff ────────────────────────────────────────────────────────────
INSERT INTO "Staff" (staff_address_id, first_name, last_name, date_joined_staff) VALUES
  (1, 'James', 'Smith', '2020-01-15'),
  (2, 'Sarah', 'Jones', '2021-03-01'),
  (3, 'Jaquez', 'Junior', '2020-01-19'),
  (4, 'Sopor', 'James', '2015-03-02'),
  (5, 'Ali', 'Maher', '2011-01-01');

-- ── Vehicles ─────────────────────────────────────────────────────────
INSERT INTO "Vehicles" (make, model, year, registration_plate) VALUES
  ('Toyota', 'Corolla', 2022, 'ABC123'),
  ('Honda',  'Civic',   2021, 'XYZ789'),
  ('Chrysler', 'S300', 2022,'ABC122'),
  ('Dodge',  'Civic',   2023, 'XYZ787'),
  ('Toyota', 'Corolla', 2019, 'DDC124');

-- ── Customers ────────────────────────────────────────────────────────
INSERT INTO "Customers" (customer_address_id, customer_status_code, date_became_customer, date_of_birth, first_name, last_name, email_address, phone_number, cell_mobile_phone_number) VALUES
  (3, 'GOOD',    '2025-01-10', '2000-05-12', 'Alice',  'Brown',  'alice@email.com',  '555-0101', '555-1101'),
  (4, 'GOOD',    '2025-02-14', '1998-08-23', 'Tom',    'Green',  'tom@email.com',    '555-0102', '555-1102'),
  (5, 'REGULAR', '2025-03-05', '2001-11-30', 'Mia',    'White',  'mia@email.com',    '555-0103', '555-1103'),
  (6, 'REGULAR', '2025-04-20', '1999-02-17', 'Liam',   'Taylor', 'liam@email.com',   '555-0104', '555-1104'),
  (7, 'BAD',     '2025-05-01', '2002-07-08', 'Sophie', 'Wilson', 'sophie@email.com', '555-0105', '555-1105');

INSERT INTO "Lessons" (lesson_type_id, customer_id, staff_id, vehicle_id, lesson_status_code, lesson_datetime, price) VALUES
  (1, 1, 1, 1, 'COMP',   '2026-06-01 09:00+00', 45.00),
  (2, 1, 1, 1, 'BOOKED', '2026-06-20 09:00+00', 45.00),
  (1, 2, 2, 2, 'COMP',   '2026-06-03 11:00+00', 45.00),
  (1, 2, 2, 2, 'COMP',   '2026-06-30 11:00+00', 45.00),
  (3, 2, 2, 2, 'BOOKED', '2026-06-21 11:00+00', 45.00),
  (1, 3, 1, 1, 'COMP',   '2026-06-05 10:00+00', 45.00),
  (4, 3, 1, 1, 'COMP',   '2026-06-07 14:00+00', 60.00),
  (2, 3, 2, 2, 'CANC',   '2026-05-20 10:00+00', 45.00),
  (1, 4, 2, 2, 'CANC',   '2026-06-08 14:00+00', 45.00),
  (2, 4, 1, 1, 'BOOKED', '2026-06-22 14:00+00', 45.00),
  (2, 5, 1, 1, 'COMP',   '2026-05-30 13:00+00', 45.00),
  (3, 5, 2, 2, 'COMP',   '2026-06-01 15:00+00', 45.00),
  (4, 5, 1, 1, 'BOOKED', '2026-06-23 15:00+00', 60.00);

-- ── Payments ─────────────────────────────────────────────────────────
INSERT INTO "Customer_Payments" (customer_id, datetime_payment, payment_method_code, amount_payment) VALUES
  (1, '2026-06-01 10:30:00', 'CRED', 45.00),
  (2, '2026-06-03 12:00:00', 'DEB',  45.00),
  (3, '2026-06-06 09:30:00', 'CASH', 45.00),
  (1, '2026-06-02 11:00:00', 'CRED', 45.00), 
  (4, '2026-06-10 14:15:00', 'DEB',  45.00); 