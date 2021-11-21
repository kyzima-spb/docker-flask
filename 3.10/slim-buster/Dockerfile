#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM python:3.10-slim-buster as build

ENV DEBIAN_FRONTEND noninteractive

RUN apt update

RUN set -x \
    && apt install -yq --no-install-recommends gcc libffi-dev build-essential

RUN set -x \
    && mkdir /wheels \
    && pip install --no-cache-dir --disable-pip-version-check wheel \
    && pip wheel flask gunicorn gevent --wheel-dir=/wheels


FROM python:3.10-slim-buster

LABEL maintainer="Kirill Vercetti <office@kyzima-spb.com>"

STOPSIGNAL SIGINT

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONPATH "/python_packages"
ENV USER_UID 1000
ENV USER_GID 1000
ENV FLASK_APP app:app
ENV FLASK_ENV production
ENV WORKER_CLASS gevent
ENV TIMEOUT 3000

EXPOSE 5000

VOLUME /app
WORKDIR /app

RUN set -x \
    && groupadd -g 1000 user \
    && useradd -u 1000 -g user -s /bin/bash -m user

RUN apt update

COPY --from=build /wheels /wheels

RUN set -x \
    && apt install -yq --no-install-recommends gettext-base gosu \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && pip install \
           --no-index \
           --find-links=/wheels \
           --no-cache-dir \
           --disable-pip-version-check \
               flask \
               gunicorn \
               gevent

ADD ./root /
ADD https://kyzima-spb.github.io/src/bash/pydep.sh /usr/local/bin

RUN ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh \
    && chmod +x /usr/local/bin/pydep.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["flask", "run"]