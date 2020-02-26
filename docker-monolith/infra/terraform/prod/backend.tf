terraform {
  backend "gcs" {
    bucket = "storage-bucket-prod-micro"
    prefix = "terraform/state"
  }
}
