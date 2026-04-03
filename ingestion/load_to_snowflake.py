import os
import requests
import snowflake.connector
import pandas as pd
from pathlib import Path

MONTHS = [
    ("2025", "01"), ("2025", "02"), ("2025", "03"),
    ("2025", "04"), ("2025", "05"), ("2025", "06"),
]

def download_parquet(year: str, month: str) -> Path:
    url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_{year}-{month}.parquet"
    path = Path(f"data/yellow_tripdata_{year}-{month}.parquet")
    path.parent.mkdir(exist_ok=True)
    print(f"Downloading {url}...")
    r = requests.get(url, stream=True)
    with open(path, "wb") as f:
        for chunk in r.iter_content(chunk_size=8192):
            f.write(chunk)
    return path

def upload_to_snowflake(parquet_path: Path):
    conn = snowflake.connector.connect(
        account=os.environ["DBT_SNOWFLAKE_ACCOUNT"],
        user=os.environ["DBT_SNOWFLAKE_USER"],
        password=os.environ["DBT_SNOWFLAKE_PW"],
        role=os.environ["DBT_SNOWFLAKE_ROLE"],
        warehouse=os.environ["DBT_SNOWFLAKE_WH"],
        database=os.environ["DBT_SNOWFLAKE_DB"],
        schema="RAW",
    )
    df = pd.read_parquet(parquet_path)
    cursor = conn.cursor()
    # PUT + COPY INTO via stage Snowflake
    cursor.execute(f"PUT file://{parquet_path.resolve()} @%YELLOW_TAXI_TRIPS")
    cursor.execute("""
        COPY INTO YELLOW_TAXI_TRIPS
        FROM @%YELLOW_TAXI_TRIPS
        FILE_FORMAT = (TYPE = PARQUET)
        MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
        ON_ERROR = CONTINUE
    """)
    conn.close()
    print(f"Loaded {parquet_path.name} into Snowflake RAW layer.")

if __name__ == "__main__":
    for year, month in MONTHS:
        path = download_parquet(year, month)
        upload_to_snowflake(path)