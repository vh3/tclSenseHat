source SenseHat.tcl

set device(fg_colour) "white"
set device(bg_colour) "black"
set device(pause) 500;  # approximate viewing time per letter (whether scrolling or pageing)
set device(rotation) 0

display "321" page 0

# set display_text meow meow moo!!!
# display $display_text scroll 0

# Display a sprite you made or got at GurgleApps: http://gurgleapps.com/tools/matrix
set sprite 0x3c,0x7e,0xdf,0xff,0xf0,0xff,0x7e,0x3c,0x3c,0x7e,0xdc,0xf8,0xf8,0xfc,0x7e,0x3c; # pacman
display $sprite scroll 0

# load a font with of named 8x8 icons from a file and display a selection of them in a predefined order
set device(font) 3
load_font 3
source eye_animation.tcl
puts "display_text=$display_text"
foreach i $display_text {
	puts "displaying $i"
	# display $i page
}

# display_list $display_text

return

set display_text [list ghost1 ghost2 smile smileL empty all_on arrow invader1 invader2 tree1 tree1lit1 tree1lit2 tree2 bunny1 bunny2 bunny3 danbo clock1 heart1F heart1 heart2 heart2F santaHat santaHat2 star1 star2 star3 star4 star5 star6 star7 star8 star9 star10 star11]
display_list $display_text

set display_text [list star1 star2 star3 star4 star5 star6 star7 star8 star9 star10 start11]
append display_text [lreverse $display_text]
display_list $display_text
