import streamlit as st
import pandas as pd
from utils.db import db



st.title("Reports/Views")

tab1, tab2, tab3, tab4, tab5 = st.tabs([
    "Upcoming Lessons",
    "Outstanding Balances",
    "Today's Schedule",
    "Revenue by Type",
    "Instructor Utilization",
])


# --- TAB 1: Upcoming Lessons ---
with tab1:
    st.subheader("Upcoming Booked Lessons")
    st.caption("All scheduled lessons from today onward.")

    df = pd.DataFrame(db.table("upcoming_lessons").select("*").execute().data)

    if df.empty:
        st.info("No upcoming lessons.")
    else:
        col1, col2 = st.columns(2)
        col1.metric("Total Upcoming", len(df))
        col2.metric("Next Lesson", f"{df.iloc[0]['lesson_date']} {df.iloc[0]['lesson_time']}")

        st.dataframe(
            df,
            width="stretch",
            hide_index=True,
            column_config={
                "lesson_id": None,
                "lesson_date": st.column_config.DateColumn("Date"),
                "lesson_time": "Time",
                "customer_name": "Customer",
                "instructor_name": "Instructor",
                "vehicle_details": "Vehicle",
                "lesson_type": "Lesson Type",
                "duration_minutes": st.column_config.NumberColumn("Duration (min)"),
            },
        )


# --- TAB 2: Outstanding Balances ---
with tab2:
    st.subheader("Active Customers with Outstanding Balances")
    st.caption("Customers who currently owe money. Sorted by amount owed.")

    df = pd.DataFrame(db.table("active_customers_with_debt").select("*").execute().data)

    if df.empty:
        st.success("🎉 No active customers have outstanding balances!")
    else:
        total_owed = df["amount_outstanding"].sum()
        col1, col2 = st.columns(2)
        col1.metric("Customers with Debt", len(df))
        col2.metric("Total Owed", f"${float(total_owed):,.2f}")

        st.markdown("**Top Debtors**")
        chart_df = df.head(10).set_index("customer_name")[["amount_outstanding"]]
        st.bar_chart(chart_df, height=300)

        st.markdown("**Details**")
        st.dataframe(
            df,
            width="stretch",
            hide_index=True,
            column_config={
                "customer_id": None,
                "customer_name": "Customer",
                "email_address": "Email",
                "phone_number": "Phone",
                "amount_outstanding": st.column_config.NumberColumn(
                    "Amount Owed", format="$%.2f"
                ),
                "last_lesson_date": st.column_config.DateColumn("Last Lesson"),
            },
        )


# --- TAB 3: Today's Schedule ---
with tab3:
    st.subheader(f"Today's Schedule — {pd.Timestamp.today().date()}")
    st.caption("Lessons happening today (excluding cancellations).")

    df = pd.DataFrame(db.table("todays_schedule").select("*").execute().data)

    if df.empty:
        st.info("No lessons scheduled for today.")
    else:
        col1, col2 = st.columns(2)
        col1.metric("Lessons Today", len(df))
        col2.metric("Total Hours", f"{df['duration_minutes'].sum() / 60:.1f}")

        st.dataframe(
            df,
            width="stretch",
            hide_index=True,
            column_config={
                "lesson_time": "Time",
                "customer_name": "Customer",
                "instructor_name": "Instructor",
                "vehicle_details": "Vehicle",
                "duration_minutes": st.column_config.NumberColumn("Duration (min)"),
                "lesson_status_code": "Status",
            },
        )


# --- TAB 4: Revenue by Lesson Type ---
with tab4:
    st.subheader("Revenue by Lesson Type")
    st.caption("Completed lesson revenue, ranked by total income.")

    df = pd.DataFrame(db.table("revenue_by_lesson_type").select("*").execute().data)

    if df.empty or df["total_revenue"].sum() == 0:
        st.info("No completed lessons yet.")
    else:
        total_revenue = df["total_revenue"].sum()
        total_lessons = df["lessons_completed"].sum()

        col1, col2, col3 = st.columns(3)
        col1.metric("Total Revenue", f"${float(total_revenue):,.2f}")
        col2.metric("Lessons Completed", f"{int(total_lessons):,}")
        col3.metric("Avg per Type", f"${float(total_revenue / max(len(df), 1)):,.2f}")

        st.markdown("**Revenue by Type**")
        chart_df = df.set_index("lesson_type")[["total_revenue"]]
        st.bar_chart(chart_df, height=300)

        st.markdown("**Details**")
        st.dataframe(
            df,
            width="stretch",
            hide_index=True,
            column_config={
                "lesson_type_id": None,
                "lesson_type": "Lesson Type",
                "duration_minutes": st.column_config.NumberColumn("Duration (min)"),
                "lesson_standard_price": st.column_config.NumberColumn(
                    "Standard Price", format="$%.2f"
                ),
                "lessons_completed": st.column_config.NumberColumn("Completed"),
                "total_revenue": st.column_config.NumberColumn(
                    "Total Revenue", format="$%.2f"
                ),
            },
        )

        top = df.iloc[0]
        if top["total_revenue"] > 0:
            st.success(
                f"💰 **Top driver:** {top['lesson_type']} — "
                f"${float(top['total_revenue']):,.2f} from {int(top['lessons_completed'])} lessons."
            )


# --- TAB 5: Instructor Utilization ---
with tab5:
    st.subheader("Instructor Performance")
    st.caption("Lessons taught, hours, and revenue per active instructor.")

    df = pd.DataFrame(db.table("instructor_utilization").select("*").execute().data)

    if df.empty:
        st.info("No instructor data.")
    else:
        col1, col2, col3, col4 = st.columns(4)
        col1.metric("Active Instructors", len(df))
        col2.metric("Lessons Taught", int(df["lessons_completed"].sum()))
        col3.metric("Hours Taught", f"{float(df['hours_taught'].sum()):.1f}")
        col4.metric("Total Revenue", f"${float(df['revenue_generated'].sum()):,.2f}")

        st.markdown("**Revenue per Instructor**")
        chart_df = df.set_index("instructor_name")[["revenue_generated"]]
        st.bar_chart(chart_df, height=300)

        st.markdown("**Details**")
        st.dataframe(
            df,
            width="stretch",
            hide_index=True,
            column_config={
                "staff_id": None,
                "instructor_name": "Instructor",
                "date_joined_staff": st.column_config.DateColumn("Joined"),
                "total_lessons_assigned": st.column_config.NumberColumn("Assigned"),
                "lessons_completed": st.column_config.NumberColumn("Completed"),
                "lessons_scheduled": st.column_config.NumberColumn("Upcoming"),
                "lessons_cancelled": st.column_config.NumberColumn("Cancelled"),
                "hours_taught": st.column_config.NumberColumn("Hours", format="%.1f"),
                "revenue_generated": st.column_config.NumberColumn(
                    "Revenue", format="$%.2f"
                ),
            },
        )

        top = df.iloc[0]
        if top["revenue_generated"] > 0:
            st.success(
                f"🏆 **Top performer:** {top['instructor_name']} — "
                f"{int(top['lessons_completed'])} lessons, "
                f"${float(top['revenue_generated']):,.2f} revenue."
            )