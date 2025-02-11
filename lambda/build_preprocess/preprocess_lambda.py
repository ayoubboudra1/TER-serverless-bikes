import json
import boto3
import os

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    
    # Get bucket names from environment variables (set these in your Lambda configuration)
    bronze_bucket = os.environ.get("BRONZE_BUCKET", "my-bronze-data-bucket-ter-serverless")
    silver_bucket = os.environ.get("SILVER_BUCKET", "my-silver-data-bucket-ter-serverless")
    
    # List objects in the Bronze bucket
    try:
        response = s3.list_objects_v2(Bucket=bronze_bucket)
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error listing objects in Bronze bucket: {str(e)}")
        }
    
    # Ensure there is at least one object in the bucket
    if "Contents" not in response or len(response["Contents"]) == 0:
        return {
            "statusCode": 404,
            "body": json.dumps("No objects found in Bronze bucket.")
        }
    
    # Sort objects by LastModified in descending order and select the most recent
    sorted_objects = sorted(response["Contents"], key=lambda obj: obj["LastModified"], reverse=True)
    latest_object = sorted_objects[0]
    key = latest_object["Key"]
    
    # Retrieve the latest object from the Bronze bucket
    try:
        obj_response = s3.get_object(Bucket=bronze_bucket, Key=key)
        content = obj_response["Body"].read().decode("utf-8")
        raw_data = json.loads(content)
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error retrieving object {key} from Bronze bucket: {str(e)}")
        }
    
    # Process the data by removing the specified columns
    processed_data = []
    for record in raw_data:
        # Remove unwanted keys if they exist
        for col in ["rental_uris", "type", "geoforzone_id", "station_id"]:
            record.pop(col, None)
        processed_data.append(record)
    
    # Save the processed data to the Silver bucket with the same key
    try:
        s3.put_object(
            Bucket=silver_bucket,
            Key=key,
            Body=json.dumps(processed_data, indent=4)
        )
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error writing processed data to Silver bucket: {str(e)}")
        }
    
    return {
        "statusCode": 200,
        "body": json.dumps(f"Processed data from {key} saved to Silver bucket with the same key.")
    }
