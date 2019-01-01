


![](https://i.imgur.com/4b7kG6x.jpg)

# BIKE CAMERA
## A video camera for your bike.

This project involves both hardware and software.  This repository contains the software only.
The software and hardware aspects of the project are described in detail at instructables.com

[**BikeCamera project**](https://www.instructables.com/id/BikeCamera-Video-Camera)

### Here are some screenshots:

![](https://i.imgur.com/KOdXxu2.jpg)

![](https://i.imgur.com/TpOWJspl.jpg)


## Contents

 - [Prerequisites](#prerequisites)
 - [Quick installer](#quick-installer)
 - [License](#license)


## Prerequisites
Raspbian Stretch
RaspberryPi Zero W
Raspberry Pi camera module
Camera cable suitable for PiZero
Power supply


## Quick installer
Install BikeCamera from your RaspberryPi's shell prompt:
```sh
$ wget -q https://git.io/fpOh4 -O /tmp/bci && bash /tmp/bci
```
The installer will complete the installation for you.

After the reboot at the end of the installation the wireless network will be
configured as an access point as follows:
* SSID: `bikecamera_bc`
* Password: ChangeMe
* IP address: 10.1.1.1
  * Username: admin
  * Password: secret


## License
See the [LICENSE](./LICENSE) file.

