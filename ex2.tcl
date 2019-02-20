# ex2.tcl - scripts to display 'full screen' colour rainbows.
# vh, 10 May , 2017
# --------------------------------------------------------------------

source device.tcl
set device(gif_output) "colours1"
package require Tk
wm withdraw .

# Play around with the pixel rendering.  options: circle, circle1...circle4, bear, heart, diagonal, vertical, plus or any letter of the alphabet
set device(pixel_render) "diagonal"
set device(gif_output) "colours_diagonal.gif"
# Display shifting rainbow colours
for {set angle -90} {$angle < 270} {incr angle} {
	
	set h [colour_transition $angle]
	set_pixel_list $h
	fb2gif
 }
 gif_assemble
 exit

wipe

set device(gif_output) "colours2"
# Create the startup list of hue values and draw them
set h [colour_transition 23.5]
set_pixel_list $h
# fb2gif

# Shift the colours 'to the left', endlessly
set device(pause) 0

for {set counter 0} {$counter <=1.0} {set counter [expr $counter + 0.01]} {

	incrlist h 0.01
	set_pixel_list $h
	fb2gif
}

 gif_assemble

return
