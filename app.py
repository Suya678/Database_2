

from utils.login import get_current_user, show_login_form
import streamlit as st
from utils.db import db



# show a one-time toast/message set elsewhere in the app
toast = st.session_state.pop("toast", None)
if toast:
    kind = toast.get("kind", "success")
    msg = toast.get("msg", "")
    if kind == "success":
        st.success(msg)
    elif kind == "info":
        st.info(msg)
    elif kind == "warning":
        st.warning(msg)
    elif kind == "error":
        st.error(msg)
    else:
        st.write(msg)

st.set_page_config(page_title="Admin App", layout="wide")
# Check if user is logged in
user = get_current_user()
if user is None:
    show_login_form()


else:
    # --- PROCEED TO ADMIN APP ---    
    # Sidebar Logout Button
    st.sidebar.write(f"Logged in as: **{user.email}**")
    if st.sidebar.button("Sign Out"):
        db.auth.sign_out()
        st.session_state.clear()
        st.rerun()
    
    # 4. Load your admin management pages
    lessons = st.Page("views/lessons.py", title="Lessons", icon="📅")
    customers = st.Page("views/customers.py", title="Customers", icon="👤")
    payments = st.Page("views/payments.py", title="Payments", icon="💳")
    reports = st.Page("views/reports.py", title="Reports", icon="📊")
    views = st.Page("views/views.py", title="Reports", icon="📊")

    pg = st.navigation(pages=[customers, lessons,  payments, reports, views])
    pg.run()




