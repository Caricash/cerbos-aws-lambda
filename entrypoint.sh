#!/usr/bin/env sh
envsubst '\
${CERBOS_HTTP_ADDR} \
${CERBOS_GRPC_ADDR} \
${CERBOS_ADMIN_API_ENABLED} \
${CERBOS_ADMIN_USERNAME} \
${CERBOS_ADMIN_PASSWORD_HASH} \
${CERBOS_GIT_URL} \
${CERBOS_POLICY_BRANCH} \
${CERBOS_POLICY_SUBDIR} \
${CERBOS_CHECKOUT_DIR} \
${CERBOS_UPDATE_POLL_INTERVAL} \
${CERBOS_OPERATION_TIMEOUT} \
${CERBOS_POLICY_DIR} \
${CERBOS_VALIDATION} \
${CERBOS_LOG_LEVEL} \
${CERBOS_GIT_USER} \
${GITHUB_TOKEN}' \
  < /conf.yml > /conf.resolved.yml

exec /gw --config /conf.resolved.yml
