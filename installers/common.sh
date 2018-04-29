pihelmetcam_hostname="pihelmetcam"
pihelmetcam_dir="/etc/pihelmetcam"
pihelmetcam_user="www-data"
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

# Outputs a PiHelmetCam Install log line
function install_log() {
    echo -e "\033[1;32mPiHelmetCam Install: $*\033[m"
}

# Outputs a PiHelmetCam Install Error log line and exits with status code 1
function install_error() {
    echo -e "\033[1;37;41mPiHelmetCam Install Error: $*\033[m"
    exit 1
}

# Outputs a welcome message
function display_welcome() {
    red='\033[0;31m'
    green='\033[1;32m'

    echo -e "${red}\n"
    echo -e "   mmmmmmmmmmmmdsssssssssssyhmmm                  "
    echo -e "  mmmmmmmmmmmmm.             .+d     MMMMMMMMMMMMM"
    echo -e " mmmmmmmmmmmmmm`  -osssssso+.  :m  mmmm           "
    echo -e "mmmmmmmmmmmmmmm`  ommmmmmmmm+  -d mmm             "
    echo -e "mmmmmmmmmmmmmmm`  omms-       -smmmm              "
    echo -e "mmmmmmmmmmmmmmm`  omms......  :h mmm              "
    echo -e " mmmmmmmmmmmmmm`  ommmmmmmmm/  :d mmm             "
    echo -e " mmmmmmmmmmmmmm`  -osssssoo+.  :m  mmm            "
    echo -e "  mmmmmmmmmmmmm.              +d     MMMMMMMMMMMMM"
    echo -e "   mmmmmmmmmmmmhsooooooooosyhdmmm                 "
    echo -e ""
    echo -e "${green}"
    echo -e "The Quick Installer will guide you through a few easy steps\n\n"
}

### NOTE: all the below functions are overloadable for system-specific installs
### NOTE: some of the below functions MUST be overloaded due to system-specific installs

function config_installation() {
    install_log "Configure device name"
    echo "Detected ${version_msg}" 
    echo "Device name: $pihelmetcam_hostname"
    echo "IMPORTANT: If you have more than one BikeCamera then this name must be changed."
    echo -n "Complete installation with this device name? [Y/n]: "
    read answer
    while [[ $answer == "n" ]]
    do
        echo "Enter a new device name"
        read device_name
        echo "Confirm that you want the device name to be $device_name? [Y/n]: "
        read answer
    done
    $pihelmetcam_hostname = $device_name
    install_log "Installation continuing with device name: $pihelmetcam_hostname"
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
    echo $pihelmetcam_hostname | sudo tee  /etc/hostname || install_error "Unable to set /etc/hostname"
    sudo sed -i -e 's/^.*pihelmetcam-installer.*$//g' /etc/hosts
    echo "127.0.1.1      " $pihelmetcam_hostname " ### Set by pihelmetcam-installer"  | sudo tee -a /etc/hosts || install_error "Unable to set /etc/hosts"
}

# Enables PHP for lighttpd and restarts service for settings to take effect
function enable_php_lighttpd() {
    install_log "Enabling PHP for lighttpd"

    sudo lighttpd-enable-mod fastcgi-php    
    sudo service lighttpd force-reload
    sudo /etc/init.d/lighttpd restart || install_error "Unable to restart lighttpd"
}

# Verifies existence and permissions of PiHelmetCam directory
function create_pihelmetcam_directories() {
    install_log "Creating PiHelmetCam directories"
    if [ -d "$pihelmetcam_dir" ]; then
        sudo mv $pihelmetcam_dir "$pihelmetcam_dir.`date +%F-%R`" || install_error "Unable to move old '$pihelmetcam_dir' out of the way"
    fi
    sudo mkdir -p "$pihelmetcam_dir" || install_error "Unable to create directory '$pihelmetcam_dir'"

    # Create a directory for existing file backups.
    sudo mkdir -p "$pihelmetcam_dir/backups"

    # Create a directory to store networking configs
    sudo mkdir -p "$pihelmetcam_dir/networking"
    # Copy existing dhcpcd.conf to use as base config
    cat /etc/dhcpcd.conf | sudo tee -a /etc/pihelmetcam/networking/defaults

    sudo chown -R $pihelmetcam_user:$pihelmetcam_user "$pihelmetcam_dir" || install_error "Unable to change file ownership for '$pihelmetcam_dir'"
}

# Generate logging enable/disable files for hostapd
function create_logging_scripts() {
    install_log "Creating logging scripts"
    sudo mkdir -p $pihelmetcam_dir/hostapd || install_error "Unable to create directory '$pihelmetcam_dir/hostapd'"

    # Move existing shell scripts 
    sudo mv $webroot_dir/installers/*log.sh $pihelmetcam_dir/hostapd || install_error "Unable to move logging scripts"
}

# Generate configuration reset files for pihelmetcam
function create_reset_scripts() {
    sudo mv /var/www/html/installers/reset.sh $pihelmetcam_dir/hostapd
    sudo mv /var/www/html/installers/button.py $pihelmetcam_dir/hostapd
}

# Move video files for pihelmetcam
function create_video_files() {
    install_log "Preparing video recording scripts"
    sudo mkdir -p $pihelmetcam_dir/video || install_error "Unable to create directory '$pihelmetcam_dir/video'"
    sudo mv /var/www/html/installers/video.py $pihelmetcam_dir/video
    sudo mv /var/www/html/installers/process_vid.sh $pihelmetcam_dir/video
    #
    # Need to move other video processing scripts HERE
    # After I have written them of course
    #
    sudo mkdir -p $pihelmetcam_dir/video/processing || install_error "Unable to create directory '$pihelmetcam_dir/video/processing'"
    sudo chmod a+r $pihelmetcam_dir/video/processing || install_error "Unable to set read permissions for '$pihelmetcam_dir/video/processing'"
    sudo chmod a+w $pihelmetcam_dir/video/processing || install_error "Unable to set write permissions for '$pihelmetcam_dir/video/processing'"
    sudo mkdir -p $pihelmetcam_dir/video/completed || install_error "Unable to create directory '$pihelmetcam_dir/video/completed'"
    sudo chmod a+r $pihelmetcam_dir/video/completed || install_error "Unable to set read permissions for '$pihelmetcam_dir/video/completed'"
    sudo chmod a+w $pihelmetcam_dir/video/completed || install_error "Unable to set write permissions for '$pihelmetcam_dir/video/completed'"
    sudo mkdir -p $pihelmetcam_dir/video/raw || install_error "Unable to create directory '$pihelmetcam_dir/video/raw'"
    sudo chmod a+r $pihelmetcam_dir/video/raw || install_error "Unable to set read permissions for '$pihelmetcam_dir/video/raw'"
    sudo chmod a+w $pihelmetcam_dir/video/raw || install_error "Unable to set write permissions for '$pihelmetcam_dir/video/raw'"
}

# Fetches latest files from github to webroot
function download_latest_files() {
    if [ -d "$webroot_dir" ]; then
        sudo mv $webroot_dir "$webroot_dir.`date +%F-%R`" || install_error "Unable to remove old webroot directory"
    fi

    install_log "Cloning latest files from github"
    git clone https://github.com/njkeng/PiHelmetCam /tmp/pihelmetcam || install_error "Unable to download files from github"
    sudo mv /tmp/pihelmetcam $webroot_dir || install_error "Unable to move pihelmetcam to web root"
}

# Sets files ownership in web root directory
function change_file_ownership() {
    if [ ! -d "$webroot_dir" ]; then
        install_error "Web root directory doesn't exist"
    fi

    install_log "Changing file ownership in web root directory"
    sudo chown -R $pihelmetcam_user:$pihelmetcam_user "$webroot_dir" || install_error "Unable to change file ownership for '$webroot_dir'"
}

# Check for existing /etc/network/interfaces and /etc/hostapd/hostapd.conf files
function check_for_old_configs() {
    if [ -f /etc/network/interfaces ]; then
        sudo cp /etc/network/interfaces "$pihelmetcam_dir/backups/interfaces.`date +%F-%R`"
        sudo ln -sf "$pihelmetcam_dir/backups/interfaces.`date +%F-%R`" "$pihelmetcam_dir/backups/interfaces"
    fi

    if [ -f /etc/hostapd/hostapd.conf ]; then
        sudo cp /etc/hostapd/hostapd.conf "$pihelmetcam_dir/backups/hostapd.conf.`date +%F-%R`"
        sudo ln -sf "$pihelmetcam_dir/backups/hostapd.conf.`date +%F-%R`" "$pihelmetcam_dir/backups/hostapd.conf"
    fi

    if [ -f /etc/dnsmasq.conf ]; then
        sudo cp /etc/dnsmasq.conf "$pihelmetcam_dir/backups/dnsmasq.conf.`date +%F-%R`"
        sudo ln -sf "$pihelmetcam_dir/backups/dnsmasq.conf.`date +%F-%R`" "$pihelmetcam_dir/backups/dnsmasq.conf"
    fi

    if [ -f /etc/dhcpcd.conf ]; then
        sudo cp /etc/dhcpcd.conf "$pihelmetcam_dir/backups/dhcpcd.conf.`date +%F-%R`"
        sudo ln -sf "$pihelmetcam_dir/backups/dhcpcd.conf.`date +%F-%R`" "$pihelmetcam_dir/backups/dhcpcd.conf"
    fi

    if [ -f /etc/rc.local ]; then
        sudo cp /etc/rc.local "$pihelmetcam_dir/backups/rc.local.`date +%F-%R`"
        sudo ln -sf "$pihelmetcam_dir/backups/rc.local.`date +%F-%R`" "$pihelmetcam_dir/backups/rc.local"
    fi
}

# Move configuration file to the correct location
function move_config_file() {
    if [ ! -d "$pihelmetcam_dir" ]; then
        install_error "'$pihelmetcam_dir' directory doesn't exist"
    fi

    install_log "Moving configuration file to '$pihelmetcam_dir'"
    sudo mv "$webroot_dir"/pihelmetcam.php "$pihelmetcam_dir" || install_error "Unable to move files to '$pihelmetcam_dir'"
}

# Set up configuration for the reset function
function configuration_for_reset() {
    install_log "Setting up configuration for the reset function"
    sudo echo "webroot_dir = \"$webroot_dir\"" >> /tmp/reset.ini || install_error "Unable to write to reset configuration file"
    sudo echo "user_reset_files = 0" >> /tmp/reset.ini || install_error "Unable to write to reset configuration file"
    sudo echo "user_files_saved = 0" >> /tmp/reset.ini || install_error "Unable to write to reset configuration file"
    sudo mv /tmp/reset.ini /etc/pihelmetcam/hostapd/ || install_error "Unable to move files to '$pihelmetcam_dir'"
}

# Set up configuration for the video functions
function configuration_for_video() {
    install_log "Setting up configuration for the video function"
    sudo echo "ffmpeg_output_format = \"mp4\"" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "ffmpeg_output_dir = \"$pihelmetcam_dir/video/completed\"" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "ffmpeg_input_dir = \"$pihelmetcam_dir/video/processing\"" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "cull_free_space = 500" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_hflip = 0" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_vflip = 0" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_hres = 960" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_vres = 720" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_framerate = 40" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_quality = 20" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_bitrate = 17" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "picamera_resolution = \"720p_SD\""> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "vid_length = 5" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "vid_dir = \"$pihelmetcam_dir/video\"" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "vid_datetime_enable = 1" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo echo "vid_datetime_size = 15" >> /tmp/video.ini || install_error "Unable to write to video configuration file"
    sudo mv /tmp/video.ini $pihelmetcam_dir/video/ || install_error "Unable to move files to '$pihelmetcam_dir'"
}

# Set permissions for all PiHelmetCam directories and folders
function set_permissions() {
    sudo chown -R $pihelmetcam_user:$pihelmetcam_user "$pihelmetcam_dir" || install_error "Unable to change file ownership for '$pihelmetcam_dir'"
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
    sudo cp $webroot_dir/config/dhcpcd.conf /etc/dhcpcd.conf || install_error "Unable to copy dhcpcd configuration file"
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
    # #PiHelmetCam is for removal script
    lines=(
    'echo 1 > /proc/sys/net/ipv4/ip_forward #PiHelmetCam'
    'iptables -t nat -A POSTROUTING -j MASQUERADE #PiHelmetCam'
    "python3 $pihelmetcam_dir/hostapd/button.py \&  #PiHelmetCam"
    "python3 $pihelmetcam_dir/video/video.py \&  #PiHelmetCam"
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
        crontab_line="*/2 * * * * sudo $pihelmetcam_dir/video/process_vid.sh >/dev/null 2>&1"

        # Check of crontab is empty
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
        "/bin/cp /etc/pihelmetcam/networking/dhcpcd.conf /etc/dhcpcd.conf"
        "/etc/pihelmetcam/hostapd/enablelog.sh"
        "/etc/pihelmetcam/hostapd/disablelog.sh"
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
    samba_updated=$(cat /etc/samba/smb.conf | grep bikecamera)
    if [ $samba_updated == ""]; then
        install_log "Updating samba config"
        # The following words in square brackets will be the name of the share
        sudo echo "[$pihelmetcam_hostname]" >> /etc/samba/smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "path = /media/usbhdd1/download" >> /etc/samba/smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "comment = Bike video folder" >> /etc/samba/smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "valid users = @users" >> /etc/samba/smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "force group = users" >> /etc/samba/smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "create mask = 0660" >> /etc/samba/smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "directory mask = 0771" >> /etc/samba/smb.conf || install_error "Unable to write to samba configuration file"
        sudo echo "read only = no" >> /etc/samba/smb.conf || install_error "Unable to write to samba configuration file"
    }
    else
        install_log "Samba configuration already updated"
    fi

}

function install_complete() {
    install_log "Installation completed!"

    echo -n "The system needs to be rebooted as a final step. Reboot now? [y/N]: "
    read answer
    if [[ $answer != "y" ]]; then
        echo "Installation aborted."
        exit 0
    fi
    sudo shutdown -r now || install_error "Unable to execute shutdown"
}

function install_pihelmetcam() {
    display_welcome
    config_installation
    update_system_packages
    install_dependencies
    set_hostname
    enable_php_lighttpd
    create_pihelmetcam_directories
    check_for_old_configs
    download_latest_files
    change_file_ownership
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
    install_complete
}
