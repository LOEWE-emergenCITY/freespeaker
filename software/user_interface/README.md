# Hardware test user interface

## Rotary encoder (with device tree overlay)
The encoder will present itself as a input device.

The settings from the current setup in `freespeaker_setup.sh` can be checked with the `evtest` tool.

```
sudo -i
apt install evtest
evtest /dev/input/event1
evtest /dev/input/event0
```

`evtest` will show details of the accessed device and if events occur.

The overlay and linux kernel driver works far better than the rotary encoder in user space!

## Rotary encoder (without device tree overlay)
This scirpt can be used to test the rotary encoder hardware.

The script does not work very well.
Detecting right turns seems a bit difficult.

Move slowly...

Install dependencies for RPi pip files
```
sudo apt install python3-venv
sudo apt install python3-dev
```

Install python dependencies without messing with the system
```
python3 -m venv venv-encoder
. venv-encoder/bin/activate
```

Run the tests

```
python encoder.py
```

The script counts a number depending on the steps to each direction and prints multiple lines with `BUTTON` when the button is pressed.

## LEDs
The WS2812 LED ring is directly connected to the atmega on the user interface PCB.

Controlling the WS2812 from the CM4 with existing drivers is not possible.
Existing drivers (e.g. [rpi_ws281x](https://github.com/jgarff/rpi_ws281x)) use PWM or SPI hardware which are not supported by GPIO8 that we connected in our design.
