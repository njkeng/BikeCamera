#!/usr/bin/env python3

# Python script to record video
#
import picamera
import shutil
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
hc_hflip = False
hc_vflip = False

# File parameters
vid_length = 5          # Video file length in minutes
vid_dir = '/etc/pihelmetcam/video/'

# GPIO parameters
buttonGPIO = 10         # Pushbutton is connected to GPIO 10 (pin 19)
ledGPIO = 7             # LED is connected to GPIO 7 (pin 26)

# Toggle start / stop recording wshen the button is pressed
#
def when_pressed():

    global current_file

    if not camera.recording:
        print ("Starting recording")
        dt = datetime.now().strftime('%Y-%m-%d_%H%M%S')
        vid_file_name = 'vid%s.h264' % dt
        filename = vid_dir + '/raw/' + vid_file_name
        print ("Filename is: " + filename)
        camera.start_recording(filename, format='h264', quality=hc_quality, bitrate=hc_bitrate)
        led.blink(on_time=0.5, off_time=0.5)
        current_file = vid_file_name

    else:
        print ("Stopping recording")
        camera.stop_recording()
        led.on()

        # Move the previously recorded file
        source = vid_dir + '/raw/' + current_file
        destination = vid_dir + '/processing/' + current_file        
        shutil.move(destination, source)


# Start a new file if the time limit is reached
#
def video_split():

    global current_file

    split_timer = Timer(vid_length * 60, video_split).start()
    if camera.recording:
        print ("Split recording")
        dt = datetime.now().strftime('%Y-%m-%d_%H%M%S')
        vid_file_name = 'vid%s.h264' % dt
        filename = vid_dir + '/raw/' + vid_file_name
        print ("Filename is: " + filename)
        camera.split_recording(filename)

        # Move the previously recorded file
        source = vid_dir + '/raw/' + current_file
        destination = vid_dir + '/processing/' + current_file        
        shutil.move(destination, source)
        current_file = vid_file_name



# Update video annotation with current time and date
#
def update_annotation():

    annotation_timer = Timer(0.5, update_annotation).start()
    if camera.recording:
        camera.annotate_text = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        # The wait_recording function is called so that all camera errors are shown on screen
        camera.wait_recording(0.2)

# Main program
#
camera = picamera.PiCamera()
camera.resolution = (hc_hres, hc_vres)
camera.framerate = hc_framerate
camera.hflip = hc_hflip
camera.vflip = hc_vflip
camera.annotate_background = picamera.Color('black')
camera.annotate_text_size = 15

# Usually don't want this.  The preview pops up over the whole desktop.
#camera.start_preview()

led = LED(ledGPIO)
led.on()

button = Button(buttonGPIO)
button.when_pressed = when_pressed

update_annotation()
video_split()

print ("Waiting for a button press")

pause()
