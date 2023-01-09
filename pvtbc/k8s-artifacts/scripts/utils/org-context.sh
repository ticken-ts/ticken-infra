function set_peer_org_context() {
    local org=$1

    export FABRIC_CFG_PATH=/config
    export CORE_PEER_LOCALMSPID="${org}MSP"
    export CORE_PEER_ADDRESS=${org}-peer0:7051
    export CORE_PEER_MSPCONFIGPATH=/orgs/peer-orgs/${org}/users/${org}-admin/msp
    export CORE_PEER_TLS_ROOTCERT_FILE=/orgs/peer-orgs/${org}/msp/tlscacerts/tlsca-signcert.pem
}