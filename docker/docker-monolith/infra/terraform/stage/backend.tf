terraform {
  backend "gcs" {
    bucket = "storage-bucket-stage-micro"
    prefix = "terraform/state"
  }
}