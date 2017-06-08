FROM swift:latest

RUN apt-get -y update && \
  apt-get -y upgrade && \
  apt-get install -y libpq-dev libxml2-dev libssl-dev uuid-dev pkg-config && \
  mkdir -p /var/www/longisland-pdx

WORKDIR /var/www/longisland-pdx

ADD Package.swift Package.swift
RUN swift package fetch

ADD Sources Sources
RUN swift build --configuration release

ADD webroot webroot

EXPOSE 8080

ENTRYPOINT ["./.build/release/longisland-pdx"]
