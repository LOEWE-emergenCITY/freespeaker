# Audio on Raspberry
The FreeSpeaker uses a module to run audio.

IMPORTANT: The amplifier can be disabled with a GPIO. Check GPIO 17 and enable the amplifier.

```
echo 17 > /sys/class/gpio/export
echo out >/sys/class/gpio/gpio17/direction
echo 1 >/sys/class/gpio/gpio17/value
echo 0 >/sys/class/gpio/gpio17/value
```

This readme shows how to install the drivers provides some details on pitfalls and updates.

The ReSpeaker Module is integrated to the ALSA (Advanced Linux Sound Architecture).

These two files show the default hardware configuration for ALSA on the CM4 and the updated version after installation.
- [fresh install](fresh_install.md)
- [after successfull install](ReSpeaker_hardware_alsa.md)

## Install (short version without problems)
After flashing the CM4 this commands bring the audio hardware to live.
This may break with future updates...

```
pi@raspberrypi:~ $ uname -r
5.15.56-v8+
pi@raspberrypi:~ $ git clone https://github.com/leinher/seeed-voicecard
pi@raspberrypi:~ $ cd seeed-voicecard/
pi@raspberrypi:~ $ sudo ./install_arm64.sh
[ lots of output it something does not work you need that again... ]
pi@raspberrypi:~ $ reboot

## Install Pitfalls
The install steps on the [seeed webside](https://wiki.seeedstudio.com/ReSpeaker_4-Mic_Linear_Array_Kit_for_Raspberry_Pi/) provide commands to install the software.

**WARNING:** The FreeSpeaker is based on the CM4 and uses a 64bit architecture.
To install the ReSpeaker drivers on arm64 you need to use a different install script: `./install_arm64.sh`

```
pi@raspberrypi:~ $ uname -r
5.15.56-v8+
```

```
git clone https://github.com/respeaker/seeed-voicecard.git
cd seeed-voicecard/
sudo ./install_arm64.sh
reboot
```

These commands did not work as expected. The hardware was not available after the reboot.

A closer look at the install script output showed that the kernel module could not build and was not installed.
The script does not provide any highlighted errors or warnings.

As of today, the problem is already fixed and a [pull request](https://github.com/respeaker/seeed-voicecard/pull/323) is ready to merge for the seeed team.

To run the ReSpeaker on the FreeSpeaker the gpio pinout was adjusted.
All changes to the original project are stored in a fork (currently on my private github account).

```
git remote add leinher https://github.com/leinher/seeed-voicecard
git fetch leinher
git checkout leinher:master
pi@raspberrypi:~/seeed-voicecard $ git log -n 1
commit 0b9dcad1e5e70db9ce3c5411b020ea8e39c129ff (HEAD -> master, leinher/master)
Author: Hermann Leinweber <hermann.leinweber@stud.tu-darmstadt.de>
Date:   Tue Aug 23 19:07:18 2022 +0200

    Change device tree to run on freespeaker hardware v1
    reflect upstream kernel changes
```

After applying this patch the build works and the hardware is available.

## Hardware test commands
Get sample music
```
pi@raspberrypi: $ wget  https://www2.cs.uic.edu/~i101/SoundFiles/StarWars60.wav
```

### Play from ReSpeaker
The ReSpeaker hardware only supports the `S32_LE` samples.

```
pi@raspberrypi:~/seeed-voicecard $ aplay -D "hw:CARD=seeed8micvoicec,DEV=0" ~/StarWars60.wav
Playing WAVE '/home/pi/StarWars60.wav' : Signed 16 bit Little Endian, Rate 22050 Hz, Mono
aplay: set_params:1343: Sample format non available
Available formats:
- S32_LE
```

To convert a file the ALSA plugin `plug` can be used as followed:
```
aplay -D "plughw:CARD=seeed8micvoicec,DEV=0" StarWars60.wav
```

### Record sound with the ReSpeaker
The ReSpeaker hardware has to AC108 with 4 channels each.
This platform can be used for 6 mics and sterio output.

This command read from all channels but just 4 are used.
```
arecord -Dac108 -f S32_LE -r 16000 -c 8 a.wav
```

You can copy this to a computer and use `audacity` to view and listen to the samples.

Use this to replay the recored file.

```
aplay -D ac101 a.wav
```
