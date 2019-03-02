# tclSenseHat

A Tcl (Tool Command Language) library (as of this writing, mostly a collection of scripts and procedures) for interacting with the Raspberry Pi SenseHat mounted on a Raspberry Pi running a variant of the Linux operating system called Raspbian.  See https://www.raspberrypi.org/products/sense-hat/. For more information about Tcl , see http://www.tcl.tk/ 

Future: (1) reorganize into a package (2) convert to OO notation (3) replace some of the brute-force efforts with more elegant algorithms.

GETTING STARTED

1. Get hardware - a working Raspberry Pi running some recent version of Raspbian operating system.  I have been buying mine in Canada from www.buyapi.ca, but most online electronics shops are selling them nowadays. There are good instructions for setting them up here:  https://www.raspberrypi.org/documentation/.  Also many, many youtube videos.  These scripts were developed on a Pi 3B and 3B+, but have been found to work just fine on the $10 Pi Zero W.  Everyone should have one of these.

2. Get hardware - a SenseHat (a compatible module that sits on top of the Raspberry Pi, also manufactured by www.raspberrypi.org).  See some info here: https://www.raspberrypi.org/blog/sense-hat-projects/ - This Hat contains an 8X8 LED matrix, a number of sensors, buttons and a mini-joystick.  This device has been to the International Space Station and has been the subject of national coding competitive challenges in the UK.  I bought mine from www.adafruit.com in North America.  There is a SenseHat emulator in recent versions of Raspbian for python coders.  I have no idea if it can be driven from Tcl. See here: https://www.raspberrypi.org/magpi/sense-hat-emulator/

3.  Update Operating System - Make sure you have the most up-to-date operating system.  You can do this by opening up a command prompt window ("Raspberry/Start" icon > Accessories > Terminal) and using the following commands:

       sudo apt-get update
       
       sudo apt-get upgrade

4.  Get software - Tcl - I used v8.6 in making these scripts.  These scripts do not make use of Tk yet.  Tcl usually comes pre-installed on Raspbian operating systems,  however, you can install the latest available version: 

      sudo apt-get install tclsh

5.  Get software - These scripts depend on the cmdline package which is available in the Tcllib package:

    sudo apt-get install tcllib
    
6. Get software - If you intend to experiment with threading (see ex5.tcl), you will need to install the Thread package:

    sudo apt-get install tcl-thread

7.  Get software - if you want to use the functionality for creating scrolling animated .gif's, you will need to install ImageMagick:

    sudo apt-get install imagemagick

8.  Get software - If you want to use the onboard sensors via i2c (lps25h.tcl script for example), you will need to install the piio package for communicating over i2c.  You will need to download source, make and install this package yourself.  There are instructions here: http://chiselapp.com/user/schelte/repository/piio/index.  Some other examples of piio usage can be found on the www.tcl.tk wiki here: https://wiki.tcl-lang.org/page/piio. 

9.  Enable i2c protocol - i2c must be enabled in the OS before you can use it. 

       sudo raspi-config, then, choose "Interfacing Options > I2C > Yes (to enable).  Reboot

10.  Get these scripts.  The scripts are not highly organized at the moment and can all be run from the same folder.  I used Geany (It comes installed with Raspian: Raspberry/Start > Programming > Geany Programmer's Editor) to edit the scripts, and configured Geany to execute them (Tools > Build Commands to RUN tclsh: tclsh8.6 "%f").  Some scripts to try out:

       ex1.tcl - a collection of examples demonstrating text scrolling, colour patterns and moving pixels
       
       ex2.tcl - a couple of dynamic rainbows making use of simple math and the hue range

       ex5.tcl - an experiment with threads - unleashing 6 parallel threads with moving pixels.

       lps25h.tcl - the calculations needed to extract and convert readings from the internal pressure sensor to real readings.

       experiment2_counter.tcl - a 2-digit counter that will allow you to count up to 999 on the 8X8 matrix.

11.  Learn - about 8X8 fonts.  (1) Download this Windows software from https://www.min.at/prinz/o/software/pixelfont/ for editing 8X8 fonts, then use it to export your favourite font in .asm format so it can be converted to work with these scripts (see script font_convert.tcl). (2) Play with 8X8 images and conver them to hexadecimal representation.  I used this website to make and modify simple images: http://gurgleapps.com/tools/matrix

SENSEHAT FEATURES

1. LED Matrix display - the SenseHat has an 8X8 matrix led display.  This respository includes scripts and procedures that display scrolling text of various kinds, colours and moving pixels.  We pass command prompt frame buffer commands via exec to interact with the OS.  IF there are more sophisticated and faster ways to make Tcl work with the frame buffer, I'm interested in knowing. 

  -script - SenseHat.tcl - main script for procedures
  - script device.tcl - parses input commands
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

4.  Haven't gotten to the gyro/,mag/accel calculations.  Interested in seeing if creating IMU is possible.  There are a ton of people developing IMU libraries here on github.  This one (written in python for the SenseHat seems a likely candidate to port from python: https://github.com/astro-pi/apollo-soyuz

5.  We have not figured out how to use Tcl to get input from the buttons.  Ideas?

Hoping it will be useful to someone, grateful for any help.

@themakerfam
