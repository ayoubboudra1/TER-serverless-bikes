terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-ter-serverless-aymen"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
