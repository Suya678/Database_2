import streamlit as st
import pandas as pd
from utils.db import db
from utils.login import check_session


if check_session() is False:
    st.rerun()


# --- DATA LOADING ---
def load_customer_data():
    response = db.table("Customer_Details").select("*").execute()
    return pd.DataFrame(response.data)

def load_status_options():
    response = db.table("Customer_Status").select("customer_status_code").execute()
    return [row["customer_status_code"] for row in response.data]


# --- ADD FORM ---
def render_add_form(status_options):
    with st.form("add_customer_form", clear_on_submit=True):
        first_name = st.text_input("First Name")
        last_name = st.text_input("Last Name")
        email = st.text_input("Email")
        phone = st.text_input("Phone")
        mobile = st.text_input("Mobile")
        status = st.selectbox("Status", options=status_options)
        dob = st.date_input("Date of Birth")
        notes = st.text_area("Notes")

        st.markdown("**Address**")
        line_1 = st.text_input("Line 1")
        line_2 = st.text_input("Line 2")
        city = st.text_input("City")
        state_province = st.text_input("State/Province")
        country = st.text_input("Country")
        zip_postcode = st.text_input("Zip/Postcode")

        submitted = st.form_submit_button("Add Customer")

        if submitted:
            try:
                db.rpc("add_customer_with_address", {
                    "p_first_name": first_name,
                    "p_last_name": last_name,
                    "p_email": email,
                    "p_phone": phone,
                    "p_mobile": mobile,
                    "p_status": status,
                    "p_dob": str(dob),
                    "p_notes": notes,
                    "p_line_1": line_1,
                    "p_line_2": line_2,
                    "p_city": city,
                    "p_state_province": state_province,
                    "p_country": country,
                    "p_zip_postcode": zip_postcode,
                }).execute()

                st.success("Customer added!")
                st.rerun()

            except Exception as e:
                st.error(f"Add failed: {e}")


# --- EDIT / DELETE FORM ---
def render_edit_form(selected, status_options):
    customer_id = int(selected["customer_id"])
    address_id = int(selected["customer_address_id"])

    st.subheader(f"Edit Customer #{customer_id}")

    with st.form("edit_customer_form"):
        first_name = st.text_input("First Name", value=selected["first_name"])
        last_name = st.text_input("Last Name", value=selected["last_name"])
        email = st.text_input("Email", value=selected["email_address"])
        phone = st.text_input("Phone", value=selected["phone_number"])
        mobile = st.text_input("Mobile", value=selected["cell_mobile_phone_number"])
        status = st.selectbox(
            "Status",
            options=status_options,
            index=status_options.index(selected["customer_status_code"])
            if selected["customer_status_code"] in status_options else 0,
        )
        dob = st.date_input("Date of Birth", value=pd.to_datetime(selected["date_of_birth"]).date())
        notes = st.text_area("Notes", value=selected["other_customer_details"] or "")

        st.markdown("**Address**")
        line_1 = st.text_input("Line 1", value=selected["line_1"] or "")
        line_2 = st.text_input("Line 2", value=selected["line_2"] or "")
        city = st.text_input("City", value=selected["city"] or "")
        state_province = st.text_input("State/Province", value=selected["state_province"] or "")
        country = st.text_input("Country", value=selected["country"] or "")
        zip_postcode = st.text_input("Zip/Postcode", value=selected["zip_postcode"] or "")

        submitted = st.form_submit_button("Save Changes")

        if submitted:
            try:
                db.rpc("update_customer_and_address", {
                    "p_customer_id": customer_id,
                    "p_first_name": first_name,
                    "p_last_name": last_name,
                    "p_email": email,
                    "p_phone": phone,
                    "p_mobile": mobile,
                    "p_status": status,
                    "p_dob": str(dob),
                    "p_notes": notes,
                    "p_address_id": address_id,
                    "p_line_1": line_1,
                    "p_line_2": line_2,
                    "p_city": city,
                    "p_state_province": state_province,
                    "p_country": country,
                    "p_zip_postcode": zip_postcode,
                }).execute()

                st.success("Customer updated!")
                st.rerun()

            except Exception as e:
                st.error(f"Update failed: {e}")


df = load_customer_data()
status_options = load_status_options()

with st.expander("➕ Add New Customer"):
    render_add_form(status_options)

if df.empty:
    st.info("No customers found in the database.")
else:
    st.subheader("All Customers")



    event = st.dataframe(
        df,
        width="stretch",
        hide_index=True,
        on_select="rerun",
        selection_mode="single-row", # This will create a dummy column to select a single row
    )

    selected_rows = event.selection.rows
    # This will be async, if a row is selected
    if selected_rows:
        selected = df.iloc[selected_rows[0]]
        render_edit_form(selected, status_options)