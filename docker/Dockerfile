ARG PYVERSION=3.11
ARG RELEASE=slim-bullseye

FROM python:$PYVERSION-$RELEASE as build

ENV DEBIAN_FRONTEND noninteractive

RUN set -ex \
    && apt update \
    && apt install -yq --no-install-recommends \
        gcc \
        libffi-dev \
        build-essential \
    && pip install \
        --no-cache-dir \
        --disable-pip-version-check \
            wheel \
    && mkdir /wheels \
    && pip wheel \
        --wheel-dir=/wheels \
            flask \
            gunicorn \
            gevent


FROM python:$PYVERSION-$RELEASE

LABEL maintainer="Kirill Vercetti <office@kyzima-spb.com>"

STOPSIGNAL SIGINT

EXPOSE 5000

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONPATH "/python_packages:/app"
ENV USER_UID 1000
ENV USER_GID 1000
ENV FLASK_APP app:app
ENV WORKER_CLASS gevent
ENV TIMEOUT 3000

WORKDIR /app

COPY --from=build /wheels /wheels

RUN set -ex \
    && apt update \
    && apt install -yq --no-install-recommends \
        gettext-base \
        gosu \
    && pip install \
        --no-index \
        --find-links=/wheels \
        --no-cache-dir \
        --disable-pip-version-check \
           flask \
           gunicorn \
           gevent \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /wheels

RUN set -ex \
   && groupadd -g 1000 user \
   && useradd -u 1000 -g user -s /bin/bash -m user

ARG USEFUL_URL="https://kyzima-spb.github.io/docker-useful/dockerfile/"
ADD $USEFUL_URL/compver/compver /usr/local/bin/
ADD $USEFUL_URL/switch-user.sh /usr/local/bin/

RUN set -ex \
    && chmod +x /usr/local/bin/switch-user.sh \
                /usr/local/bin/compver

COPY ./root /

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["flask", "run"]
