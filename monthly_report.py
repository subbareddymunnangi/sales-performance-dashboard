"""Automates the monthly Excel report (replaces manual Excel work).
pip install pandas sqlalchemy pymysql openpyxl
Run: python monthly_report.py 2024 11"""
import sys, pandas as pd
from sqlalchemy import create_engine
USER, PWD, HOST, DB = "root", "YOUR_PASSWORD", "localhost", "sales_db"
yr, mo = int(sys.argv[1]), int(sys.argv[2])
eng = create_engine(f"mysql+pymysql://{USER}:{PWD}@{HOST}/{DB}")
df = pd.read_sql(f"SELECT * FROM vw_sales_dashboard WHERE order_year={yr} AND order_month={mo}", eng)
with pd.ExcelWriter(f"Sales_Report_{yr}_{mo:02d}.xlsx") as w:
    pd.DataFrame({"Orders":[len(df)],"Revenue":[df.sales_amount.sum()],"Profit":[df.profit.sum()],
                  "Margin %":[round(df.profit.sum()/df.sales_amount.sum()*100,2)]}).to_excel(w,"Summary",index=False)
    df.groupby("region_name")[["sales_amount","profit"]].sum().sort_values("sales_amount",ascending=False).to_excel(w,"By Region")
    df.groupby("category")[["sales_amount","profit"]].sum().to_excel(w,"By Category")
print("Report created")
