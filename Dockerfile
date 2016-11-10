FROM alpine
RUN apk add --no-cache socat
VOLUME ["/local", "/tmp/out"]
COPY helpers /local/helpers
ENTRYPOINT ["socat"]
