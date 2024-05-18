#!/usr/bin/python
import time
import paho.mqtt.client as mqtt
import RPi.GPIO as GPIO
import signal                   
import sys
import uuid

START_RECORDING_GPIO = 17
STOP_RECORDING_GPIO = 27
STATUS_RECORDING_GPIO = 22


def on_connect(client, userdata, flags, reason_code, properties=None):
    print(f"Connected with result code {reason_code}")


def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))


def setup_gpio():
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(START_RECORDING_GPIO, GPIO.IN)
    GPIO.setup(STOP_RECORDING_GPIO, GPIO.IN)
    GPIO.setup(STATUS_RECORDING_GPIO, GPIO.OUT)
    
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
    setup_gpio()
    signal.signal(
        signal.SIGINT, 
        lambda sig, frame: signal_handler(sig, frame, client.loop_stop)
    )
    is_recording = False
    client.publish("recording","OFF", retain=True)
    GPIO.output(STATUS_RECORDING_GPIO, False)
    while True:
        # TODO: Refactor, other publisher might overwrite recording => Would not work anymore
        is_recording_pin = GPIO.input(START_RECORDING_GPIO)
        is_stop_recording_pin = GPIO.input(STOP_RECORDING_GPIO)
        if is_recording_pin and not is_recording:
            client.publish("recording",str(uuid.uuid4()), retain=True)
            GPIO.output(STATUS_RECORDING_GPIO, True)
            is_recording = True
        elif not is_recording_pin and is_stop_recording_pin and is_recording: 
            client.publish("recording","OFF", retain=True)
            GPIO.output(STATUS_RECORDING_GPIO, False)
            is_recording = False
        time.sleep(1)
    
    
if __name__ == '__main__':
    main()