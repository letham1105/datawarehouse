import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv
import os
import sys

# Đảm bảo load đúng file .env từ thư mục root của project
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
env_path = os.path.join(project_root, '.env')

# Load biến môi trường từ file .env
load_dotenv(env_path)

# Lấy thông tin kết nối từ env
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

# Debug: In ra các giá trị để kiểm tra
print(" Debug các biến môi trường:")
print(f"  DB_USER = '{DB_USER}' (type: {type(DB_USER)})")
print(f"  DB_PASSWORD = '{DB_PASSWORD}' (type: {type(DB_PASSWORD)})")
print(f"  DB_HOST = '{DB_HOST}' (type: {type(DB_HOST)})")
print(f"  DB_PORT = '{DB_PORT}' (type: {type(DB_PORT)})")
print(f"  DB_NAME = '{DB_NAME}' (type: {type(DB_NAME)})")

# Kiểm tra các biến môi trường
required_vars = {
    "DB_USER": DB_USER,
    "DB_PASSWORD": DB_PASSWORD,
    "DB_HOST": DB_HOST,
    "DB_PORT": DB_PORT,
    "DB_NAME": DB_NAME
}

missing_vars = [var for var, value in required_vars.items() if not value]
if missing_vars:
    print(f" Thiếu các biến môi trường: {', '.join(missing_vars)}")
    print(f"Đang tìm file .env tại: {env_path}")
    print(f" File .env tồn tại: {os.path.exists(env_path)}")
    sys.exit(1)

print(f" Kết nối đến: {DB_HOST}:{DB_PORT}/{DB_NAME} với user: {DB_USER}")

# Tạo kết nối tới PostgreSQL
try:
    engine = create_engine(
        f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )
    # Test kết nối
    with engine.connect() as conn:
        print(" Kết nối database thành công!")
except Exception as e:
    print(f" Lỗi kết nối database: {e}")
    sys.exit(1)

# Đọc file CSV, ép kiểu để tránh cảnh báo "mixed types"
csv_path = os.path.join(project_root, "data", "clean_sales.csv")
print(f" Đọc file CSV: {csv_path}")

if not os.path.exists(csv_path):
    print(f" File CSV không tồn tại: {csv_path}")
    sys.exit(1)

df = pd.read_csv(
    csv_path,
    dtype={
        "Invoice": str,
        "StockCode": str
    },
    low_memory=False
)
print(f"Đã đọc {len(df)} dòng dữ liệu")

# Ghi dữ liệu vào PostgreSQL
df.to_sql("stg_orders", engine, schema="public", if_exists="replace", index=False)

print("Đã load dữ liệu vào bảng 'stg_orders' trong DB thành công!")