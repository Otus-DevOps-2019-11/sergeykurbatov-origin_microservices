provider "google" {
  version = "~> 2.15"
  project = var.project
  region  = var.region
}

module "storage-bucket-stage" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.3.0"
  name = "storage-bucket-stage-micro"
  location = var.region
  force_destroy = true
}
module "storage-bucket-prod" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.3.0"
  name = "storage-bucket-prod-micro"
  location = var.region
  force_destroy = true
}

output storage-bucket_stage_url {
  value = module.storage-bucket-stage.url
}
output storage-bucket_prod_url {
  value = module.storage-bucket-prod.url
}
