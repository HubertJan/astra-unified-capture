#!/usr/bin/python
import time
import paho.mqtt.client as mqtt
import RPi.GPIO as GPIO
import signal                   
import sys

EVENT_GPIO = 17

def on_connect(client, userdata, flags, reason_code, properties=None):
    print(f"Connected with result code {reason_code}")


def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))


def setup_gpio():
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(EVENT_GPIO, GPIO.IN)
    
def setup_mqtt_client():
    client = mqtt.Client(client_id="py-sensors")
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect("192.168.2.1", 1883, 60)
    return client


def signal_handler(sig, frame, on_cleanup):
    GPIO.cleanup()
    sys.exit(0)
    on_cleanup()

def main():
    print("Start MQT Client")
    client = setup_mqtt_client()
    client.loop_start()
    client.publish("recording","ON", retain=True)
    print("Published 0N")
    setup_gpio()
    signal.signal(
        signal.SIGINT, 
        lambda sig, frame: signal_handler(sig, frame, client.loop_stop)
    )
    previous_state = None
    while True:
        # Refactor, other publisher might overwrite recording => Would not work anymore
        if GPIO.input(EVENT_GPIO) == 1 and previous_state != 1:
            client.publish("recording","ON", retain=True)
            previous_state = 1
        if GPIO.input(EVENT_GPIO) == 0 and previous_state != 0: 
            client.publish("recording","OFF", retain=True)
            previous_state = 0
        time.sleep(1)
    
    
if __name__ == '__main__':
    main()