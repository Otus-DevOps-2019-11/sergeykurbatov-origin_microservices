variable public_key_path {
  description = "Path to the public key used to connect to instance"
}
variable zone {
  description = "Zone"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-micro-base"
}
variable private_key {
  description = "Path to private key file for ssh connection"
  default = "~/.ssh/appuser"
}
variable install_app {
  default = false
}
variable instance_count {
  default = "1"
}
