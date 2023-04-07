# Table of contents

`kyzimaspb/flask` - is the base image for creating your own image with the Flask application.

- [How to create an image?](#how-to-create-an-image)
  - [Directory organization](#directory-organization) 
  - [Create Dockerfile](#create-dockerfile)
  - [Run in production mode](#run-in-production-mode)
  - [Run in development mode](#run-in-development-mode)
- [How to change UID/GID?](#how-to-change-uidgid)
- [Gunicorn configuration](#gunicorn-configuration)
  - [Method 1: Environment Variables](#method-1--environment-variables)
  - [Method 2: Configuration file](#method-2--configuration-file)


## How to create an image?

### Directory organization

Let's look at an example of creating an image for an existing Flask application.

The Flask application will use the project's [flat-layout][1] directory organization technique:

```
project_root_directory
├── Dockerfile        # To build an image
├── pyproject.toml    # AND/OR setup.cfg, setup.py
├── requirements.txt  # Fixed dependencies
├── ...
├── instance          # Configuration or deployment-specific files
└── app
    ├── ...
    └── __init__.py   # Contains the app variable or factory
```

### Create Dockerfile

It is recommended that you fix the version of the base image.
The version used is just an example:

```dockerfile
FROM kyzimaspb/flask:3.9-slim-bullseye

COPY ./requirements.txt ./

RUN set -ex \
    && pip install \
        --no-cache-dir \
        --disable-pip-version-check \
        -r requirements.txt

COPY . ./
```

### Run in production mode

Build an image file named `flask_app`
then run the container named `flask_app_1` in daemon mode
and forward the specified ports
to the specified ports of the host machine:

```shell
$ docker build -t flask_app .
$ docker run \
      --rm \
      -d \
      --name flask_app_1 \
      -p 5000:5000 \
      -e FLASK_APP=app:app \
      flask_app
```

Gunicorn is used as a production UWSGI web server.

### Run in development mode

In development mode, the application's source files are mounted into the container as a volume.

Build an image file named `flask_app` then run the container named `flask_app_1`:

```bash
$ docker build -t flask_app .
$ docker run \
    --rm \
    -ti \
    --name flask_app_1 \
    -v $(pwd):/app \
    -e FLASK_APP=app:app \
    -e FLASK_DEBUG=1 \
    flask_app
```

In Flask below version 2.2.0, the `FLASK_ENV` environment variable is used to enable debug mode:

```bash
$ docker run \
    --rm \
    -ti \
    --name flask_app_1 \
    -v $(pwd):/app \
    -e FLASK_APP=app:app \
    -e FLASK_ENV=development \
    flask_app
```


## How to change UID/GID?

By default, the application runs as a normal user with id 1000.
You can specify any user or group id
via the `USER_ID` and `GROUP_ID` environment variables at startup:

```shell
$ docker run \
      --rm \
      -d \
      --name flask_app_1 \
      -p 5000:5000 \
      -e FLASK_APP=app:app \
      -e USER_UID=1001 \
      -e USER_GID=1001 \
      flask_app
```

You can also use existing user or group names:

```shell
$ docker run \
      --rm \
      -d \
      --name flask_app_1 \
      -p 5000:5000 \
      -e FLASK_APP=app:app \
      -e USER_UID=www-data \
      -e USER_GID=www-data \
      flask_app
```


## Gunicorn configuration

By default, Gunicorn stores configuration files in the `/etc/gunicorn` directory,
but it can be changed using the `GUNICORN_CONFIG_LOCATION` environment variable.

### Method 1: Environment Variables

Configuration parameter values can be set via environment variables with the `GUNICORN_` prefix in the variable name.

The parameter names are the same as the environment variable names.
For example, the value of the `timeout` option can be set using the `GUNICORN_TIMEOUT` environment variable.

An exception for the `bind` option, its value is given by two variables: `GUNICORN_HOST` and `GUNICORN_PORT`.

```shell
$ docker run \
      --rm \
      -d \
      --name flask_app_1 \
      -p 9000:9000 \
      -e FLASK_APP=app:app \
      -e GUNICORN_PORT=9000 \
      -e GUNICORN_TIMEOUT=5000 \
      flask_app
```

So far, a limited number of variables are supported to test this approach.

### Method 2: Configuration file

If you don't like the first method for some reason,
you can copy the config file into the image:

```dockerfile
# ...
COPY ./gunicorn_config.py /etc/gunicorn/config.py
# ...
```

Or mount the file to the container at startup:

```shell
$ docker run \
      --rm \
      -d \
      --name flask_app_1 \
      -p 5000:5000 \
      -e FLASK_APP=app:app \
      -v $(pwd)/gunicorn_config.py:/etc/gunicorn/config.py \
      flask_app
```


[1]: <https://setuptools.pypa.io/en/latest/userguide/package_discovery.html#flat-layout> "flat-layout"
[2]: <https://setuptools.pypa.io/en/latest/userguide/package_discovery.html#src-layout> "src-layout"
