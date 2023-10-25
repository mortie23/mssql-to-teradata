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
MSSQL_PASSWORD = os.getenv("MSSQL_PASSWORD")


# %%
# Azure SQL DB
def connect_mssql_azuredb() -> pyodbc.Connection:
    server_name = "tcp:mortimer.database.windows.net"
    port = "1433"
    database = "mortimer_dev"
    username = "mortimer"

    # URL-encode the special characters in the password
    password_encode = urllib.parse.quote_plus(MSSQL_PASSWORD)
    server_name_encoded = urllib.parse.quote_plus(server_name)

    conn_str = f"""
    Driver={{ODBC Driver 18 for SQL Server}};
    Server={server_name_encoded},{port};
    Database={database};
    Persist Security Info=False;
    UID={username};
    PWD={password_encode};
    MultipleActiveResultSets=False;
    Connection Timeout=30;
    """

    return pyodbc.connect(conn_str)


# %%
# Self hosted AWS EC2
def connect_mssql_iaas() -> pyodbc.Connection:
    database = "mortimer_dev"

    conn_str = f"""
    Driver={{ODBC Driver 18 for SQL Server}};
    Server=mortie23.com,1433;
    Database={database};
    UID=sa;
    PWD={MSSQL_PASSWORD};
    TrustServerCertificate=yes;
    """
    return pyodbc.connect(conn_str)


conn = connect_mssql_iaas()
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
def truncate_table(table_name: str) -> dict:
    """Truncate a table in the NFL schema

    Args:
        table_name (str): The name of the table

    Returns:
        dict: _description_
    """

    try:
        # Execute the SQL command to truncate the table
        cursor = conn.cursor()
        command = f"TRUNCATE TABLE [nfl].[{table_name}]"
        cursor.execute(command)
        conn.commit()
        response = {"response": "success"}
    except Exception as e:
        response = {"response": e}
    finally:
        return response


def load_table(table_name: str) -> dict:
    """Load data from a CSV file to a table in Azure SQL DB

    Args:
        table_name (str): the name of the CSV file and corresponding table

    Returns:
        dict: number of loaded rows
    """

    # read data from CSV
    df_data = pd.read_csv(f"../data/{table_name}.csv")
    truncate_table(table_name)

    num_records = df_data.to_sql(
        name=f"{table_name}", schema="nfl", con=engine, if_exists="append", index=False
    )

    # Test existence of data in table
    query = f"SELECT * FROM [nfl].[{table_name}]"
    df = pd.read_sql(query, engine)

    return {"loaded": num_records, "table_count": len(df)}


# %%
load_table("game")
load_table("game_stats")
load_table("game_type")
load_table("game_venue")
load_table("player")
load_table("team_lookup")
load_table("venue")
load_table("weather")
# %%
