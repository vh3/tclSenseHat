# experiment3_counter.tcl - a script to demonstrate a 2-digit counter
# that fits in an 8x8 display 
# vh, 29 Apr 2017
# ------------------------------------------------------------

# Load the script to read a temperature from the SenseHat
source lps25h.tcl

# Load the LED scripts
source device.tcl

proc counter x {

# Define tiny numbers 0-9 that are only 3 columns wide. rotate them into column
# format and strip away the first 4 columns.  When we want 2 digits, we can add
# the 2 together, then rotate the final character upright.
# We used: http://gurgleapps.com/tools/matrix to create the hex statements

	set num(0)    [lrange [rotate_hex [split "0x07,0x05,0x05,0x05,0x07,0x00,0x00,0x00" ","] 270] 4 end]; # zero
	set num(1)    [lrange [rotate_hex [split "0x01,0x01,0x01,0x01,0x01,0x00,0x00,0x00" ","] 270] 4 end]; # one
	set num(2)    [lrange [rotate_hex [split "0x07,0x01,0x07,0x04,0x07,0x00,0x00,0x00" ","] 270] 4 end]; # two
	set num(3)    [lrange [rotate_hex [split "0x07,0x01,0x07,0x01,0x07,0x00,0x00,0x00" ","] 270] 4 end]; # three
	set num(4)    [lrange [rotate_hex [split "0x05,0x05,0x07,0x01,0x01,0x00,0x00,0x00" ","] 270] 4 end]; # four
	set num(5)    [lrange [rotate_hex [split "0x07,0x04,0x07,0x01,0x07,0x00,0x00,0x00" ","] 270] 4 end]; # five
	set num(6)    [lrange [rotate_hex [split "0x07,0x04,0x07,0x05,0x07,0x00,0x00,0x00" ","] 270] 4 end]; # six
	set num(7)    [lrange [rotate_hex [split "0x07,0x01,0x01,0x01,0x01,0x00,0x00,0x00" ","] 270] 4 end]; # seven
	set num(8)    [lrange [rotate_hex [split "0x07,0x05,0x07,0x05,0x07,0x00,0x00,0x00" ","] 270] 4 end]; # eight
	set num(9)    [lrange [rotate_hex [split "0x07,0x05,0x07,0x01,0x01,0x00,0x00,0x00" ","] 270] 4 end]; # nine
	set num(000)  [split "0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00" ","]
	set num(100)  [split "0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80" ","]
	set num(200)  [split "0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xc0" ","]
	set num(300)  [split "0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xe0" ","]
	set num(400)  [split "0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xf0" ","]
	set num(500)  [split "0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xf8" ","]
	set num(600)  [split "0x00,0x00,0x00,0x00,0x00,0x00,0x80,0xf8" ","]
	set num(700)  [split "0x00,0x00,0x00,0x00,0x00,0x00,0xc0,0xf8" ","]
	set num(800)  [split "0x00,0x00,0x00,0x00,0x00,0x00,0xe0,0xf8" ","]
	set num(900)  [split "0x00,0x00,0x00,0x00,0x00,0x00,0xf0,0xf8" ","]
	set num(1000) [split "0x00,0x00,0x00,0x00,0x00,0x00,0xf8,0xf8" ","]
	set num(over) [split "0x00,0x00,0x77,0x00,0x00,0x00,0xf8,0xf8" ","]

	# Max counter for this proc is 999.  TODO: fix code to update max to 1099
	if {$x>999} {display $num(over) page} else {

		set digit1 [lrange $num([string index [format %03d $x] 0]00) end-1 end]
		# puts "digit1=$digit1"
		set my_list ""
		append my_list $num([string index [format %03d $x] 1]) " $num([string index [format %03d $x] 2])"
		# puts "my_list:$my_list"

		set display_hex [lreplace [rotate_hex $my_list 90] end-1 end [lindex $digit1 0]]
		lappend display_hex [lindex $digit1 1]
		# puts "display_hex=$display_hex"
		device display $display_hex -mode page
	}
}

set device(rotation) 0
set device(bg_colour) black
set device(pause) 1000
set stop false
while {!$stop} {

	# Temperature
	set device(fg_colour) white
	set data [read_temp]
	counter [lindex $data 0]

	# Pressure
	set test 0;after 2000 {set test 1};vwait test
	set device(fg_colour) white
	set value [format "%03d" [expr round([lindex $data 1] / 1.)]]
	# puts "pressure value=$value"
	#set string [string range $value end-2 end]
	#puts "string is [format %d $string]"

	puts "pressure=[format %d [expr double([string range [format "%03d" [expr round(double([lindex $data 1]) / 1.)]] end-2 end])] ]"
	counter [format %d [string range [format "%03d" [expr round(double([lindex $data 1]) / 1.)]] end-2 end]]
}
