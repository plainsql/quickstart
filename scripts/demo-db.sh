#!/usr/bin/env bash

# Prepares a hosted Postgres database as the public PlainSQL demo. Applies the
# goose migrations, loads the sample users and posts, and creates a read-only
# role that the docs publish. Safe to run more than once.
#
# Usage:
#   DATABASE_OWNER_URL="postgresql://owner:secret@host/blog?sslmode=require" scripts/demo-db.sh
#
# DATABASE_OWNER_URL is the owner connection string. It is never printed.
# DATABASE_URL is the application connection string; this script does not use it.
# DEMO_ROLE and DEMO_PASSWORD set the read-only login. Both are public by
# design, so use values that you are happy to publish.

set -euo pipefail

DIR="$(CDPATH= cd "$(dirname "${0}")/.." && pwd)"
cd "${DIR}"

: "${DATABASE_OWNER_URL:?set DATABASE_OWNER_URL to the owner connection string}"
: "${DEMO_ROLE:=demo}"
: "${DEMO_PASSWORD:=demopassword1}"
: "${DEMO_CONNECTION_LIMIT:=20}"
: "${DEMO_STATEMENT_TIMEOUT:=5s}"

GOOSE="go run github.com/pressly/goose/v3/cmd/goose@v3.28.0"

step() {
    echo "==> ${*}"
}

fail() {
    echo "FAIL: ${*}" >&2
    exit 1
}

require_command() {
    local name="${1}"
    command -v "${name}" >/dev/null 2>&1 || fail "${name} is required but not on PATH"
}

# run_sql FILE runs one SQL file as the owner. psql stops on the first error.
run_sql() {
    local file="${1}"
    psql "${DATABASE_OWNER_URL}" \
        --quiet \
        --set ON_ERROR_STOP=1 \
        --set demo_role="${DEMO_ROLE}" \
        --set demo_password="${DEMO_PASSWORD}" \
        --set demo_connection_limit="${DEMO_CONNECTION_LIMIT}" \
        --set demo_statement_timeout="${DEMO_STATEMENT_TIMEOUT}" \
        --file "${file}"
}

step "Checking prerequisites"
require_command go
require_command psql

step "Applying goose migrations"
# shellcheck disable=SC2086
${GOOSE} -dir migrations postgres "${DATABASE_OWNER_URL}" up

step "Loading sample data"
run_sql scripts/demo-seed.sql

step "Creating the read-only role ${DEMO_ROLE}"
run_sql scripts/demo-role.sql

# Replace the owner credentials in the URL with the demo credentials. The rest
# of the URL, including the host, database, and sslmode, stays the same.
DEMO_URL="$(printf '%s' "${DATABASE_OWNER_URL}" | sed -E "s#//[^@/]*@#//${DEMO_ROLE}:${DEMO_PASSWORD}@#")"

step "Checking the read-only role"
psql "${DEMO_URL}" --quiet --set ON_ERROR_STOP=1 --tuples-only --no-align \
    --command "SELECT count(*) || ' users, ' || (SELECT count(*) FROM posts) || ' posts' FROM users"
if psql "${DEMO_URL}" --quiet --command "INSERT INTO users (email) VALUES ('write-check@example.com')" >/dev/null 2>&1; then
    fail "the ${DEMO_ROLE} role can write; check the grants in scripts/demo-role.sql"
fi

step "Done"
echo "Public read-only DSN:"
echo "  ${DEMO_URL}"
