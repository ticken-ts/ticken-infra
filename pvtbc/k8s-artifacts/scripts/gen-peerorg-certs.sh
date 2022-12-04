set -x

echo "...Generating certificates for org $1..."

export ORG_NAME="$1"
export ORG_DOMAIN="$ORG_NAME.example.com"

export CA_NAME="ca-${ORG_NAME}"
export FABRIC_CA_CLIENT_HOME="/orgs/peer-orgs/${ORG_NAME}/"

mkdir -p $FABRIC_CA_CLIENT_HOME

fabric-ca-client enroll \
  -u https://admin:adminpw@${CA_NAME}:7054 \
  --caname $CA_NAME \
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
    OrganizationalUnitIdentifier: orderer" > "/orgs/peer-orgs/${ORG_NAME}/msp/config.yaml"


fabric-ca-client register \
  --caname ca-${ORG_NAME} \
  --id.name peer0 \
  --id.secret peer0pw \
  --id.type peer \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"

fabric-ca-client register \
  --caname ca-${ORG_NAME} \
  --id.name user1 \
  --id.secret user1pw \
  --id.type client \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"

fabric-ca-client register \
  --caname ca-${ORG_NAME} \
  --id.name ${ORG_NAME}-admin \
  --id.secret ${ORG_NAME}-adminpw \
  --id.type admin \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"


fabric-ca-client enroll \
  -u https://peer0:peer0pw@ca-${ORG_NAME}:7054 \
  --caname ca-${ORG_NAME} \
  -M "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/msp" \
  --csr.hosts peer0.${ORG_DOMAIN} \
  --csr.hosts ${ORG_NAME}-peer0 \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"

cp "/orgs/peer-orgs/${ORG_NAME}/msp/config.yaml" \
   "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/msp/config.yaml"

fabric-ca-client enroll -u \
  https://peer0:peer0pw@ca-${ORG_NAME}:7054 \
  --caname ca-${ORG_NAME} \
  -M "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/tls" \
  --enrollment.profile tls \
  --csr.hosts peer0.${ORG_DOMAIN} \
  --csr.hosts ca-${ORG_NAME} \
  --csr.hosts localhost \
  --csr.hosts ${ORG_NAME}-peer0 \
  --tls.certfiles  "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"

cp "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/tls/tlscacerts/"* \
   "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/tls/ca.crt"

cp "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/tls/signcerts/"* \
   "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/tls/server.crt"

cp "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/tls/keystore/"* \
   "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/tls/server.key"






mkdir -p "/orgs/peer-orgs/${ORG_NAME}/msp/tlscacerts"
cp "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/tls/tlscacerts/"* \
   "/orgs/peer-orgs/${ORG_NAME}/msp/tlscacerts/ca.crt"

mkdir -p "/orgs/peer-orgs/${ORG_NAME}/tlsca"
cp "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/tls/tlscacerts/"* \
   "/orgs/peer-orgs/${ORG_NAME}/tlsca/tlsca.${ORG_DOMAIN}-cert.pem"

mkdir -p "/orgs/peer-orgs/${ORG_NAME}/ca"
cp "/orgs/peer-orgs/${ORG_NAME}/nodes/peer0.${ORG_DOMAIN}/msp/cacerts/"* \
   "/orgs/peer-orgs/${ORG_NAME}/ca/ca.${ORG_DOMAIN}-cert.pem"


fabric-ca-client enroll \
  -u https://user1:user1pw@ca-${ORG_NAME}:7054 \
  --caname ca-${ORG_NAME} \
  -M "/orgs/peer-orgs/${ORG_NAME}/users/User1@${ORG_DOMAIN}/msp" \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"

cp "/orgs/peer-orgs/${ORG_NAME}/msp/config.yaml" \
   "/orgs/peer-orgs/${ORG_NAME}/users/User1@${ORG_DOMAIN}/msp/config.yaml"



fabric-ca-client enroll \
  -u https://${ORG_NAME}-admin:${ORG_NAME}-adminpw@ca-${ORG_NAME}:7054 \
  --caname ca-${ORG_NAME} \
  -M "/orgs/peer-orgs/${ORG_NAME}/users/Admin@${ORG_DOMAIN}/msp" \
  --tls.certfiles "/orgs/fabric-ca/${ORG_NAME}/tls-cert.pem"

cp "/orgs/peer-orgs/${ORG_NAME}/msp/config.yaml" \
   "/orgs/peer-orgs/${ORG_NAME}/users/Admin@${ORG_DOMAIN}/msp/config.yaml"

{ set +x; } 2>/dev/null
