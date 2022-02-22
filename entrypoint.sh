#!/bin/bash

set -e 

APPDIR=/app
HARAKA_HOME=$APPDIR/haraka
YMLFILE=$APPDIR/data.yml

KEYFILE=$HARAKA_HOME/config/tls_key.pem
CERTFILE=$HARAKA_HOME/config/tls_cert.pem

if [ ! -d $HARAKA_HOME ]; then
    mkdir $HARAKA_HOME
fi

function mkconfig {
    if [ ! -d $HARAKA_HOME/config ]; then
        mkdir config
        haraka -i $HARAKA_HOME
    fi
    
    if [ ! -f $YMLFILE ]; then  
        echo "config from environment"
        echo "me: $HARAKA_ME" > $YMLFILE
        echo "port: $HARAKA_PORT" >> $YMLFILE
        echo "loglevel: $HARAKA_LOGLEVEL" >> $YMLFILE
        
        echo "auth:" >> $YMLFILE
        echo "  users:" >> $YMLFILE
        echo "    - name: '$HARAKA_IN_USER'" >> $YMLFILE
        echo "      pwd: '$HARAKA_IN_PWD'" >> $YMLFILE

        echo "smtp_forward:" >> $YMLFILE
        echo "  user: $HARAKA_OUT_USER" >> $YMLFILE
        echo "  pwd: '$HARAKA_OUT_PWD'" >> $YMLFILE
        echo "  domains:">> $YMLFILE
        echo "    - name: $HARAKA_OUT_DOMAIN" >> $YMLFILE
        echo "      user: $HARAKA_OUT_USER" >> $YMLFILE
        echo "      pwd: '$HARAKA_OUT_PWD'" >> $YMLFILE

        if [[ ! -z "${HARAKA_MONGO_CONNECTION}" ]]; then
            echo "mongodb:" >> $YMLFILE
            echo "  connection: '$HARAKA_MONGO_CONNECTION'" >> $YMLFILE
            echo "  db: '$HARAKA_MONGO_DB'" >> $YMLFILE
        fi
        echo "done creating '$YMLFILE' from environment"
    fi
    if [[ ! -z "$HARAKA_SHOW_CONFIG" ]]; then
        echo "--- $YMLFILE ---"
        cat $YMLFILE
        echo "----------------"
    fi
    echo "processing templates"
    for f in $APPDIR/templates/*.j2; do
        outfile=`basename "${f%.j2}"`
        outfile="$HARAKA_HOME/config/$outfile"
        echo "creating '$outfile' from '$f'"
        jinja2 $f $YMLFILE --format=yml > $outfile
    done    
}

function mkcert {
    if [ ! -f $CERTFILE ]; then
        echo "creating certificates for tls"
        openssl req -x509 -nodes -days 2190 -newkey rsa:2048 \
            -subj "$HARAKA_CERT_SUBJ" \
            -keyout $KEYFILE -out $CERTFILE
    fi
}

if [ "$1" == "haraka" ]; then
    mkconfig
    mkcert
    echo "launching haraka"
    exec haraka -c $HARAKA_HOME
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