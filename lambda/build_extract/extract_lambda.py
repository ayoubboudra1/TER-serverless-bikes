import urllib.request
import json
import os
from datetime import datetime
import boto3

def lambda_handler(event, context):
    # Read configuration from a local JSON file
    try:
        with open("data.json", "r") as f:
            cleaned_bike_data = json.load(f)
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error reading data.json: {str(e)}")
        }
    
    now = datetime.now()
    folder_name = now.strftime("%Y-%m-%d")
    file_name = now.strftime("%H:%M.json")
    s3_key = f"{folder_name}/{file_name}"
    
    free_bike_data = []
    
    for obj in cleaned_bike_data:
        try:
            free_bike_status_url = obj.get("free_bike_status")
            if free_bike_status_url:
                # Use urllib.request to fetch the URL
                with urllib.request.urlopen(free_bike_status_url) as response:
                    response_body = response.read()
                    free_bikes_json = json.loads(response_body.decode("utf-8"))
                    if "data" in free_bikes_json and "bikes" in free_bikes_json["data"]:
                        for bike in free_bikes_json["data"]["bikes"]:
                            bike["type"] = "free_bike"
                            bike["time"] = int(now.timestamp())
                            bike.update({
                                "Country Code": obj.get("Country Code", ""),
                                "Company Name": obj.get("Name", ""),
                                "Location": obj.get("Location", ""),
                                "System ID": obj.get("System ID", "")
                            })
                            free_bike_data.append(bike)
        except Exception as e:
            print(f"Error processing {obj.get('Name', 'unknown')}: {str(e)}")
    
    s3 = boto3.client('s3')
    bucket_name = os.environ.get("BRONZE_BUCKET", "my-bronze-data-bucket-unique-123")
    try:
        s3.put_object(
            Bucket=bucket_name,
            Key=s3_key,
            Body=json.dumps(free_bike_data, indent=4)
        )
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error writing to S3: {str(e)}")
        }
    
    return {
        "statusCode": 200,
        "body": json.dumps(f"Extracted data for {len(free_bike_data)} bikes saved to {bucket_name}/{s3_key}")
    }
