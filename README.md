# tclSenseHat
A tcl library (as of this writing, mostly a collection of scripts and procedures) for interacting with the Raspberry Pi SenseHat
See https://www.raspberrypi.org/products/sense-hat/
For more information about tcl, see http://www.tcl.tk/

GETTING STARTED

1. Get hardware - a working Raspberry Pi running some recent version of Raspbian operating system.  I have been buying mine in Canada from www.buyapi.ca, but most electronics shops are selling them nowadays. There are good instructions for setting them up here:  https://www.raspberrypi.org/documentation/.  Also many, many youtube videos.

2. Get hardware - a SenseHat (a compatible module that sits on top of the Raspberry Pi, also manufactured by www.raspberrypi.org).  See some info here: https://www.raspberrypi.org/blog/sense-hat-projects/ - This Hat contains an 8X8 LED matrix, a number of sensors, buttons and a mini-joystick.  This device has been to the International Space Station and has been the subject of national coding competitive challenges in the UK.  I bought mine from www.adafruit.com in North America.  There is a SenseHat emulator in recent versions of Raspbian for python coders.  I have no idea if it can be driven from Tcl. See here:

3.  Update Operating System - Make sure you have the most up-to-date operating system.  You can do this by opening up a command prompt window ("Raspberry/Start" icon > Accessories > Terminal) and using the following commands:

       sudo apt-get update
       sudo apt-get upgrade

4.  Get software - Tcl - I used v8.6 in making these scripts.  These scripts do not make use of Tk yet.  Tcl is usually installed on Raspbian operating systems,  however, you can install the latest available version: 

      sudo get apt-install tclsh

5.  Get sofware - These scripts depend on cmdline package which is available in the Tcllib package:

    sudo apt-get install Tcllib
    
6. Get software - If you intend to experiment with threading (see ex5.tcl), you will need to install the Thread package:
    sudo apt-get install tcl-thread

7.  Get software - if you want to use the functionality for creating scrolling animated .gif's, you will need to install ImageMagick:

    sudo apt-get install imagemagick

8.  Get software - If you want to use the onboard sensors via i2c (lps25h.tcl script for example), you will need to install the piio package for communicating over i2c.  You will need to download source, make and install this package yourself.  There are instructions here: http://chiselapp.com/user/schelte/repository/piio/index.  Some other examples of piio usage can be found on the www.tcl.tk wiki here: https://wiki.tcl-lang.org/page/piio. 

9.  Enable i2c protocol - i2c must be enabled 

       sudo raspi-config
       then, choose "Interfacing Options > I2C > Yes (to enable).  Reboot

10.  Get these scripts.  The scripts are not highly organized at the moment and can all be run from the same folder.  I used Geany (Raspberry/Start > Programming > Geany Programmer's Editor).  It comes installed with Raspian) to edit the scripts, and configured Geany to execute the scripts (Tools > Build Commands to RUN tclsh: tclsh8.6 "%f").  Some scripts to try out:

       ex1.tcl - a collection of examples demonstrating text scrolling, colour patterns and moving pixels
       ex2.tcl - a couple of dynamic rainbows making use of simple math and the hue range
       ex3.tcl - more hue fun
       ex5.tcl - an experiment with threads - unleashing 6 parallel threads with moving pixels.
       lps25h.tcl - the calculations needed to extract and convert readings from the internal pressure sensor to real readings.
       experiment2_counter.tcl - a 2-digit counter that will allow you to count up to 999 on the 8X8 matrix.
       
FEATURES

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


@themakerfam
