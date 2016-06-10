Certlint API
============

A simple web API interface for the [certlint](https://github.com/awslabs/certlint.git) project.


Installation
------------

Provided as an Alpine Docker image.

    docker pull thoom/certlint-api
    docker run -p 9000:9000 --name certlint-api -d thoom/certlint-api


Usage
-----

Post a DER certificate to `/lint` endpoint.
