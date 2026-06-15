import streamlit as st
import pandas as pd
from utils.db import db
from utils.login import check_session

if check_session() is False:
    st.rerun()

# --- DATA LOADING ---
def load_payments():
    response = db.table("payment_details").select("*").execute();
    return pd.DataFrame(response.data)

def load_customers():
    return db.table("Customers").select("customer_id, first_name, last_name").execute().data

def load_payment_methods():
    return db.table("Payment_Methods").select("payment_method_code, payment_method_description").execute().data


# --- ADD PAYMENT DIALOG ---
@st.dialog("Record Payment or Refund", width="large")
def add_payment_dialog():
    customers = load_customers()
    methods = load_payment_methods()

    if not customers:
        st.warning("No customers in the system.")
        return

    format_cust = lambda c: f"{c['first_name']} {c['last_name']} (ID: {c['customer_id']})"
    format_method = lambda m: f"{m['payment_method_code']} - {m['payment_method_description']}"

    transaction_type = st.radio("Transaction Type *", ["Payment", "Refund"], horizontal=True)
    selected_customer = st.selectbox("Customer *", options=customers, format_func=format_cust, index=None)
    selected_method = st.selectbox("Method *", options=methods, format_func=format_method, index=None)
    amount = st.number_input("Amount *", min_value=0.01, step=10.0, value=None, placeholder="0.00")
    notes = st.text_area("Notes (optional)")

    if not (selected_customer and selected_method and amount):
        st.caption("Fill in customer, method, and amount.")
        return

    label = "Record Payment" if transaction_type == "Payment" else "Issue Refund"
    if st.button(label, type="primary", use_container_width=True):
        try:
            final_amount = amount if transaction_type == "Payment" else -amount
            db.table("Customer_Payments").insert({
                "customer_id": selected_customer["customer_id"],
                "datetime_payment": pd.Timestamp.now(tz="UTC").isoformat(),
                "payment_method_code": selected_method["payment_method_code"],
                "amount_payment": final_amount,
                "other_payment_details": notes if notes else None,
            }).execute()
            st.session_state["toast"] = {
                "msg": f"{transaction_type} recorded! Balance updated.", 
                "kind": "success"
            }
            st.rerun()
        except Exception as e:
            st.error(f"Failed: {e}")


# --- DELETE FORM ---
def render_delete_form(selected):
    customer_id = int(selected["customer_id"])
    datetime_payment = selected["datetime_payment"]
    amount = selected["amount_payment"]
    is_refund = amount < 0

    st.subheader("Payment Details")
    st.write(f"**Customer:** {selected['customer_name']}")
    st.write(f"**Date:** {datetime_payment}")
    st.write(f"**Method:** {selected['payment_method_code']}")
    st.write(f"**Type:** {'Refund' if is_refund else 'Payment'}")
    st.write(f"**Amount:** ${abs(amount):.2f}")
    if selected["other_payment_details"]:
        st.write(f"**Notes:** {selected['other_payment_details']}")

    st.markdown("---")
    st.caption("Deleting recalculates the customer's balance automatically.")

    confirm = st.checkbox("Confirm Delete", key=f"confirm_{customer_id}_{datetime_payment}")
    if st.button("🗑️ Delete Payment", disabled=not confirm):
        try:
            db.table("Customer_Payments").delete() \
                .eq("customer_id", customer_id) \
                .eq("datetime_payment", datetime_payment) \
                .execute()
            st.session_state["toast"] = {"msg": "Payment deleted!", "kind": "success"}
            st.rerun()
        except Exception as e:
            st.error(f"Delete failed: {e}")


df = load_payments()

if st.button("➕ Record Payment / Refund", type="primary"):
    add_payment_dialog()

if df.empty:
    st.info("No payments recorded yet.")
else:
    st.subheader("All Payments")

    event = st.dataframe(
        df,
        width="stretch",
        hide_index=True,
        on_select="rerun",
        selection_mode="single-row",
        column_config={
            "amount_payment": st.column_config.NumberColumn(
                "Amount",
                help="Positive = payment received; Negative = refund issued",
                format="$%.2f",
            ),
        },
    )

    selected_rows = event.selection.rows
    if selected_rows:
        selected = df.iloc[selected_rows[0]]
        render_delete_form(selected)