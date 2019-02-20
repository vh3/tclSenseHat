# ex3.tcl - An experiment with colour

source device.tcl
set device(gif_output) "colours_full_plus"
set device(pixel_render) "plus"
package require Tk
wm withdraw .

# iterate through every hue, display a full screen of this colour
# See more about the hue-saturation-brightness colour model here:
# https://en.wikipedia.org/wiki/HSL_and_HSV

# Loop forever
set stop false
while {!$stop} {

	# Hue (colour) values run from zero to one in the "hue-saturation-brightness" model.  Step through the hues in tiny increments, and display on the screen.
	set brightness 1.0; # the closer to one, the brighter the colours appear
	set saturation 1.0; # the closer to zero, the closer to white (washed out) the colours appear
	set hue_step 0.001
	set first_loop true
	for {set hue 0} {$hue < 1 } {set hue [expr $hue + $hue_step]} {

		# Convert our hue value (h s b) to an (r g b) value
		set colour [hsv2rgb $hue $saturation $brightness]

		# Convert our rgb value to a 2-byte (16-bit) colour value needed to display on the SenseHat led matrix.  The output is a 2-byte hex value
		set colour [colour888to565 $colour]
		# prts "colour is:$colour"
		wipe $colour
		if {$first_loop} {fb2gif}	
		# pause
	}
	
	if {$first_loop} {gif_assemble;set first_loop false}
}
