--- =====================================================================
--- VIEW 1: Combines customer info with their address for easy access.
--- =====================================================================
DROP VIEW IF EXISTS "customer_details" CASCADE;
CREATE VIEW "customer_details" AS
SELECT
  c.*,
  a.line_1,
  a.line_2,
  a.line_3,
  a.city,
  a.state_province,
  a.country,
  a.zip_postcode
FROM "Customers" c
LEFT JOIN "Addresses" a ON a.address_id = c.customer_address_id;


--- =====================================================================
--- VIEW 2: Combines lesson info with customer, instructor, vehicle, and lesson type details.
--- =====================================================================
DROP VIEW IF EXISTS "lesson_details" CASCADE;
CREATE VIEW "lesson_details" AS
SELECT
    l.lesson_id,
    l.lesson_date,
    l.lesson_time,
    l.price,
    l.lesson_status_code,
    l.other_lesson_details,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.phone_number AS customer_phone,
    s.first_name || ' ' || s.last_name AS instructor_name,
    v.vehicle_details,
    lt.duration_minutes,
    lt.lesson_details,
    ls.lesson_status_description
FROM "Lessons" l
JOIN "Customers" c ON c.customer_id = l.customer_id
JOIN "Staff" s ON s.staff_id = l.staff_id
JOIN "Vehicles" v ON v.vehicle_id = l.vehicle_id
JOIN "Lesson_Types" lt ON lt.lesson_type_id = l.lesson_type_id
JOIN "Lesson_Status" ls ON ls.lesson_status_code = l.lesson_status_code;



--- =====================================================================
--- VIEW 3: Combines payment info with customer details for easy access by the front end.
--- =====================================================================
DROP VIEW IF EXISTS "payment_details" CASCADE;
CREATE VIEW "payment_details" AS
SELECT
  c.customer_id,
  c.first_name || ' ' || c.last_name AS customer_name,
  p.datetime_payment,
  p.payment_method_code,
  p.amount_payment,
  p.other_payment_details
FROM "Customer_Payments" p
LEFT JOIN "Customers" c ON c.customer_id = p.customer_id;

--- =====================================================================
--- VIEW 4: Shows all upcoming lessons with relevant details for scheduling and reminders.
--- =====================================================================
DROP VIEW IF EXISTS "upcoming_lessons" CASCADE;
CREATE VIEW "upcoming_lessons" AS
SELECT
    l.lesson_id,
    l.lesson_date,
    l.lesson_time,
    c.first_name || ' ' || c.last_name AS customer_name,
    s.first_name || ' ' || s.last_name AS instructor_name,
    v.vehicle_details,
    lt.lesson_details AS lesson_type,
    lt.duration_minutes
FROM "Lessons" l
JOIN "Customers" c ON c.customer_id = l.customer_id
LEFT JOIN "Staff" s ON s.staff_id = l.staff_id
JOIN "Vehicles" v ON v.vehicle_id = l.vehicle_id
JOIN "Lesson_Types" lt ON lt.lesson_type_id = l.lesson_type_id
WHERE l.lesson_status_code = 'BOOKED'
  AND l.lesson_date >= CURRENT_DATE
ORDER BY l.lesson_date, l.lesson_time;

--- =====================================================================
---  VIEW 5: Shows all customers with outstanding balances for follow-up and reporting.
--- =====================================================================
DROP VIEW IF EXISTS "active_customers_with_debt" CASCADE;
CREATE VIEW "active_customers_with_debt" AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email_address,
    c.phone_number,
    c.amount_outstanding,
    (SELECT MAX(lesson_date) FROM "Lessons" 
     WHERE customer_id = c.customer_id AND lesson_status_code = 'COMP') AS last_lesson_date
FROM "Customers" c
WHERE c.customer_status_code = 'ACTIVE'
  AND c.amount_outstanding > 0
ORDER BY c.amount_outstanding DESC;

--- =====================================================================
--- VIEW 6: Shows today's schedule with all relevant details for the day.
--- =====================================================================
DROP VIEW IF EXISTS "todays_schedule" CASCADE;
CREATE VIEW "todays_schedule" AS
SELECT
    l.lesson_time,
    c.first_name || ' ' || c.last_name AS customer_name,
    s.first_name || ' ' || s.last_name AS instructor_name,
    v.vehicle_details,
    lt.duration_minutes,
    l.lesson_status_code
FROM "Lessons" l
JOIN "Customers" c ON c.customer_id = l.customer_id
LEFT JOIN "Staff" s ON s.staff_id = l.staff_id
JOIN "Vehicles" v ON v.vehicle_id = l.vehicle_id
JOIN "Lesson_Types" lt ON lt.lesson_type_id = l.lesson_type_id
WHERE l.lesson_date = CURRENT_DATE
  AND l.lesson_status_code != 'CANC'
ORDER BY l.lesson_time;



--- =====================================================================
--- VIEW 7: Shows revenue by lesson type for financial reporting and analysis.
--- =====================================================================
DROP VIEW IF EXISTS "revenue_by_lesson_type" CASCADE;
CREATE VIEW "revenue_by_lesson_type" AS
SELECT
    lt.lesson_type_id,
    lt.lesson_details AS lesson_type,
    lt.duration_minutes,
    lt.lesson_standard_price,
    COUNT(l.lesson_id) AS lessons_completed,
    COALESCE(SUM(l.price), 0) AS total_revenue
FROM "Lesson_Types" lt
LEFT JOIN "Lessons" l 
    ON l.lesson_type_id = lt.lesson_type_id 
    AND l.lesson_status_code = 'COMP'
GROUP BY lt.lesson_type_id, lt.lesson_details, lt.duration_minutes, lt.lesson_standard_price
ORDER BY total_revenue DESC;



--- =====================================================================
--- VIEW 8: Shows instructor utilization metrics for performance tracking and scheduling.
--- =====================================================================
DROP VIEW IF EXISTS "instructor_utilization" CASCADE;
CREATE VIEW "instructor_utilization" AS
SELECT
    s.staff_id,
    s.first_name || ' ' || s.last_name AS instructor_name,
    s.date_joined_staff,
    COUNT(l.lesson_id) AS total_lessons_assigned,
    COUNT(*) FILTER (WHERE l.lesson_status_code = 'COMP') AS lessons_completed,
    COUNT(*) FILTER (WHERE l.lesson_status_code = 'BOOKED') AS lessons_scheduled,
    COUNT(*) FILTER (WHERE l.lesson_status_code = 'CANC') AS lessons_cancelled,
    COALESCE(SUM(lt.duration_minutes) FILTER (WHERE l.lesson_status_code = 'COMP'), 0) / 60.0 AS hours_taught,
    COALESCE(SUM(l.price) FILTER (WHERE l.lesson_status_code = 'COMP'), 0) AS revenue_generated
FROM "Staff" s
LEFT JOIN "Lessons" l ON l.staff_id = s.staff_id
LEFT JOIN "Lesson_Types" lt ON lt.lesson_type_id = l.lesson_type_id
WHERE s.date_left_staff IS NULL  -- only current staff
GROUP BY s.staff_id, s.first_name, s.last_name, s.date_joined_staff
ORDER BY revenue_generated DESC;