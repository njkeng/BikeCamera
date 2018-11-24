bc_devicename="bikecamera"
bikecamera_dir="/etc/bikecamera"
bikecamera_user="www-data"
version=`sed 's/\..*//' /etc/debian_version`

# Determine version, set default home location for lighttpd and 
# php package to install 
webroot_dir="/var/www/html" 
if [ $version -eq 9 ]; then 
    version_msg="Raspian 9.0 (Stretch)" 
    php_package="php7.0-cgi" 
elif [ $version -eq 8 ]; then 
    version_msg="Raspian 8.0 (Jessie)" 
    php_package="php5-cgi" 
else 
    version_msg="Raspian earlier than 8.0 (Wheezy)"
    webroot_dir="/var/www" 
    php_package="php5-cgi" 
fi 

# Outputs a BikeCamera Install log line
function install_log() {
    echo -e "\033[1;32mBikeCamera Install: $*\033[m"
}

# Outputs a BikeCamera Install Error log line and exits with status code 1
function install_error() {
    echo -e "\033[1;37;41mBikeCamera Install Error: $*\033[m"
    exit 1
}

# Outputs a BikeCamera Install attention line
function install_attn() {
    echo -e "\033[1;33mBikeCamera Attention: $*\033[m"
}

# Outputs a welcome message
function display_welcome() {
    red='\033[0;31m'
    green='\033[1;32m'

    echo -e "${red}\n"
    echo -e "   mmmmmmmmmmmmmmmmmmmmmmmmmmmmmm                 "
    echo -e "  mmmmmmmmmmmmm.             .+dM    MMMMMMMMMMMMM"
    echo -e " mmmmmmmmmmmmmm.  -osssssso+.  :m  mmmm           "
    echo -e "mmmmmmmmmmmmmmm.  ommmmmmmmm+  -d mmm             "
    echo -e "mmmmmmmmmmmmmmm.  omms'''''   -smmmm              "
    echo -e "mmmmmmmmmmmmmmm.  omms......  :h mmm              "
    echo -e " mmmmmmmmmmmmmm.  ommmmmmmmm+  :d mmm             "
    echo -e " mmmmmmmmmmmmmm.  -osssssoo+.  :m  mmm            "
    echo -e "  mmmmmmmmmmmmm.              +dM    MMMMMMMMMMMMM"
    echo -e "   mmmmmmmmmmmmmmmmmmmmmmmmmmmmmm                 "
    echo -e ""
    echo -e "${green}"
    echo -e "The Quick Installer will guide you through a few easy steps\n\n"
}

### NOTE: all the below functions are overloadable for system-specific installs
### NOTE: some of the below functions MUST be overloaded due to system-specific installs

function config_installation() {
    install_log "Configure device name"
    echo "Detected ${version_msg}" 
    echo "Device name: $bc_devicename"
    install_attn "IMPORTANT:" 
    echo "If you have more than one BikeCamera then this name must be changed."
    user_devicename=""
    echo -n "Complete installation with this device name? [Y/n]: "
    read answer
    while [[ $answer == "n" ]]
    do
        echo "Enter a new device name"
        read user_devicename
        echo "Confirm that you want the device name to be $user_devicename [Y/n]: "
        read answer
    done
    if [ "$user_devicename" == "" ]; then
    	bikecamera_devicename="$bc_devicename"
    else
    	bikecamera_devicename="$user_devicename"
    fi
    install_attn "Installation continuing with device name: $bikecamera_devicename"
}

# Runs a system software update to make sure we're using all fresh packages
function update_system_packages() {
    # OVERLOAD THIS
    install_error "No function definition for update_system_packages"
}

# Installs additional dependencies using system package manager
function install_dependencies() {
    # OVERLOAD THIS
    install_error "No function definition for install_dependencies"
}

# Sets the hostname of the Pi
function set_hostname() {
    echo $bikecamera_devicename | sudo tee  /etc/hostname || install_error "Unable to set /etc/hostname"
    sudo sed -i -e 's/^.*bikecamera-installer.*$//g' /etc/hosts
    echo "127.0.1.1      " $bikecamera_devicename " ### Set by bikecamera-installer"  | sudo tee -a /etc/hosts || install_error "Unable to set /etc/hosts"
}

# Enables PHP for lighttpd and restarts service for settings to take effect
function enable_php_lighttpd() {
    install_log "Enabling PHP for lighttpd"

    sudo lighttpd-enable-mod fastcgi-php    
    sudo service lighttpd force-reload
    sudo /etc/init.d/lighttpd restart || install_error "Unable to restart lighttpd"
}

# Verifies existence and permissions of BikeCamera directory
function create_bikecamera_directories() {
    install_log "Creating BikeCamera directories"
    if [ -d "$bikecamera_dir" ]; then
        sudo mv $bikecamera_dir "$bikecamera_dir.`date +%F-%R`" || install_error "Unable to move old '$bikecamera_dir' out of the way"
    fi
    sudo mkdir -p "$bikecamera_dir" || install_error "Unable to create directory '$bikecamera_dir'"

    # Create a directory for existing file backups.
    sudo mkdir -p "$bikecamera_dir/backups"

    # Create a directory to store networking configs
    sudo mkdir -p "$bikecamera_dir/networking"
    # Copy existing dhcpcd.conf to use as base config
    cat /etc/dhcpcd.conf | sudo tee -a /etc/bikecamera/networking/defaults

    sudo chown -R $bikecamera_user:$bikecamera_user "$bikecamera_dir" || install_error "Unable to change file ownership for '$bikecamera_dir'"
}

# Generate logging directories for hostapd
function create_logging_scripts() {
    install_log "Creating logging scripts"
    sudo mkdir -p $bikecamera_dir/hostapd || install_error "Unable to create directory '$bikecamera_dir/hostapd'"
}

# Generate configuration reset files for bikecamera
function create_reset_scripts() {
    sudo mv /var/www/html/installers/reset.sh $bikecamera_dir/hostapd
    sudo mv /var/www/html/installers/button.py $bikecamera_dir/hostapd
}

# Move video files for bikecamera
function create_video_files() {
    install_log "Preparing video recording directories and scripts"
    sudo mkdir -p $bikecamera_dir/video || install_error "Unable to create directory '$bikecamera_dir/video'"
    sudo mv /var/www/html/installers/video.py $bikecamera_dir/video
    sudo mv /var/www/html/installers/process_vid.sh $bikecamera_dir/video

    sudo mkdir -p $pihelmetcam_dir/video/mp4 || install_error "Unable to create directory '$pihelmetcam_dir/video/mp4'"
    sudo chmod a+r $pihelmetcam_dir/video/mp4 || install_error "Unable to set read permissions for '$pihelmetcam_dir/video/mp4'"
    sudo chmod a+w $ppihelmetcam_dir/video/mp4 || install_error "Unable to set write permissions for '$pihelmetcam_dir/video/mp4'"
    sudo mkdir -p $bikecamera_dir/video/completed || install_error "Unable to create directory '$bikecamera_dir/video/completed'"
    sudo chmod a+r $bikecamera_dir/video/completed || install_error "Unable to set read permissions for '$bikecamera_dir/video/completed'"
    sudo chmod a+w $bikecamera_dir/video/completed || install_error "Unable to set write permissions for '$bikecamera_dir/video/completed'"
    sudo mkdir -p $bikecamera_dir/video/raw || install_error "Unable to create directory '$bikecamera_dir/video/raw'"
    sudo chmod a+r $bikecamera_dir/video/raw || install_error "Unable to set read permissions for '$bikecamera_dir/video/raw'"
    sudo chmod a+w $bikecamera_dir/video/raw || install_error "Unable to set write permissions for '$bikecamera_dir/video/raw'"
    #
    # Link the video directory so the web server can create live links to the video files
    #
    sudo ln -s $bikecamera_dir/video /var/www/html
}

# Fetches latest files from github to webroot
function download_latest_files() {
    if [ -d "$webroot_dir" ]; then
        sudo mv $webroot_dir "$webroot_dir.`date +%F-%R`" || install_error "Unable to remove old webroot directory"
    fi

    install_log "Cloning latest files from github"
    git clone https://github.com/njkeng/BikeCamera /tmp/bikecamera || install_error "Unable to download files from github"
    sudo mv /tmp/bikecamera $webroot_dir || install_error "Unable to move bikecamera to web root"
}

# Sets files ownership in web root directory
function change_file_ownership() {
    if [ ! -d "$webroot_dir" ]; then
        install_error "Web root directory doesn't exist"
    fi

    install_log "Changing file ownership in web root directory"
    sudo chown -R $bikecamera_user:$bikecamera_user "$webroot_dir" || install_error "Unable to change file ownership for '$webroot_dir'"
}

# Update default config files with hostname and ethernet MAC for this device
function update_config_files() {
	# Update AP interface definition with this device's MAC address
	mac_address=$(cat /sys/class/net/wlan0/address)
	sudo sed -i "s/b8:27:eb:ff:ff:ff/$mac_address/g" $webroot_dir/config/dnsmasq.conf || install_error "Unable to write mac address to dnsmasq"

	# Update hostapd config with this device's hostname
	sudo sed -i "s/bikecamera/$bikecamera_devicename/g" $webroot_dir/config/hostapd.conf || install_error "Unable to write hostname to AP config"
}

# Check for existing /etc/network/interfaces and /etc/hostapd/hostapd.conf files
function check_for_old_configs() {
    if [ -f /etc/network/interfaces ]; then
        sudo cp /etc/network/interfaces "$bikecamera_dir/backups/interfaces.`date +%F-%R`"
        sudo ln -sf "$bikecamera_dir/backups/interfaces.`date +%F-%R`" "$bikecamera_dir/backups/interfaces"
    fi

    if [ -f /etc/hostapd/hostapd.conf ]; then
        sudo cp /etc/hostapd/hostapd.conf "$bikecamera_dir/backups/hostapd.conf.`date +%F-%R`"
        sudo ln -sf "$bikecamera_dir/backups/hostapd.conf.`date +%F-%R`" "$bikecamera_dir/backups/hostapd.conf"
    fi

    if [ -f /etc/dnsmasq.conf ]; then
        sudo cp /etc/dnsmasq.conf "$bikecamera_dir/backups/dnsmasq.conf.`date +%F-%R`"
        sudo ln -sf "$bikecamera_dir/backups/dnsmasq.conf.`date +%F-%R`" "$bikecamera_dir/backups/dnsmasq.conf"
    fi

    if [ -f /etc/rc.local ]; then
        sudo cp /etc/rc.local "$bikecamera_dir/backups/rc.local.`date +%F-%R`"
        sudo ln -sf "$bikecamera_dir/backups/rc.local.`date +%F-%R`" "$bikecamera_dir/backups/rc.local"
    fi
}

# Move configuration file to the correct location
function move_config_file() {
    if [ ! -d "$bikecamera_dir" ]; then
        install_error "'$bikecamera_dir' directory doesn't exist"
    fi

    install_log "Moving configuration file to '$bikecamera_dir'"
    sudo mv "$webroot_dir"/bikecamera.php "$bikecamera_dir" || install_error "Unable to move files to '$bikecamera_dir'"
}

# Set up configuration for the reset function
function configuration_for_reset() {
    install_log "Setting up configuration for the reset function"
    sudo echo "webroot_dir = \"$webroot_dir\"" >> /tmp/reset.ini || install_error "Unable to write to reset configuration file"
    sudo mv /tmp/reset.ini /etc/bikecamera/hostapd/ || install_error "Unable to move files to '$bikecamera_dir'"
}

# Set up configuration for the video functions
function configuration_for_video() {
    install_log "Setting up configuration for the video recording function"
    sudo echo "cull_free_space = 1000" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_rotation = 0" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_hres = 960" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_vres = 720" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_framerate = 40" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_quality = 20" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_bitrate = 17" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_resolution = \"720p_SD\"">> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_awb_mode = \"auto\"">> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_exp_mode = \"auto\"">> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "vid_length = 5" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "vid_dir = \"$bikecamera_dir/video\"" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "vid_datetime_enable = 1" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "vid_datetime_size = 15" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo mv /tmp/video.ini $bikecamera_dir/video/ || install_error "Unable to move files to '$bikecamera_dir'"

    sudo echo "status_start = 0" >> /tmp/status.ini || install_error "Unable to write to video status file"
    sudo echo "status_stop = 0" >> /tmp/status.ini || install_error "Unable to write to video status file"
    sudo echo "status_current = 0" >> /tmp/status.ini || install_error "Unable to write to video status file"
    sudo mv /tmp/status.ini $bikecamera_dir/video/ || install_error "Unable to move files to '$bikecamera_dir'"
}

# Set permissions for all BikeCamera directories and folders
function set_permissions() {
    sudo chown -R $bikecamera_user:$bikecamera_user "$bikecamera_dir" || install_error "Unable to change file ownership for '$bikecamera_dir'"
}

# Set up default configuration
function default_configuration() {
    install_log "Setting up hostapd"
    if [ -f /etc/default/hostapd ]; then
        sudo mv /etc/default/hostapd /tmp/default_hostapd.old || install_error "Unable to remove old /etc/default/hostapd file"
    fi
    sudo cp $webroot_dir/config/default_hostapd /etc/default/hostapd || install_error "Unable to copy hostapd defaults file"
    sudo cp $webroot_dir/config/hostapd.conf /etc/hostapd/hostapd.conf || install_error "Unable to copy hostapd configuration file"
    sudo cp $webroot_dir/config/dnsmasq.conf /etc/dnsmasq.conf || install_error "Unable to copy dnsmasq configuration file"
    sudo cp $webroot_dir/config/interfaces /etc/network/interfaces || install_error "Unable to copy interface configuration file"

    # After these configuration files are installed, dhcpcd is no linger needed, so disable
    sudo update-rc.d dhcpcd disable

    # Backup original wifi client configuration files
    if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ]; then
        sudo cp /etc/wpa_supplicant/wpa_supplicant.conf $webroot_dir/config/wpa_supplicant.conf || install_error "Unable to copy original wpa_supplicant configuration"
    fi
    if [ -f /etc/wpa_supplicant/wpa_supplicant_wlan0.conf ]; then
        sudo cp /etc/wpa_supplicant/wpa_supplicant_wlan0.conf $webroot_dir/config/wpa_supplicant_wlan0.conf || install_error "Unable to copy original wpa_supplicant_wlan0 configuration"
    fi
    if [ -f /etc/wpa_supplicant/wpa_supplicant_wlan1.conf ]; then
        sudo cp /etc/wpa_supplicant/wpa_supplicant_wlan1.conf $webroot_dir/config/wpa_supplicant_wlan1.conf || install_error "Unable to copy original wpa_supplicant_wlan1 configuration"
    fi

    # Generate required lines for Rasp AP to place into rc.local file.
    # #BikeCamera is for removal script
    lines=(
    'echo 1 > /proc/sys/net/ipv4/ip_forward #BikeCamera'
    'iptables -t nat -A POSTROUTING -j MASQUERADE #BikeCamera'
    "python3 $bikecamera_dir/hostapd/button.py \&  #BikeCamera"
    "python3 $bikecamera_dir/video/video.py \&  #BikeCamera"
    )
    
    for line in "${lines[@]}"; do
        if grep "$line" /etc/rc.local > /dev/null; then
            echo "$line: Line already added"
        else
            sudo sed -i "s~^exit 0$~$line\nexit 0~" /etc/rc.local
            echo "Adding line $line"
        fi
    done
}

# Set up cron configuration
function process_vid_crontab() {
    install_log "Setting up cron for post-processing video files"

    # Read crontab into a temporary file
    sudo crontab -l > /tmp/current_crontab

    # Check if process_vid is already in crontab
    process_vid_exists=$(cat /tmp/current_crontab | grep 'process_vid.sh')
    if [ "$process_vid_exists" == "" ]; then

        # Assemble new line for crontab file
        # Run processing script every 2 minutes
        crontab_line="*/2 * * * * sudo $bikecamera_dir/video/process_vid.sh >/dev/null 2>&1"

        # Check if crontab is empty
        crontab_exists=$(cat /tmp/current_crontab | grep 'no crontab')
        if [ "$crontab_exists" != "" ]; then
            # If crontab is empty, write a new crontab file
            echo "$crontab_line" >  /tmp/new_crontab
        else
            # If crontab exists, append video processing to the end
            cp /tmp/current_crontab /tmp/new_crontab
            echo "$crontab_line" >>  /tmp/new_crontab
        fi
        # Intitalise crontab with the updated configuration file
        sudo crontab /tmp/new_crontab
    fi
}


# Add a single entry to the sudoers file
function sudo_add() {
    sudo bash -c "echo \"www-data ALL=(ALL) NOPASSWD:$1\" | (EDITOR=\"tee -a\" visudo)" \
        || install_error "Unable to patch /etc/sudoers"
}

# Adds www-data user to the sudoers file with restrictions on what the user can execute
function patch_system_files() {
    # add symlink to prevent wpa_cli cmds from breaking with multiple wlan interfaces
    install_log "symlinked wpa_supplicant hooks for multiple wlan interfaces"
    sudo ln -s /usr/share/dhcpcd/hooks/10-wpa_supplicant /etc/dhcp/dhclient-enter-hooks.d/
    # Set commands array
    cmds=(
        "/sbin/ifdown"
        "/sbin/ifup"
        "/bin/cat /etc/wpa_supplicant/wpa_supplicant.conf"
        "/bin/cat /etc/wpa_supplicant/wpa_supplicant-wlan0.conf"
        "/bin/cat /etc/wpa_supplicant/wpa_supplicant-wlan1.conf"
        "/bin/cp /tmp/wifidata /etc/wpa_supplicant/wpa_supplicant.conf"
        "/bin/cp /tmp/wifidata /etc/wpa_supplicant/wpa_supplicant-wlan0.conf"
        "/bin/cp /tmp/wifidata /etc/wpa_supplicant/wpa_supplicant-wlan1.conf"
        "/sbin/wpa_cli -i wlan0 scan_results"
        "/sbin/wpa_cli -i wlan0 scan"
        "/sbin/wpa_cli reconfigure"
        "/bin/cp /tmp/hostapddata /etc/hostapd/hostapd.conf"
        "/etc/init.d/hostapd start"
        "/etc/init.d/hostapd stop"
        "/etc/init.d/dnsmasq start"
        "/etc/init.d/dnsmasq stop"
        "/bin/cp /tmp/dhcpddata /etc/dnsmasq.conf"
        "/sbin/shutdown -h now"
        "/sbin/reboot"
        "/sbin/ip link set wlan0 down"
        "/sbin/ip link set wlan0 up"
        "/sbin/ip -s a f label wlan0"
        "/sbin/ip link set wlan1 down"
        "/sbin/ip link set wlan1 up"
        "/sbin/ip -s a f label wlan1"
        "/bin/cp /etc/bikecamera/networking/dhcpcd.conf /etc/dhcpcd.conf"
        "/sbin/hwclock"
        "/bin/date"
    )

    # Check if sudoers needs patching
    if [ $(sudo grep -c www-data /etc/sudoers) -ne 28 ]
    then
        # Sudoers file has incorrect number of commands. Wiping them out.
        install_log "Cleaning sudoers file"
        sudo sed -i '/www-data/d' /etc/sudoers
        install_log "Patching system sudoers file"
        # patch /etc/sudoers file
        for cmd in "${cmds[@]}"
        do
            sudo_add $cmd
            IFS=$'\n'
        done
    else
        install_log "Sudoers file already patched"
    fi
}

# Check if Samba config needs updating
function samba_settings() {
    samba_updated=$(cat /etc/samba/smb.conf | grep $bikecamera_devicename)
    if [ "$samba_updated" == "" ]; then
        install_log "Updating samba config"
        sudo cp /etc/samba/smb.conf "/etc/samba/smb.conf.`date +%F-%R`" || install_error "Unable to move old /etc/samba/smb.conf out of the way"
        sudo cp /etc/samba/smb.conf /tmp/new_smb.conf  || install_error "Unable to create temporary smb.conf"
        sudo chmod a+w /tmp/new_smb.conf  || install_error "Unable to change permissions of temporary smb.conf"
        sudo echo "" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        # The following words in square brackets will be the name of the share
        sudo echo "[$bikecamera_devicename]" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "path = $bikecamera_dir/video/completed" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "comment = Bike video folder" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "browseable = yes" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "writeable = no" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "only guest = no" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "public = yes" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "guest ok = yes" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "read only = yes" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "create mask = 0660" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "directory mask = 0771" >> /tmp/new_smb.conf || install_error "Unable to write to samba configuration file"
        sudo chmod g-w,o-w /tmp/new_smb.conf  || install_error "Unable to change permissions of temporary smb.conf"
        sudo mv /tmp/new_smb.conf /etc/samba/smb.conf || install_error "Unable to move new samba configuration file into place"
    else
        install_log "Samba configuration already updated"
    fi
}

# Check if camera and I2C are enabled
function check_camera_i2c_enabled() {

	# Check for camera enabled
	if [ $(sudo grep "start_x=1" /boot/config.txt) -ne 1 ]; then
        install_log "The camera interface is already enabled"
	else
        sudo sed -i "s/start_x=0/start_x=1/g" /boot/config.txt  || install_error "Unable to enable the camera interface"
    	install_log "The camera interface has been enabled"
	fi

	# Check for I2C enabled
    if [ -e /dev/i2c-1 ]; then
        install_log "I2C is enabled"
    else
        install_attn "I2C is not enabled"
        echo "I2C is required to use a Real Time Clock"
        echo "I2C can be enabled using the Raspberry Pi Configuration tool or raspi-config"
    fi

}

# Enable i2c RTC kernel module
function rtc_kernel_module() {

    install_log "Enabling real-time clock kernel module"

    # Check if /boot/config.txt needs patching
    if [ $(sudo grep -c DS3231 /boot/config.txt) -ne 1 ]
    then
        # Didn't find existing line for DS3231 support
        config_plus_date="$bikecamera_dir/boot.config.txt.`date +%F-%R`"
        install_log "Patching /boot/config.txt"
	    sudo sh -c "echo 'cp /boot/config.txt $config_plus_date'" || install_error "Unable to copy /boot/config.txt to $bikecamera_dir"
        sudo sh -c "echo '' >> /boot/config.txt" || install_error "Unable to write to /boot/config.txt"
        sudo sh -c "echo '# Enable Real Time Clock' >> /boot/config.txt" || install_error "Unable to write to /boot/config.txt"
        sudo sh -c "echo 'dtoverlay=i2c-rtc,ds3231' >> /boot/config.txt" || install_error "Unable to write to /boot/config.txt"
    else
        install_log "RTC kernel module already enabled"
    fi

    # Remove fake hardware clock which uses NTP
    sudo apt-get -y remove fake-hwclock || install_error "Unable to remove module fake-hwclock"
    sudo update-rc.d -f fake-hwclock remove || install_error "Unable to remove fake-hwclock from rc-d"

    # Enable original hw-clock script
    sudo cp /lib/udev/hwclock-set "/lib/udev/hwclock-set.`date +%F-%R`" || install_error "Unable to move old /lib/udev/hwclock-set out of the way"
    sudo cp /lib/udev/hwclock-set /tmp/new_hwclock-set  || install_error "Unable to create temporary hwclock-set"
    line_number=$(grep -n "if \[ -e /run/systemd/system \]" /tmp/new_hwclock-set  | cut -d : -f 1 )
    line_1=$line_number"s/.*/\#if \[ \-e \/run\/systemd\/system \] \; then/"
    line_2=$(( line_number + 1 ))"s/.*/\#    exit 0/"
    line_3=$(( line_number + 2 ))"s/.*/\#fi/"
    sudo sed -i "$line_1" /tmp/new_hwclock-set || install_error "Unable to write to /tmp/new_hwclock-set"
    sudo sed -i "$line_2" /tmp/new_hwclock-set || install_error "Unable to write to /tmp/new_hwclock-set"
    sudo sed -i "$line_3" /tmp/new_hwclock-set || install_error "Unable to write to /tmp/new_hwclock-set"
    sudo mv /tmp/new_hwclock-set /lib/udev/hwclock-set || install_error "Unable to move new hwclock-set file into place"

    # Set the time on the RTC
    if [ -e /dev/rtc ]; then
    	sudo hwclock -w
        install_attn "The time has been set on the Real Time Clock"
    else
        install_attn "Could not set the Real Time Clock.  Is there one installed?"
    fi
}

function install_complete() {
    install_log "Installation completed!"

    echo -n "The system needs to be rebooted as a final step. Reboot now? [Y/n]: "
    read answer
    if [[ $answer == "n" ]]; then
        echo "Installation aborted."
        exit 0
    fi
    sudo shutdown -r now || install_error "Unable to execute shutdown"
}

function install_bikecamera() {
    display_welcome
    config_installation
    update_system_packages
    install_dependencies
    set_hostname
    install_dependencies
    enable_php_lighttpd
    create_bikecamera_directories
    check_for_old_configs
    download_latest_files
    change_file_ownership
    update_config_files
    create_logging_scripts
    create_reset_scripts
    create_video_files
    move_config_file
    configuration_for_reset
    configuration_for_video
    set_permissions
    default_configuration
    process_vid_crontab
    sudo_add
    patch_system_files
    samba_settings
    check_camera_i2c_enabled
    rtc_kernel_module
    install_complete
}
