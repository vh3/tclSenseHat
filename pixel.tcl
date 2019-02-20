# pixel.tcl - A script to take an 8x8  .raw frame buffer file and elaborate
# each pixel as an 8X8 graphic and save to .gif file.
# Result file will be 64X64 pixels

# hex definitions of simple shapes for pixel design
# circle_open - 0x3c,0x42,0x81,0x81,0x81,0x81,0x42,0x3c
# circle_fill - 0x3c,0x7e,0xff,0xff,0xff,0xff,0x7e,0x3c
# vertical    - 0x3c,0x3c,0x3c,0x3c,0x3c,0x3c,0x3c,0x3c
# horizontal  - 0x00,0x00,0xff,0xff,0xff,0xff,0x00,0x00
# plus        - 0x3c,0x3c,0xff,0xff,0xff,0xff,0x3c,0x3c
# diagonal    - 0xc0,0xe0,0xf8,0x7c,0x3e,0x1f,0x07,0x03
# thick ring  - 0x3c,0x7e,0xe7,0xc3,0xc3,0xe7,0x7e,0x3c
# circle_setback - 0x00,0x3c,0x7e,0x7e,0x7e,0x7e,0x3c,0x00
source device.tcl

proc custom_pixel {pixel_data {template ""}} {
	
	global device
	set height $device(height)
	set width $device(width)	
	set bg_colour "#000000"
	if {$template == ""} {set template [split "0x00,0x3c,0x7e,0x7e,0x7e,0x7e,0x3c,0x00" ,]}
	set template_rows [llength $template]
	puts "template=$template"

	set new_pixels ""
	# iterate over each row of pixels in the original file
	for {set row 0} {$row < $height} {incr row} {
		
		puts "row=$row"
		# grab the current row of pixel data
		set current_row [lindex $pixel_data $row]
		
		# iterate over each row of the template
		for {set template_row 0} {$template_row < $template_rows} {incr template_row} {

			set new_row ""

			# iterate over each individual pixel in this row			
			puts "template_row=$template_row"

			# iterate over each of the pixels in our current row of pixel data
			for {set pixel 0} {$pixel < $width} {incr pixel} {

				# what is the colour of this pixel?
				set fg_colour [lindex $current_row $pixel]
				puts "fg_colour=$fg_colour"

				# what is the hex value for this row definition in the template?
				set hex_val [lindex $template $template_row]
				set bin_val [hex2bin $hex_val]
				set bin_val [split $bin_val ""]
				puts "bin_val=$bin_val"

				# map the colours to the zeros and ones of this pixel definition
				set this_pixel [lmap temp $bin_val {string map "0 $bg_colour 1 $fg_colour" $temp}]
				puts "this_pixel=$this_pixel"

				foreach i $this_pixel {	lappend new_row $i}
			}

			# puts "new_row is now:$new_row"
			# We now have a complete row of pixel data.  Append it to the image data
			lappend new_pixels $new_row 				
		}
	}
	
	return $new_pixels
}

set input_filename "test.raw"
set output_filename "test.gif"
puts "reading file:$input_filename"

# Read the data from this file
set image_data [fbfile_read $input_filename]
# puts "image data=$image_data"

# apply the pixel template to each of the pixels in the input file
set new_image_data [custom_pixel $image_data]
puts "image data is now=$new_image_data"
# puts $image_data
puts "There are [llength $new_image_data] rows of data in the image returned"

# set row_counter 0
# foreach i $new_image_data {
#	
#	puts "row:$row_counter = length [llength $i]"
#	incr row_counter
# }

package require Tk
wm withdraw .
set my_image [image create photo]
$my_image put $new_image_data
$my_image write -format gif $output_filename

exit
