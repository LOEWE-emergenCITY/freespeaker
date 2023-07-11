#!/bin/bash
# Constant vars for downloading the image
RASPI_OS_FULL_NAME="2023-05-03-raspios-bullseye-arm64-lite"
RASPI_IMAGE_FULL_URL="https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64-lite.img.xz"
# constant values used in multiple functions
MOUNT_PATH_BOOT="$(pwd)/mnt/boot"
MOUNT_PATH_ROOTFS="$(pwd)/mnt/rootfs"

function _help() {
	echo """
$0 is a script to setup the hardware of the free speaker.
This script needs root rights to run mount, dd, etc..

Usage: \$ $0 command

Commands:
	init
		check this machine and init the tools to run the tasks this script provides.

	access-emmc
		enable the usb device feature to access the emmc of the CM4 without booting it

	mount
		Mount the boot and rootfs partition (run access-emmc before this)

	download-os
		Download the Raspberry OS light image

	flash
		Flash the image to the emmc. (run access-emmc before this)

	config-image
		Set configs in the image for headless access (run mount-emmc first)

	umount
		umount the emmc to disconnect safely.

Further help
	Access the serial terminal (as serial tools are always a pain...)

$ picocom -b 115200 -d 8 -y n -p 1 -f n /dev/serial0

	Use the environment variables
$ source freespeaker_setup_env
$ sudo -E ./freespeaker_setup.sh <command>
"""
}

function _run_init() {
  # Primary source
  # https://www.raspberrypi.com/documentation/computers/compute-module.html#flashing-the-compute-module-emmc
  echo "TODO: libusb-1.X-dev must be installed"
	# on ubuntu (PC)
	# apt install libusb-1.0-0-dev pkg-config build-essential make
	# # The header file is not in a include dir as exepcted by the usbboot project...
	# ln -s /usr/include/libusb-1.0/libusb.h /usr/include/libusb.h
	#
	# on arch	linux
	# pacman -S libusb
	if [ ! -d usbboot ]
  then
		echo Installing usbboot
    git clone --depth=1 https://github.com/raspberrypi/usbboot
    pushd usbboot
    make
    popd
	else
		echo -e "skipping usbboot"
		echo -e "usbboot already installed at $(pwd)/usbboot"
	fi
}

function _enable_emmc_access() {
	echo """
Hardware setup:
Connect the power supply slice and the mainboard.

1. Connect jumper to J6 (this is nRPI_BOOT)
2. Connect your machine with a USB cable to J5 on the mainboard
3. (optional) Connect a TTY interface to see what is going on
4. Press enter to start the rpi boot tool
5. power up the hardware
"""
	read -p "Start rpiboot tool"
	cd usbboot
	./rpiboot
	cd -
	echo "The CM4 should now be visible as a block devices ready to mount"
	echo "You will need the device name for the next step"
	# direct print was to fast to show the new devices
	sleep 5
	echo "showing output of lsblk"
	lsblk
}

function _download_os() {
	wget -O image.img.xz ${RASPI_IMAGE_FULL_URL}
  xz -d image.img.xz
}
 
function _flash() {
	if [ -z ${FREESPEAKER_TARGET_DEVICE_PATH+x} ]
	then
		read -p "Enter the target device path: " TARGET_DEVICE_PATH
	else
		TARGET_DEVICE_PATH=${FREESPEAKER_TARGET_DEVICE_PATH}
		read -p "Are you sure to write to ${TARGET_DEVICE_PATH}. (Enter to continue, Crtl+c to abort)"

	fi
	dd if=./image.img of=$TARGET_DEVICE_PATH bs=4M conv=fdatasync status=progress
	echo "Do not forget: ENABLE UART before first boot!"
}

function _mount_emmc() {
	echo $FREESPEAKER_TARGET_DEVICE_PATH
	if [ -z ${FREESPEAKER_TARGET_DEVICE_PATH+x} ]
	then
		read -p "Enter the target device path: " TARGET_DEVICE_PATH
	else
		TARGET_DEVICE_PATH=${FREESPEAKER_TARGET_DEVICE_PATH}
		echo $TARGET_DEVICE_PATH
		read -p "Going to mount ${TARGET_DEVICE_PATH}. (Enter to continue, Crtl+c to abort)"
	fi

	mkdir -p $MOUNT_PATH_BOOT
	mkdir -p $MOUNT_PATH_ROOTFS
	# partition name is not always clear..
	[ -b "${TARGET_DEVICE_PATH}p1" ] && DEVICE_PATH_BOOT="${TARGET_DEVICE_PATH}p1"
	[ -b "${TARGET_DEVICE_PATH}1"  ] && DEVICE_PATH_BOOT="${TARGET_DEVICE_PATH}1"
	[ -b "${TARGET_DEVICE_PATH}p2" ] && DEVICE_PATH_ROOTFS="${TARGET_DEVICE_PATH}p2"
	[ -b "${TARGET_DEVICE_PATH}2"  ] && DEVICE_PATH_ROOTFS="${TARGET_DEVICE_PATH}2"

	mount $DEVICE_PATH_BOOT   $MOUNT_PATH_BOOT
	mount $DEVICE_PATH_ROOTFS $MOUNT_PATH_ROOTFS
}

function _umount_emmc() {
	sync
	umount $MOUNT_PATH_BOOT
	umount $MOUNT_PATH_ROOTFS
}

function _set_dtoverlays() {
	# Details on the overlays can be found in the kernel repo from the raspberry pi
	# https://github.com/raspberrypi/linux
	# arch/arm64/boot/dts/overlays/README

	# Enable uart5 which is used to flash the atmegas on each slice
	echo dtoverlay=uart5 >> $MOUNT_PATH_BOOT/config.txt
	# add an input device for the rotary encoder
	# test with # evtext /dev/input/event1
	echo dtoverlay=rotary-encoder,pin_a=23,pin_b=4,relative_axis=1 >> $MOUNT_PATH_BOOT/config.txt
	# add button device for button of the rotary encoder
	# test with # evtext /dev/input/event0
  echo dtoverlay=gpio-key,gpio=22,gpio_pull=off,label=freespeaker_ui,keycode=76 >> $MOUNT_PATH_BOOT/config.txt
	# find inputs in journal
	# journalctl --boot 0 | grep "kernel: input:"

	# RTC
	echo dtparam=i2c_vc=on >> $mount_path_boot/config.txt
  echo dtoverlay=i2c-rtc,pcf85063a,i2c_csi_dsi >> $mount_path_boot/config.txt
	# test with hwclock --verbose
	# this will show it the device is up and running only
	# the wakeup is not tested

}

function _wifi_setup() {
	if [ -z ${FREESPEAKER_WIFI_SSID+x} ]
	then
		read -p "Enter the SSID to connect the FreeSpeaker to: " WIFI_SSID
	else
		WIFI_SSID=$FREESPEAKER_WIFI_SSID
	fi
	if [ -z ${FREESPEAKER_WIFI_PSK+x} ]
	then
		read -p "Enter the password for the given Network: " WIFI_PSK
	else
		WIFI_PSK=$FREESPEAKER_WIFI_PSK
	fi

	echo """
country=DE
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
  ssid=\"${WIFI_SSID}\"
  psk=\"${WIFI_PSK}\"
}
""" > $MOUNT_PATH_BOOT/wpa_supplicant.conf
}

function _config_image() {
	# Debug uart (this is not part of the overlays as it is essential to get the hardware running
	echo enable_uart=1 >> $MOUNT_PATH_BOOT/config.txt
	#_set_dtoverlays
	# ssh headless activation
	USER=hiba
	PASSWORD=$(openssl passwd -6 hiba)
	# remove to file be able to run script multiple times..
	rm -f $MOUNT_PATH_BOOT/userconf.txt
	echo -n "${USER}:${PASSWORD}" >> $MOUNT_PATH_BOOT/userconf.txt
	touch $MOUNT_PATH_BOOT/ssh
	# connect to wifi
	#_wifi_setup
}

function _abort_without_root_access() {
	if [[ $EUID -ne 0 ]]; then
	   echo "This script must be run as root (use sudo)" 1>&2
	   exit 1
	fi
}


# main #######################################################################
# get command line parameters
if [ $# -eq 0 ]
then
	echo -e "No command provided. Showing help"
	_help	
	exit 1
fi

while [ $# -gt 0 ]
	do
		case "$1" in
			"init")
				_run_init
			;;
			"access-emmc")
				_abort_without_root_access
				_enable_emmc_access
			;;
			"mount")
				_abort_without_root_access
				_mount_emmc
			;;
			"download-os")
				_download_os
			;;
			"flash")
				_abort_without_root_access
				_flash
			;;
			"config-image")
				_abort_without_root_access
				_config_image
			;;
			"umount")
				_abort_without_root_access
				_umount_emmc
			;;
			"-v"|"--debug")
			DEBUG="true"
			;;
			"-vv")
				DEBUG="true"
				set -x
			;;
			"--help")
				_help
				exit
			;;
			*)
				echo "Unexpected parameter given: $1"
				echo "showing help..."
				echo ""
				_help
				exit 1
			;;
		esac
	test $# -gt 0 && shift
done
