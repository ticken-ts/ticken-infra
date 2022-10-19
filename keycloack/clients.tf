resource "keycloak_openid_client_scope" "attendant_app" {
  realm_id    = keycloak_realm.attendants_realm.id
  name        = "attendant-app"
  description = "add all necessary scopes to attendant's app"
}

resource "keycloak_openid_audience_protocol_mapper" "ticket_service_audience_mapper" {
  realm_id                 = keycloak_realm.attendants_realm.id
  client_scope_id          = keycloak_openid_client_scope.attendant_app.id
  name                     = "ticket-service-audience-mapper"
  included_custom_audience = "ticken.ticket.service"
}

resource "keycloak_openid_audience_protocol_mapper" "user_service_audience_mapper" {
  realm_id                 = keycloak_realm.attendants_realm.id
  client_scope_id          = keycloak_openid_client_scope.attendant_app.id
  name                     = "user-service-audience-mapper"
  included_custom_audience = "ticken.user.service"
}

resource "keycloak_openid_client" "postman_attendant_app" {
  realm_id                     = keycloak_realm.attendants_realm.id
  client_id                    = "postman-attendant-app"
         
  name                         = "postman attendant app"
  enabled                      = true

  access_type                  = "PUBLIC"
  direct_access_grants_enabled = true
}

resource "keycloak_openid_client_default_scopes" "postman_attendant_app_default_scopes" {
  realm_id  = keycloak_realm.attendants_realm.id
  client_id = keycloak_openid_client.postman_attendant_app.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.attendant_app.name,
  ]
}





resource "keycloak_openid_client" "postman_organizer_app" {
  realm_id            = keycloak_realm.organizers_realm.id
  client_id           = "postman-organizer-app"

  name                = "postman organizer app"
  enabled             = true

  access_type                  = "PUBLIC"
  direct_access_grants_enabled = true
}