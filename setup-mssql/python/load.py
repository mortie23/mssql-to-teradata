# %%
import pyodbc
from sqlalchemy import create_engine
import pandas as pd
from dotenv import load_dotenv
import urllib.parse
import logging

logging.basicConfig()
logging.getLogger("sqlalchemy.engine").setLevel(logging.INFO)

load_dotenv()
MSSQL_PASSWORD = os.getenv("MSSQL_PASSWORD"

# %%
# Define your Azure SQL Server connection string
server_name = "tcp:mortimer.database.windows.net"
port = "1433"
database = "mortimer_dev"
username = "mortimer"
password = MSSQL_PASSWORD
driver = "ODBC Driver 17 for SQL Server"

# URL-encode the special characters in the password
password_encode = urllib.parse.quote_plus(password)
server_name_encoded = urllib.parse.quote_plus(server_name)

conn_str = f"""
Driver={{ODBC Driver 18 for SQL Server}};
Server={server_name},{port};
Database=mortimer_dev;
Persist Security Info=False;
UID=mortimer;
PWD={password};
MultipleActiveResultSets=False;
Connection Timeout=30;
"""

conn = pyodbc.connect(conn_str)

# %%
# Test connection to Azure SQL DB to specific Database
df = pd.read_sql_query(
    "select * from information_schema.tables where table_catalog='mortimer_dev'", conn
)

# %%
# SQLAlchemy connection engine
engine = create_engine("mssql+pyodbc://", creator=lambda: conn)

# %%
# Pandas query using SQLAlchemy engine
query = "SELECT * FROM [information_schema].[tables]"
df = pd.read_sql(query, engine)

# %%
def load_table(table_name: str) -> dict:
    """Load data from a CSV file to a table in Azure SQL DB

    Args:
        table_name (str): the name of the CSV file and corresponding table

    Returns:
        dict: number of loaded rows
    """

    # read data from CSV
    df_data = pd.read_csv(f"../data/{table_name}.csv")

    num_records = df_data.to_sql(
        name="weather", schema="nfl", con=engine, if_exists="append", index=False
    )

    # Test existence of data in table
    query = f"SELECT * FROM [nfl].[{table_name}]"
    df = pd.read_sql(query, engine)

    return {"loaded": num_records, "table_count": len(df)}

# %%
load_table("weather")
load_table("venue")
# %%
