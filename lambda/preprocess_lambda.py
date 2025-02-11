import json
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    
    bronze_bucket = os.environ.get("BRONZE_BUCKET", "my-bronze-data-bucket-unique-123")
    silver_bucket = os.environ.get("SILVER_BUCKET", "my-silver-data-bucket-unique-123")
    
    # Retrieve the raw data from the Bronze bucket
    try:
        raw_obj = s3.get_object(Bucket=bronze_bucket, Key="raw_data.json")
        raw_data = json.loads(raw_obj['Body'].read().decode('utf-8'))
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error reading raw data from S3: {str(e)}")
        }
    
    # Remove unwanted columns from each bike record
    processed_data = []
    for bike in raw_data:
        for col in ["rentl_uris", "type", "geoforzone_id", "station_id"]:
            bike.pop(col, None)
        processed_data.append(bike)
    
    # Format S3 key with current date and time (YYYY-MM-DD/HH:MM.json)
    now = datetime.now()
    folder_name = now.strftime("%Y-%m-%d")
    file_name = now.strftime("%H:%M.json")
    s3_key = f"{folder_name}/{file_name}"
    
    # Save the processed data to the Silver bucket
    try:
        s3.put_object(
            Bucket=silver_bucket,
            Key=s3_key,
            Body=json.dumps(processed_data, indent=4)
        )
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error writing processed data to S3: {str(e)}")
        }
    
    return {
        "statusCode": 200,
        "body": json.dumps(f"Processed data saved to bucket '{silver_bucket}' with key '{s3_key}'")
    }
