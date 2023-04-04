#!/usr/bin/env bash


getPythonPackageVersion()
{
    pip show "$1" | grep Version | sed -e "s/Version: //"
}


export PYTHON_FLASK_VERSION
PYTHON_FLASK_VERSION="$(getPythonPackageVersion "Flask")"
export GUNICORN_CONFIG_LOCATION="/etc/gunicorn"

if [[ -z $USER_UID ]]; then
  USER_UID=$(id -u)
fi

if [[ -z $USER_GID ]]; then
  USER_GID=$(id -g)
fi

if [[ "$(id -u)" = '0' ]] && [[ "$USER_UID" != '0' ]]; then
  exec switch-user.sh -v \
    -d /app \
    -d "$GUNICORN_CONFIG_LOCATION" \
    -e "$BASH_SOURCE" \
      "$USER_UID:$USER_GID" "$*"
fi

if [[ "$1" = 'flask' ]]; then
  if compver.sh "$PYTHON_FLASK_VERSION < 0.11"
  then
    echo "Unsupported Flask version $PYTHON_FLASK_VERSION" >&2
    exit 1
  fi

  DEBUG_ENABLE=false

  if compver.sh "$PYTHON_FLASK_VERSION < 2.2.0"
  then
    case "${FLASK_ENV:-production}" in
      'development') DEBUG_ENABLE=true ;;
      'production') DEBUG_ENABLE=false ;;
      *)
        echo "Unknown environment $FLASK_ENV" >&2
        exit 1
        ;;
    esac
  else
    if [[ "${FLASK_DEBUG:-0}" = '0' ]]; then
      DEBUG_ENABLE=false
    else
      DEBUG_ENABLE=true
    fi
  fi

  if [[ "$2" = 'run' ]]; then
    if $DEBUG_ENABLE; then
      exec flask run --host=0.0.0.0
    else
      export GUNICORN_CONFIG_FILE="$GUNICORN_CONFIG_LOCATION/config.py"
      envsubst < "$GUNICORN_CONFIG_LOCATION/config.tmpl" > "$GUNICORN_CONFIG_FILE"
      exec gunicorn -c "$GUNICORN_CONFIG_FILE" "$FLASK_APP"
    fi
  fi
fi

exec "$@"
