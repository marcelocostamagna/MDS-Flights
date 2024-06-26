
# Modern Data Stack Project
## Meltano - DuckDB - DBT - Minio - Streamlit
## Overview

This demo project demonstrates an end-to-end data pipeline using the modern data stack. Steps are as follow:

- Crawls data from an object storage with Meltano
- Loads data into a warehouse with DuckDB
- Transforms data and generates semantic model from physical model using DBT
- Deploys UI data apps with Streamlit

This will populate four DuckDB tables:

- [Landing][flights_raw] Will contain all ingested files including metadata as filename or insertion date
- [Bronze][flights] Only unique flights will populate this table
- [Silver][delays] Data related to `delays`
- [Gold] Contains summarized tables such as `avg_dealys` or `total_delays`

![](./imgs/ddb_tables.jpeg)

This pipeline can run on both environments:

- Local Development: It requires having [Meltano installed](https://docs.meltano.com/getting-started/installation/)
- Docker

And data can be retrieved from:

- Local Minio service
- AWS S3 object storage

## Initial Setup
### Building services 
```bash
# Build custom images basen on Meltano and Minio
make build

# Start Services, note that an example source file (flights_1.csv) is loaded under Minio landing bucket
make up

# Stop Services
make down
```

## Running e2e pipeline
### Environment setup
1 - Edit `.env` for setting Meltano environment variables
```bash
cat ./.env
```

2 - Option 1: Specify which file to read from object storage, it must previously exist in source bucket. 

*Note*: an example file (flights_1.csv) is loaded in Minio **landing bucket** by default, you can find other example files under `data/raw` to manually upload them

```bash
export SRC_FILE=flights_1.csv
```

3- Option 2: Generate synthetic flights data

 A python script that will generate and upload flights data every 60 seconds to an object storage
```bash
# Edit .env file and define object storage credentials
cat apps/flights-generator/.env
# Begin uploading synthetic data to a specific bucket
make generate_flights
```

### Running pipeline with Meltano
#### Option 1: Retrieve data from local object storage 
```bash
# Set Minio variables
export MINIO_ACCESS_KEY_ID=minio
export MINIO_SECRET_ACCESS_KEY=minio123
export MINIO_REGION=us-east-1

# Run local with Docker
make run_docker

# Running in developer mode requires changing DuckDB DB owner and group
# since Docker creates volumes as ROOT owner locking the DB access
meltano install --force
sudo chown -R $(id -u):$(id -g) data/db
make run_dev

```

#### Option 2: Retrieve data from AWS S3 object storage

```bash
# Define AWS key and secrets
export AWS_ACCESS_KEY_ID=<your_access_key>
export AWS_SECRET_ACCESS_KEY=<your_secret_key>
export AWS_REGION=us-east-1

# Run local with Docker retrieving data from AWS
make run_aws
```

## Visualizing with Streamlit

Access [Streamlite UI](http://localhost:8501/)

![](./imgs/flights_dashboard.jpeg)

## Querying DB with DuckDB
Requires [DuckDB binary](https://duckdb.org/docs/installation/?version=stable&environment=cli&platform=linux&download_method=package_manager)
```bash
# Sudo can be required since ROOT may be the owner

# List tables
sudo duckdb data/db/flights.db "SELECT database_name, schema_name, table_name, estimated_size, column_count FROM duckdb_tables();"

# List raw files ingested
sudo duckdb data/db/flights.db "SELECT DISTINCT _sdc_source_file FROM flights_raw;"
```

## Visualizing logs
The `meltano.log` file is placed under *logs/* folder

## Utils
```bash
# Check plugin config 
meltano --environment=dev config target-s3
# Test plugin config
meltano config tap-s3-csv test
# Update plugins
Try running `meltano lock --update --all` to ensure your plugins are up to date
```