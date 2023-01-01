set -x

#==============================================================#
# Global constants and parameters                              #
#==============================================================#
ORG_NAME=$1
ORG_TYPE=$2

USER_NAME=$3
USER_TYPE=$4

RCAADMIN_USER=$5

ID_NAME="${USER_NAME}"
ID_SECRET="${USER_NAME}pw"

CA_NAME="${ORG_NAME}-ca"
TLS_CERT_FILE="/tls/tls.crt"
USER_MSP_DIR="/orgs/${ORG_TYPE}-orgs/${ORG_NAME}/users/${USER_NAME}/msp"

RCAADMIN_MSP_DIR="/orgs/${ORG_TYPE}-orgs/${ORG_NAME}/users/${RCAADMIN_USER}/msp"

export FABRIC_CA_CLIENT_HOME="/orgs/${ORG_TYPE}-orgs/${ORG_NAME}"

#==============================================================#
# Add organization user                                        #
#==============================================================#
mkdir -p ${USER_MSP_DIR}

echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/${CA_NAME}-7054-${CA_NAME}.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/${CA_NAME}-7054-${CA_NAME}.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/${CA_NAME}-7054-${CA_NAME}.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/${CA_NAME}-7054-${CA_NAME}.pem
    OrganizationalUnitIdentifier: orderer" > ${USER_MSP_DIR}/config.yaml

fabric-ca-client register \
  --url           https://${CA_NAME}:7054 \
  --id.type       ${USER_TYPE} \
  --id.name       ${ID_NAME} \
  --id.secret     ${ID_SECRET} \
  --tls.certfiles ${TLS_CERT_FILE} \
  --mspdir        ${RCAADMIN_MSP_DIR}

fabric-ca-client enroll \
  --url https://${ID_NAME}:${ID_SECRET}@${CA_NAME}:7054 \
  --caname ${CA_NAME} \
  --mspdir ${USER_MSP_DIR} \
  --tls.certfiles ${TLS_CERT_FILE}

