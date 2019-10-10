FROM alpine:latest
RUN apk --no-cache add jq curl git
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
