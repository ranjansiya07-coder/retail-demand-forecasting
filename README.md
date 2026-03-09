# Retail Demand Forecasting & Inventory Optimization

## Project Overview
This project develops an end-to-end retail demand forecasting system using SQL and Machine Learning to predict daily store sales and support inventory planning decisions.

The solution combines SQL-based business analysis with machine learning models to forecast demand and determine optimal inventory reorder points, helping reduce stock-outs and improve operational efficiency.

---

## Dataset
Rossmann Store Sales Dataset (Kaggle)

- Daily sales data from **1,115 retail stores**
- Time period: **January 2013 – July 2015**
- Total records: **836,000+ transactions**

Key variables include:

Store, Date, Sales, Customers, Promo, StoreType, Assortment, CompetitionDistance, SchoolHoliday, StateHoliday, and promotional indicators.

---

## Project Workflow

### 1. Data Cleaning & Preprocessing
- Removed records where stores were closed
- Removed zero-sales records
- Converted Date column to datetime format
- Handled missing values in competition and promotion fields
- Prepared dataset for analysis and modeling

---

### 2. Feature Engineering
Additional features were created to capture time-based demand patterns:

- Year
- Month
- Week Number
- Quarter
- DayOfWeek
- IsWeekend
- Lag_7 (sales from 7 days ago)
- Rolling_Mean_7 (7-day moving average)

These features help the model capture **seasonality and short-term demand momentum**.

---

### 3. SQL Business Analysis
SQL was used to perform business-level analysis including:

- Total sales and transaction analysis
- Store-wise revenue contribution
- Monthly and yearly sales trends
- Promotion impact on sales
- Weekend vs weekday demand patterns
- Store ranking using window functions
- Running total and month-over-month growth analysis

---

### 4. Exploratory Data Analysis
EDA was performed to understand sales distribution, seasonality, and promotional impact.

Key insights:

- Sales distribution is right-skewed
- Significant sales spikes during year-end months
- Promotions significantly increase average sales
- Weekly demand patterns show cyclical behavior

---

### 5. Machine Learning Models
Multiple regression models were trained and compared:

- Linear Regression
- Decision Tree Regressor
- Random Forest Regressor
- XGBoost Regressor

Evaluation Metrics:

- Mean Absolute Error (MAE)
- Root Mean Squared Error (RMSE)
- R² Score

Best Model: **Random Forest Regressor (R² ≈ 0.90)**

Random Forest captured complex demand patterns and provided the best predictive performance.

---

### 6. Inventory Optimization
Forecasted demand was used to calculate optimal inventory reorder points.

Reorder Point Formula:

Reorder Point = (Average Daily Demand × Lead Time) + Safety Stock

Safety Stock Formula:

Safety Stock = Z × Demand Standard Deviation × √Lead Time

Where:

- Lead Time = 7 days
- Z = 1.65 (95% service level)

This approach helps balance inventory availability while minimizing overstocking risk.

---

### 7. Model Deployment
The final model was deployed using **Streamlit** to create an interactive forecasting interface.

The application allows users to:

- Input store-level operational features
- Generate real-time daily sales predictions
- Calculate suggested inventory reorder points

This demonstrates the transition from analytical modeling to a usable business application.

---


---

## Technologies Used

Python  
SQL  
Pandas  
NumPy  
Scikit-learn  
Streamlit  
Matplotlib / Seaborn  

---

## Business Impact

This system enables retail businesses to:

- Forecast future product demand
- Identify seasonal sales patterns
- Optimize inventory planning
- Reduce stock-out risks
- Improve operational decision-making

---

## Author

Ranjan  
Data Science & Analytics
