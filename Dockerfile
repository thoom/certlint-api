#
# CertLint web-service docker image
# This docker requires running in privileged mode
#
FROM ruby:alpine
MAINTAINER Z.d.Peacock <zdp@thoomtech.com>

#
# Install certlint and certlint-x509helper
#
COPY certlint /usr/local/certlint
COPY asn1c /usr/local/certlint/build-x509helper/asn1c
COPY x509helper-installer.sh /tmp

#
# Install pre-requisite packages for building the certlint-x509helper
# Store the build dependencies so that they can be removed later
#
RUN apk add --no-cache --update --virtual .build-deps \
    build-base automake git patch libtool  autoconf curl \
    && apk add --no-cache --update libstdc++ \
    # Once these files are in place, run the shell script to build the certlint-x509helper
    && sh /tmp/x509helper-installer.sh \
    && rm /tmp/x509helper-installer.sh \
    #
    # Required ruby gems (-N doesn't install ruby documentation)
    #  - certlint:  public_suffix open4 simpleidn
    #  - web-service: sinatra thin
    #
    && gem install -N public_suffix:1.5.3 open4 simpleidn sinatra thin \
    # Remove leftover build dependencies
    && apk del .build-deps

# Save the API to the correct location
WORKDIR /server
COPY api .

EXPOSE 9000

CMD ["thin", "-R", "config.ru", "-p", "9000", "start"]
