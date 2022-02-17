# Haraka as forwarder to Office 365
There are some applications that need to send email using a O365 account that doesn't
support the required TLS versions.

This small machine will sit as a smtp forwarder in between whatever uses the deprecated
versions of TLS and newer ones.

## Config
Config using environment variables.
- HARAKA_PORT=587                       Port that haraka listens to
- HARAKA_ME=demo.test.com               FQDN of the mailserver
- HARAKA_IN_USER=inuser@test.com        Inbound username 
- HARAKA_IN_PWD=inpassword              Inbound password
- HARAKA_OUT_USER=someuser@test.com     Outbound username
- HARAKA_OUT_PWD=supersecret            Outbound password
- HARAKA_OUT_DOMAIN=test.com            Outbound sending domain

And a special one `HARAKA_CERT_SUBJ` that is used to create a certificate for TLS
if none is found.
- HARAKA_CERT_SUBJ="/C=SE/ST=SomeState/O=Acme Inc/OU=It Department/CN=demo.test.com"

## Usage
```shell
docker volume create haraka365
docker run  -d --restart unless-stopped -v "haraka365:/app/config" haraka365
```

## Notes

```
openssl req -x509 -nodes -days 2190 -newkey rsa:2048 \
        -keyout config/tls_key.pem -out config/tls_cert.pem
```

- http://haraka.github.io/
- https://github.com/mattrobenolt/jinja2-cli
