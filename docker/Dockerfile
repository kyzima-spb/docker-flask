ARG PYVERSION=3.11
ARG RELEASE=slim-bookworm

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
        --disable-pip-version-check wheel \
    && mkdir /wheels \
    && pip wheel --wheel-dir=/wheels gevent


FROM python:$PYVERSION-$RELEASE

LABEL maintainer="Kirill Vercetti <office@kyzima-spb.com>"

STOPSIGNAL SIGINT

EXPOSE 5000

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONPATH "/python_packages:/app"
ENV USER_UID 1000
ENV USER_GID 1000
ENV FLASK_APP app:app

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
            gevent \
    && pip install \
        --no-cache-dir \
        --disable-pip-version-check \
            flask \
            gunicorn \
            pythoninfo \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /wheels

RUN set -ex \
   && groupadd -g 1000 user \
   && useradd -u 1000 -g user -s /bin/bash -m user

COPY --from=kyzimaspb/useful /apps/compver/compver.sh /usr/local/bin/
COPY --from=kyzimaspb/useful /apps/switch-user/switch-user.sh /usr/local/bin/

COPY ./root /

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["flask", "run"]
