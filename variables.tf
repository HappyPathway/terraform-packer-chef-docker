variable "vault_chef_credentials_path" {
  
}

variable "service_name" {
  
}

variable "service_version" {
  
}


variable "chef_env" {}

variable "packer_download_url" {
  default = "https://releases.hashicorp.com/packer/1.2.5/packer_1.2.5_linux_amd64.zip"
}

variable "docker_repo" {}
variable "docker_registry" {}
variable "docker_username" {}
variable "docker_password" {}
