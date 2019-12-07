![](https://raw.githubusercontent.com/b23prodtm/balena-sound/development/images/balenaSound-logo.png)

# Bluetooth audio streaming for any audio device

**Starter project enabling you to add bluetooth audio streaming to any old speakers or Hi-Fi using just a Raspberry Pi.**

This project has been tested on Raspberry Pi 3B/3B+ and Raspberry Pi Zero W. If you're using a Raspberry Pi 3 or above you don't need any additional hardware but if you'd like to use a Pi Zero W this will require an additional HAT as this model has no audio output.

## Hardware required

* Raspberry Pi 3A+/3B/3B+/Zero W
* SD Card (we recommend 8GB Sandisk Extreme Pro)
* Power supply

To use the Raspberry Pi, you can choose:
<!-- toc -->
- [Connect to the Blue-Speakers](#Connect-to-the-Blue-Speakers)
  + 3.5mm audio cable to the input on your speakers/Hi-Fi
- [As a transmitter to bluetooth speakers](#As-a-transmitter-to-bluetooth-speakers):
  + A sound card connected to the USB port for the loopback
  + A TosLink optical cable (recommended) or RCA Stereo to the output of your TV Set/Console
  + A Wireless soundbar or headphones
<!-- tocstop -->
To use the dashboard, you must have a personal Github.com account and access to the a broadband Internet connection

**Note:** the Raspberry Pi Zero cannot be used on it's own as it has no audio output. To use the Pi Zero you'll need to add something like the [Pimoroni pHAT DAC](https://shop.pimoroni.com/products/phat-dac) to go with it.
## Software required

* A download of this project (of course)
* Software to flash an SD card ([balenaEtcher](https://balena.io/etcher))
* A free [balenaCloud](https://balena.io/cloud) account
* The [balena CLI tools](https://github.com/balena-io/balena-cli/blob/master/INSTALL.md)

## Setup and use

To run this project is as simple as deploying it to a balenaCloud application; no additional configuration is required (unless you're using a DAC HAT).

### Setup the Raspberry Pi

* Sign up for or login to the [balenaCloud dashboard](https://dashboard.balena-cloud.com)
* Create an application, selecting the correct device type for your Raspberry Pi
* Add a device to the application, enabling you to download the OS
* Flash the downloaded OS to your SD card with [balenaEtcher](https://balena.io/etcher)
* Power up the Pi and check it's online in the dashboard

### Deploy this application

* Install the [balena CLI tools](https://github.com/balena-io/balena-cli/blob/master/INSTALL.md)
* Login with `sudo balena login`
* Run `./deploy.sh`

### Customize device name

By default, your device will be displayed as `blue-speakers-pi` when you search for Bluetooth devices.
You can change this using `BLUETOOTH_DEVICE_NAME` environment variable that can be set in balena dashboard
(navigate to dashboard -> app -> device -> device variables).

### Set output volumes

By default, balenaSound will set the output volume of your Raspberry Pi to 100% on the basis you can then control the volume upto the maximum from the connected bluetooth device. If you would like to override this, define the `SYSTEM_OUTPUT_VOLUME` environment variable.

Secondly, balenaSound will play connection/disconnection notification sounds at a volume of 75%. If this unsuitable, you can override this with the `CONNECTION_NOTIFY_VOLUME` environment variable.

**Note:** these variables should be defined as integer values without the `%` symbol.

## Connect to the Blue-Speakers

* After the application has pushed and the device has downloaded the latest changes you're ready to go!
* Connect the audio output of your Pi to the AUX input on your Hi-Fi or speakers
* Search for your device (`blue-speakers-pi` name is used by default) on your phone or laptop and pair.
* Let the music play!

This project is in active development so if you have any feature requests or issues please submit them here on GitHub. PRs are welcome, too.

## Multiple container use
If you plan to use Balena Sound as part of a multiple container app (for example, having an app with PiHole & Balena sound), don't forget to add the following label to your `docker-compose.yml` file. (source: https://www.balena.io/docs/learn/develop/multicontainer/#labels)

Example:
```
bluetooth:
  build: ./bluetooth-audio
  privileged: true
  network_mode: host
  labels:
    io.balena.features.dbus: '1'
```
## As a transmitter to bluetooth speakers
The modern way of audio streaming to your new wireless speakers, now available to you. You don't have any bluetooth capability on your old set top box?
You can definitely use your Raspberry Pi to add a wireless connection to old TV set top boxes, using an USB card (snd_usb_audio). You have to connect from an audio source to the sound card input (either digital, optical or analog jacks). Then Blue-Speakers can pair to your existing bluetooth speakers device. To configure the wireless speakers, adjust the Device Service Variable to your needs.

    BTSPEAKER_SINK XX:XX:XX:XX:XX:XX:

Any bluetooth enabled software (phone or tablet settings) may help you to find it. Fill it with the physical Bluetooth address and balenaOS will restart immediatelly. You may hear the sound if the device is up and pairable.

![Setting the device speaker address](https://raw.githubusercontent.com/b23prodtm/balena-sound/development/images/device-name-config.png)

## Buffer underruns
  1.If you encounter some buffer underrun while streaming music through the btspeaker, set higher PCM_BUFFER_TIME.
Another original way exists, to optimize the bluetooth (hci0) serial communication, by switching on console hands-off.
  2.By default, Raspberry Pi attaches /dev/ttyAMA0 Serial UART to use with the console.
So, first disable read-only rootfs on Host:

    mount -o remount,rw /

Then mask the serial getty service:

    systemctl mask serial-getty@serial0.service

Then reboot the board and you should be all set.

## Work-in-progress
You may find it difficult to synchronize pictures with the sound if you're watching a film. That's because of the CPU usage that requires as high values as 200-300ms to get stable audio streaming. We 're looking for solutions to decrease the amount of time needed in PCM_BUFFER_TIME.
