#!/usr/bin/env python3

# Python script to record video
#
import picamera
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
vid_dir = '/etc/pihelmetcam/video/processing'

# GPIO parameters
buttonGPIO = 10         # Pushbutton is connected to GPIO 10 (pin 19)
ledGPIO = 7             # LED is connected to GPIO 7 (pin 26)


# Create an infinite supply of output files for video recording
#
def output_files():

    datetime = datetime.now().isoformat()
    filename = vid_dir 'vid%s.jpg' % datetime
    print (filename)
    yield io.open(filename)

# Toggle start / stop recording wshen the button is pressed
#
def when_pressed():

    if ! camera.recording()
        print ("Starting recording")
        camera.start_recording(output_files(), quality=hc_quality, bitrate=hc_bitrate)
        led.on()
        split_timer.start()

    if camera.recording()
        print ("Stopping recording")
        camera.stop_recording()
        led.off()
        split_timer.cancel()

# Start a new file if the time limit is reached
#
def video_split():

    if camera.recording()
        camera.split_recording(output_files())
        split_timer.start()


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

print ("Waiting for a button press")

pause()
