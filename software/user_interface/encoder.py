# Rotary encoder test driver

import RPi.GPIO as GPIO

def btn_pressed():
    print("BUTTON")


class Encoder(object):
    def __init__(self, A, B, T=None, Delay=None):

        GPIO.setmode(GPIO.BCM)

        self.T = T
        if T is not None:
            GPIO.setup(T, GPIO.OUT)
            GPIO.output(T,0)

        GPIO.setup(A, GPIO.IN, pull_up_down=GPIO.PUD_UP)
        GPIO.setup(B, GPIO.IN, pull_up_down=GPIO.PUD_UP)

        self.delay = Delay
        self.A = A
        self.B = B
        self.pos = 0
        self.state = (GPIO.input(B) << 1) | GPIO.input(A)
        self.edges = (0,1,-1,2,-1,0,-2,1,1,-2,0,-1,2,-1,1,0)

        if self.delay is not None:
            GPIO.add_event_detect(A, GPIO.BOTH, callback=self.__update,
                                  bouncetime=self.delay)
            GPIO.add_event_detect(B, GPIO.BOTH, callback=self.__update,
                                  bouncetime=self.delay)
        else:
            GPIO.add_event_detect(A, GPIO.BOTH, callback=self.__update)
            GPIO.add_event_detect(B, GPIO.BOTH, callback=self.__update)

    def __update(self, channel):
        if self.T is not None:
            GPIO.output(self.T,1)                   # flag entry

        state = (self.state & 0b0011)   \
            | (GPIO.input(self.B) << 3) \
            | (GPIO.input(self.A) << 2)

        gflag = '' if self.edges[state] else ' - glitch'
        if (self.T is not None) and not self.edges[state]:  # flag no-motion glitch
            GPIO.output(self.T,0)
            GPIO.output(self.T,1)

        self.pos += self.edges[state]

        self.state = state >> 2

#        print(' {} - state: {:04b} pos: {}{}'.format(channel,state,self.pos,gflag))

        if self.T is not None:
            GPIO.output(self.T,0)                   # flag exit

    def read(self):
        return self.pos

    def read_reset(self):
        rv = self.pos
        self.pos = 0
        return rv

    def write(self,pos):
        self.pos = pos
    
    if __name__ == "__main__":
        import encoder
        import time
        from gpiozero import Button

        btn = Button(22)
        enc = encoder.Encoder(23, 4,T=16)

        prev = enc.read()
        
        btn.when_pressed = btn_pressed

        while True:
        #while not btn.is_held :
            now = enc.read()
            if now != prev:
                print('{:+4d}'.format(now))
                prev = now
            if not btn.is_pressed:
                print("BUTTON")

