#!/usr/bin/env python3

# Python script to record video
#
import picamera
import shutil
from gpiozero import Button, LED
from threading import Timer
from signal import pause
from datetime import datetime

# GPIO parameters
buttonGPIO = 10         # Pushbutton is connected to GPIO 10 (pin 19)
ledGPIO = 7             # LED is connected to GPIO 7 (pin 26)

# Read key-value pairs from the ini file
myvars = {}
with open(vid_dir + '/video.ini') as myfile:
    for line in myfile:
        name, var = line.partition(" = ")[::2]
        myvars[name.strip()] = var.strip()

# Video parameters
hc_hflip = int(myvars["picamera_hflip"])
hc_vflip = int(myvars["picamera_vflip"])
hc_hres = int(myvars["picamera_hres"])
hc_vres = int(myvars["picamera_vres"])
hc_framerate = int(myvars["picamera_framerate"])
hc_quality = int(myvars["picamera_quality"])
hc_bitrate = int(myvars["picamera_bitrate"])

# File parameters
vid_length = int(myvars["vid_length"])          # Video file length in minutes
vid_dir = myvars["vid_dir"].strip('"')
vid_datetime_enable = int(myvars["vid_datetime_enable"])
vid_datetime_size = int(myvars["vid_datetime_size"])

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
        shutil.move(source, destination)


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
        shutil.move(source, destination)
        current_file = vid_file_name



# Update video annotation with current time and date
#
def update_annotation():

    annotation_timer = Timer(0.5, update_annotation).start()
    if camera.recording:
        if vid_datetime_enable:
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
if vid_datetime_enable:
    camera.annotate_background = picamera.Color('black')
    camera.annotate_text_size = vid_datetime_size

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
