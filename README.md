# Online Retail II Data Warehouse Project

## Mục tiêu project

* Nguồn dữ liệu: CSV Online Retail II (Kaggle).
* Quy trình:

  1. Python **extract & load raw data** → Database (raw schema).
  2. DBT **transform**: staging → `dim_product`, `dim_customer`, `dim_date` → `fact_sales`.
  3. DBT **tests + docs** → lineage graph.
  4. Visualization: **Streamlit**, hoặc **Tableau / Power BI** kết nối database.

---

## Step 1: Tạo virtual environment

```bash
python -m venv .venv
source .venv/bin/activate
```

---

## Step 2: Cài đặt Python packages

```bash
pip install pandas sqlalchemy psycopg2-binary streamlit plotly dbt-core dbt-postgres kaggle python-dotenv
```

---

## Step 3: Download dataset từ Kaggle

1. Tạo file `~/.kaggle/kaggle.json` với API key.
2. Download và giải nén:

```bash
kaggle datasets download -d mashlyn/online-retail-ii-uci
unzip online-retail-ii-uci.zip -d data/
```

---

## Step 4: Extract dữ liệu

```bash
python scripts/extract.py
```

---

## Step 5: Kiểm tra dữ liệu

```bash
python scripts/check_data.py
```

---

## Step 6: Xem trước dữ liệu đã clean

```bash
python scripts/preview_clean_data.py
```

---

## Step 7: Load dữ liệu vào PostgreSQL

1. Tạo file `.env` trong project với nội dung:
2. Load dữ liệu bằng script:

```bash
python scripts/load.py
```

> Script `load.py` đọc thông tin DB từ `.env` và load dữ liệu vào bảng **stg_orders**.

---

## Step 8: Thiết lập DBT profile

1. Tạo thư mục DBT:

```bash
mkdir -p ~/.dbt
nano ~/.dbt/profiles.yml
```

2. Ví dụ `profiles.yml`:

> Nếu chia sẻ repo, commit `profiles.yml.example` thay vì file thật.

---

## Step 9: Chạy Metabase (visualization)

```bash
docker-compose -f docker-compose-metabase.yml up -d
```

* Nếu cổng 5432 bị chiếm, check:

```bash
sudo lsof -i :5432
sudo kill -9 <PID>
```

* Truy cập Metabase: [http://localhost:3000/](http://localhost:3000/)
* Add database để load dữ liệu lên Metabase.

---

## Step 10: Chạy DBT để build dữ liệu dimensional

```bash
dbt debug       # kiểm tra kết nối DB
dbt run         # chạy các model (staging → dim → fact)
dbt test        # chạy các test
dbt docs generate
dbt docs serve  # xem lineage graph
```

> Sau bước này, có đầy đủ **staging tables, dimension tables, fact table** và **lineage graph**.

---

## Step 11: Visualization

* Streamlit:

```bash
streamlit run scripts/app.py
```

* Hoặc kết nối PostgreSQL với Tableau / Power BI để tạo dashboard.

---

## Notes / Lưu ý

* **Biến môi trường**: `.env` để lưu thông tin DB, tránh commit mật khẩu.
* **Profiles DBT**: dùng `profiles.yml.example` cho share, user copy → rename → điền thông tin.
* **Cổng 5432**: đảm bảo không xung đột giữa Docker PostgreSQL và local DB.
* **Commit**: chỉ commit code, script, CSV example; không commit `.env` hay `profiles.yml` thật.
