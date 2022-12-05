set -x

echo "...Generating certificates for orderer $1..."

export ORG_NAME="$1"
export ORG_DOMAIN="$ORG_NAME.example.com"

export CA_NAME="ca-${ORG_NAME}"
export FABRIC_CA_CLIENT_HOME="/orgs/ord-orgs/${ORG_NAME}/"

mkdir -p $FABRIC_CA_CLIENT_HOME

fabric-ca-client enroll \
  -u https://admin:adminpw@${CA_NAME}:7054 \
  --caname ca-${ORG_NAME} \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"

echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca-${ORG_NAME}-7054-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca-${ORG_NAME}-7054-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca-${ORG_NAME}-7054-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca-${ORG_NAME}-7054-ca-${ORG_NAME}.pem
    OrganizationalUnitIdentifier: orderer" > "/orgs/ord-orgs/${ORG_NAME}/msp/config.yaml"

fabric-ca-client register \
  --caname ca-${ORG_NAME} \
  --id.name orderer \
  --id.secret ordererpw \
  --id.type orderer \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"

fabric-ca-client register \
  --caname ca-${ORG_NAME} \
  --id.name ${ORG_NAME}-admin \
  --id.secret ${ORG_NAME}-adminpw \
  --id.type admin \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"



fabric-ca-client enroll \
  -u https://orderer:ordererpw@ca-${ORG_NAME}:7054 \
  --caname ca-${ORG_NAME} \
  -M "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/msp" \
  --csr.hosts ord0.${ORG_DOMAIN} \
  --csr.hosts localhost \
  --csr.hosts ca-${ORG_DOMAIN} \
  --csr.hosts ${ORG_NAME}-ord0 \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"

cp "/orgs/ord-orgs/${ORG_NAME}/msp/config.yaml" \
   "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/msp/config.yaml"

fabric-ca-client enroll \
  -u https://orderer:ordererpw@ca-${ORG_NAME}:7054 \
  --caname ca-${ORG_NAME} \
  -M "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/tls" \
  --enrollment.profile tls \
  --csr.hosts ord0.${ORG_DOMAIN} \
  --csr.hosts localhost \
  --csr.hosts ca-${ORG_NAME} \
  --csr.hosts ${ORG_NAME}-ord0 \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"

cp "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/tls/tlscacerts/"* \
   "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/tls/ca.crt"

cp "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/tls/signcerts/"* \
   "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/tls/server.crt"

cp "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/tls/keystore/"* \
   "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/tls/server.key"

mkdir -p "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/msp/tlscacerts"
cp "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/tls/tlscacerts/"* \
   "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/msp/tlscacerts/tlsca.${ORG_DOMAIN}-cert.pem"

mkdir -p "/orgs/ord-orgs/${ORG_NAME}/msp/tlscacerts"
cp "/orgs/ord-orgs/${ORG_NAME}/nodes/ord0.${ORG_DOMAIN}/tls/tlscacerts/"* \
   "/orgs/ord-orgs/${ORG_NAME}/msp/tlscacerts/tlsca.${ORG_DOMAIN}-cert.pem"


fabric-ca-client enroll \
  -u https://${ORG_NAME}-admin:${ORG_NAME}-adminpw@ca-${ORG_NAME}:7054 \
  --caname ca-${ORG_NAME} \
  -M "/orgs/ord-orgs/${ORG_NAME}/users/Admin@${ORG_DOMAIN}/msp" \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"

cp "/orgs/ord-orgs/${ORG_NAME}/msp/config.yaml" \
   "/orgs/ord-orgs/${ORG_NAME}/users/Admin@${ORG_DOMAIN}/msp/config.yaml"

{ set +x; } 2>/dev/null
