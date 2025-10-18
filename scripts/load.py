import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

# Load biến môi trường từ file .env
load_dotenv()

# Lấy thông tin kết nối từ env
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

# Tạo kết nối tới PostgreSQL
engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# Đọc file CSV, ép kiểu để tránh cảnh báo "mixed types"
df = pd.read_csv(
    "data/clean_sales.csv",
    dtype={
        "Invoice": str,
        "StockCode": str
    },
    low_memory=False
)

# Ghi dữ liệu vào PostgreSQL
df.to_sql("stg_orders", engine, schema="public", if_exists="replace", index=False)

print("Đã load dữ liệu vào bảng 'stg_orders' trong DB thành công!")
