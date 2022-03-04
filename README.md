# Haraka as forwarder to Office 365
There are some applications that need to send email using a O365 account that doesn't
support the required TLS versions.

This small machine will sit as a smtp forwarder in between whatever uses the deprecated
versions of TLS and newer ones.

## Config
### Config using environment variables.
There are a set of environment variables that will generate a yml file
which in turn will be applied to all config templates.

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

### Config using yml
If you need more options than the environment variables then create a yml file
directly and map as a volume in for example docker-compose.

```docker-compose
    volumes:
      - './data.yml:/app/data.yml'

```
The file needs to end up at `/app/data.yml`

```yml
---
me: mailserver
port: 587
loglevel: info
auth:
  # a list of user accounts that are allowed to send
  users:
    - name: inbounduser@somedomain.com
      pwd: 'supersneekypassword'
    - name: inbounduser@someotherdomain.com
      pwd: 'anothersecret'

# accounts to use when forwarding emails.
smtp_forward:
  # optional defaults if domains is not used or empty
  user: o365user@somedomain.com
  pwd: 'realysecret'
  # a list of domains that will be matched on `mail_from` domain name
  domains: 
    - name: somedomain.com
      user: o365user@somedomain.com
      pwd: 'realysecret'
    - name: someotherdomain.com
      user: realuser@someotherdomain.com
      pwd: 'realysecretagain'

# optional config for headers plugin
# headers:
#   required: 'From,Date'

# optional mongodb plugin from https://github.com/Helpmonks/haraka-plugin-mongodb
# mongodb:
#   connection: 'mongodb://root:example@mongo:27017/?authSource=admin'
#   db: 'haraka'



```

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
- https://github.com/Helpmonks/haraka-plugin-mongodb
- https://github.com/mattrobenolt/jinja2-cli
