// ------------------------------------------------------------------------------- //
// ------------------------------ attendant's app -------------------------------- //
// ------------------------------------------------------------------------------- //
resource "keycloak_openid_client_scope" "attendant_app" {
  realm_id    = keycloak_realm.attendants_realm.id
  name        = "attendant-app"
  description = "add all necessary scopes to attendant's app"
}

resource "keycloak_openid_audience_protocol_mapper" "ticket_service_audience_to_attendants_mapper" {
  realm_id                 = keycloak_realm.attendants_realm.id
  client_scope_id          = keycloak_openid_client_scope.attendant_app.id
  name                     = "ticket-service-audience-to-attendants-mapper"
  included_custom_audience = "ticken.ticket.service"
}

resource "keycloak_openid_audience_protocol_mapper" "user_service_audience_to_attendants_mapper" {
  realm_id                 = keycloak_realm.attendants_realm.id
  client_scope_id          = keycloak_openid_client_scope.attendant_app.id
  name                     = "user-service-audience-to-attendants-mapper"
  included_custom_audience = "ticken.user.service"
}

resource "keycloak_openid_client" "postman_attendant_app" {
  realm_id                     = keycloak_realm.attendants_realm.id
  client_id                    = "postman-attendant-app"
         
  name                         = "postman attendant app"
  enabled                      = true

  access_type                  = "PUBLIC"
  standard_flow_enabled = true
  direct_access_grants_enabled = true
  valid_redirect_uris = [
    "exp://*"
  ]
  valid_post_logout_redirect_uris = [
    "exp://*"
  ]
  
  login_theme = "mytheme"
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
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //


// ------------------------------------------------------------------------------- //
// ------------------------------- organizer's app ------------------------------- //
// ------------------------------------------------------------------------------- //
resource "keycloak_openid_client_scope" "organizer_app" {
  realm_id    = keycloak_realm.organizers_realm.id
  name        = "organizer-app"
  description = "add all necessary scopes to organizer's app"
}

resource "keycloak_openid_audience_protocol_mapper" "event_service_audience_to_organizers_mapper" {
  realm_id                 = keycloak_realm.organizers_realm.id
  client_scope_id          = keycloak_openid_client_scope.organizer_app.id
  name                     = "event-service-audience-to-organizers-mapper"
  included_custom_audience = "ticken.event.service"
}

resource "keycloak_openid_audience_protocol_mapper" "user_service_audience_to_organizers_mapper" {
  realm_id                 = keycloak_realm.organizers_realm.id
  client_scope_id          = keycloak_openid_client_scope.organizer_app.id
  name                     = "user-service-audience-to-organizers-mapper"
  included_custom_audience = "ticken.user.service"
}

resource "keycloak_openid_client" "postman_organizer_app" {
  realm_id            = keycloak_realm.organizers_realm.id
  client_id           = "postman-organizer-app"

  name                = "postman organizer app"
  enabled             = true

  access_type                  = "PUBLIC"
  standard_flow_enabled = true
  direct_access_grants_enabled = true
  
  valid_redirect_uris = [
    "http://localhost:5173/*"
  ]
  valid_post_logout_redirect_uris = [
    "http://localhost:5173/*"
  ]
  
  login_theme = "mytheme"
}

resource "keycloak_openid_client_default_scopes" "postman_organizer_app_default_scopes" {
  realm_id  = keycloak_realm.organizers_realm.id
  client_id = keycloak_openid_client.postman_organizer_app.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.organizer_app.name,
  ]
}
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //
