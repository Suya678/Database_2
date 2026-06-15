

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
lessons = st.Page("views/lessons.py", title="Lessons", icon="📅")
customers = st.Page("views/customers.py", title="Customers", icon="👤")
payments = st.Page("views/payments.py", title="Payments", icon="💳")
views = st.Page("views/views.py", title="Views & Reports", icon="📊")

pg = st.navigation(pages=[customers, lessons,  payments, views])
pg.run()




