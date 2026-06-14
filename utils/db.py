import streamlit as st
from supabase import create_client, Client

# Initialize the base Supabase connection
db = create_client(st.secrets["SUPABASE_URL"], st.secrets["SUPABASE_KEY"])


