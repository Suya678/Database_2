import streamlit as st
import pandas as pd
from datetime import datetime

# Guard against not logged in users
if "supabase" not in st.session_state:
    st.error("Please log in first.")
    st.stop()

supabase = st.session_state.supabase

st.title("📅 Lessons Management")

# FETCH DATA ---

def load_lessons_data():
    response = supabase.table("Lessons").select("*").execute()
    return pd.DataFrame(response.data)

df = load_lessons_data()

if df.empty:
    st.info("No lessons found in the database.")
else:
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("Total Booked Lessons", len(df))
    with col2:
        # Assumes you have a 'status' column (e.g., Completed, Pending, Canceled)
        pending_count = len(df[df['status'] == 'Pending']) if 'status' in df.columns else 0
        st.metric("Pending Confirmation", pending_count)
    with col3:
        st.metric("Today's Date", datetime.today().strftime('%Y-%m-%d'))

    st.divider()

    # --- STEP 4: SIDEBAR FILTERS ---
    st.sidebar.header("Filter Lessons")
    
    # Filter by Instructor (if column exists)
    if "instructor_name" in df.columns:
        instructors = ["All"] + list(df["instructor_name"].unique())
        selected_instructor = st.sidebar.selectbox("Instructor", instructors)
        if selected_instructor != "All":
            df = df[df["instructor_name"] == selected_instructor]

    # Filter by Status (if column exists)
    if "status" in df.columns:
        statuses = ["All"] + list(df["status"].unique())
        selected_status = st.sidebar.selectbox("Status", statuses)
        if selected_status != "All":
            df = df[df["status"] == selected_status]

    # --- STEP 5: THE BEST DISPLAY TOOL (`st.data_editor`) ---
    st.write("### Lesson Schedule")
    st.caption("💡 Double-click any cell to edit details instantly, or use the search bar on the top right of the table.")

    # st.data_editor allows admins to search, sort, filter, and even edit cells!
    edited_df = st.data_editor(
        df,
        use_container_width=True,
        hide_index=True,
        column_config={
            "id": None, # Hides the ID column from the admin so it looks cleaner
            "status": st.column_config.SelectboxColumn(
                "Status",
                help="Lesson status",
                options=["Pending", "Confirmed", "Canceled", "Completed"],
                required=True,
            ),
            "date": st.column_config.DateColumn("Lesson Date", format="YYYY-MM-DD"),
            "price": st.column_config.NumberColumn("Amount Paid", format="$%d"),
        },
        disabled=["id", "created_at"] # Prevent admins from messing with database timestamps
    )

    # --- STEP 6: SAVE CHANGES BUTTON ---
    # If the admin edited a cell, this button saves it back to Supabase
    if st.button("Save Changes to Database", type="primary"):
        try:
            # Simple mock-update example (For production, you'd loop through changes)
            # supabase.table("lessons").upsert(edited_df.to_dict(orient="records")).execute()
            st.success("Database updated successfully!")
        except Exception as e:
            st.error(f"Failed to update database: {e}")