FROM node:17-bullseye-slim

LABEL org.opencontainers.image.authors="me@kmpm.se"
LABEL org.opencontainers.image.source=https://github.com/kmpm/haraka365


WORKDIR /app

RUN npm install -g npm@8.4.1

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python2 build-essential
ENV PYTHON=/usr/bin/python2

RUN npm -g config set user root && \
    npm install -g Haraka@2.8.28 && \
    haraka -i /app


RUN apt-get install -y  curl && \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output /tmp/get-pip.py && \
    python2 /tmp/get-pip.py && \
    yes | pip2 install jinja2-cli pyyaml

COPY templates /app/templates

COPY haraka-entrypoint.sh /usr/local/bin
RUN chmod 0755 /usr/local/bin/haraka-entrypoint.sh

ENV HARAKA_PORT=587
ENV HARAKA_ME=demo.test.com
ENV HARAKA_IN_USER=inuser@test.com HARAKA_IN_PWD=inpassword
ENV HARAKA_OUT_USER=someuser@test.com HARAKA_OUT_PWD=supersecret HARAKA_OUT_DOMAIN=test.com
ENV HARAKA_CERT_SUBJ="/C=SE/ST=SomeState/O=Acme Inc/OU=It Department/CN=demo.test.com"
ENV HARAKA_LOGLEVEL=info


EXPOSE 587

ENTRYPOINT [ "haraka-entrypoint.sh" ]
CMD [ "haraka" ]