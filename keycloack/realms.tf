resource "keycloak_realm" "organizers_realm" {
  realm             = "organizers"
  enabled           = true
  display_name      = "organizers"
}

resource "keycloak_realm" "attendants_realm" {
  realm             = "attendants"
  enabled           = true
  display_name      = "attendants"
}
