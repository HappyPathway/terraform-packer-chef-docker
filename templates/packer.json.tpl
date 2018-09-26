{
    "variables": {
      "chef_validation_key": "${CHEF_VALIDATION_KEY}",
      "chef_client_name": "${CHEF_VALIDATION_CLIENT_NAME}",
      "chef_server_url": "${CHEF_SERVER_URL}",
      "chef_encrypted_data_bag_secret": "${CHEF_ENCRYPTED_DATA_BAG_SECRET}",
      "chef_env": "${CHEF_ENV}",
      "docker_repo": "${DOCKER_REPO}"
      "login_server": "${DOCKER_REGISTRY}",
      "login_username": "${DOCKER_USERNAME}",
      "login_password": "${DOCKER_PASSWORD}",
      "service_name": "${SERVICE_NAME}",
      "service_version": "${SERVICE_VERSION}",
      "src_image": "${SOURCE_IMAGE}",
      "working_dir": "{{env `PWD` }}",
      "home_dir": "{{env `HOME` }}",
    },
    "builders": [
      {
        "type": "docker",
        "image": "ubuntu",
        "commit": true,
        "login": true,
        "login_server": "{{user `login_server`}}",
        "login_username": "{{user `login_username`}}",
        "login_password": "{{user `login_password`}}"
    ],
    "provisioners": [
      {
          "type": "shell",
          "inline": [
            "sudo apt-get update",
            "mkdir -p /tmp/packer-chef-client"
          ]
      },
      {
          "type": "file",
          "source": "{{user `chef_encrypted_data_bag_secret`}}",
          "destination": "/tmp/packer-chef-client/encrypted_data_bag_secret"
      },
      {
          "type": "chef-client",
          "server_url": "{{user `chef_server_url`}}",
          "chef_environment": "{{ user `chef_env`}}",
          "run_list": "recipe[{{ user `service_name` }}]",
          "ssl_verify_mode": "verify_none",
          "validation_key_path": "{{user `chef_validation_key` }}",
          "validation_client_name": "{{user `chef_client_name` }}",
          "json": {
            "encrypted_data_bag_secret_path": "/tmp/packer-chef-client/encrypted_data_bag_secret"
          }
      }
    ],
    {
  "post-processors": [
    [
      {
        "type": "docker-tag",
        "repository": "{{user `docker_repo`}}/{{user `service_name`}}",
        "tag": "{{user `service_version`}}"
      },
      {
        "type": "docker-push",
        "login": true,
        "login_server": "{{user `login_server`}}",
        "login_password": "{{user `login_password`}}"
    ]
  ]
}
  

