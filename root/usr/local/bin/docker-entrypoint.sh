#!/usr/bin/env bash
set -e


if [[ "$1" = 'run' ]]; then
    case "$FLASK_ENV" in
        'development')
            flask run --host=0.0.0.0
            ;;
        'production')
            envsubst < /gunicorn_config.tmpl > /gunicorn_config.py
            gunicorn -c /gunicorn_config.py $FLASK_APP
            ;;
        *)
            echo "Unknow environment $FLASK_ENV" >&2
            exit 1
            ;;
    esac
fi

exec "$@"
