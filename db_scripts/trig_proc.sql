
-- =====================================================================
--- Function 1: Add Customer with address
-- =====================================================================
CREATE OR REPLACE FUNCTION add_customer_with_address(
  p_first_name varchar,
  p_last_name varchar,
  p_email varchar,
  p_phone varchar,
  p_mobile varchar,
  p_status varchar,
  p_dob date,
  p_notes text,
  p_line_1 varchar,
  p_line_2 varchar,
  p_line_3 varchar,
  p_city varchar,
  p_state_province varchar,
  p_country varchar,
  p_zip_postcode varchar
)
RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE
  v_address_id int;
  v_customer_id int;
BEGIN
  -- Insert address first
  INSERT INTO "Addresses" (
    line_1,
    line_2,
    line_3,
    city,
    state_province,
    country,
    zip_postcode
  )
  VALUES (
    p_line_1,
    p_line_2,
    p_line_3,
    p_city,
    p_state_province,
    p_country,
    p_zip_postcode
  )
  RETURNING address_id INTO v_address_id;

  -- Insert customer linked to address
  INSERT INTO "Customers" (
    first_name,
    last_name,
    email_address,
    phone_number,
    cell_mobile_phone_number,
    customer_status_code,
    date_of_birth,
    date_became_customer,
    other_customer_details,
    customer_address_id
  )
  VALUES (
    p_first_name,
    p_last_name,
    p_email,
    p_phone,
    p_mobile,
    p_status,
    p_dob,
    NOW(),
    p_notes,
    v_address_id
  )
  RETURNING customer_id INTO v_customer_id;
  RETURN v_customer_id;

END;
$$;
-- =====================================================================



-- =====================================================================
--- Function 2: Update Customer and Address
-- =====================================================================
CREATE OR REPLACE function update_customer_and_address(
  p_customer_id int,
  p_first_name varchar,
  p_last_name varchar,
  p_email varchar,
  p_phone varchar,
  p_mobile varchar,
  p_status varchar,
  p_dob date,
  p_notes text,
  p_address_id int,
  p_line_1 varchar,
  p_line_2 varchar,
  p_line_3 varchar,
  p_city varchar,
  p_state_province varchar,
  p_country varchar,
  p_zip_postcode varchar
)
Returns void
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE "Customers" SET
    first_name = p_first_name,
    last_name = p_last_name,
    email_address = p_email,
    phone_number = p_phone,
    cell_mobile_phone_number = p_mobile,
    customer_status_code = p_status,
    date_of_birth = p_dob,
    other_customer_details = p_notes
  WHERE customer_id = p_customer_id;

  UPDATE "Addresses" SET
    line_1 = p_line_1,
    line_2 = p_line_2,
    line_3 = p_line_3,
    city = p_city,
    state_province = p_state_province,
    country = p_country,
    zip_postcode = p_zip_postcode
  WHERE address_id = p_address_id;
END;
$$;

--- =====================================================================
--- Function 3: Get available time slots for a given date and duration
--- Returns time slots where at least one staff and one vehicle are free
--- =====================================================================
CREATE OR REPLACE FUNCTION get_available_times(
    p_date date,
    p_duration_minutes int
)
RETURNS TABLE (available_time time)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH slots AS (
        SELECT generate_series(
            (p_date + time '09:00'),
            (p_date + time '17:00') - (p_duration_minutes || ' min')::interval,
            interval '15 min'
        ) AS slot_start
    )
    SELECT slot_start::time
    FROM slots s
    WHERE
        -- some staff is free
        (SELECT COUNT(*) FROM "Staff") > (
            SELECT COUNT(DISTINCT l.staff_id)
            FROM "Lessons" l
            JOIN "Lesson_Types" lt USING (lesson_type_id)
            WHERE l.lesson_date = p_date
              AND l.lesson_status_code != 'CANC'
              AND l.staff_id IS NOT NULL
              AND (l.lesson_date + l.lesson_time) < s.slot_start + (p_duration_minutes || ' min')::interval
              AND (l.lesson_date + l.lesson_time + (lt.duration_minutes || ' min')::interval) > s.slot_start
        )
        AND
        -- some vehicle is free
        (SELECT COUNT(*) FROM "Vehicles") > (
            SELECT COUNT(DISTINCT l.vehicle_id)
            FROM "Lessons" l
            JOIN "Lesson_Types" lt USING (lesson_type_id)
            WHERE l.lesson_date = p_date
              AND l.lesson_status_code != 'CANC'
              AND (l.lesson_date + l.lesson_time) < s.slot_start + (p_duration_minutes || ' min')::interval
              AND (l.lesson_date + l.lesson_time + (lt.duration_minutes || ' min')::interval) > s.slot_start
        );
END;
$$;


-- =====================================================================

--- =====================================================================
--- Function 4: Get available staff for a given date, time and duration
--- Returns staff members who are free during the specified time slot
--- =====================================================================
CREATE OR REPLACE FUNCTION get_available_staff(
    p_date date,
    p_time time,
    p_duration_minutes int
)
RETURNS TABLE (staff_id int, first_name varchar, last_name varchar)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT s.staff_id, s.first_name, s.last_name
    FROM "Staff" s
    WHERE NOT EXISTS (
        -- Check for any overlapping lessons for this specific staff member
        SELECT 1 
        FROM "Lessons" l
        JOIN "Lesson_Types" lt ON l.lesson_type_id = lt.lesson_type_id
        WHERE l.staff_id = s.staff_id
          AND l.lesson_date = p_date
          AND l.lesson_status_code != 'CANC'
          AND (p_date + p_time) < (l.lesson_date + l.lesson_time + (lt.duration_minutes || ' minutes')::interval)
          AND (p_date + p_time + (p_duration_minutes || ' minutes')::interval) > (l.lesson_date + l.lesson_time)
    );
END;
$$;

--- =====================================================================
--- Function 5: Get available vehicles for a given date, time and duration
--- Returns vehicles that are free during the specified time slot
--- =====================================================================
CREATE OR REPLACE FUNCTION get_available_vehicles(
    p_date date,
    p_time time,
    p_duration_minutes int
)
RETURNS TABLE (vehicle_id int, vehicle_details text)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT v.vehicle_id, v.vehicle_details
    FROM "Vehicles" v
    WHERE NOT EXISTS (
        -- Check for any overlapping lessons for this specific vehicle
        SELECT 1 
        FROM "Lessons" l
        JOIN "Lesson_Types" lt ON l.lesson_type_id = lt.lesson_type_id
        WHERE l.vehicle_id = v.vehicle_id
          AND l.lesson_date = p_date
          AND l.lesson_status_code != 'CANC'
          AND (p_date + p_time) < (l.lesson_date + l.lesson_time + (lt.duration_minutes || ' minutes')::interval)
          AND (p_date + p_time + (p_duration_minutes || ' minutes')::interval) > (l.lesson_date + l.lesson_time)
    );
END;
$$;

--- =====================================================================
--- Function 6: Prevent deletion of completed lessons
--- Completed lessons are important for historical records and financial calculations( amount outstanding = sum of completed lessons - sum of payments ), so we block their deletion.
--- =====================================================================
CREATE OR REPLACE FUNCTION check_lesson_before_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Direct lesson delete: block if completed because customers balance are determined by it
    IF OLD.lesson_status_code = 'COMP' THEN
        RAISE EXCEPTION 'Cannot delete a completed lesson';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER trg_prevent_delete_completed_lesson 
BEFORE DELETE ON "Lessons"
FOR EACH ROW
WHEN (pg_trigger_depth() = 0)  -- only fire on direct deletes, not cascades
EXECUTE FUNCTION check_lesson_before_delete();
--- =====================================================================


--- =====================================================================
--- Function 7: Enforce valid lesson status transitions
--- Only allow valid transitions between lesson statuses (e.g., BOOKED -> COMP or CANC, but not COMP -> BOOKED or CANC -> BOOKED)
--- =====================================================================
CREATE OR REPLACE FUNCTION enforce_lesson_status_transitions()
RETURNS TRIGGER AS $$
BEGIN
    -- No change, nothing to check
    IF OLD.lesson_status_code = NEW.lesson_status_code THEN
        RETURN NEW;
    END IF;
    
    -- Terminal states cannot transition out, a completed lesson cannot be cancelled vice-versa
    IF OLD.lesson_status_code IN ('COMP', 'CANC') THEN
        RAISE EXCEPTION 'Cannot change status of a % lesson', OLD.lesson_status_code;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER trg_enforce_lesson_status_transitions
BEFORE UPDATE OF lesson_status_code ON "Lessons"
FOR EACH ROW EXECUTE FUNCTION enforce_lesson_status_transitions();
--- =====================================================================



--- =====================================================================
--- Function/Trigger 8: Prevent double booking and enforce business hours
--- Ensures that a staff member, customer, or vehicle cannot be double-booked for overlapping lessons and that lessons are only scheduled during business hours (9 AM to 5 PM).
--- =================================================================
CREATE OR REPLACE FUNCTION check_lesson_validity()
RETURNS TRIGGER AS $$
DECLARE
    v_duration int;
    v_new_start timestamp;
    v_new_end timestamp;
    v_conflict_count int;
BEGIN
    -- 1. Get the duration of the lesson being booked
    SELECT duration_minutes INTO v_duration 
    FROM "Lesson_Types" 
    WHERE lesson_type_id = NEW.lesson_type_id;

    -- Calculate exact start and end timestamps
    v_new_start := NEW.lesson_date + NEW.lesson_time;
    v_new_end := v_new_start + (v_duration || ' minutes')::interval;

    -- 2. Enforce Business Hours (9 AM to 5 PM)
    IF v_new_start::time < '09:00:00'::time OR v_new_end::time > '17:00:00'::time THEN
        RAISE EXCEPTION 'Lesson falls outside of business hours (09:00 to 17:00).';
    END IF;

    -- 3. Check for double bookings (Overlap logic)
    SELECT COUNT(*) INTO v_conflict_count
    FROM "Lessons" l
    JOIN "Lesson_Types" lt ON l.lesson_type_id = lt.lesson_type_id
    WHERE l.lesson_status_code != 'CANC' -- Ignore cancelled lessons
      AND l.lesson_id IS DISTINCT FROM NEW.lesson_id -- Handle updates safely
      AND l.lesson_date = NEW.lesson_date
      AND (
          l.staff_id = NEW.staff_id OR
          l.customer_id = NEW.customer_id OR
          l.vehicle_id = NEW.vehicle_id
      )
      AND (
          -- Time overlap condition: (Start A < End B) AND (End A > Start B)
          (l.lesson_date + l.lesson_time) < v_new_end AND
          ((l.lesson_date + l.lesson_time) + (lt.duration_minutes || ' minutes')::interval) > v_new_start
      );

    IF v_conflict_count > 0 THEN
        RAISE EXCEPTION 'Double booking detected! The Customer, Staff, or Vehicle is already booked for this time slot.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_prevent_invalid_lesson
BEFORE INSERT OR UPDATE ON "Lessons"
FOR EACH ROW EXECUTE FUNCTION check_lesson_validity();


-- =====================================================================
--- Function/Trigger 9: Trigger to maintain Customers.amount_outstanding ---
--- Derived as: SUM(price of completed lessons) - SUM(payments)
--- Maintained automatically on:
---   - lesson INSERT (if status = COMP)
---   - lesson status change to/from COMP
---   - lesson DELETE (only possible if not COMP, per trigger #5)
---   - payment INSERT / UPDATE / DELETE
--- =====================================================================
CREATE OR REPLACE FUNCTION recalc_customer_balance(p_customer_id int)
RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
    v_billed   decimal(10,2);
    v_paid     decimal(10,2);
BEGIN
    SELECT COALESCE(SUM(price), 0) INTO v_billed
    FROM "Lessons"
    WHERE customer_id = p_customer_id
      AND lesson_status_code = 'COMP';

    SELECT COALESCE(SUM(amount_payment), 0) INTO v_paid
    FROM "Customer_Payments"
    WHERE customer_id = p_customer_id;

    UPDATE "Customers"
    SET amount_outstanding = v_billed - v_paid
    WHERE customer_id = p_customer_id;
END;
$$;
--- Trigger function: fires after lesson changes that could affect balance
CREATE OR REPLACE FUNCTION trg_lesson_balance_update()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM recalc_customer_balance(OLD.customer_id);
    ELSE
        PERFORM recalc_customer_balance(NEW.customer_id);
    END IF;
    RETURN NULL; 
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_lesson_changes_update_balance
AFTER INSERT OR UPDATE OR DELETE ON "Lessons"
FOR EACH ROW EXECUTE FUNCTION trg_lesson_balance_update();

-- Trigger function: fires after payment changes
CREATE OR REPLACE FUNCTION trg_payment_balance_update()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM recalc_customer_balance(OLD.customer_id);
    ELSE
        PERFORM recalc_customer_balance(NEW.customer_id);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER trg_payment_changes_update_balance
AFTER INSERT OR UPDATE OR DELETE ON "Customer_Payments"
FOR EACH ROW EXECUTE FUNCTION trg_payment_balance_update();
