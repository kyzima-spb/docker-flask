#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
FROM python:3.10-alpine3.14 as build

RUN apk update
RUN apk add --no-cache build-base libffi-dev

RUN mkdir /wheels \
    && pip install --no-cache-dir --disable-pip-version-check wheel \
    && pip wheel flask gunicorn gevent --wheel-dir=/wheels


FROM python:3.10-alpine3.14

LABEL maintainer="Kirill Vercetti <office@kyzima-spb.com>"

STOPSIGNAL SIGINT

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
    && addgroup -g 1000 user \
    && adduser -u 1000 -G user -s /bin/sh -D user

RUN apk update

COPY --from=build /wheels /wheels

RUN set -x \
    && apk add --no-cache bash shadow gettext su-exec \
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