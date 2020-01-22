UPDATE_URL="https://raw.githubusercontent.com/njkeng/BikeCamera/master/"
wget -q ${UPDATE_URL}/installers/common.sh -O /tmp/bikecameracommon.sh
source /tmp/bikecameracommon.sh && rm -f /tmp/bikecameracommon.sh

function update_system_packages() {
    install_log "Updating sources"
    sudo apt-get update || install_error "Unable to update package list"
}

install_bikecamera
