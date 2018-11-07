FROM alpine:latest
LABEL maintainer="iarly selbir"

EXPOSE 8180

RUN apk --update add tor haproxy

COPY haproxy.conf docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
