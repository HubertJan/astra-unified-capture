FROM alpine
RUN apk update && apk add python3 \
    && apk add py3-rpigpio \
    && apk add py3-paho-mqtt
COPY main.py /var/publisher/
CMD ["/var/publisher/main.py"]