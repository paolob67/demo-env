# main.tf
# remember to set an environment variable with the IBM CLOUD API KEY
# > export IC_API_KEY="ibmcloud_api_key"
# > terraform plan

# Set provider for IBM Cloud resources
provider "ibm" {
  region = var.region
}

# Create a VPC (Virtual Private Cloud)
resource "ibm_is_vpc" "vpc" {
  name = var.vpc_name
}

# Create a subnet within the VPC
resource "ibm_is_subnet" "subnet" {
  name                     = var.subnet_name
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = var.zone
  ipv4_cidr_block          = "10.240.0.0/24"
}

# Create a security group to manage firewall rules
resource "ibm_is_security_group" "sec_group" {
  name = var.sec_group_name
  vpc  = ibm_is_vpc.vpc.id
}

# Allow SSH access (inbound) from anywhere
resource "ibm_is_security_group_rule" "allow_ssh" {
  group     = ibm_is_security_group.sec_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Allow HTTPS access (inbound) from anywhere
resource "ibm_is_security_group_rule" "allow_https" {
  group     = ibm_is_security_group.sec_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}

# Allow all outbound traffic
resource "ibm_is_security_group_rule" "allow_all_outbound" {
  group     = ibm_is_security_group.sec_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Create an instance (VSI) within the VPC
resource "ibm_is_instance" "vsi" {
  name            = var.instance_name
  image           = var.image
  profile         = var.instance_profile
  zone            = var.zone
  vpc             = ibm_is_vpc.vpc.id
  primary_network_interface {
    subnet          = ibm_is_subnet.subnet.id
    security_groups = [ibm_is_security_group.sec_group.id]
  }
  keys = [var.ssh_key_id]
  boot_volume {
    name = "boot-vol"
  }
}

# Allocate a public IP address for the VSI
resource "ibm_is_floating_ip" "fip" {
  name   = "demo-floating-ip"
  target = ibm_is_instance.vm.primary_network_interface[0].id
}

# Create  sblock storage volume for the VSI
resource "ibm_is_volume" "block_storage" {
  name           = var.volume_name
  zone           = var.zone
  profile        = "general-purpose"
  capacity       = 100
}

# Attach the storage to the VSI
resource "ibm_is_instance_volume_attachment" "attach_volume" {
  instance = ibm_is_instance.vm.id
  volume   = ibm_is_volume.block_storage.id
  delete_volume_on_instance_delete = true
}

# Create a Cloud Object Storage (COS) Instance
data "ibm_resource_instance" "cos_instance" {
  name     = var.cos_instance_name
  location = var.region
  service  = "cloud-object-storage"
}

# Create a bucket in the COS instance
resource "ibm_cos_bucket" "object_storage" {
  bucket_name          = var.bucket_name
  resource_instance_id = data.ibm_resource_instance.cos_instance.id
  storage_class        = "standard"
}
