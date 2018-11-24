UPDATE_URL="https://raw.githubusercontent.com/njkeng/BikeCamera/master/"
wget -q ${UPDATE_URL}/installers/common.sh -O /tmp/bikecameracommon.sh
source /tmp/bikecameracommon.sh && rm -f /tmp/bikecameracommon.sh

function update_system_packages() {
    install_log "Updating sources"
    sudo apt-get update || install_error "Unable to update package list"
}

function install_dependencies() {
    install_log "Installing required packages"
    sudo apt-get -y install lighttpd $php_package git hostapd dnsmasq samba samba-common-bin python-smbus i2c-tools php7.0-zip gpac || install_error "Unable to install dependencies"
}

install_bikecamera
