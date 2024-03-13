#!/usr/bin/python
import time
import paho.mqtt.client as mqtt

# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, reason_code, properties=None):
    print(f"Connected with result code {reason_code}")
    # Subscribing in on_connect() means that if we lose the connection and
    # reconnect then subscriptions will be renewed.
    client.subscribe("$SYS/#")

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))

mqttc = mqtt.Client(client_id="py-sensors")
mqttc.on_connect = on_connect
mqttc.on_message = on_message

mqttc.connect("192.168.2.1", 1883, 60)

mqttc.loop_start() #start the loop
print("Subscribing to topic","house/bulbs/bulb1")
mqttc.subscribe("house/bulbs/bulb1")
is_recording = False
while True:
    print("Publishing message to topic","house/bulbs/bulb1")
    if is_recording:
        mqttc.publish("recording","ON")
    if not is_recording:
        mqttc.publish("recording","OFF")
    is_recording = not is_recording
    time.sleep(4)
mqttc.loop_stop() #stop the loop