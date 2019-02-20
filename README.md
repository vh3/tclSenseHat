# tclSenseHat
A tcl library (as of this writing, mostly a collection of scripts and procedures) for interacting with the Raspberry Pi SenseHat
See https://www.raspberrypi.org/products/sense-hat/
For more information about tcl, see http://www.tcl.tk/

GETTING STARTED

1. Get hardware - a working Raspberry Pi running some recent version of Raspbian operating system.  I have been buying mine in Canada from www.buyapi.ca, but every electronics seems to be selling them nowadays. There are good instructions for setting them up here:  https://www.raspberrypi.org/documentation/.  Also many, many youtube videos.

2. Get hardware - a SenseHat (a compatible module that sits on top of the Raspberry Pi, also manufactured by www.raspberrypi.org.  See some info here: https://www.raspberrypi.org/blog/sense-hat-projects/ - This Hat contains an 8X8 LED matrix, a number of sensors, buttons and a mini-joystick.  This device has been to the International Space Station and has been the subject of national coding competitive challenges.  I bought mine from www.adafruit.com in North America.  There is a SenseHat emulator in recent versions of Raspbian for python coders.  I have no idea if it can be driven from Tcl. See here:
3.  Make sure you have the most up-to-date operating system.  You can do this by opening up a command prompt ("Raspberry/Start" icong > Accessories > Terminal and using the following commands:

       sudo apt-get update
       sudo apt-get upgrade

3.  Get software - Tcl 8.6+.  These scripts do not make use of Tk yet..  Tcl is usually installed on Raspbian operating systems,  however, you can install the latest available version: 

      sudo get apt-install tclsh

3.  Get sofware - These scripts depend on cmdline package which is available in the Tcllib package:

    sudo apt-get install Tcllib
    
4. Get software - IF you intend to experiment with threading (see ex5.tcl), you will need to install the Thread package:

    sudo apt-get install tcl-thread

5.  Get software

I would be grateful for any help in organizing this into a proper package, or converting to object oriented notation, or making it generic for any frame buffer device or really anything that might make it useful for others.

1. LED Matrix display - the SenseHat has an 8X8 matrix led display.  This respository includes scripts and procedures that display scrolling text of various kinds, and 

  -script - SenseHat.tcl - main script for 
  - demonstration - 
 - dependency: package get_opts
 - dependency: application ImageMagic.  These scripts will output the scrolling pattern to an animated .gif.  This is useful if you intend to use this script without a Raspberry Pi and want to see how it works.  See file animated_gif_demo.gif 

These tcl-only scripts were written to run on the raspberry pi under Linux and have been tested on a PI3B+ only.  They might run under Windows with the ImageMagic software installed, with some motification of the exec commands if you wish only to capture the output to an animated gif rather than the LED Matrix.

2. basic i2c interactions

- script: i2c_dump.tcl - iterates over i2c busses and addresses to discover connected i2c devices
- dependency: requires the piio package which must be compiled and installed beforehand.  See: https://wiki.tcl-lang.org/page/piio
- source: http://chiselapp.com/user/schelte/repository/piio/wiki?name=piio

3. temperature sensor via i2c

- dependency: package piio 
- script: lps25h.tcl
- reference: st.com has created great reference material.  This script was made with the documentation provided here:
      A.  LPS25H data sheet - http://www.st.com/resource/en/datasheet/lps25h.pdf
      B.  How to interpret temperature and pressure reading for the LPS25H -                              http://www.st.com/resource/en/technical_note/dm00242306.pdf
      C.  Hardware and software guidelines for use of LPS25H pressure sensor http://www.st.com/content/ccc/resource/technical/document/application_note/a0/f2/a5/e7/58/c8/49/b9/DM00108837.pdf/files/DM00108837.pdf/jcr:content/translations/en.DM00108837.pdf


