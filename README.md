# Tech_Layoffs
Analyzed global tech layoffs using SQL and Power BI to uncover trends across companies, countries, and funding stages. Cleaned and transformed data, performed EDA, and built an interactive dashboard revealing key insights like early-stage vulnerability and top layoff contributors.
# 📊 Global Tech Layoffs: Data-Driven Insights (2020–2025)

This project analyzes global tech layoffs from March 2020 to September 2025 using SQL for data cleaning and exploratory analysis, and Power BI for interactive visualization. It uncovers patterns across companies, countries, and funding stages — revealing how early-stage firms were disproportionately affected.

## 🔍 Dataset
- Source: [Layoffs 2022 – Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
- Records: 2,800+ companies
- Fields: Company, Country, Industry, Funding Stage, Total Laid Off, Percentage Laid Off, Date

## 🧼 Data Cleaning (SQL)
- Removed duplicates using `ROW_NUMBER() OVER (PARTITION BY ...)`
- Converted text columns to proper types (`DATE`, `INT`, `DECIMAL`)
- Handled nulls and blanks with `COALESCE()` and `ISNULL()`
- Used staging tables and safe update logic

## 📊 Exploratory Analysis (SQL)
- Layoffs by year, month, and industry
- Top companies with 100% layoffs
- Country-wise and funding-stage breakdowns
- Cumulative trends and multi-event layoffs
- Funding stage vs. layoff percentage

## 📈 Power BI Dashboard
![Dashboard Screenshot](https://drive.google.com/file/d/1XmyDQsayt7fI0u6cvbuslSzMozuXMw0m/view?usp=sharing)

**Key Metrics:**
- Total Layoffs: 768K
- Avg % Laid Off: 29%
- Companies: 2,811 | Countries: 67

**Visuals:**
- Line chart: Layoff trend over time
- Bar chart: Top companies by layoffs
- Map: Country-wise distribution
- Filters: Year, Industry, Funding Stage

## 📌 Key Insight
> Early-stage companies (Seed to Series B) had the highest average layoff percentage (47.2%), indicating greater vulnerability during market downturns.

## 🧠 Business Implications
- **Investors**: Funding stage correlates with layoff risk
- **HR Teams**: Industry-specific volatility post-COVID
- **Strategy Leaders**: Timing and geography matter in workforce planning


📬 Connect with me on [LinkedIn](www.linkedin.com/in/tati-sai-anjan-5577b7243)  
