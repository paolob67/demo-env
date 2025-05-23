// variables.tf
variable "region" {
  default = "eu-de"
}

variable "zone" {
  default = "eu-de-1"
}

variable "vpc_name" {
  default = "demo-vpc"
}

variable "subnet_name" {
  default = "demo-subnet"
}

variable "sec_group_name" {
  default = "demo-sec-group"
}

variable "instance_name" {
  default = "demo-vm"
}

variable "instance_profile" {
  default = "bx2-4x16"
}

variable "image" {
  default = "ibm-centos-7-9-minimal-amd64-3"
}

variable "ssh_key_id" {
  description = "SSH key ID"
}

variable "volume_name" {
  default = "demo-volume"
}

variable "cos_instance_name" {
  description = "Name of the IBM Cloud Object Storage instance"
}

variable "bucket_name" {
  default = "demo-object-storage-bucket"
}

