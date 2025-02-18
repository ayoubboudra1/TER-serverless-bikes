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
    
    # Load pricing_data.json and vehicle_data.json from the local filesystem
    try:
        # Define paths to local files
        pricing_data_path = os.path.join(os.getcwd(), "pricing_data.json")  # Path to pricing_data.json
        vehicle_data_path = os.path.join(os.getcwd(), "vehicle_types_data.json")  # Path to vehicle_data.json
        
        # Load pricing_data.json
        with open(pricing_data_path, 'r') as f:
            pricing_data = json.load(f)
        
        # Load vehicle_data.json
        with open(vehicle_data_path, 'r') as f:
            vehicle_data = json.load(f)
        
        print(f"Loaded pricing data with {len(pricing_data)} entries.")
        print(f"Loaded vehicle data with {len(vehicle_data)} entries.")
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error loading local JSON files: {str(e)}")
        }
    
    # Define mappings for vehicle_type_id and pricing_plan
    vehicle_type_mapping = {
        "Capital Bike Share": {
            "1": "cdd5c4a4-d9a8-4518-b6f4-050e76495b48",
            "2": "f82fddf2-249f-4b77-b828-4e4e95b5decc",
        },
        "Lime Washington DC": {
            "1": "4517135a-0bb3-44c3-8083-9ebd9d35ac56",
            "2": "aafee11d-db6c-4295-94d4-bd2649e8ab7e",
            "3": "c8749d12-a39e-4894-aaf4-5deb1f5bff58",
            "4": "8a4ae9df-2d0b-4e59-904b-1e9134a6dd40"
        },
        "Veo Washington DC": {
            "0": "4adb27fe-75e1-45ba-8e4b-b803a51e49ec",
            "1": "581b43e7-f587-4f7b-b123-590a941a18a9",
            "2": "5acc675c-4609-47c2-8a91-d31e7aa30e35",
            "3": "bec72995-4fe7-4e51-a6dd-8bbb3caa80ed"
        }
    }
    
    pricing_plan_mapping = {
        "Capital Bike Share": "EBIKE_SINGLE_RIDE",
        "Lime Washington DC": "LIME_DEFAULT_PRICING"
    }
    
    # Process the data by removing the specified columns and updating vehicle_type_id and pricing_plan
    processed_data = []
    for record in raw_data:
        # Remove unwanted columns
        for col in ["rental_uris", "vehicle_type"]:
            record.pop(col, None)
        
        # Update vehicle_type_id if applicable
        company_name = record.get("company_name")
        vehicle_type_id = record.get("vehicle_type_id")
        
        if company_name and vehicle_type_id:
            # Update vehicle_type_id based on company_name
            company_mapping = vehicle_type_mapping.get(company_name)
            if company_mapping and vehicle_type_id in company_mapping:
                record["vehicle_type_id"] = company_mapping[vehicle_type_id]
            
            # Handle specific case for Veo Washington DC and vehicle_type_id == "0"
            if company_name == "Veo Washington DC" and vehicle_type_id == "0":
                record["vehicle_type_id"] = "4adb27fe-75e1-45ba-8e4b-b803a51e49ec"
        
        # Add additional details from vehicle_data.json
        if vehicle_type_id in vehicle_data:
            record.update(vehicle_data[vehicle_type_id])
        
        # Update pricing_plan if applicable
        if company_name in pricing_plan_mapping:
            plan_id = pricing_plan_mapping[company_name]
            record["pricing_plan_id"] = plan_id
            
            # Add additional details from pricing_data.json
        if record["pricing_plan_id"] in pricing_data:
            record.update(pricing_data[plan_id])
        
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