FROM node:17-bullseye-slim

LABEL org.opencontainers.image.authors="me@kmpm.se"
LABEL org.opencontainers.image.source=https://github.com/kmpm/haraka365


WORKDIR /app

RUN npm install -g npm@8.4.1

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python2 build-essential make cmake g++ tnef
ENV PYTHON=/usr/bin/python2

# Install templating tools
RUN apt-get install -y  curl && \
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output /tmp/get-pip.py && \
    python2 /tmp/get-pip.py && \
    yes | pip2 install jinja2-cli pyyaml


RUN npm -g config set user root && \
    npm install -g Haraka@2.8.28 haraka-plugin-mongodb@1.8.1 haraka-plugin-headers@1.0.2

# Create default haraka config
ENV HARAKA_HOME=/app/haraka

RUN mkdir -p ${HARAKA_HOME} && \
    haraka -i ${HARAKA_HOME}


COPY templates /app/templates

COPY entrypoint.sh /usr/local/bin
RUN chmod 0755 /usr/local/bin/entrypoint.sh

# Default environment
ENV HARAKA_PORT=587
ENV HARAKA_ME=demo.test.com
ENV HARAKA_IN_USER=inuser@test.com HARAKA_IN_PWD=inpassword
ENV HARAKA_OUT_USER=someuser@test.com HARAKA_OUT_PWD=supersecret HARAKA_OUT_DOMAIN=test.com
ENV HARAKA_CERT_SUBJ="/C=SE/ST=SomeState/O=Acme Inc/OU=It Department/CN=demo.test.com"
ENV HARAKA_LOGLEVEL=info

EXPOSE 587

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "haraka" ]
