

-- =====================================================================
--- 1. Procedure/Trigger TO PREVENT DOUBLE BOOKING OF LESSIONS ---
--- ALLL LESSIONS ARE ASSUEMD TO BE 1 HOUR ---
CREATE OR REPLACE FUNCTION check_double_booking()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
  lesson_duration interval := '1 hour';
BEGIN
  IF EXISTS (
    SELECT 1 FROM "Lessons"
    WHERE staff_id = NEW.staff_id
      AND lesson_id <> COALESCE(NEW.lesson_id, -1)
      AND lesson_status_code != 'CANC'
      AND (NEW.lesson_datetime, NEW.lesson_datetime + lesson_duration)
          OVERLAPS (lesson_datetime, lesson_datetime + lesson_duration)
  ) THEN
    RAISE EXCEPTION 'Staff member % already has a lesson scheduled at this time', NEW.staff_id;
  END IF;

  IF EXISTS (
    SELECT 1 FROM "Lessons"
    WHERE vehicle_id = NEW.vehicle_id
      AND lesson_id <> COALESCE(NEW.lesson_id, -1)
      AND lesson_status_code != 'CANC'
      AND (NEW.lesson_datetime, NEW.lesson_datetime + lesson_duration)
          OVERLAPS (lesson_datetime, lesson_datetime + lesson_duration)
  ) THEN
    RAISE EXCEPTION 'Vehicle % is already booked at this time', NEW.vehicle_id;
  END IF;

  IF EXISTS (
    SELECT 1 FROM "Lessons"
    WHERE customer_id = NEW.customer_id
      AND lesson_id <> COALESCE(NEW.lesson_id, -1)
      AND lesson_status_code != 'CANC'
      AND (NEW.lesson_datetime, NEW.lesson_datetime + lesson_duration)
          OVERLAPS (lesson_datetime, lesson_datetime + lesson_duration)
  ) THEN
    RAISE EXCEPTION 'Customer % already has a lesson scheduled at this time', NEW.customer_id;
  END IF;

  RETURN NEW;
END;
$$ ;

CREATE TRIGGER trg_check_double_booking
  BEFORE INSERT OR UPDATE ON "Lessons"
  FOR EACH ROW
  EXECUTE FUNCTION check_double_booking();
-- =====================================================================



-- =====================================================================
--- 2. PROCEDURE TO RECORD PAYMENT ---
CREATE OR REPLACE PROCEDURE record_payment(
  p_customer_id  int,
  p_amount       decimal(10,2),
  p_method       varchar(10)
)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO "Customer_Payments" (customer_id, datetime_payment, payment_method_code, amount_payment)
  VALUES (p_customer_id, NOW(), p_method, p_amount);
END;
$$;
-- =====================================================================

-- =====================================================================
--- 3. PROCEDURE TO BOOK A LESSION ---
CREATE OR REPLACE PROCEDURE book_lesson(
  p_lesson_type_id int,
  p_customer_id    int,
  p_staff_id       int,
  p_vehicle_id     int,
  p_lesson_datetime timestamptz
)
LANGUAGE plpgsql AS $$
DECLARE
  v_price decimal(10,2);
BEGIN
  SELECT price INTO v_price FROM "Lesson_Types" WHERE lesson_type_id = p_lesson_type_id;
  INSERT INTO "Lessons" (lesson_type_id, customer_id, staff_id, vehicle_id, lesson_status_code, lesson_datetime, price)
  VALUES (p_lesson_type_id, p_customer_id, p_staff_id, p_vehicle_id, 'BOOKED', p_lesson_datetime, v_price);
END;
$$;
-- =====================================================================

