#!/usr/bin/env bash
set -e

if [[ -z $USER_UID ]]; then
    USER_UID=$(id -u)
fi

if [[ -z $USER_GID ]]; then
    USER_GID=$(id -g)
fi

if [[ "$1" = 'flask' ]]; then
    echo "Run Flask CLI; User: $(id -u), Command: $@"

    if [[ "$(id -u)" = '0' ]]; then
        chown -R $USER_UID:$USER_GID /home/user /app
        usermod -u $USER_UID user
        groupmod -g $USER_GID user

		# then restart script as user
		exec gosu user "$BASH_SOURCE" "$@"
	fi

    if [[ "$2" = 'run' ]]; then
        case "$FLASK_ENV" in
            'development')
                exec flask run --host=0.0.0.0
                ;;
            'production')
                envsubst < /gunicorn_config.tmpl > $HOME/gunicorn_config.py
                exec gunicorn -c $HOME/gunicorn_config.py $FLASK_APP
                ;;
            *)
                echo "Unknow environment $FLASK_ENV" >&2
                exit 1
                ;;
        esac
    fi
fi

exec "$@"
