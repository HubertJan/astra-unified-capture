FROM alpine
RUN apk update && apk add hostapd \
    && apk add dnsmasq \
    && touch /etc/dnsmasq.conf
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY hostapd.conf /etc/hostapd/
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]