#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import click
from sqlalchemy import create_engine
from tqdm.auto import tqdm

zones_dtype = {
    "LocationID": "Int64",
    "Borough": "string",
    "Zone": "string",
    "service_zone": "string"
}

trips_dtype = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64"
}

parse_dates = [
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime"
]

def load_zones_data(engine, zones_url, zones_table):
    """Load taxi zones data into PostgreSQL database"""
    try:
        print(f"Downloading zone lookup data from {zones_url}...")
        
        df_zones = pd.read_csv(
            zones_url, 
            dtype=zones_dtype
        )
        
        print(f"Loading {len(df_zones)} rows into {zones_table} table...")

        df_zones.to_sql(
            name=zones_table,
            con=engine,
            if_exists='replace',
            index=False
        )
        
        print(f"Successfully loaded {len(df_zones)} zones into {zones_table} table.")
        return True
    
    except Exception as e:
        print(f"Error loading zones data: {e}")
        print(" Continuing with trip data loading...")
        return False

@click.command()
@click.option('--load-zones/--no-load-zones', default=True, help='Load taxi zone lookup table')
@click.option('--zones-table', default='taxi_zone_lookup', help='Taxi zones table name')
@click.option('--zones-url', default='https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv', help='URL to taxi zones CSV file')
@click.option('--pg-user', default='root', help='PostgreSQL user')
@click.option('--pg-pass', default='root', help='PostgreSQL password')
@click.option('--pg-host', default='localhost', help='PostgreSQL host')
@click.option('--pg-port', default=5432, type=int, help='PostgreSQL port')
@click.option('--pg-db', default='ny_taxi', help='PostgreSQL database name')
@click.option('--year', default=2021, type=int, help='Year of the data')
@click.option('--month', default=1, type=int, help='Month of the data')
@click.option('--target-table', default='yellow_taxi_data', help='Target table name')
@click.option('--chunksize', default=100000, type=int, help='Chunk size for reading CSV')
def run(load_zones, zones_table, zones_url, pg_user, pg_pass, pg_host, pg_port, pg_db, year, month, target_table, chunksize):
    """Ingest data into PostgreSQL database"""
    engine = create_engine(f'postgresql://{pg_user}:{pg_pass}@{pg_host}:{pg_port}/{pg_db}')

    if load_zones:
        load_zones_data(engine, zones_url, zones_table)

    prefix = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow'
    url = f'{prefix}/yellow_tripdata_{year}-{month:02d}.csv.gz'
    
    df_iter = pd.read_csv(
        url,
        dtype=trips_dtype,
        parse_dates=parse_dates,
        iterator=True,
        chunksize=chunksize
    )

    first = True

    for df_chunk in tqdm(df_iter):
        if first:
            # Create table schema (no data)
            df_chunk.head(0).to_sql(
                name=target_table,
                con=engine,
                if_exists='replace'
            )
            first = False

        # Insert chunk
        df_chunk.to_sql(
            name=target_table,
            con=engine,
            if_exists='append'
        )

if __name__ == '__main__':
    run()