# ticken-infra

## Keycloak

The `keycloak-themes` folder contains the necessary theme to match the app/backoffice design, it must be mounted to `opt/keycloak/themes` (or copy the contents) when using the official keycloak docker image. If not using the docker image, read the keycloak docs to know where to copy the themes.

To apply the keycloak configuration using terraform it is necessary to create a client for terraform inside the `master` realm, give the necessary permissions and copy the client secret:

- Login into the admin page
- Go to the "Clients" section
- Click "Create client"
- Under "client ID" type `terraform` and click next
- In the "capability config" step, enable "client authentication" and then under "authentication flow" enable "service accounts roles"
- If you haven't been redirected to the client page, go to the "clients" section and click on the newly created client 
- Go to the "service accounts roles" tab and click "assign role"
- Enable all the roles and click "assign"
- Go to the "credentials" tab and copy the client secret
- On your terminal, go to the "keycloak" folder and input `terraform apply`
- Paste the previously copied client secret when prompted
- Enter `yes` to confirm the changes
