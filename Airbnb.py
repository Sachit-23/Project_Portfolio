# ==============================
# AirBnB EDA + MySQL Integration
# ==============================

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import mysql.connector

# ------------------------------
# 1. Load Dataset
# ------------------------------

file_path = "airbnb/Airbnb_Open_Data.csv"
df = pd.read_csv(file_path)

print("Initial Shape:", df.shape)

# Clean column names
df.columns = df.columns.str.strip()

# ------------------------------
# 2. Data Cleaning
# ------------------------------

# Remove $ and commas, convert to numeric
for col in ['price', 'service fee']:
    if col in df.columns:
        df[col] = (
            df[col]
            .astype(str)
            .str.replace('$', '', regex=False)
            .str.replace(',', '', regex=False)
            .str.strip()
        )
        df[col] = pd.to_numeric(df[col], errors='coerce')

# Convert dates
if 'last review' in df.columns:
    df['last review'] = pd.to_datetime(df['last review'], errors='coerce')

# Fill reviews per month
if 'reviews per month' in df.columns:
    df['reviews per month'] = (
        pd.to_numeric(df['reviews per month'], errors='coerce')
        .fillna(0)
    )

# Drop critical missing values
df.dropna(subset=['NAME', 'host name'], inplace=True)

# Remove duplicates
df.drop_duplicates(inplace=True)

print("After Cleaning Shape:", df.shape)

# ------------------------------
# 3. Visualizations
# ------------------------------

sns.set_style("whitegrid")

# Price Distribution
plt.figure(figsize=(10, 6))
sns.histplot(df['price'], bins=50, kde=True)
plt.title('Distribution of Listing Prices')
plt.show()

# Room Type Count
plt.figure(figsize=(8, 5))
sns.countplot(x='room type', data=df)
plt.title('Room Type Distribution')
plt.show()

# Neighborhood Count
plt.figure(figsize=(12, 8))
sns.countplot(
    y='neighbourhood group',
    data=df,
    order=df['neighbourhood group'].value_counts().index
)
plt.title('Listings by Neighborhood Group')
plt.show()

# Price vs Room Type
plt.figure(figsize=(10, 6))
sns.boxplot(x='room type', y='price', data=df)
plt.title('Price vs Room Type')
plt.show()

# Reviews Over Time
if 'last review' in df.columns:
    reviews_over_time = (
        df.dropna(subset=['last review'])
          .groupby(df['last review'].dt.to_period('M'))
          .size()
    )

    plt.figure(figsize=(12, 6))
    reviews_over_time.plot(kind='line')
    plt.title('Number of Reviews Over Time')
    plt.show()





import pyodbc
import pandas as pd

# ------------------------------
# 4. SQL Server Integration
# ------------------------------

# Select required columns
insert_df = df[['NAME', 'host name', 'price',
                'service fee', 'room type',
                'neighbourhood group']].copy()

# 🔥 Convert NaN → None
insert_df = insert_df.astype(object).where(pd.notnull(insert_df), None)

# Convert to list
data = insert_df.values.tolist()

# ------------------------------
# Connect to SQL Server
# ------------------------------

server = 'DESKTOP-LS9GD9F\\SQLEXPRESS'   # or 'DESKTOP-XXXX\\SQLEXPRESS'
database = 'mydatabase'
username = 'sa'
password = 'Admin@1234'

# Create connection
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 18 for SQL Server};'
    f'SERVER={server};'
    f'DATABASE={database};'
    f'UID={username};'
    f'PWD={password};'
    'TrustServerCertificate=yes;'
)

print("✅ SQL Server connected successfully!")

cursor = conn.cursor()

# ------------------------------
# Create Database (if not exists)
# ------------------------------

cursor.execute("""
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'mydatabase')
BEGIN
    CREATE DATABASE mydatabase
END
""")

conn.commit()

# Close and reconnect to use new database
conn.close()

conn = pyodbc.connect(
    'DRIVER={ODBC Driver 18 for SQL Server};'
    f'SERVER={server};'
    'DATABASE=mydatabase;'
    f'UID={username};'
    f'PWD={password};'
    'TrustServerCertificate=yes;'
)

cursor = conn.cursor()

# ------------------------------
# Drop Table if exists
# ------------------------------

cursor.execute("""
IF OBJECT_ID('airbnb_listings', 'U') IS NOT NULL
    DROP TABLE airbnb_listings
""")

# ------------------------------
# Create Table (SQL Server Syntax)
# ------------------------------

create_table_query = """
CREATE TABLE airbnb_listings (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(255),
    host_name VARCHAR(255),
    price DECIMAL(10,2),
    service_fee DECIMAL(10,2),
    room_type VARCHAR(100),
    neighbourhood_group VARCHAR(100)
)
"""

cursor.execute(create_table_query)

# ------------------------------
# Insert Data (SQL Server uses ? not %s)
# ------------------------------

cursor.executemany("""
    INSERT INTO airbnb_listings
    (name, host_name, price, service_fee, room_type, neighbourhood_group)
    VALUES (?, ?, ?, ?, ?, ?)
""", data)

conn.commit() 

print("✅ Data inserted successfully into SQL Server!")

conn.close()


