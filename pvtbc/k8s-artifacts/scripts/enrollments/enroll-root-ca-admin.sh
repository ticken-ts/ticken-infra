set -x

#==============================================================#
# Global constants and parameters                              #
#==============================================================#
ORG_NAME=$1
ORG_TYPE=$2
RCAADMIN_USER=$3
RCAADMIN_PASS=$4

CA_NAME="${ORG_NAME}-ca"
TLS_CERT_FILE="/tls/tls.crt"
USER_MSP_DIR="/orgs/${ORG_TYPE}-orgs/${ORG_NAME}/users/${RCAADMIN_USER}/msp"

#==============================================================#
# Enroll the root CA user                                      #
#==============================================================#
fabric-ca-client enroll \
  --url https://${RCAADMIN_USER}:${RCAADMIN_PASS}@${CA_NAME}:7054 \
  --mspdir ${USER_MSP_DIR} \
  --tls.certfiles ${TLS_CERT_FILE}