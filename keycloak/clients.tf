// ------------------------------------------------------------------------------- //
// --------------------------- attendant's clients ------------------------------- //
// ------------------------------------------------------------------------------- //
data "keycloak_openid_client" "attendant_realm_management_client" {
  realm_id  = keycloak_realm.attendants_realm.id
  client_id = "realm-management"
}


resource "keycloak_openid_client_scope" "attendant_app_audiences" {
  realm_id    = keycloak_realm.attendants_realm.id
  name        = "attendant-client-audiences"
  description = "add all necessary audiences to attendant's app"
}

resource "keycloak_openid_audience_protocol_mapper" "ticket_service_audience_to_attendants_mapper" {
  realm_id                 = keycloak_realm.attendants_realm.id
  client_scope_id          = keycloak_openid_client_scope.attendant_app_audiences.id
  name                     = "ticket-service-audience-to-attendants-mapper"
  included_custom_audience = "ticken.ticket.service"
}

resource "keycloak_openid_client" "mobile_attendant_app" {
  realm_id                     = keycloak_realm.attendants_realm.id
  client_id                    = "mobile-attendant-app"

  name                         = "mobile attendant app"
  enabled                      = true

  access_type                  = "PUBLIC"
  standard_flow_enabled        = true
  direct_access_grants_enabled = true

  valid_redirect_uris = [
    "exp://*", "ticken-app://*"
  ]
  valid_post_logout_redirect_uris = [
    "exp://*", "ticken-app://*"
  ]

  login_theme = "mytheme"
}



resource "keycloak_openid_client" "ticken_ticket_service_in_attendant_realm" {
  realm_id            = keycloak_realm.attendants_realm.id
  client_id           = "ticken.ticket.service"

  name                = "ticken ticket service"
  enabled             = true

  # todo -> this is only during development
  client_secret       = "7x!A%D*G-KaPdSgVkYp3s5v8y/B?E(H+"

  access_type              = "CONFIDENTIAL"
  service_accounts_enabled = true
}

resource "keycloak_openid_client_service_account_role" "manage_users_grant_to_ticket_service_in_organizers_realm" {
  realm_id                = keycloak_realm.attendants_realm.id

  //noinspection HILUnresolvedReference (golang is not detecting this dependency)
  service_account_user_id = keycloak_openid_client.ticken_ticket_service_in_attendant_realm.service_account_user_id

  client_id               = data.keycloak_openid_client.attendant_realm_management_client.id
  role                    = "manage-users"
}

resource "keycloak_openid_client_service_account_role" "view_users_grant_to_ticket_service_in_organizers_realm" {
  realm_id                = keycloak_realm.attendants_realm.id

  //noinspection HILUnresolvedReference (golang is not detecting this dependency)
  service_account_user_id = keycloak_openid_client.ticken_ticket_service_in_attendant_realm.service_account_user_id

  client_id               = data.keycloak_openid_client.attendant_realm_management_client.id
  role                    = "view-users"
}



resource "keycloak_openid_client_default_scopes" "mobile_attendant_app_default_scopes" {
  realm_id  = keycloak_realm.attendants_realm.id
  client_id = keycloak_openid_client.mobile_attendant_app.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",

    # add required audiences of the app as default
    keycloak_openid_client_scope.attendant_app_audiences.name,
  ]
}
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //


// ------------------------------------------------------------------------------- //
// ------------------------------- organizer's app ------------------------------- //
// ------------------------------------------------------------------------------- //
data "keycloak_openid_client" "organizer_realm_management_client" {
  realm_id  = keycloak_realm.organizers_realm.id
  client_id = "realm-management"
}


resource "keycloak_openid_client_scope" "organizer_app_audience" {
  realm_id    = keycloak_realm.organizers_realm.id
  name        = "organizer-client-audiences"
  description = "all necessary audiences to attendant's app"
}

resource "keycloak_openid_audience_protocol_mapper" "event_service_audience_to_organizers_mapper" {
  realm_id                 = keycloak_realm.organizers_realm.id
  client_scope_id          = keycloak_openid_client_scope.organizer_app_audience.id
  name                     = "event-service-audience-to-organizers-mapper"
  included_custom_audience = "ticken.event.service"
}

resource "keycloak_openid_client" "client_organizer_app" {
  realm_id            = keycloak_realm.organizers_realm.id
  client_id           = "client-organizer-app"

  name                = "client organizer app"
  enabled             = true

  access_type                  = "PUBLIC"
  standard_flow_enabled        = true
  direct_access_grants_enabled = true
  
  valid_redirect_uris = [
    "http://localhost:5173/*"
  ]
  valid_post_logout_redirect_uris = [
    "http://localhost:5173/*"
  ]
  web_origins = [
    "http://localhost:5173"
  ]
  
  login_theme = "mytheme"
}



resource "keycloak_openid_client" "ticken_event_service_in_organizers_realm" {
  realm_id            = keycloak_realm.organizers_realm.id
  client_id           = "ticken.event.service"

  name                = "ticken event service"
  enabled             = true

  # todo -> this is only during development
  client_secret       = "7x!A%D*G-KaPdSgVkYp3s5v8y/B?E(H+"

  access_type              = "CONFIDENTIAL"
  service_accounts_enabled = true
}

resource  "keycloak_openid_client_service_account_role" "manage_users_grant_to_event_service_in_organizers_realm" {
  realm_id                = keycloak_realm.organizers_realm.id

  //noinspection HILUnresolvedReference (golang is not detecting this dependency)
  service_account_user_id = keycloak_openid_client.ticken_event_service_in_organizers_realm.service_account_user_id

  client_id               = data.keycloak_openid_client.organizer_realm_management_client.id
  role                    = "manage-users"
}

resource  "keycloak_openid_client_service_account_role" "view_users_grant_to_event_service_in_organizers_realm" {
  realm_id                = keycloak_realm.organizers_realm.id

  //noinspection HILUnresolvedReference (golang is not detecting this dependency)
  service_account_user_id = keycloak_openid_client.ticken_event_service_in_organizers_realm.service_account_user_id

  client_id               = data.keycloak_openid_client.organizer_realm_management_client.id
  role                    = "view-users"
}


resource "keycloak_openid_client_default_scopes" "client_organizer_app_default_scopes" {
  realm_id  = keycloak_realm.organizers_realm.id
  client_id = keycloak_openid_client.client_organizer_app.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",

    # add required audiences of the app as default
    keycloak_openid_client_scope.organizer_app_audience.name,
  ]
}
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //


// ------------------------------------------------------------------------------- //
// ----------------------------- validator's client ------------------------------ //
// ------------------------------------------------------------------------------- //
data "keycloak_openid_client" "validator_realm_management_client" {
  realm_id  = keycloak_realm.validators_realm.id
  client_id = "realm-management"
}


resource "keycloak_openid_client_scope" "validator_app_audience" {
  realm_id    = keycloak_realm.validators_realm.id
  name        = "validator-client-audiences"
  description = "add all necessary audiences to organizer's app"
}

resource "keycloak_openid_audience_protocol_mapper" "validator_service_audience_to_validators_mapper" {
  realm_id                 = keycloak_realm.validators_realm.id
  client_scope_id          = keycloak_openid_client_scope.validator_app_audience.id
  name                     = "validator-service-audience-to-validators-mapper"
  included_custom_audience = "ticken.validator.service"
}

resource "keycloak_openid_client" "mobile_validator_app" {
  realm_id            = keycloak_realm.validators_realm.id
  client_id           = "mobile.validator.app"

  name                = "mobile validator app"
  enabled             = true

  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true # log in validator
  service_accounts_enabled     = true # log in app to request validator login
  direct_access_grants_enabled = true # todo

  client_secret = "yCqXN4CvFFZzHnH5b1rNItSnsOAf3lOZ"

  valid_redirect_uris = [
    "exp://*", "ticken-validator-app://*"
  ]
  valid_post_logout_redirect_uris = [
    "exp://*", "ticken-validator-app://*"
  ]

  login_theme = "mytheme"
}



resource "keycloak_openid_client" "ticken_event_service_in_validators_realm" {
  realm_id            = keycloak_realm.validators_realm.id
  client_id           = "ticken.event.service"

  name                = "ticken event service"
  enabled             = true

  # todo -> this is only during development
  client_secret       = "7x!A%D*G-KaPdSgVkYp3s5v8y/B?E(H+"

  access_type              = "CONFIDENTIAL"
  service_accounts_enabled = true

  # to enable to login user user credentials
  # when registering validators
  direct_access_grants_enabled = true
}

resource  "keycloak_openid_client_service_account_role" "manage_users_grant_to_event_service_in_validators_realm" {
  realm_id                = keycloak_realm.validators_realm.id

  //noinspection HILUnresolvedReference (golang is not detecting this dependency)
  service_account_user_id = keycloak_openid_client.ticken_event_service_in_validators_realm.service_account_user_id

  client_id               = data.keycloak_openid_client.validator_realm_management_client.id
  role                    = "manage-users"
}

resource  "keycloak_openid_client_service_account_role" "view_users_grant_to_event_service_in_validators_realm" {
  realm_id                = keycloak_realm.validators_realm.id

  //noinspection HILUnresolvedReference (golang is not detecting this dependency)
  service_account_user_id = keycloak_openid_client.ticken_event_service_in_validators_realm.service_account_user_id

  client_id               = data.keycloak_openid_client.validator_realm_management_client.id
  role                    = "view-users"
}


resource "keycloak_openid_client_default_scopes" "mobile_validator_app_default_scopes" {
  realm_id  = keycloak_realm.validators_realm.id
  client_id = keycloak_openid_client.mobile_validator_app.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",

    keycloak_openid_client_scope.validator_app_audience.name,
  ]
}

resource "keycloak_openid_client_default_scopes" "ticken_event_service_in_validators_realm_default_scopes" {
  realm_id  = keycloak_realm.validators_realm.id
  client_id = keycloak_openid_client.ticken_event_service_in_validators_realm.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",

    keycloak_openid_client_scope.validator_app_audience.name,
  ]
}
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //

