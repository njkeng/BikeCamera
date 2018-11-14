<?php

define('RASPI_CONFIG', '/etc/bikecamera');
define('RASPI_CONFIG_NETWORKING',RASPI_CONFIG.'/networking');
define('RASPI_ADMIN_DETAILS', RASPI_CONFIG.'/bikecamera.auth');
define('RASPI_WIFI_CLIENT_INTERFACE', 'wlan0');

// Constants for configuration file paths.
// These are typical for default RPi installs. Modify if needed.
define('RASPI_HOSTAPD_CONFIG', '/etc/hostapd/hostapd.conf');
define('RASPI_WPA_SUPPLICANT_CONFIG', '/etc/wpa_supplicant/wpa_supplicant.conf');
define('RASPI_HOSTAPD_CTRL_INTERFACE', '/var/run/hostapd');
define('RASPI_WPA_CTRL_INTERFACE', '/var/run/wpa_supplicant');

//Page title text
define('RASPI_PAGETITLE_NAME', 'BikeCamera Configuration Portal');

//Menu navbar text
define('RASPI_NAVBAR_NAME', 'BikeCamera Configuration Portal v1.0');

// Optional services, set to true to enable.
define('RASPI_VIDEOSETTINGS_ENABLED', true );
define('RASPI_VIDEOFILES_ENABLED', true );
define('RASPI_CLIENT_ENABLED', true );
define('RASPI_HOTSPOT_ENABLED', true );
define('RASPI_TIME_ENABLED', false );
define('RASPI_CONFAUTH_ENABLED', true );
define('RASPI_SYSTEM_ENABLED', true );

?>
