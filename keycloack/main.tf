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

provider "keycloak" {
    client_id     = "terraform"
    client_secret =  var.keycloak_client_secret
    url           = "http://localhost:8080"
    base_path     = "" // required for new keycloack version
}