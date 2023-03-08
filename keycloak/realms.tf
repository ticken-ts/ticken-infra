// ------------------------------------------------------------------------------- //
// ------------------------------ organizer's realm ------------------------------ //
// ------------------------------------------------------------------------------- //
resource "keycloak_realm" "organizers_realm" {
  realm             = "organizers"
  enabled           = true
  display_name      = "organizers"
  login_theme       = "mytheme"
  registration_email_as_username = true
  registration_allowed = true
}
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //


// ------------------------------------------------------------------------------- //
// ------------------------------ attendant's realm ------------------------------ //
// ------------------------------------------------------------------------------- //
resource "keycloak_realm" "attendants_realm" {
  realm             = "attendants"
  enabled           = true
  display_name      = "attendants"
  login_theme       = "mytheme"
  registration_email_as_username = true
  registration_allowed = true
}
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //
// ------------------------------------------------------------------------------- //