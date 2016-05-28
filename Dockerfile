#
# CertLint web-service docker image
# This docker requires running in privileged mode
#
FROM ubuntu:16.04
MAINTAINER Z.d.Peacock <zdp@thoomtech.com>

# Install ruby and pre-requisite packages for building the certlint-x509helper
RUN apt-get update -y && \
    apt-get install -y build-essential git patch libtool ruby ruby-dev autoconf curl

#
# Install certlint and certlint-x509helper
#
ADD certlint /usr/local/certlint
ADD asn1c /usr/local/certlint/build-x509helper/asn1c

# Once these files are in place, run the shell script to build the certlint-x509helper
ADD x509helper-installer.sh /tmp
RUN sh /tmp/x509helper-installer.sh && \
    rm /tmp/x509helper-installer.sh

#
# Required ruby gems (-N doesn't install ruby documentation)
#  - certlint:  public_suffix open4 simpleidn
#  - web-service: sinatra thin
#
RUN gem install -N public_suffix:1.5.3 open4 simpleidn sinatra thin

# Save the API to the correct location
WORKDIR /usr/local/app
ADD api .

EXPOSE 9000

CMD ["thin", "-R", "config.ru", "-p", "9000", "start"]
