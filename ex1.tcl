# ex1.tcl - device examples for 8X8 LED matrix with text and path elements

# Uncomment examples to try differernt display examples 

source device.tcl

# Set global defaults explicitly, or as inline parameters.
set device(pause) 200
# set device(pixel_render) "temp"

# EXAMPLE 1 - The simplest example
device display "This is some scrolling text" 

# EXAMPLE 2 - Text with some configuration parameters
# device display "beep beep!" -rotation 180 -bg_colour "blue" -fg_colour "green" -pause 5 -brightness 8 -mode "scroll" -pause 100
# return

# EXAMPLE 3 - Scroll the text in a different direction
# device display "beep beep!" -rotation 90 -fg_colour "white" -pause 5 -brightness 8 -mode "scroll" -pause 100
# return

# EXAMPLE 4 - Text with many configuration parameters
# device display "Beep! Beep! I'm a sheep said a Beep! Beep! I'm a sheep! Meow! Meow! I'm a cow said a Meow! Meow! I'm a cow"   -rotation 180 -bg_colour black -fg_colour pink -pause 500 -brightness 3 -endless false
# return

# EXAMPLE 5 - Text with many configuration parameters
# Note the recording switch on the end-the frame buffer is saved to file for later compiling into a .gif
# device display "Beep! Beep! I'm a sheep said a Beep! Beep! I'm a sheep! Meow! Meow! I'm a cow said a Meow! Meow! I'm a cow"   -rotation 0 -bg_colour blue -fg_colour pink -delay 1 -brightness 9 -record "Georgia_circle5"

# EXAMPLE 6 - Display a shifting random pattern of pixels  
# for {set x 0} {$x<100} {incr x} {
#	random 
# 	set test 0;after 100 {set test 1};vwait test
# }
# return 

# EXAMPLE 7 - Fill the screen with solid colours  
# set colour_list [list red orange yellow green blue indigo violet]
# foreach i $colour_list {
#	wipe $i
#	pause 200
#}
#return

# EXAMPLE 8 - Display a hex image
# You can create your own hex image at www.xxxxxxxxxx.com
# wipe
# set no_mouth    [rotate_hex [split "0x3e,0x7b,0x8b,0xfb,0xfb,0x8b,0x7b,0x3e" ","] 90]; # no mouth  
# set device(record) true
# device display $no_mouth -fg_colour "white" -bg_colour "black" -mode page
# return

# EXAMPLE 9 - Display a moving pixel
# wipe green
# A path is definition is a list of pixel positions (0 starts in the top left corner, row by row)
# set path_list [list 0 1 2 3 4 5 6 7 15 23 31 39 47 55 63 62 61 60 59 58 57 56 48 40 32 24 16 8 0]
# device display -endless -bg_colour "blue" -fg_colour "red" -path $path_list
# TODO - fix the remnant pixel when the pattern restarts
# return

# EXAMPLE 10 - Combine a hex shape and a moving pixel display - this is our rendition of a Ceylon raider
# set no_mouth    [rotate_hex [split "0x3e,0x7b,0x8b,0xfb,0xfb,0x8b,0x7b,0x3e" ","] 90]; # no mouth  
# device display $no_mouth -fg_colour "white" -bg_colour "black" -mode page
# TODO: account for rotation in path display
# set path [list 17 18 19 20 21 22]
# append path [lreverse $path]
# device display -endless -path $path -fg_colour "red" -fade_steps 2 -pause 500

# EXAMPLE 11 - Display a moving pixel - a path that touches every pixel on the display
# random
 set path [list 0 1 2 3 4 5 6 7 14 21 28 35 42 49 56 57 58 59 60 61 62 63 54 45 36 27 18 9 0 8 16 24 32 40 48 56 49 42 35  28 21 14 7 15 23 31 39 47 55 63 54 45 36 27 18 9 0 1 2 3 4 5 6 7 15 23 31 39 47 55 63 62 61 60 59 58 57 56 48 40 32 24 16 8 0  8 16 24 25 26 27 28 29 30 31 23 15 7 6 5 4 12 20 28 36 44 52 60 61 62 63 55 47 39 38 37 36 35 34 33 32 40 48 56 57 58 59 51 43 35 27 19 11 3 2 1 0 1 2 3 4 5 6 7 15 14 13 12 11 10 9 8 16  17 18 19 20 21 22 23 31 30 29 28 27 26 25 24 32 33 34 35 36 37 38 39 47 46 45 44 43 42 41 40 48 49 50 51 52 53 54 55 63 62 61 60 59 58 57 56]
 append path [lreverse [lrange $path 0 end-1]]
 device display -endless -path $path -pause 1 -fade_steps 4 -fg_colour "blue"
# TODO: Figure out why the last pixel on the fade tail turns dark red when fade_steps=5
