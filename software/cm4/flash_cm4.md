# Flash CM4 on Mainboard

See `freespeaker_setup.sh` to setup the CM4.

The script does not install all dependencies to run properly.
We assume that users at this stage can find missing packages.

The script is a tool to help remember the steps and commands.
It is not intended to run without understanding it.

The following steps will setup the FreeSpeaker.

You need to finish these steps:

1. Install tools to access the EMMC on the CM4 via usb
2. Download and flash image (Raspberry Pi OS)
3. configure headless access
4. configure the linux kernel to use the hardware setup
5. boot the CM4 for the first time

Use the scripts help for further details.
```
./freespeaker_setup.sh --help
```
