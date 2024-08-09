#!/usr/bin/env sh

# read env file & pass to command as --dart-define args
ARGS=$(cat .env | sed 's/^\|$/"/g' | sed "s/^/--dart-define=/" | xargs -d'\n')

flutter build "${1}" ${ARGS}
