import json
import os
from datetime import datetime
import boto3
import urllib.request  # Use urllib.request for HTTP requests

def lambda_handler(event, context):
    # Read configuration from a local JSON file
    try:
        with open("data.json", "r") as f:  # Adjust path if data.json is stored in Lambda Layer
            cleaned_bike_data = json.load(f)
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error reading data.json: {str(e)}")
        }

    # Validate that cleaned_bike_data is a list of dictionaries
    if not isinstance(cleaned_bike_data, list) or not all(isinstance(obj, dict) for obj in cleaned_bike_data):
        return {
            "statusCode": 500,
            "body": json.dumps("Invalid data structure in data.json. Expected a list of dictionaries.")
        }

    now = datetime.now()
    timestamp = int(now.timestamp())
    folder_name = "FreeBikeStatusData"
    file_name = now.strftime("%Y-%m-%d %H:%M.json")
    s3_key = f"{folder_name}/{file_name}"

    free_bike_data = []

    for obj in cleaned_bike_data:
        try:
            free_bike_status_url = obj.get("free_bike_status")
            if not free_bike_status_url:
                print(f"Skipping {obj.get('Name', 'unknown')}: No free_bike_status URL provided.")
                continue

            # Fetch the URL using urllib.request
            try:
                with urllib.request.urlopen(free_bike_status_url) as response:
                    if response.getcode() != 200:
                        print(f"HTTP Error processing {obj.get('Name', 'unknown')}: {response.getcode()}")
                        continue

                    response_body = response.read().decode("utf-8")
                    free_bikes_json = json.loads(response_body)

                    # Check if the expected structure exists
                    if "data" not in free_bikes_json or "bikes" not in free_bikes_json["data"]:
                        print(f"Error processing {obj.get('Name', 'unknown')}: Invalid JSON structure.")
                        continue

                    for bike in free_bikes_json["data"]["bikes"]:
                        bike["type"] = "free_bike"
                        bike["time"] = timestamp
                        bike.update({
                            "country_code": obj.get("Country Code", ""),
                            "company_name": obj.get("Name", ""),
                            "location": obj.get("Location", ""),
                            "system_id": obj.get("System ID", "")
                        })
                        free_bike_data.append(bike)

            except urllib.error.HTTPError as http_err:
                print(f"HTTP Error processing {obj.get('Name', 'unknown')}: {http_err}")
            except urllib.error.URLError as url_err:
                print(f"URL Error processing {obj.get('Name', 'unknown')}: {url_err}")

        except Exception as e:
            print(f"Error processing {obj.get('Name', 'unknown')}: {str(e)}")

    # Write data to S3
    s3 = boto3.client('s3')
    bucket_name = "my-bronze-data-bucket-ter-serverless"  # Hardcoded S3 bucket name
    try:
        s3.put_object(
            Bucket=bucket_name,
            Key=s3_key,
            Body=json.dumps(free_bike_data, indent=4),
            ContentType="application/json"
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