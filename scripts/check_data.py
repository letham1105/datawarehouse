import pandas as pd
import os

# 1. Đường dẫn tới file CSV gốc
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
data_path = os.path.join(base_dir, "data", "online_retail_II.csv")

# 2. Đọc dữ liệu
df = pd.read_csv(data_path, encoding='unicode_escape')

print("=== Kiểm tra dữ liệu ban đầu ===")
print(df.info())
print(f"\nSố dòng: {len(df)}, Số cột: {len(df.columns)}")

# 3. Kiểm tra giá trị thiếu
missing = df.isnull().sum()
print("\nSố giá trị thiếu theo từng cột:")
print(missing[missing > 0])

# 4. Kiểm tra trùng lặp
duplicates = df.duplicated().sum()
print(f"\nSố dòng trùng lặp: {duplicates}")

# 5. Kiểu dữ liệu
print("\nKiểu dữ liệu của các cột:")
print(df.dtypes)

# 6. Kiểm tra dữ liệu bất thường
if "Quantity" in df.columns:
    negative_qty = df[df["Quantity"] < 0]
    print(f"\nSố dòng có Quantity âm: {len(negative_qty)}")

if "Price" in df.columns:
    zero_price = df[df["Price"] <= 0]
    print(f"Số dòng có Price <= 0: {len(zero_price)}")

print("\n=== Bắt đầu làm sạch dữ liệu ===")

# 7. Loại bỏ trùng lặp
df.drop_duplicates(inplace=True)

# 8. Xử lý giá trị thiếu
if "Description" in df.columns:
    df["Description"] = df["Description"].fillna("Unknown Product")

if "Customer ID" in df.columns:
    df["Customer ID"] = df["Customer ID"].fillna(-1).astype(int)

# 9. Loại bỏ giá trị Price <= 0
if "Price" in df.columns:
    df = df[df["Price"] > 0]

# 10. Chuyển kiểu dữ liệu
if "InvoiceDate" in df.columns:
    df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"], errors="coerce")

# 11. Tách dữ liệu trả hàng (Quantity âm)
returns_df = pd.DataFrame()
if "Quantity" in df.columns:
    returns_df = df[df["Quantity"] < 0]
    df = df[df["Quantity"] >= 0]

# 12. Lưu dữ liệu sạch
clean_path = os.path.join(base_dir, "data", "clean_sales.csv")
returns_path = os.path.join(base_dir, "data", "returns.csv")

df.to_csv(clean_path, index=False)
if not returns_df.empty:
    returns_df.to_csv(returns_path, index=False)

print("\n=== Thống kê sau khi làm sạch ===")
print(f"Số dòng còn lại: {len(df)}")
if not returns_df.empty:
    print(f"Số dòng hàng trả lại (Quantity âm): {len(returns_df)}")
print(f"Dữ liệu sạch đã lưu tại: {clean_path}")
if not returns_df.empty:
    print(f"Dữ liệu hàng trả lại lưu tại: {returns_path}")
