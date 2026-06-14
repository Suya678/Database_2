import streamlit as st
from .db import db

# Login Form/Screen
def show_login_form():
    st.title("Driving School Admin Portal")
    st.subheader("Please sign in to manage bookings")
    
    email = st.text_input("Admin email")
    password = st.text_input("Password", type="password")
    
    if st.button("Log In", type="primary"):
        try:
            # Use Supabase to verify this staff member
            db.auth.sign_in_with_password({"email": email, "password": password})
            st.rerun()
        except Exception as e:
            st.error("Invalid email or password. Please try again.")


# Gets the current session if the user is logged in
def get_current_user():
    try:
        session = db.auth.get_session()
        return session.user if session else None
    except Exception:
        return None
    
def check_session():
    if get_current_user() is None:
        return False
    else:
        return True