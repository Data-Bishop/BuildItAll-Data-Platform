import random
from faker import Faker
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, FloatType, DateType, TimestampType
from datetime import datetime
import os
import shutil
import argparse

# Initialize Faker
fake = Faker()
Faker.seed(42)

# Initialize SparkSession
spark = SparkSession.builder \
    .appName("SyntheticDataGeneration") \
    .config("spark.executor.memory", "2g") \
    .config("spark.executor.cores", 1) \
    .config("spark.default.parallelism", 10) \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("spark.hadoop.fs.s3a.aws.credentials.provider", "com.amazonaws.auth.DefaultAWSCredentialsProviderChain") \
    .getOrCreate()

def generate_orders(region, n, customer_count=500_000):
    """Generate daily orders for a specific region as a Spark DataFrame."""
    try:
        data = [(i, random.randint(1, customer_count), fake.date_between(start_date='-1d', end_date='today'), round(random.uniform(20.0, 1000.0), 2), region) for i in range(1, n+1)]
        schema = StructType([
            StructField("order_id", IntegerType(), False),
            StructField("customer_id", IntegerType(), False),
            StructField("order_date", DateType(), False),
            StructField("total", FloatType(), False),
            StructField("region", StringType(), False)
        ])
        print(f"Generated {n} orders for region: {region}")
        return spark.createDataFrame(data, schema)
    except Exception as e:
        print(f"Error generating orders for region {region}: {e}")
        return None   

def generate_order_items(region, n, order_count=1_000_000, product_count=800_000):
    """Generate daily order items for a specific region as a Spark DataFrame."""
    
    try:
        data = [(random.randint(1, order_count), random.randint(1, product_count), random.randint(1, 5), round(random.uniform(5.0, 300.0), 2), region) for _ in range(n)]
        schema = StructType([
            StructField("order_id", IntegerType(), False),
            StructField("product_id", IntegerType(), False),
            StructField("quantity", IntegerType(), False),
            StructField("price", FloatType(), False),
            StructField("region", StringType(), False)
        ])
        print(f"Generated {n} order items for region: {region}")
        return spark.createDataFrame(data, schema)
    except Exception as e:
        print(f"Error generating order items for region {region}: {e}")
        return None

def generate_payments(region, n, order_count=1_000_000):
    """Generate daily payments for a specific region as a Spark DataFrame."""
    try:
        methods = ['card', 'bank', 'transfer', 'cash_on_delivery', 'opay']
        statuses = ['completed', 'pending', 'failed']
        data = [(i, random.randint(1, order_count), random.choice(methods), random.choice(statuses), fake.date_time_between(start_date='-1d', end_date='now'), region) for i in range(1, n+1)]
        schema = StructType([
            StructField("payment_id", IntegerType(), False),
            StructField("order_id", IntegerType(), False),
            StructField("method", StringType(), False),
            StructField("status", StringType(), False),
            StructField("timestamp", TimestampType(), False),
            StructField("region", StringType(), False)
        ])
        print(f"Generated {n} payments for region: {region}")
        return spark.createDataFrame(data, schema)
    except Exception as e:
        print(f"Error generating payments for region {region}: {e}")
        return None

def save_as_single_file(df, output_path, file_name):
    """Save a DataFrame as a single Parquet file with the specified name."""
    try:
        # Write the DataFrame to a temporary directory
        temp_dir = f"/tmp/temp_{file_name}"  # Use local temporary directory
        df.coalesce(1).write.mode("overwrite").parquet(temp_dir)

        # Find the actual Parquet file in the temporary directory
        for file in os.listdir(temp_dir):
            if file.endswith(".parquet"):        
                try:
                    # Move and rename the file to S3
                    shutil.move(f"{temp_dir}/{file}", f"{output_path}/{file_name}.parquet")
                    print(f"Saved {file_name}.parquet to {output_path}")
                    break
                except Exception as e:
                    print(f"Error saving {file_name}.parquet to {output_path}: {e}")
                    break     

        # Remove the temporary directory
        shutil.rmtree(temp_dir)
        print(f"Removed temporary directory: {temp_dir}")
    except Exception as e:
        print(f"Error saving DataFrame to single file: {e}")

if __name__ == "__main__":
    try:
        # Parse command-line arguments
        parser = argparse.ArgumentParser()
        parser.add_argument("--output-path", required=True, help="S3 path to save the generated Parquet files")
        args = parser.parse_args()

        # Output directory for the generated data
        output_path = args.output_path

        # Get today's date for file naming
        today = datetime.now().strftime("%Y-%m-%d")

        # Define regions or providers
        regions = ["Africa", "Europe", "Asia"]

        # Define record counts for each dataset
        record_counts = {
            "orders": [1_000_000, 800_000, 1_200_000],  # Different record counts for each region
            "order_items": [600_000, 500_000, 700_000],
            "payments": [500_000, 400_000, 600_000]
        }

        for i, region in enumerate(regions):
            # Generate datasets for each region with varying record counts
            orders = generate_orders(region, record_counts["orders"][i])
            order_items = generate_order_items(region, record_counts["order_items"][i])
            payments = generate_payments(region, record_counts["payments"][i])

            # Save datasets to single Parquet files
            save_as_single_file(orders, output_path, f"orders_{region.replace(' ', '_')}_{today}")
            save_as_single_file(order_items, output_path, f"order_items_{region.replace(' ', '_')}_{today}")
            save_as_single_file(payments, output_path, f"payments_{region.replace(' ', '_')}_{today}")

        print("Data generation and saving completed successfully.")
        # Stop SparkSession
        spark.stop()
    except Exception as e:
        print(f"Error in main execution: {e}")
        spark.stop()