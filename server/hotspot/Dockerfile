FROM alpine
RUN apk update && apk add hostapd \
    && apk add dhcp \
    && touch /etc/dhcp/dhcpd.conf \
    && touch /var/lib/dhcp/dhcpd.leases \
    && mkdir /run/dhcp/
COPY dhcpd.conf /etc/dhcp/dhcpd.conf
COPY hostapd.conf /etc/hostapd/
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]