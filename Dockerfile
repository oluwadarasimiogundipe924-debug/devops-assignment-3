FROM alpine:3.22

RUN apk add --no-cache \
    bash \
    coreutils \
    procps \
    iputils \
    bind-tools \
    libc-utils

WORKDIR /app

COPY app/app.sh /app/app.sh

RUN chmod +x /app/app.sh

ENTRYPOINT ["/app/app.sh"]

CMD ["help"]
