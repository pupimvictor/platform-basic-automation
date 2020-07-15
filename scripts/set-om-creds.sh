echo "OM target - opsmgr-02.${PKS_DOMAIN_NAME} - User: ${OPSMAN_USER}"

export OM_TARGET="opsmgr-02.${PKS_DOMAIN_NAME}"
export OM_USERNAME="${OPSMAN_USER}"
export OM_PASSWORD="${OPSMAN_PASSWORD}"
export OM_SKIP_SSL_VALIDATION=true
