FROM dreamacro/clash-premium:latest
COPY ./entrypoint.sh /entrypoint.sh
RUN apk add --no-cache --update iproute2 \
    && apk add --no-cache --update iptables \
    && rm -rf /var/cache/apk/*
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "/clash"]