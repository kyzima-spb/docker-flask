FROM python:3.8-slim

LABEL maintainer="Kirill Vercetti <office@kyzima-spb.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONPATH "/python_packages"
ENV FLASK_ENV production
ENV WORKER_CLASS gevent
ENV TIMEOUT 3000

EXPOSE 5000

RUN apt update

RUN set -x \
    && apt install -yq --no-install-recommends gettext-base \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./root /
ADD https://kyzima-spb.github.io/src/bash/pydep.sh /usr/local/bin

RUN ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh \
    && chmod +x /usr/local/bin/pydep.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["run"]