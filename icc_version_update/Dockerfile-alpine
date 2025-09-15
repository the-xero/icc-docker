FROM alpine:3.21

RUN apk add --no-cache curl git bash

WORKDIR /app

COPY update_version.sh /app/update_version.sh
RUN chmod +x /app/update_version.sh

CMD ["./update_version.sh"]
