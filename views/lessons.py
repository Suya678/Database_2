import streamlit as st
import pandas as pd
from datetime import date
from utils.db import db
from utils.login import check_session


# --- DATA LOADING ---
def load_lessons_data():
    response = db.table("lesson_details").select("*").execute()
    return pd.DataFrame(response.data)

def load_active_customers():
    response = db.table("Customers").select("customer_id, first_name, last_name").eq("customer_status_code", "ACTIVE").execute()
    return response.data

def load_lesson_types():
    response = db.table("Lesson_Types").select("*").execute()
    return response.data


# --- BOOKING DIALOG ---
@st.dialog("Book a Lesson", width="large")
def booking_dialog():
    customers = load_active_customers()
    lesson_types = load_lesson_types()

    if not customers:
        st.warning("No active customers available to book.")
        return
    
    format_cust = lambda c: f"{c['first_name']} {c['last_name']} (ID: {c['customer_id']})"
    format_type = lambda t: f"{t['lesson_details']} - {t['duration_minutes']} mins (${t['lesson_standard_price']})"

    selected_customer = st.selectbox("Customer *", options=customers, format_func=format_cust, index=None)
    selected_type = st.selectbox("Lesson Type *", options=lesson_types, format_func=format_type, index=None)
    lesson_date = st.date_input("Lesson Date *", min_value=date.today(), value=None)

    # We need these pieces of info to even query for available times
    if not (selected_customer and selected_type and lesson_date):
        st.caption("Fill in customer, lesson type, and date to see available times.")
        return

    duration = selected_type["duration_minutes"]
    times_resp = db.rpc("get_available_times", {
        "p_date": str(lesson_date),
        "p_duration_minutes": duration,
    }).execute()
    available_times = [t["available_time"] for t in times_resp.data]

    if not available_times:
        st.warning(f"No available slots on {lesson_date} for a {duration}-minute lesson.")
        return

    selected_time = st.selectbox("Available Times *", options=available_times, index=None)
    if not selected_time:
        return

    staff_resp = db.rpc("get_available_staff", {
        "p_date": str(lesson_date), "p_time": selected_time, "p_duration_minutes": duration
    }).execute()
    vehicle_resp = db.rpc("get_available_vehicles", {
        "p_date": str(lesson_date), "p_time": selected_time, "p_duration_minutes": duration
    }).execute()

    available_staff = staff_resp.data
    available_vehicles = vehicle_resp.data

    if not available_staff or not available_vehicles:
        st.error("No instructors or vehicles available for this slot.")
        return

    format_staff = lambda s: f"{s['first_name']} {s['last_name']}"
    format_veh = lambda v: v["vehicle_details"]

    selected_staff = st.selectbox("Instructor *", options=available_staff, format_func=format_staff, index=None)
    selected_vehicle = st.selectbox("Vehicle *", options=available_vehicles, format_func=format_veh, index=None)
    notes = st.text_area("Lesson Notes (Optional)")
    price = st.number_input("Price ($)", value=float(selected_type["lesson_standard_price"]), min_value=0.0, max_value=99999999.99,format="%.2f",)

    if not (selected_staff and selected_vehicle):
        return

    if st.button("Book Lesson", type="primary", use_container_width=True):
        try:
            db.table("Lessons").insert({
                "customer_id": selected_customer["customer_id"],
                "lesson_type_id": selected_type["lesson_type_id"],
                "lesson_date": str(lesson_date),
                "lesson_time": str(selected_time),
                "staff_id": selected_staff["staff_id"],
                "vehicle_id": selected_vehicle["vehicle_id"],
                "price": price,
                "lesson_status_code": "BOOKED",
                "other_lesson_details": notes if notes else None,
            }).execute()
            st.session_state["toast"] = {"msg": "Lesson booked!", "kind": "success"}
            st.rerun()  # closes the dialog and refreshes the page
        except Exception as e:
            st.error(f"Booking failed: {e}")

# --- ADD LESSON  ---
def render_add_lesson_flow():
    st.markdown("**1. Select Customer & Lesson Type**")
    customers = load_active_customers()
    lesson_types = load_lesson_types()

    if not customers:
        st.warning("No active customers available to book.")
        return

    # Formatting functions for dropdowns
    format_cust = lambda c: f"{c['first_name']} {c['last_name']} (ID: {c['customer_id']})"
    format_type = lambda t: f"{t['lesson_details']} - {t['duration_minutes']} mins (${t['lesson_standard_price']})"

    selected_customer = st.selectbox("Customer *", options=customers, format_func=format_cust, index=None)
    selected_type = st.selectbox("Lesson Type *", options=lesson_types, format_func=format_type, index=None)
    lesson_date = st.date_input("Lesson Date *", min_value=date.today(), value=None)

    # Only proceed if we have a type and a date
    if selected_type and lesson_date and selected_customer:
        duration = selected_type["duration_minutes"]
        st.markdown("**2. Select Time**")
        # RPC Call 1: Get available times for this date and duration
        times_resp = db.rpc("get_available_times", {
            "p_date": str(lesson_date), 
            "p_duration_minutes": duration
        }).execute()
        
        available_times = [t["available_time"] for t in times_resp.data]

        if not available_times:
            st.warning(f"No available slots on {lesson_date} for a {duration}-minute lesson.")
        else:
            selected_time = st.selectbox("Available Times *", options=available_times)

            if selected_time:
                st.markdown("**3. Select Instructor & Vehicle**")
                # RPC Call 2 & 3: Get available staff and vehicles for this EXACT slot
                staff_resp = db.rpc("get_available_staff", {
                    "p_date": str(lesson_date), "p_time": selected_time, "p_duration_minutes": duration
                }).execute()
                
                vehicle_resp = db.rpc("get_available_vehicles", {
                    "p_date": str(lesson_date), "p_time": selected_time, "p_duration_minutes": duration
                }).execute()

                available_staff = staff_resp.data
                available_vehicles = vehicle_resp.data

                if not available_staff or not available_vehicles:
                    st.error("Error: Instructors or Vehicles became unavailable.")
                else:
                    format_staff = lambda s: f"{s['first_name']} {s['last_name']}"
                    format_veh = lambda v: v['vehicle_details']

                    selected_staff = st.selectbox("Instructor *", options=available_staff, format_func=format_staff)
                    selected_vehicle = st.selectbox("Vehicle *", options=available_vehicles, format_func=format_veh)
                    notes = st.text_area("Lesson Notes (Optional)")

                    # Final Submission
                    if st.button("Book Lesson", type="primary"):
                        try:
                            db.table("Lessons").insert({
                                "customer_id": selected_customer["customer_id"],
                                "lesson_type_id": selected_type["lesson_type_id"],
                                "lesson_date": str(lesson_date),  # Store as datetime or separate date/time as needed
                                "lesson_time": str(selected_time),
                                "staff_id": selected_staff["staff_id"],
                                "vehicle_id": selected_vehicle["vehicle_id"],
                                "price": selected_type["lesson_standard_price"],
                                "lesson_status_code": "BOOKED",
                                "other_lesson_details": notes if notes else None,
                            }).execute()
                            st.session_state["toast"] = {"msg": "Lesson booked!", "kind": "success"}
                            st.rerun()
                        except Exception as e:
                            st.error(f"Booking failed: {e}")

# --- EDIT / CANCEL FORM ---
def render_manage_lesson_form(selected):
    lesson_id = int(selected["lesson_id"])
    current_status = selected["lesson_status_code"]

    st.subheader(f"Manage Lesson #{lesson_id}")
    st.write(f"**Date:** {selected['lesson_date']} | **Time:** {selected['lesson_time']}")
    st.write(f"**Status:** {current_status}")

    st.markdown("---")

    # Cancel Button
    cancel_disabled = current_status in ("CANC", "COMP") # Can't cancel if already cancelled or completed
    if st.button("🚫 Cancel Lesson", disabled=cancel_disabled, use_container_width=True):
        try:
            db.table("Lessons").update(
                {"lesson_status_code": "CANC"}
            ).eq("lesson_id", lesson_id).execute()
            st.session_state["toast"] = {"msg": "Lesson cancelled!", "kind": "success"}
            st.rerun()
        except Exception as e:
            st.error(f"Cancellation failed: {e}")

    # Delete Button must be confirmed and is disabled for completed lessons
    delete_disabled_reason = "Completed lessons cannot be deleted." if current_status == "COMP" else None
    confirm = st.checkbox("Confirm Delete", key=f"confirm_delete_{lesson_id}")
    delete_disabled = not confirm or current_status == "COMP"

    if st.button("🗑️ Delete Record", disabled=delete_disabled, use_container_width=True):
        try:
            db.table("Lessons").delete().eq("lesson_id", lesson_id).execute()
            st.session_state["toast"] = {"msg": "Lesson permanently deleted!", "kind": "success"}
            st.rerun()
        except Exception as e:
            st.error(f"Delete failed: {e}")

    if delete_disabled_reason:
        st.caption(delete_disabled_reason)

df = load_lessons_data()


if st.button("➕ Book New Lesson", type="primary"):
    booking_dialog()

if df.empty:
    st.info("No lessons found in the database.")
else:
    st.subheader("All Lessons")

    # Dataframe with selection enabled
    event = st.dataframe(
        df,
        width="stretch",
        hide_index=True,
        on_select="rerun",
        selection_mode="single-row",
    )

    selected_rows = event.selection.rows
    if selected_rows:
        selected = df.iloc[selected_rows[0]]
        render_manage_lesson_form(selected)