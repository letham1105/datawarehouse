CSV (Online Retail II)  
- (Python) Extract & Load raw → Database (raw schema)
- (dbt) Transform: staging → dim_product, dim_customer, dim_date → fact_sales
- dbt tests + dbt docs (lineage graph)
- Visualization: Streamlit (Python) hoặc Tableau/Power BI (kết nối DB)
  
# Step 1

```sh
python -m venv .venv
source .venv/bin/activate
```

# step 2
```sh
pip install pandas sqlalchemy psycopg2-binary streamlit plotly dbt-core dbt-postgres
```

# step 3
```sh
pip install kaggle
~/.kaggle/kaggle.json
kaggle datasets download -d mashlyn/online-retail-ii-uci
unzip online-retail-ii-uci.zip -d data/
```

# step 4 
- extract data
- run command:
  
```sh
python scripts/extract.py
```

# step 5
- check_data 
- run command:
  
```sh
python scripts/check_data.py
```
# step 6
- xem lại dữ liệu thực sự đã sạch chưa 
- run command:
  
```sh
python scripts/preview_clean_data.py
```

# step 7 
- load vào postgrest 
- run command:
- 
```sh
python scripts/load.py
```
