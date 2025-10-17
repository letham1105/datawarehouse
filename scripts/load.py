import pandas as pd
from sqlalchemy import create_engine

# Tạo kết nối tới PostgreSQL
engine = create_engine("postgresql+psycopg2://lethitham:123456@localhost:5432/retail_dw")

# Đọc file CSV, ép kiểu để tránh cảnh báo "mixed types"
df = pd.read_csv(
    "data/clean_sales.csv",
    dtype={
        "Invoice": str,        # Ép kiểu chuỗi cho cột Invoice
        "StockCode": str       # Ép kiểu chuỗi cho cột StockCode
    },
    low_memory=False           # Đọc file theo block lớn, giảm cảnh báo
)

# Ghi dữ liệu vào PostgreSQL
df.to_sql("stg_orders", engine, if_exists="replace", index=False)

print("Đã load dữ liệu vào bảng 'stg_orders' trong DB thành công!")
