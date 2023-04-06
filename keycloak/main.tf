terraform {
  required_providers {
    keycloak = {
      source = "mrparkers/keycloak"
      version = "4.2.0"
    }
  }
}

variable "keycloak_admin_username" {
  type = string
}

variable "keycloak_admin_password" {
  type = string
}

variable "keycloak_url" {
  type = string
  default = "http://localhost:8080"
}

provider "keycloak" {
    client_id     = "admin-cli"
    url           = var.keycloak_url
    username      = var.keycloak_admin_username
    password      = var.keycloak_admin_password
    base_path     = "" // required for new keycloak version
}
