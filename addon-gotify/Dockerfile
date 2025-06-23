FROM golang:alpine as builder

WORKDIR /build
RUN apk add --no-cache git
RUN git clone https://github.com/gotify/server.git . && \
    go build -o gotify

FROM alpine

RUN adduser -D -H -u 1000 gotify
USER gotify

COPY --from=builder /build/gotify /usr/local/bin/gotify

EXPOSE 80

CMD [ "gotify", "--config", "/data/config.yml" ]