# georgia_fun2.tcl

source device.tcl

set device(fg_colour)  "pink"
set device(bg_colour)   "blue"
set device(pause)       500; # approximate viewing time per letter (whether scrolling or pageing)

# Make up a list of numbers you want the pixel drawer to follow.
# 00 01 02 03 04 05 06 07
# 08 09 10 11 12 13 14 15
# 16 17 18 19 20 21 22 23
# 24 25 26 27 28 29 30 31
# 32 33 34 35 36 37 38 39
# 40 41 42 43 44 45 46 47
# 48 49 50 51 52 53 54 55
# 56 57 58 59 60 61 62 63

# See the default paths that were already made
# display "Autobots rrroll out......" scroll

random

# display_path 

# Make your own path.  Look at the examples below
#device display "9876543210" -mode page -record countdown1 -fg_colour red -bg_colour blue

#return

set my_path [list 0 1 2 3 4 5 6 7 15 14 13 12 11 10 9 8 16 17 18 19 20 21 22 23 31 30 29 28 27 26 25 24 32 33 34 35 36 37 38 39 47 46 45 44 43 42 41 40 48 49 50 51 52 53 54 55 63 62 61 60 59 58 57 56]
# random
# device display -path $my_path -record path2 -fg_colour "red" -bg_colour "black"

# return 

# See the Ceylon eyes!
# display "3 2 1"
wipe black
# Draw a head (drew this and got this hex from http://gurgleapps.com/tools/matrix - you have to draw this rotated)
set device(fg_colour) "green"
set device(bg_colour) "fire engine red"

set small_mouth [rotate_hex [split "0x3e,0x7b,0x8b,0xbb,0xbb,0x8b,0x7b,0x3e" ","] 90]; #small mouth 
set no_mouth    [rotate_hex [split "0x3e,0x7b,0x8b,0xfb,0xfb,0x8b,0x7b,0x3e" ","] 90]; # no mouth  

device display $no_mouth -mode page -fg_colour white -bg_colour black
device display -path [list 17 18 19 20 21 22 21 20 19 18 17] -record path3 -fg_colour red -bg_colour black -mode scroll
set test 0;after 1000 {set test 1}; vwait test

return 

set test 0;after 1000 {set test 1}; vwait test
set device(pause) 400
display "$small_mouth" page
display "$no_mouth" page
display "$small_mouth" page
display "$no_mouth" page
display "$small_mouth" page
display "$no_mouth" page
set device(fg_colour) "blue"
display "$small_mouth" page
display "$no_mouth" page
set device(fg_colour) "green"
display "$small_mouth" page
display "$no_mouth" page
set device(fg_colour) "red"
display "$small_mouth" page
display "$no_mouth" page
set device(fg_colour) "canary yellow"
display "$small_mouth" page
display "$no_mouth" page
set device(pause) 500
set device(fg_colour) "white"
display "$small_mouth" page
display "$no_mouth" page

set device(fg_colour) "fire engine red"
display_path [lindex $device(path_list) end] true

set small_mouth [rotate_hex [split 0x3e,0x7b,0x8b,0xbb,0xbb,0x8b,0x7b,0x3e" ","] 270]; #small mouth 
set no_mouth   [rotate_hex [split 0x3e,0x7b,0x8b,0xfb,0xfb,0x8b,0x7b,0x3e" ","] 270]; # no mouth  
# ------------------------------------------------------
return

set my_path [list 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63]
display_path $my_path

# zig-zag from top to bottom
set my_path [list 0 1 2 3 4 5 6 7 15 14 13 12 11 10 9 8 16 17 18 19 20 21 22 23 31 30 29 28 27 26 25 24 32 33 34 35 36 37 38 39 47 46 45 44 43 42 41 40 48 49 50 51 52 53 54 55 63 62 61 60 59 58 57 56]
display_path $my_path

# spiral from outside to inside
set my_path [list 000 8 16 24 32 40 48 56 57 58 59 60 61 62 63  55 47 39 31 23 15 7 6 5 4 3 2 1 009 17 25 33 41 49 50 51 52 53 54 46 38 30 22 14 13 12 11 10 018 26 34 42 43 44 45 37 29 21 20  19 027 35 36 28]
display_path $my_path

# Ceylon eyes back and forth...
set my_path [list 17 18 19 20 21 22]
display_path $my_path true
