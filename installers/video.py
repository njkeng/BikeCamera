#!/usr/bin/env python3

# Python script to record video
#
from picamera import PiCamera
from gpiozero import Button, LED
from threading import Timer
from signal import pause
from datetime import datetime

# Video parameters
hc_hres = 640
hc_vres = 360
hc_framerate = 24
hc_quality = 20
hc_bitrate = 750000
hc_hflip = True
hc_vflip = False

# File parameters
vid_length = 5          # Video file length in minutes
vid_dir = '/etc/pihelmetcam/video/processing/'

# GPIO parameters
buttonGPIO = 10         # Pushbutton is connected to GPIO 10 (pin 19)
ledGPIO = 7             # LED is connected to GPIO 7 (pin 26)

# Toggle start / stop recording wshen the button is pressed
#
def when_pressed():

    if not camera.recording:
        print ("Starting recording")
        dt = datetime.now().isoformat()
        filename = vid_dir + 'vid%s.h264' % dt
        print ("Filename is: " + filename)
        camera.start_recording(filename, format='h264', quality=hc_quality, bitrate=hc_bitrate)
        led.on()
        split_timer.start()

    if camera.recording:
        print ("Stopping recording")
        camera.stop_recording()
        led.off()
        split_timer.cancel()

# Start a new file if the time limit is reached
#
def video_split():

    if camera.recording:
        print ("Split recording")
        dt = datetime.now().isoformat()
        filename = vid_dir + 'vid%s.h264' % dt
        print ("Filename is: " + filename)
        camera.split_recording(filename)
        split_timer.start()

# Update video annotation with current time and date
#
def update_annotation():

    if camera.recording:
        camera.annotate_text = datetime.now().isoformat()

        # Wait for a delay time
        # The wait_recording function should be called so 
        # that all camera errors are shown on screen
        camera.wait_recording(0.2)
    annotation_timer.start()

# Main program
#
camera = PiCamera()
camera.resolution = (hc_hres, hc_vres)
camera.framerate = hc_framerate
camera.hflip = hc_hflip
camera.vflip = hc_vflip

led = LED(ledGPIO)
led.off()

button = Button(buttonGPIO)
button.when_pressed = when_pressed

split_timer = Timer(vid_length * 60, video_split)
annotation_timer = Timer(0.5, update_annotation)

print ("Waiting for a button press")

pause()
