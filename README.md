# Driving School Admin Portal

A Streamlit admin app for managing a driving school — customers, lesson bookings,
payments, and reporting views. Data is stored in [Supabase](https://supabase.com)
(Postgres).

## Features

- **Customers** — add, edit, and delete customers with full address details
- **Lessons** — book lessons with live availability checks for times, instructors,
  and vehicles; cancel or delete existing lessons
- **Payments** — record payments and refunds; balances update automatically
- **Views** — reporting dashboards (upcoming lessons, outstanding balances,
  today's schedule, revenue by lesson type, instructor utilization)

## Stack

- Python / [Streamlit](https://streamlit.io)
- [Supabase](https://supabase.com) (Postgres) via `supabase-py`

## Setup

1. **Create a virtual environment and install dependencies**

   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Configure secrets** — create `.streamlit/secrets.toml`:

   ```toml
   SUPABASE_URL = "https://<your-project>.supabase.co"
   SUPABASE_KEY = "<your-supabase-key>"
   ```

   This file is gitignored. Do not commit it.

3. **Set up the database** — run the scripts in `db_scripts/` against your
   Supabase project, in order:
   ```
   schema.sql      # tables
   views.sql       # reporting views
   trig_proc.sql   # triggers and stored procedures
   seed.sql        # sample data (optional)
   ```

## Run

```bash
streamlit run app.py
```

## Project structure

```
app.py            Entry point and page navigation
utils/            Database client and auth helpers
views/            One file per page (customers, lessons, payments, views)
db_scripts/       SQL schema, views, procedures, and seed data
```
