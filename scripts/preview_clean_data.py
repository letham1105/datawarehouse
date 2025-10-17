import pandas as pd
import os

base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
clean_path = os.path.join(base_dir, "data", "clean_sales.csv")

df_clean = pd.read_csv(clean_path)

print("=== Thông tin dữ liệu sạch ===")
print(df_clean.info())

print("\n5 dòng đầu tiên:")
print(df_clean.head())

print("\nSố dòng:", len(df_clean))
print("Số giá trị thiếu sau khi làm sạch:")
print(df_clean.isnull().sum()[df_clean.isnull().sum() > 0])

# Kiểm tra lại xem còn dữ liệu bất thường không
print("\nSố dòng Quantity âm:", len(df_clean[df_clean["Quantity"] < 0]))
print("Số dòng Price <= 0:", len(df_clean[df_clean["Price"] <= 0]))
print("\nKiểm tra hoàn tất.")
