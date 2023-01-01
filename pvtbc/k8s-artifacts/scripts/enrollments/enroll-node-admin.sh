set -x

#==============================================================#
# Global constants and parameters                              #
#==============================================================#
ORG_NAME=$1
ORG_TYPE=$2
ORG_NODE=$3
RCAADMIN_USER=$4

ID_NAME="${ORG_NAME}-${ORG_NODE}"
ID_SECRET="${ORG_NAME}-${ORG_NODE}pw"

CSR_HOSTS="${ORG_NAME}-${ORG_NODE},localhost"

CA_NAME="${ORG_NAME}-ca"
TLS_CERT_FILE="/tls/tls.crt"
RCAADMIN_MSP_DIR="/orgs/${ORG_TYPE}-orgs/${ORG_NAME}/users/${RCAADMIN_USER}/msp"
NODE_MSP_DIR="/orgs/${ORG_TYPE}-orgs/${ORG_NAME}/nodes/${ORG_NAME}-${ORG_NODE}/msp"

export FABRIC_CA_CLIENT_HOME="/orgs/${ORG_TYPE}-orgs/${ORG_NAME}"


#==============================================================#
# Add node admin                                               #
#==============================================================#
mkdir -p ${NODE_MSP_DIR}

echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/${CA_NAME}-7054.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/${CA_NAME}-7054.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/${CA_NAME}-7054.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/${CA_NAME}-7054.pem
    OrganizationalUnitIdentifier: orderer" > ${NODE_MSP_DIR}/config.yaml

fabric-ca-client  register \
  --url           https://${CA_NAME}:7054 \
  --id.name       ${ID_NAME} \
  --id.secret     ${ID_SECRET} \
  --id.type       ${ORG_TYPE} \
  --tls.certfiles ${TLS_CERT_FILE} \
  --mspdir        ${RCAADMIN_MSP_DIR}

fabric-ca-client enroll \
  --url https://${ID_NAME}:${ID_SECRET}@${CA_NAME}:7054 \
  --csr.hosts "${CSR_HOSTS}" \
  --mspdir ${NODE_MSP_DIR} \
  --tls.certfiles ${TLS_CERT_FILE}