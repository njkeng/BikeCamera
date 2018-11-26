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
ledGPIO = 24            # LED is connected to GPIO 24 (pin 18)

# Read key-value pairs from the ini file
myvars = {}
with open('/etc/bikecamera/video/video.ini') as myfile:
    for line in myfile:
        name, var = line.partition(" = ")[::2]
        myvars[name.strip()] = var.strip()
myfile.close()

# Video parameters
hc_rotation = int(myvars["picamera_rotation"])
hc_hres = int(myvars["picamera_hres"])
hc_vres = int(myvars["picamera_vres"])
hc_framerate = int(myvars["picamera_framerate"])
hc_quality = int(myvars["picamera_quality"])
hc_bitrate = int(myvars["picamera_bitrate"]) * 1000000
hc_awb_mode = myvars["picamera_awb_mode"].strip('"')
hc_exp_mode = myvars["picamera_exp_mode"].strip('"')

# File parameters
vid_length = int(myvars["vid_length"])          # Video file length in minutes
vid_dir = myvars["vid_dir"].strip('"')
vid_datetime_enable = int(myvars["vid_datetime_enable"])
vid_datetime_size = int(myvars["vid_datetime_size"])
vid_camera_name = myvars["vid_camera_name"].strip('"')

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
        update_status()

    else:
        print ("Stopping recording")
        camera.stop_recording()
        led.on()
        update_status()

        # Move the previously recorded file
        source = vid_dir + '/raw/' + current_file
        destination = vid_dir + '/completed/' + current_file        
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
#        camera.split_recording(filename)
        camera.stop_recording()
        camera.start_recording(filename)

        # Move the previously recorded file
        source = vid_dir + '/raw/' + current_file
        destination = vid_dir + '/completed/' + current_file        
        shutil.move(source, destination)
        current_file = vid_file_name

# Update video annotation with current time and date
#
def update_annotation():

    annotation_timer = Timer(0.5, update_annotation).start()
    if camera.recording:
        camera_text = vid_camera_name + '  '
        if vid_datetime_enable:
            camera_text = camera_text + datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        camera.annotate_text = camera_text
        # The wait_recording function is called so that all camera errors are shown on screen
        camera.wait_recording(0.2)

# Check for start or stop commands stored in a file
#
def check_status():

    status_timer = Timer(2, check_status).start()

    # Read key-value pairs from the ini file
    statusvars = {}
    with open('/etc/bikecamera/video/status.ini', 'r') as statusfile:
        for line in statusfile:
            name, var = line.partition(" = ")[::2]
            statusvars[name.strip()] = var.strip()
    statusfile.close()

    status_start = int(statusvars["status_start"])
    status_stop = int(statusvars["status_stop"])

    if status_start:
        if not camera.recording:
            when_pressed()
        update_status()

    if status_stop:
        if camera.recording:
            when_pressed()
        update_status()


def update_status():
    statusfile = open('/etc/bikecamera/video/status.ini', 'w')
    statusfile.write("status_start = 0\n")
    statusfile.write("status_stop = 0\n")
    if camera.recording:
        statusfile.write("status_current = 1\n")
    else:
        statusfile.write("status_current = 0\n")

    statusfile.close()

# Main program
#
camera = picamera.PiCamera()
camera.resolution = (hc_hres, hc_vres)
camera.framerate = hc_framerate
camera.rotation = hc_rotation
camera.awb_mode = hc_awb_mode
camera.exposure_mode = hc_exp_mode
camera.annotate_background = picamera.Color('black')
camera.annotate_text_size = vid_datetime_size

# Usually don't want this.  The preview pops up over the whole desktop.
#camera.start_preview()

led = LED(ledGPIO)
led.on()

button = Button(buttonGPIO)
button.when_pressed = when_pressed

video_split()
update_annotation()
check_status()

print ("Waiting for a button press")

pause()
