variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-micro-base"
}
