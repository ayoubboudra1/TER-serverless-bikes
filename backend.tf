terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-ter-serverless" # Replace with your bucket name
    key            = "state/terraform.tfstate"                  # Path within the bucket for the state file
    region         = "us-east-1"                                # Replace with your AWS region
    dynamodb_table = "terraform-lock"                           # Optional: table for state locking
    encrypt        = true
  }
}
