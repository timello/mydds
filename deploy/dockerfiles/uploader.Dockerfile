FROM golang:alpine AS build-env

RUN apk --no-cache add tzdata

WORKDIR /staging

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -v -a -o uploader ./cmd/uploader

FROM alpine

WORKDIR /app

COPY --from=build-env staging/uploader .
COPY --from=build-env /usr/share/zoneinfo /usr/share/zoneinfo

ENV TZ=Europe/Berlin

EXPOSE 8080

CMD ["./uploader"]
