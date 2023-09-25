#!/usr/bin/env bash


getPythonPackageVersion()
{
    pip show "$1" | grep Version | sed -e "s/Version: //"
}


GUNICORN_CONFIG_LOCATION=${GUNICORN_CONFIG_LOCATION:-'/etc/gunicorn'}
pythonFlaskVersion="$(getPythonPackageVersion "Flask")"

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
  if compver.sh "$pythonFlaskVersion < 0.11"
  then
    echo "Unsupported Flask version $pythonFlaskVersion" >&2
    exit 1
  fi

  debugEnable=false

  if compver.sh "$pythonFlaskVersion < 2.2.0"
  then
    FLASK_ENV=${FLASK_ENV:-'production'}
    case "$FLASK_ENV" in
      'development')
        debugEnable=true
        export FLASK_ENV
        ;;
      'production')
        debugEnable=false
        export FLASK_ENV
        ;;
      *)
        echo "Unknown environment $FLASK_ENV" >&2
        exit 1
        ;;
    esac
  else
    FLASK_DEBUG=${FLASK_DEBUG:-'0'}
    if [[ "$FLASK_DEBUG" = '0' ]]; then
      debugEnable=false
      export FLASK_DEBUG
    else
      debugEnable=true
      export FLASK_DEBUG
    fi
  fi

  if [[ "$2" = 'run' ]]; then
    if $debugEnable; then
      args='run --host=0.0.0.0'

      if [[ "${DEV_HTTPS:-0}" = '0' ]]; then
        export DEV_HTTPS='0'
      else
        args+=' --cert=adhoc'
        export DEV_HTTPS='1'
      fi

      exec flask $args
    else
      GUNICORN_CONFIG_TEMPLATE="$GUNICORN_CONFIG_LOCATION/config.tmpl"
      GUNICORN_CONFIG_FILE="$GUNICORN_CONFIG_LOCATION/config.py"

      if [[ ! -f "$GUNICORN_CONFIG_FILE" ]]; then
        export GUNICORN_CONFIG_LOCATION
        export GUNICORN_CONFIG_TEMPLATE
        export GUNICORN_CONFIG_FILE
        source "$GUNICORN_CONFIG_LOCATION/variables.sh"
        envsubst < "$GUNICORN_CONFIG_TEMPLATE" > "$GUNICORN_CONFIG_FILE"
      fi

      exec gunicorn -c "$GUNICORN_CONFIG_FILE" "$FLASK_APP"
    fi
  fi
fi

exec "$@"
