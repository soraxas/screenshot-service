FROM golang:latest AS build-env
WORKDIR /src
ENV CGO_ENABLED=0
COPY go.* /src/
RUN go mod download
COPY main.go .
RUN go build -a -o gochro -ldflags="-s -w" -trimpath

FROM alpine:latest

RUN apk add --no-cache chromium \
    && rm -rf /var/cache/apk \
    && mkdir -p /var/cache/apk

RUN mkdir -p /app \
    && adduser -D chrome \
    && chown -R chrome:chrome /app

RUN apk add dumb-init

# USER chrome
WORKDIR /app

ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/

COPY --from=build-env /src/gochro .

#USER chrome

# ENTRYPOINT [ "./gochro" ]
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["./gochro", "-host", "0.0.0.0:80", "-disable-sandbox"]

