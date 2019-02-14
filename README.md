# tclSenseHat
A tcl library (as of this writing, mostly a collection of scripts and procedures) for interacting with the Raspberry Pi SenseHat
See https://www.raspberrypi.org/products/sense-hat/
FOr more information about tcl, see http://www.tcl.tk/

1. LED Matrix display - the SenseHat has an 8X8 matrix led display.  This respository includes scripts and procedures that display scrolling text of various kinds, and 

  -script - SenseHat.tcl - main script for 
  - demonstration - 
 - dependency: package get_opts
 - dependency: application ImageMagic.  These scripts will output the scrolling pattern to an animated .gif.  This is useful if you intend to use this script without a Raspberry Pi and want to see how it works.  See file animated_gif_demo.gif 

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


