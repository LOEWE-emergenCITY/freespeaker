# How did it look on a newly installed OS
pi@raspberrypi:~ $ aplay -l
**** List of PLAYBACK Hardware Devices ****
card 0: Headphones [bcm2835 Headphones], device 0: bcm2835 Headphones [bcm2835 Headphones]
  Subdevices: 8/8
  Subdevice #0: subdevice #0
  Subdevice #1: subdevice #1
  Subdevice #2: subdevice #2
  Subdevice #3: subdevice #3
  Subdevice #4: subdevice #4
  Subdevice #5: subdevice #5
  Subdevice #6: subdevice #6
  Subdevice #7: subdevice #7
card 1: vc4hdmi0 [vc4-hdmi-0], device 0: MAI PCM i2s-hifi-0 [MAI PCM i2s-hifi-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 2: vc4hdmi1 [vc4-hdmi-1], device 0: MAI PCM i2s-hifi-0 [MAI PCM i2s-hifi-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
pi@raspberrypi:~ $ aplay -L
null
    Discard all samples (playback) or generate zero samples (capture)
hw:CARD=Headphones,DEV=0
    bcm2835 Headphones, bcm2835 Headphones
    Direct hardware device without any conversions
plughw:CARD=Headphones,DEV=0
    bcm2835 Headphones, bcm2835 Headphones
    Hardware device with all software conversions
default:CARD=Headphones
    bcm2835 Headphones, bcm2835 Headphones
    Default Audio Device
sysdefault:CARD=Headphones
    bcm2835 Headphones, bcm2835 Headphones
    Default Audio Device
dmix:CARD=Headphones,DEV=0
    bcm2835 Headphones, bcm2835 Headphones
    Direct sample mixing device
hw:CARD=vc4hdmi0,DEV=0
    vc4-hdmi-0, MAI PCM i2s-hifi-0
    Direct hardware device without any conversions
plughw:CARD=vc4hdmi0,DEV=0
    vc4-hdmi-0, MAI PCM i2s-hifi-0
    Hardware device with all software conversions
default:CARD=vc4hdmi0
    vc4-hdmi-0, MAI PCM i2s-hifi-0
    Default Audio Device
sysdefault:CARD=vc4hdmi0
    vc4-hdmi-0, MAI PCM i2s-hifi-0
    Default Audio Device
hdmi:CARD=vc4hdmi0,DEV=0
    vc4-hdmi-0, MAI PCM i2s-hifi-0
    HDMI Audio Output
dmix:CARD=vc4hdmi0,DEV=0
    vc4-hdmi-0, MAI PCM i2s-hifi-0
    Direct sample mixing device
hw:CARD=vc4hdmi1,DEV=0
    vc4-hdmi-1, MAI PCM i2s-hifi-0
    Direct hardware device without any conversions
plughw:CARD=vc4hdmi1,DEV=0
    vc4-hdmi-1, MAI PCM i2s-hifi-0
    Hardware device with all software conversions
default:CARD=vc4hdmi1
    vc4-hdmi-1, MAI PCM i2s-hifi-0
    Default Audio Device
sysdefault:CARD=vc4hdmi1
    vc4-hdmi-1, MAI PCM i2s-hifi-0
    Default Audio Device
hdmi:CARD=vc4hdmi1,DEV=0
    vc4-hdmi-1, MAI PCM i2s-hifi-0
    HDMI Audio Output
dmix:CARD=vc4hdmi1,DEV=0
    vc4-hdmi-1, MAI PCM i2s-hifi-0
    Direct sample mixing device
pi@raspberrypi:~ $ arecord -l
**** List of CAPTURE Hardware Devices ****
