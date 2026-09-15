#!/usr/bin/env bash
# Home Assistant add-on entrypoint for Sure.
#
# Translates /data/options.json into the environment variables Sure expects,
# prepares the database, then runs the web server and the Sidekiq worker.
set -euo pipefail

CONFIG_PATH="/data/options.json"

if [ ! -f "$CONFIG_PATH" ]; then
    echo "Config file not found: $CONFIG_PATH"
    exit 1
fi

option() {
    jq --raw-output "$1" "$CONFIG_PATH"
}

# Required configuration
POSTGRES_USER=$(option '.postgres_user // "postgres"')
POSTGRES_PASSWORD=$(option '.postgres_password')
POSTGRES_DB=$(option '.postgres_db // "postgres"')
SECRET_KEY_BASE=$(option '.secret_key_base')
DB_HOST=$(option '.db_host // "172.30.32.1"')
DB_PORT=$(option '.db_port // "5432"')
REDIS_URL=$(option '.redis_url // "redis://3b88f413-redis:6379"')
SELF_HOSTED=$(option '.self_hosted')
RAILS_FORCE_SSL=$(option '.rails_force_ssl')
RAILS_ASSUME_SSL=$(option '.rails_assume_ssl')
ONBOARDING_STATE=$(option '.onboarding_state // "open"')

# Optional configuration
PLAID_CLIENT_ID=$(option '.plaid_client_id // empty')
PLAID_SECRET=$(option '.plaid_secret // empty')
PLAID_ENV=$(option '.plaid_env // empty')
OPENAI_ACCESS_TOKEN=$(option '.openai_access_token // empty')

echo "DEBUG: Configured values:"
echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_PASSWORD: HIDDEN"
echo "POSTGRES_DB: $POSTGRES_DB"
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "REDIS_URL: $REDIS_URL"
echo "SELF_HOSTED: $SELF_HOSTED"
echo "RAILS_FORCE_SSL: $RAILS_FORCE_SSL"
echo "RAILS_ASSUME_SSL: $RAILS_ASSUME_SSL"
echo "ONBOARDING_STATE: $ONBOARDING_STATE"
echo "PLAID_CLIENT_ID: $PLAID_CLIENT_ID"
echo "PLAID_SECRET: HIDDEN"
echo "PLAID_ENV: $PLAID_ENV"
echo "OPENAI_ACCESS_TOKEN: HIDDEN"

export POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB SECRET_KEY_BASE
export DB_HOST DB_PORT REDIS_URL
export SELF_HOSTED RAILS_FORCE_SSL RAILS_ASSUME_SSL ONBOARDING_STATE

[ -n "$PLAID_CLIENT_ID" ] && export PLAID_CLIENT_ID
[ -n "$PLAID_SECRET" ] && export PLAID_SECRET
[ -n "$PLAID_ENV" ] && export PLAID_ENV
[ -n "$OPENAI_ACCESS_TOKEN" ] && export OPENAI_ACCESS_TOKEN

# Custom environment variables: the escape hatch for anything Sure reads that
# this addon has no option of its own for (SMTP settings, alternative AI
# providers, Rails tuning). Exported after the mapped options on purpose, so an
# entry that reuses one of their names wins and nobody is stuck with a value
# this wrapper decided for them.
#
# Both halves come back base64-encoded because a value may legitimately contain
# newlines (a PEM key) and a name may contain one until it is validated below;
# pairing raw lines would desynchronise the loop. @base64 works on jq 1.6, which
# is what Debian ships -- --raw-output0 does not.
custom_env_names=()
while IFS= read -r encoded_name && IFS= read -r encoded_value; do
    name=$(printf '%s' "$encoded_name" | base64 -d)
    value=$(printf '%s' "$encoded_value" | base64 -d)

    # Refuse rather than skip: a name the shell cannot export would otherwise
    # leave the user with a setting that looks applied in the UI but is not.
    if [[ ! "$name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
        echo "Invalid env_vars name '${name}': use letters, digits and underscores, not starting with a digit" >&2
        exit 1
    fi

    export "${name}=${value}"
    custom_env_names+=("$name")
done < <(jq --raw-output '(.env_vars // [])[] | (.name | @base64), (.value | @base64)' "$CONFIG_PATH")

# Names only. Any of these can hold a credential, and unlike the options above
# there is no way to tell which.
echo "ENV_VARS: ${custom_env_names[*]:-(none)} (values hidden)"

# /rails/storage is a symlink to this path (see Dockerfile), so Active Storage
# uploads land on the add-on's persistent volume.
mkdir -p /data/storage

prepare_pid=""
worker_pid=""
web_pid=""
stopping=0

terminate() {
    stopping=1
    # The "|| true" is load-bearing: kill is the last command of the && list, so
    # under errexit its failure would abort the script mid-loop. Bash reaps
    # exited children on its own, so signalling an already-dead process fails
    # routinely -- that is the normal path when one service dies on its own.
    for pid in "$prepare_pid" "$worker_pid" "$web_pid"; do
        [ -n "$pid" ] && kill -TERM "$pid" 2>/dev/null || true
    done
    return 0
}

# Installed before any long-running step. This script is PID 1, and PID 1 does
# not get the default signal handlers, so without a trap Home Assistant's stop
# request would be ignored until Docker escalates to SIGKILL.
trap terminate TERM INT

# Create or migrate the database once, before either process starts. Sidekiq
# boots Rails too and would fail on a database that does not exist yet. It runs
# in the background so that a stop request during a long migration is honoured.
/rails/bin/docker-entrypoint ./bin/rails db:prepare &
prepare_pid=$!
prepare_status=0
wait "$prepare_pid" || prepare_status=$?
prepare_pid=""
if [ "$stopping" -eq 1 ]; then
    echo "Stop requested during database preparation"
    exit "$prepare_status"
fi
if [ "$prepare_status" -ne 0 ]; then
    echo "Database preparation failed (exit ${prepare_status})"
    exit "$prepare_status"
fi

# Sure runs background jobs on Sidekiq, which has no in-process mode, so the
# worker needs its own process next to the web server.
/rails/bin/docker-entrypoint bundle exec sidekiq &
worker_pid=$!

/rails/bin/docker-entrypoint "$@" &
web_pid=$!

# If either process exits, stop the other one so Home Assistant restarts the
# add-on instead of leaving it half running.
exit_code=0
wait -n || exit_code=$?
terminate
wait || true
exit "$exit_code"
