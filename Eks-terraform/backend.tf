terraform {
  backend "s3" {
    bucket = "Sekhar-state-0912" # Replace with your actual S3 bucket name
    key    = "EKS/terraform.tfstate"
    region = "ap-south-1"
  }
}
