import streamlit as st
import pickle
import pandas as pd
import numpy as np

st.set_page_config(page_title="Retail Sales Predictor", layout="wide")

st.title("Retail Sales Forecasting & Inventory Optimization")
st.markdown("Predict daily sales using advanced retail features.")

model = pickle.load(open("rf_model.pkl", "rb"))
model_columns = pickle.load(open("model_columns.pkl", "rb"))

st.divider()

col1, col2 = st.columns(2)

with col1:
    store = st.number_input("Store ID", 1, 1115, 1)
    open_store = st.selectbox("Store Open?", [1, 0])
    promo = st.selectbox("Promo Running?", [0, 1])
    promo2 = st.selectbox("Promo2 Active?", [0, 1])
    school_holiday = st.selectbox("School Holiday?", [0, 1])
    state_holiday = st.selectbox("State Holiday", ["0", "a", "b", "c"])

with col2:
    store_type = st.selectbox("Store Type", ["a", "b", "c", "d"])
    assortment = st.selectbox("Assortment Type", ["a", "b", "c"])
    competition_distance = st.number_input("Competition Distance", 0.0, 10000.0, 500.0)
    comp_open_month = st.slider("Competition Open Since Month", 1, 12, 6)
    comp_open_year = st.slider("Competition Open Since Year", 2000, 2025, 2010)

st.divider()

col3, col4 = st.columns(2)

with col3:
    day_of_week = st.slider("Day of Week (0=Mon, 6=Sun)", 0, 6)
    year = st.slider("Year", 2013, 2015, 2015)
    month = st.slider("Month", 1, 12, 6)
    week = st.slider("Week Number", 1, 52, 25)
    quarter = st.slider("Quarter", 1, 4, 2)

with col4:
    lag_7 = st.number_input("Sales 7 Days Ago", 0.0, 50000.0, 5000.0)
    rolling_mean_7 = st.number_input("Rolling Mean (Last 7 Days)", 0.0, 50000.0, 6000.0)
    is_weekend = st.selectbox("Is Weekend?", [0, 1])

st.divider()

if st.button("Predict Sales"):

    input_data = pd.DataFrame(columns=model_columns)
    input_data.loc[0] = 0

    # Basic features
    input_data["Store"] = store
    input_data["Open"] = open_store
    input_data["Promo"] = promo
    input_data["Promo2"] = promo2
    input_data["SchoolHoliday"] = school_holiday
    input_data["CompetitionDistance"] = competition_distance
    input_data["CompetitionOpenSinceMonth"] = comp_open_month
    input_data["CompetitionOpenSinceYear"] = comp_open_year
    input_data["Year"] = year
    input_data["Month"] = month
    input_data["Week"] = week
    input_data["Quarter"] = quarter
    input_data["DayOfWeek"] = day_of_week
    input_data["Lag_7"] = lag_7
    input_data["Rolling_Mean_7"] = rolling_mean_7
    input_data["IsWeekend"] = is_weekend

    # One-hot encoding manually
    input_data[f"StateHoliday_{state_holiday}"] = 1
    if store_type != "a":
        input_data[f"StoreType_{store_type}"] = 1
    if assortment != "a":
        input_data[f"Assortment_{assortment}"] = 1

    prediction = model.predict(input_data)[0]

    st.success(f" Predicted Daily Sales: ₹ {prediction:,.2f}")

    # Inventory logic
    lead_time = 7
    z_value = 1.65
    demand_std = rolling_mean_7 * 0.2
    safety_stock = z_value * demand_std * np.sqrt(lead_time)
    reorder_point = (prediction * lead_time) + safety_stock

    st.info(f" Suggested Reorder Point: {int(reorder_point):,} units")
