data "vault_generic_secret" "chef" {
    path = "${var.vault_chef_credentials_path}"
}

resource "local_file" "chef_validator" {
    content     = "${data.vault_generic_secret.chef.data["validation_key"]}"
    filename = "${path.root}/chef_validator.pem"
}

resource "local_file" "ecnrypted_data_bag_secret" {
    content = "${data.vault_generic_secret.chef.data["encrypted_data_bag_secret"]}"
    filename = "${path.root}/chef_encrypted_data_bag_secret.pem"
}

data "template_file" "packer_config" {
    depends_on = [
        "local_file.chef_validator",
        "local_file.ecnrypted_data_bag_secret",
    ]
    vars = {
        CHEF_VALIDATION_KEY = "${path.root}/chef_validator.pem"
        CHEF_VALIDATION_CLIENT_NAME = "${data.vault_generic_secret.chef.data["validation_client_name"]}"
        CHEF_SERVER_URL = "${data.vault_generic_secret.chef.data["server_url"]}"
        CHEF_ENCRYPTED_DATA_BAG_SECRET = "${path.root}/chef_encrypted_data_bag_secret.pem"
        CHEF_ENV = "${var.chef_env}"
        DOCKER_REPO = "${var.docker_repo}"
        DOCKER_CMD = "${var.docker_cmd}"
        DOCKER_REGISTRY = "${var.docker_registry}"
        DOCKER_USERNAME = "${var.docker_username}"
        DOCKER_PASSWORD = "${var.docker_password}"
        SERVICE_NAME = "${var.service_name}"
        SERVICE_VERSION = "${var.service_version}"
        SOURCE_IMAGE = "${var.source_image}"
  }
  template = "${file("${path.module}/templates/packer.json")}"
}

resource "local_file" "packer_config" {
    content = "${data.template_file.packer_config.rendered}"
    filename = "${path.root}/${var.service_name}-packer.json"
}

resource "null_resource" "packer_build" {
    depends_on = [
        "local_file.chef_validator",
        "local_file.ecnrypted_data_bag_secret",
        "local_file.packer_config"
    ]
  triggers = {
      template_file   =  "${data.template_file.packer_config.rendered}"
  }

  provisioner "local-exec" {
      command = "bash ${path.module}/templates/docker_installer.sh"
  }
    
  provisioner "local-exec" {
      command = "curl -o ${path.root}/packer.zip ${var.packer_download_url}"
  }
    
  provisioner "local-exec" {
      command = "unzip -d ${path.root} ${path.root}/packer.zip"
  }
  
  provisioner "local-exec" {
      command = "${path.root}/packer build ${path.root}/${var.service_name}-packer.json"
  }

  provisioner "local-exec" {
      command = "rm ${path.root}/${var.service_name}-packer.json"
  }

  provisioner "local-exec" {
      command = "rm ${path.root}/packer; rm ${path.root}/packer.zip"
  }
}
