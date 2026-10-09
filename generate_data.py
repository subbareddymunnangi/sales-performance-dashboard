import numpy as np, pandas as pd
rng = np.random.default_rng(42)

regions = pd.DataFrame({
 "region_id": range(1,16),
 "region_name": ["Andhra Pradesh","Telangana","Karnataka","Tamil Nadu","Kerala","Maharashtra","Gujarat","Rajasthan",
                 "Delhi","Uttar Pradesh","West Bengal","Odisha","Madhya Pradesh","Punjab","Bihar"],
 "zone": ["South","South","South","South","South","West","West","North","North","North","East","East","Central","North","East"],
 "market_weight": [1.1,1.3,1.5,1.4,0.9,1.8,1.3,0.9,1.7,1.2,1.0,0.7,0.8,0.8,0.6]})

cats = {"Electronics":(8000,60000,.18),"Furniture":(3000,40000,.22),"Office Supplies":(100,3000,.30),
        "Clothing":(500,6000,.35),"Home Appliances":(4000,35000,.20)}
prods=[];pid=1
for c,(lo,hi,m) in cats.items():
    for i in range(1,9):
        prods.append((pid,f"{c} Item {i}",c,round(rng.uniform(lo,hi),2),m));pid+=1
products = pd.DataFrame(prods,columns=["product_id","product_name","category","unit_price","margin_pct"])

n_cust=3000
customers = pd.DataFrame({
 "customer_id": range(1,n_cust+1),
 "customer_name":[f"Customer {i}" for i in range(1,n_cust+1)],
 "segment": rng.choice(["Consumer","Corporate","Home Office"],n_cust,p=[.55,.30,.15]),
 "region_id": rng.choice(regions.region_id,n_cust,p=regions.market_weight/regions.market_weight.sum())})

N=52000
dates = pd.date_range("2022-01-01","2024-11-30")
# seasonality + growth
w = np.array([1+0.35*(d.month in (10,11,12)) + 0.0006*(d-dates[0]).days for d in dates]); w/=w.sum()
order_date = rng.choice(dates,N,p=w)
cust = customers.sample(N,replace=True,random_state=1).reset_index(drop=True)
prod = products.sample(N,replace=True,random_state=2).reset_index(drop=True)
qty = rng.integers(1,6,N)
disc = rng.choice([0,.05,.10,.15,.20],N,p=[.45,.2,.15,.12,.08])
sales_amt = (prod.unit_price*qty*(1-disc)).round(2)
profit = (sales_amt*prod.margin_pct - prod.unit_price*qty*disc*0.3).round(2)
ship = rng.choice(["Standard","Express","Same Day"],N,p=[.6,.3,.1])
sales = pd.DataFrame({"order_id":[f"ORD-{100000+i}" for i in range(N)],
 "order_date":pd.to_datetime(order_date).strftime("%Y-%m-%d"),
 "customer_id":cust.customer_id,"product_id":prod.product_id,"region_id":cust.region_id,
 "quantity":qty,"discount":disc,"sales_amount":sales_amt,"profit":profit,"ship_mode":ship})
for name,df in [("regions",regions),("products",products),("customers",customers),("sales",sales)]:
    df.to_csv(f"data/{name}.csv",index=False); print(name,len(df))
