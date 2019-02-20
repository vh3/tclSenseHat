source device.tcl

global display
set display(record) true

random

set device(fg_colour) "orange"
set display(bg_colour) "black"
device display "Woo Hoo!" -record text1

set device(rotation) 90
device display "Woo Hoo! " -record text2

set device(fg_colour) "red"
set display(bg_colour) "blue"
set device(rotation) 180
device display "Woo Hoo! " -record text3

set device(fg_colour) "blue"
set display(bg_colour) "pink"
set device(rotation) 270
device display "Woo Hoo! " -record text4

# gif_assemble

# display_path
