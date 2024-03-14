#!/usr/bin/python
import RPi.GPIO as GPIO
import random
import time

switch = 17

GPIO.setmode(GPIO.BCM)
GPIO.setup(switch, GPIO.IN)

randomNothing = ["nothing", "still nothing", "just waiting", "Oh! Was there anything? No, probably just a fly", "I'm bored", "I wanna go home"]

try:
    while True:
        if GPIO.input(switch) is 1:
            print("I saw the sign!")
        else: 
            print(random.choice(randomNothing))
        time.sleep(1)
        
        
except KeyboardInterrupt:
    print("Bye Bye")
    GPIO.cleanup()