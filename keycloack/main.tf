terraform {
  required_providers {
    keycloak = {
      source = "mrparkers/keycloak"
      version = "3.11.0-rc.0"
    }
  }
}

variable "keycloak_client_secret" {
  type = string
}

variable "keycloak_url" {
  type = string
  default = "http://localhost:8080"
}

provider "keycloak" {
    client_id     = "terraform"
    url           = var.keycloak_url
    client_secret = var.keycloak_client_secret
    base_path     = "" // required for new keycloak version
}