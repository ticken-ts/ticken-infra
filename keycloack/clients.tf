resource "keycloak_openid_client" "postman_attendant_app" {
  realm_id            = keycloak_realm.attendants_realm.id
  client_id           = "postman-attendant-app"

  name                = "postman attendant app"
  enabled             = true

  access_type                  = "PUBLIC"
  direct_access_grants_enabled = true
}

resource "keycloak_openid_client" "postman_organizer_app" {
  realm_id            = keycloak_realm.organizers_realm.id
  client_id           = "postman-organizer-app"

  name                = "postman organizer app"
  enabled             = true

  access_type                  = "PUBLIC"
  direct_access_grants_enabled = true
}