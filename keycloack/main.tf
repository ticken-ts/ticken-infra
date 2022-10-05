terraform {
  required_providers {
    keycloak = {
      source = "mrparkers/keycloak"
      version = "3.11.0-rc.0"
    }
  }
}

provider "keycloak" {
    client_id     = "terraform"
    client_secret = "pIRQefR2XbFLB3Tuqw7MuyXE6oDjJ9bt" // remove
    url           = "http://localhost:8080"
    base_path     = "" // required for new keycloack version
}



