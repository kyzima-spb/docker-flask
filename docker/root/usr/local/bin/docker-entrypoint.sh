#!/usr/bin/env bash

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


getPythonPackageVersion()
{
    pip show "$1" | grep Version | sed -e "s/Version: //"
}


export PYTHON_FLASK_VERSION="$(getPythonPackageVersion "Flask")"
export GUNICORN_CONFIG_LOCATION="/etc/gunicorn"

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

        chown -R $USER_UID:$USER_GID /home/user "$GUNICORN_CONFIG_LOCATION" /app

		    # then restart script as user
        if commandExists "gosu"; then
            exec gosu $USER_UID:$USER_GID "$BASH_SOURCE" "$@"
        else
            exec su-exec $USER_UID:$USER_GID "$BASH_SOURCE" "$@"
        fi
    fi
    
    if [[ "$PYTHON_FLASK_VERSION" < '1.0.0' ]]; then
        echo "Unsupported Flask version $FLASK_VERSION" >&2
        exit 1
    elif [[ "$PYTHON_FLASK_VERSION" < '2.2.0' ]]; then
        FLASK_ENV=${FLASK_ENV:-'production'}
        case "$FLASK_ENV" in
            'development') IS_DEBUG=true ;;
            'production') IS_DEBUG=false ;;
            *)
                echo "Unknow environment $FLASK_ENV" >&2
                exit 1
                ;;
        esac
    else
        FLASK_DEBUG=${FLASK_DEBUG:-'0'}
        case "$FLASK_DEBUG" in
            '0') IS_DEBUG=false ;;
            *) IS_DEBUG=true ;;
        esac
    fi

    if [[ "$2" = 'run' ]]; then
        if $IS_DEBUG; then
            exec flask run --host=0.0.0.0
        else
            export GUNICORN_CONFIG_FILE="$GUNICORN_CONFIG_LOCATION/config.py"
            envsubst < "$GUNICORN_CONFIG_LOCATION/config.tmpl" > "$GUNICORN_CONFIG_FILE"
            exec gunicorn -c "$GUNICORN_CONFIG_FILE" "$FLASK_APP"
        fi
    fi
fi

exec "$@"
