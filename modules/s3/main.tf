resource "aws_s3_bucket" "bronze" {
  bucket = var.bronze_bucket_name
  # acl           = "private"
  force_destroy = true # This forces deletion even if the bucket is not empty

  # versioning {
  #   enabled = true
  # }
}

resource "aws_s3_bucket" "silver" {
  bucket = var.silver_bucket_name
  # acl           = "private"
  force_destroy = true # This forces deletion even if the bucket is not empty

  # versioning {
  #   enabled = true
  # }
}
