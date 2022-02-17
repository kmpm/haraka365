#!/bin/bash

set -e 


function mkjinja {
    ymlfile=$1
    tmpl=$2
    jinja2 templates/$tmpl.j2 $ymlfile --format=yml > config/$tmpl 
}

function mkconfig {
    if [ ! -d config ]; then
        mkdir config
        haraka -i /app
    fi
    YMLFILE=haraka-docker.yml
    echo haraka_me: $HARAKA_ME > $YMLFILE
    echo haraka_port: $HARAKA_PORT >> $YMLFILE
    echo haraka_out_user: $HARAKA_OUT_USER >> $YMLFILE
    echo haraka_out_pwd: $HARAKA_OUT_PWD >> $YMLFILE
    echo haraka_out_domain: $HARAKA_OUT_DOMAIN >> $YMLFILE
    echo haraka_in_user: $HARAKA_IN_USER >> $YMLFILE
    echo haraka_in_pwd: $HARAKA_IN_PWD >> $YMLFILE

    mkjinja $YMLFILE me
    mkjinja $YMLFILE smtp.ini
    mkjinja $YMLFILE smtp_forward.ini
    mkjinja $YMLFILE auth_flat_file.ini
    mkjinja $YMLFILE plugins
    mkjinja $YMLFILE tls.ini
}

function mkcert {
    if [ ! -f config/tls_cert.pem ]; then
        openssl req -x509 -nodes -days 2190 -newkey rsa:2048 \
            -subj "$HARAKA_CERT_SUBJ" \
            -keyout config/tls_key.pem -out config/tls_cert.pem
    fi
}

if [ "$1" == "haraka" ]; then
    mkconfig
    mkcert
    exec haraka -c /app
    exit 0
fi

if [ "$1" == mkconfig ]; then
    mkconfig
    exit 0
fi

if [ "$1" == mkcert ]; then
    mkcert
    exit 0
fi


exec $@