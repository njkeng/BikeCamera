#!/bin/bash

function reset_default_configuration() {

	webroot_dir=$(sudo cat /etc/pihelmetcam/hostapd/reset.ini | grep --only-matching --perl-regexp "(?<=webroot_dir = \")\S+(?=\")")

    	echo Restoring PiHelmetCam defaults
	    sudo cp $webroot_dir/config/hostapd.conf /etc/hostapd/hostapd.conf
	    sudo cp $webroot_dir/config/dnsmasq.conf /etc/dnsmasq.conf
	    sudo cp $webroot_dir/config/dhcpcd.conf /etc/dhcpcd.conf
	    sudo cp $webroot_dir/config/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
	    sudo cp $webroot_dir/config/wpa_supplicant_wlan0.conf /etc/wpa_supplicant/wpa_supplicant_wlan0.conf
	    sudo cp $webroot_dir/config/wpa_supplicant_wlan1.conf /etc/wpa_supplicant/wpa_supplicant_wlan1.conf
	    sudo rm /etc/pihelmetcam/pihelmetcam.auth

}

reset_default_configuration
