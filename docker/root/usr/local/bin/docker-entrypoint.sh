#!/usr/bin/env bash
# set -e

commandExists()
{
    command -v "$1" > /dev/null 2>&1
}


userExists()
{
    getent passwd $1 > /dev/null 2>&1
}


groupExists()
{
    getent group $1 > /dev/null 2>&1
}


if [[ -z $USER_UID ]]; then
    USER_UID=$(id -u)
fi

if [[ -z $USER_GID ]]; then
    USER_GID=$(id -g)
fi

if [[ "$1" = 'flask' ]]; then
    echo "Run Flask CLI; User: $(id -u), Group: $(id -g), Command: $@"

    if [[ "$(id -u)" = '0' ]] && [[ "$USER_UID" != '0' ]]; then
        if ! userExists "$USER_UID"; then
            usermod -u "$USER_UID" user
        fi
        
        if ! groupExists "$USER_GID"; then
            groupmod -g "$USER_GID" user
        fi

        chown -R $USER_UID:$USER_GID /home/user /app

		    # then restart script as user
        if commandExists "gosu"; then
            exec gosu $USER_UID:$USER_GID "$BASH_SOURCE" "$@"
        else
            exec su-exec $USER_UID:$USER_GID "$BASH_SOURCE" "$@"
        fi
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
