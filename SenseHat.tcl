# SenseHat.tcl - script to convert input text to a scrolling display
# vh, 7 May 2017
# ------------------------------------------------------------------

proc pause_to_debug {{message "Hit Enter to continue ==> "}} {
	global device
	if {$device(debug)} {
		puts -nonewline $message
		flush stdout
		gets stdin
	}
	
	return
}

# define a procedure to pause
proc pause {{user_pause ""}} {
	
	global device
	if {$user_pause == ""} {set user_pause $device(pause)}
	set test 0
	after $user_pause {set test 1}
	vwait test
	return	
}

# Initialize some basic defaults,
# Initialize these only on load to allow other calling scripts to change them
proc load_defaults {} {

	global device

	# Supporting hardware interaction packages
	set device(debug)          false
	set device(package_gpio)    piio
	set device(package_i2c)     piio
	set device(package_spi)     piio
	set device(brightness)      10 ; # value from 1-8 (zero is also valid, but not useful)
	set device(brightness_max)  10.0 ;# the reference value for maximum brighness values. This must have a decimal place
	set device(fg_colour)       "pink"
	set device(bg_colour)       "black"
	set device(syspath)         "/dev/fb1" ; # path to linux device
	set device(bpp)             2; # bytes per pixel (the SenseHat uses r=5 bits, g=6 bits, g=5 bits=16 bits=2 bytes
	set device(width)           8; # width of display, pixels
	set device(height)          8; # height of display, pixels
	set device(pause)           100; # approximate viewing time per letter (whether scrolling or pageing) in milliseconds
	set device(font)            "";   # the script will search for a local file called "font<$device(font)>.tcl".  Otherwise, it will use an internal default font definition
	set device(font_data)       ""; # the raw font information
	set device(mode)            scroll; # values: page or scroll
	set device(endless)         false
	set device(colour_file)     ""; # the script will read a local file for colour definitions.  Otherwise a set of default internal colour definitions will be loaded.
	set device(colours)         ""
	set device(fade_steps)      5; # the number of steps it takes a pixel in a path to fade, when a path  definition is being used.
	set device(path)            ""   ;# currently defined pixel display path
	set device(path_list)       ""   ; # the list of all predefined pixel display paths
	set device(record)          false; # set this flag to dump the output of the display to an animated .gif file
	set device(gif_zoom)        16; # A factor to scale the output gif files when creating animated gif outputs.
	set device(gif_tempname)    "_image_";# name of temporary files created while creating gif recording
	set device(gif_output)      "8x8.gif"; # the name of the output file for animated gif dump of the led screen animation
	set device(pixel_render)    "circle" ;# shape to render pixels.  The shape can be any letter in the current font, or a list of hex characters defining the shape such as: [split "0x00,0x3c,0x7e,0x7e,0x7e,0x7e,0x3c,0x00" ,]  
	set device(dump_counter)    0; # automated counter of files.  Internal value.
	set device(rotation)        0; # rotates the display clockwise (valid values= 90, 180, 270)
	set device(rotation_definitions) [list {0 {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63}} \
{90 {7 15 23 31 39 47 55 63 6 14 22 30 38 46 54 62 5 13 21 29 37 45 53 61 4 12 20 28 36 44 52 60 3 11 19 27 35 43 51 59 2 10 18 26 34 42 50 58 1 9 17 25 33 41 49 57 0 8 16 24 32 40 48 56}} \
{180 {63 62 61 60 59 58 57 56 55 54 53 52 51 50 49 48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0}} \
{270 {56 48 40 32 24 16 8 0 57 49 41 33 25 17 9 1 58 50 42 34 26 18 10 2 59 51 43 35 27 19 11 3 60 52 44 36 28 20 12 4 61 53 45 37 29 21 13 5 62 54 46 38 30 22 14 6 63 55 47 39 31 23 15 7}}]

	define_paths
	colour_load 
}

proc colour_load {} {

	global device 

	# Load the colour lookup table.  If we fail to load the external colour table, load some basic colours.
	if {[catch {source $device(colour_file)} err]} {

		# A collection of 30 basic colours / random selection of colour names that made the kids curious.
		# Find 700+ more colour names and definitions at: http://latexcolor.com/

		set device(colours) [list \
		{{Colour Name} Description         {3-byte hex colour} r g b} \
		{black             Black           #000000 0.00 0.00 0.00} \
		{{warm black}      {Warm black}    #004242 0.00 0.26 0.26} \
		{gray              Gray            #808080 0.50 0.50 0.50} \
		{grey              Grey            #808080 0.50 0.50 0.50} \
		{brown             Brown           #964B00 0.59 0.29 0.00} \
		{red               Red             #FF0000 1.00 0.00 0.00} \
		{{fire engine red} {Fire engine red} #CE2029 0.81 0.09 0.13} \
		{{hot pink}        {Hot pink}      #FF69B4 1.00 0.41 0.71} \
		{pink              Pink            #FFC0CB 1.00 0.75 0.80} \
		{orange            Orange        #FFA500 1.00 0.65 0.00} \
		{{burnt orange}    {Burnt orange}  #CC5500 0.80 0.33 0.00} \
		{yellow            Yellow          #FFFF00 1.00 1.00 0.00} \
		{{canary yellow}   {Canary yellow} #FFEF00 1.00 0.94 0.00} \
		{green              Green          #00FF00 0.00 1.0 0.00} \
		{{british racing green} {British racing green} #004225 0.00 0.26 0.15} \
		{{neon green}      {Neon green}    #39FF14 0.22 0.88 0.08} \
		{blue              Blue            #0000FF 0.00 0.00 1.0} \
		{{navy blue}       {Navy blue}     #000080 0.00 0.00 0.50} \
		{{dark midnight blue} {Dark midnight blue} #003366 0.00 0.20 0.40} \
		{indigo            Indigo          #4B0082 0.29 0.00 0.51} \
		{violet            Violet          #8F00FF 0.56 0.00 1.00} \
		{{vivid violet}    {Vivid violet}  #9F00FF 0.62 0.00 1.00} \
		{cyan              Cyan            #00FFFF 0.00 1.00 1.00} \
		{periwinkle        Periwinkle      #CCCCFF 0.80 0.80 1.00} \
		{magenta           Magenta         #FF00FF 1.00 0.00 1.00} \
		{maroon            Maroon         #800000 0.50 0.00 0.00} \
		{purple            Purple         #800080 0.50 0.00 0.50} \
		{white             White           #FFFFFF 1.00 1.00 1.00} \
		{snow              Snow            #FFFAFA 1.00 0.98 0.98} ]
	}

	# puts "[llength $device(colours)] colour definitions loaded"
	return
}

# Code to convert 3-byte colour definitions (well, in our case we are using 3 decimal values)
# into 2 byte hex (ie. 8-8-8 bits into 5-6-5 bits) so that the colour definition is 
# 2-bytes (5+6+5 = 16bits =2 bytes) per pixel, which is what the SenseHat needs to display.
# Here we input rgb values 0 <= x <= 1.
# the output is in a format that we need to pass to the linux frame buffer of the Raspberry Pi. 
proc colour888to565 input_rgb {

	global device
	# puts "brightness=$device(brightness)"

	# TODO: Make the function more useful elsewhere and check whether the input is a list of integers (probably 1-255), convert the values to 0<x<1

	# 8-bit=255max, 6-bit=63max,5-bit=31max

	# puts "brightness factor=[expr ($device(brightness) / 8.)]"

	set output_r_d [format %03.1d [expr round ([lindex $input_rgb 0] * 31.* ($device(brightness) / $device(brightness_max)))]]
	set output_g_d [format %03.1d [expr round ([lindex $input_rgb 1] * 63.* ($device(brightness) / $device(brightness_max)))]]
	set output_b_d [format %03.1d [expr round ([lindex $input_rgb 2] * 31.* ($device(brightness) / $device(brightness_max)))]]

	set output_r [format %05b [expr round ([lindex $input_rgb 0] * 31.* ($device(brightness) / $device(brightness_max)))]]
	set output_g [format %06b [expr round ([lindex $input_rgb 1] * 63.* ($device(brightness) / $device(brightness_max)))]]
	set output_b [format %05b [expr round ([lindex $input_rgb 2] * 31.* ($device(brightness) / $device(brightness_max)))]]

#	set output_r_d [format %03.1d [expr round ([lindex $input_rgb 0] * 31.)]]
#	set output_g_d [format %03.1d [expr round ([lindex $input_rgb 1] * 63.)]]
#	set output_b_d [format %03.1d [expr round ([lindex $input_rgb 2] * 31.)]]

#	set output_r [format %05b [expr round ([lindex $input_rgb 0] * 31.)]]
#	set output_g [format %06b [expr round ([lindex $input_rgb 1] * 63.)]]
#	set output_b [format %05b [expr round ([lindex $input_rgb 2] * 31.)]]

	# puts "(r g b)($input_rgb)=${output_r}${output_g}${output_b}"
	# puts "(r g b)(input_rbb=$input_rgb) output_rgb=${output_r_d} ${output_g_d} ${output_b_d}"
	# return individual bytes, in LSB MSB order 
	return "[format \\x%2.2x [bin2int [string range "${output_r}${output_g}${output_b}" 8 15]]][format \\x%2.2x [bin2int [string range "${output_r}${output_g}${output_b}" 0 7]]]"
}

# increment the values of a list by a prescribed increment.
# Inputs are expected 0 < x < 1, and outputs are returned 0 < x < 1
# This procedure is used for endlessly cycling through hue values
proc incrlist {mylistvar {increment_val 1.}} {
	
	upvar $mylistvar mylist
	set new_list ""
	foreach i $mylist {
		
		# cap the values at 1.0 to cycle through the values endlessly if required
		set new_value [expr (int(($i + $increment_val) * 1000) % 1000) / 1000.]
		# puts "old value=$i, new value=$new_value"

		lappend new_list $new_value
	}

	set mylist $new_list 
	return $new_list	
}

# proc to convert hsv model colour definition to an rgb value (where 0 <= r,g,b <=1).  
# Code after: http://code.activestate.com/recipes/133527-convert-hsv-colorspace-to-rgb/
proc hsv2rgb {h s v} {
  if {$s <= 0.0} {
    # achromatic
    set v [expr {int(255 * $v)}]
    return "$v $v $v"
  } else {
		set v [expr {double($v)}]
		if {$h >= 1.0} { set h 0.0 }
		set h [expr {6.0 * $h}]
		set f [expr {double($h) - int($h)}]
    
#    	set p [expr {int(255 * $v * (1.0 - $s))}]
#    	set q [expr {int(255 * $v * (1.0 - ($s * $f)))}]
#    	set t [expr {int(255 * $v * (1.0 - ($s * (1.0 - $f))))}]
#    	set v [expr {int(255 * $v)}]    
    
		set p [expr {$v * (1.0 - $s)}]
		set q [expr {$v * (1.0 - ($s * $f))}]
		set t [expr {$v * (1.0 - ($s * (1.0 - $f)))}]
		set v [expr {$v}]

		# puts "p=$p, Q=$q, t=$t, v=$v"
		switch [expr {int($h)}] {
		  0 { return "$v $t $p" }
		  1 { return "$q $v $p" }
		  2 { return "$p $v $t" }
		  3 { return "$p $q $v" }
		  4 { return "$t $p $v" }
		  5 { return "$v $p $q" }
		}
	}
}

# Convert a binary string to an integer. After http://wiki.tcl.tk/3242
# This works for up to 32 bits.
# Any more and the value will roll over.
proc bin2int {binstring {signed_flag "unsigned"}} {

	# puts "binstring is $binstring"

    # Take the 2's complement if necessary
    if {$signed_flag=="signed"} {
		# puts "checking the sign"

	    if {$binstring == 0} {
	        return 0 
	    } elseif  {[string index $binstring 0] == 1} {
		# If the first bit is set, it means that this is a negative number.  Take the 2's complement.
	        set sign "-"
		set binstring [string map {0 1 1 0}  $binstring]
		set binstring [bin_add $binstring "1"]

	    } else {
			# puts "This number was signed, but positive"
		        set sign +
	    }	
    } else {

	# puts "This was an unsigned number"
	set sign +
    }

    set ret 0
    foreach bit [split $binstring ""] {
        set ret [expr {$ret << 1}]
        if {[string is boolean $bit]} {
            set ret [expr {$ret | $bit}]
        } else {
            error "string is not binary!"
        }
    }
    return ${sign}${ret}
}

# Procedure to look up a colour word or phrase and return 5-6-5-bit colour as a 2-byte hex
proc colour_lookup colour {

	# # puts "inside proc colour_lookup.  Colour=$colour"
	global device
	# puts "There are [llength $device(colours)] colours to choose from..."

	# it is possible that a hex colour definition was passed in.  If so, return the same value
	# If the colour is not in hex format, do a colour_lookup
	set exp {\\x([0-9a-fA-F]){2}}
	set result [regexp -all $exp $colour]
	# puts "result=$result"
	if {$result == 2} {
		
		# puts "a hex value was passed to the colour_lookup function"
		return $colour
	}

	if {[set rgb [lrange [lsearch -inline -index 0 $device(colours) [string trim [string tolower $colour]]] 3 5]] == ""} {
		puts "Didn't find '$colour' in the colour set."
		return -1
	}

	# puts "colour=$colour, rgb=$rgb"

	# convert our decimal rgb to hex
	set result [colour888to565 $rgb]
	# puts "colour=$colour, rgb=$rgb 565hex=$result"
	return $result
}

# usage example
# set colour "blue"
# puts "$colour=[colour_lookup $colour]"

proc load_font {font_id} {

	global device

	# If we can't load a font file, set a default font
	if {$device(font) == "default" || [catch {source "font${device(font)}.tcl"} err ]} {
	
		puts "Loading default font."
		set device(font) default
	
		set font_data [list \
		{ } {0x00  0x00  0x00  0x00  0x00  0x00  0x00  0x00 } \
		!   {0x30  0x78  0x78  0x30  0x30  0x00  0x30  0x00 } \
		{\"} {0x6C  0x6C  0x28  0x00  0x00  0x00  0x00  0x00 } \
		{\#} {0x6C  0x6C  0xFE  0x6C  0xFE  0x6C  0x6C  0x00 } \
		{$} {0x18  0x7E  0xC0  0x7C  0x06  0xFC  0x18  0x00 } \
		%   {0x00  0xC6  0xCC  0x18  0x30  0x66  0xC6  0x00 } \
		&   {0x38  0x6C  0x38  0x76  0xDC  0xCC  0x76  0x00 } \
		'   {0x60  0x60  0xC0  0x00  0x00  0x00  0x00  0x00 } \
		(   {0x18  0x30  0x60  0x60  0x60  0x30  0x18  0x00 } \
		)   {0x60  0x30  0x18  0x18  0x18  0x30  0x60  0x00 } \
		*   {0x00  0x66  0x3C  0xFF  0x3C  0x66  0x00  0x00 } \
		+   {0x00  0x30  0x30  0xFC  0x30  0x30  0x00  0x00 } \
		,   {0x00  0x00  0x00  0x00  0x00  0x30  0x30  0x60 } \
		-   {0x00  0x00  0x00  0xFC  0x00  0x00  0x00  0x00 } \
		.   {0x00  0x00  0x00  0x00  0x00  0x30  0x30  0x00 } \
		/   {0x06  0x0C  0x18  0x30  0x60  0xC0  0x80  0x00 } \
		0   {0x7C  0xC6  0xCE  0xDE  0xF6  0xE6  0x7C  0x00 } \
		1   {0x30  0x70  0x30  0x30  0x30  0x30  0xFC  0x00 } \
		2   {0x78  0xCC  0x0C  0x38  0x60  0xCC  0xFC  0x00 } \
		3   {0x78  0xCC  0x0C  0x38  0x0C  0xCC  0x78  0x00 } \
		4   {0x1C  0x3C  0x6C  0xCC  0xFE  0x0C  0x1E  0x00 } \
		5   {0xFC  0xC0  0xF8  0x0C  0x0C  0xCC  0x78  0x00 } \
		6   {0x38  0x60  0xC0  0xF8  0xCC  0xCC  0x78  0x00 } \
		7   {0xFC  0xCC  0x0C  0x18  0x30  0x30  0x30  0x00 } \
		8   {0x78  0xCC  0xCC  0x78  0xCC  0xCC  0x78  0x00 } \
		9   {0x78  0xCC  0xCC  0x7C  0x0C  0x18  0x70  0x00 } \
		:   {0x00  0x30  0x30  0x00  0x00  0x30  0x30  0x00 } \
		{;} {0x00  0x30  0x30  0x00  0x00  0x30  0x30  0x60 } \
		<   {0x18  0x30  0x60  0xC0  0x60  0x30  0x18  0x00 } \
		=   {0x00  0x00  0xFC  0x00  0x00  0xFC  0x00  0x00 } \
		>   {0x60  0x30  0x18  0x0C  0x18  0x30  0x60  0x00 } \
		?   {0x78  0xCC  0x0C  0x18  0x30  0x00  0x30  0x00 } \
		@   {0x7C  0xC6  0xDE  0xDE  0xDC  0xC0  0x78  0x00 } \
		A   {0x30  0x78  0xCC  0xCC  0xFC  0xCC  0xCC  0x00 } \
		B   {0xFC  0x66  0x66  0x7C  0x66  0x66  0xFC  0x00 } \
		C   {0x3C  0x66  0xC0  0xC0  0xC0  0x66  0x3C  0x00 } \
		D   {0xF8  0x6C  0x66  0x66  0x66  0x6C  0xF8  0x00 } \
		E   {0xFE  0x62  0x68  0x78  0x68  0x62  0xFE  0x00 } \
		F   {0xFE  0x62  0x68  0x78  0x68  0x60  0xF0  0x00 } \
		G   {0x3C  0x66  0xC0  0xC0  0xCE  0x66  0x3E  0x00 } \
		H   {0xCC  0xCC  0xCC  0xFC  0xCC  0xCC  0xCC  0x00 } \
		I   {0x78  0x30  0x30  0x30  0x30  0x30  0x78  0x00 } \
		J   {0x1E  0x0C  0x0C  0x0C  0xCC  0xCC  0x78  0x00 } \
		K   {0xE6  0x66  0x6C  0x78  0x6C  0x66  0xE6  0x00 } \
		L   {0xF0  0x60  0x60  0x60  0x62  0x66  0xFE  0x00 } \
		M   {0xC6  0xEE  0xFE  0xFE  0xD6  0xC6  0xC6  0x00 } \
		N   {0xC6  0xE6  0xF6  0xDE  0xCE  0xC6  0xC6  0x00 } \
		O   {0x38  0x6C  0xC6  0xC6  0xC6  0x6C  0x38  0x00 } \
		P   {0xFC  0x66  0x66  0x7C  0x60  0x60  0xF0  0x00 } \
		Q   {0x78  0xCC  0xCC  0xCC  0xDC  0x78  0x1C  0x00 } \
		R   {0xFC  0x66  0x66  0x7C  0x6C  0x66  0xE6  0x00 } \
		S   {0x78  0xCC  0xE0  0x70  0x1C  0xCC  0x78  0x00 } \
		T   {0xFC  0xB4  0x30  0x30  0x30  0x30  0x78  0x00 } \
		U   {0xCC  0xCC  0xCC  0xCC  0xCC  0xCC  0xFC  0x00 } \
		V   {0xCC  0xCC  0xCC  0xCC  0xCC  0x78  0x30  0x00 } \
		W   {0xC6  0xC6  0xC6  0xD6  0xFE  0xEE  0xC6  0x00 } \
		X   {0xC6  0x6C  0x38  0x38  0x6C  0xC6  0xC6  0x00 } \
		Y   {0xCC  0xCC  0xCC  0x78  0x30  0x30  0x78  0x00 } \
		Z   {0xFE  0xC6  0x8C  0x18  0x32  0x66  0xFE  0x00 } \
		{[} {0x78  0x60  0x60  0x60  0x60  0x60  0x78  0x00 } \
		\]  {0x78  0x18  0x18  0x18  0x18  0x18  0x78  0x00 } \
		^   {0x10  0x38  0x6C  0xC6  0x00  0x00  0x00  0x00 } \
		_   {0x00  0x00  0x00  0x00  0x00  0x00  0x00  0xFF } \
		`   {0x30  0x30  0x18  0x00  0x00  0x00  0x00  0x00 } \
		a   {0x00  0x00  0x78  0x0C  0x7C  0xCC  0x76  0x00 } \
		b   {0xE0  0x60  0x60  0x7C  0x66  0x66  0xDC  0x00 } \
		c   {0x00  0x00  0x78  0xCC  0xC0  0xCC  0x78  0x00 } \
		d   {0x1C  0x0C  0x0C  0x7C  0xCC  0xCC  0x76  0x00 } \
		e   {0x00  0x00  0x78  0xCC  0xFC  0xC0  0x78  0x00 } \
		f   {0x38  0x6C  0x60  0xF0  0x60  0x60  0xF0  0x00 } \
		g   {0x00  0x00  0x76  0xCC  0xCC  0x7C  0x0C  0xF8 } \
		h   {0xE0  0x60  0x6C  0x76  0x66  0x66  0xE6  0x00 } \
		i   {0x30  0x00  0x70  0x30  0x30  0x30  0x78  0x00 } \
		j   {0x0C  0x00  0x0C  0x0C  0x0C  0xCC  0xCC  0x78 } \
		k   {0xE0  0x60  0x66  0x6C  0x78  0x6C  0xE6  0x00 } \
		l   {0x70  0x30  0x30  0x30  0x30  0x30  0x78  0x00 } \
		m   {0x00  0x00  0xCC  0xFE  0xFE  0xD6  0xC6  0x00 } \
		n   {0x00  0x00  0xF8  0xCC  0xCC  0xCC  0xCC  0x00 } \
		o   {0x00  0x00  0x78  0xCC  0xCC  0xCC  0x78  0x00 } \
		p   {0x00  0x00  0xDC  0x66  0x66  0x7C  0x60  0xF0 } \
		q   {0x00  0x00  0x76  0xCC  0xCC  0x7C  0x0C  0x1E } \
		r   {0x00  0x00  0xDC  0x76  0x66  0x60  0xF0  0x00 } \
		s   {0x00  0x00  0x7C  0xC0  0x78  0x0C  0xF8  0x00 } \
		t   {0x10  0x30  0x7C  0x30  0x30  0x34  0x18  0x00 } \
		u   {0x00  0x00  0xCC  0xCC  0xCC  0xCC  0x76  0x00 } \
		v   {0x00  0x00  0xCC  0xCC  0xCC  0x78  0x30  0x00 } \
		w   {0x00  0x00  0xC6  0xD6  0xFE  0xFE  0x6C  0x00 } \
		x   {0x00  0x00  0xC6  0x6C  0x38  0x6C  0xC6  0x00 } \
		y   {0x00  0x00  0xCC  0xCC  0xCC  0x7C  0x0C  0xF8 } \
		z   {0x00  0x00  0xFC  0x98  0x30  0x64  0xFC  0x00 } \
		\{  {0x1C  0x30  0x30  0xE0  0x30  0x30  0x1C  0x00 } \
		|   {0x18  0x18  0x18  0x00  0x18  0x18  0x18  0x00 } \
		\}  {0xE0  0x30  0x30  0x1C  0x30  0x30  0xE0  0x00 } \
		~   {0x76  0xDC  0x00  0x00  0x00  0x00  0x00  0x00 } \
		\\  {0xC0  0x60  0x30  0x18  0x0C  0x06  0x02  0x00 } \
		"circle"    {0x00 0x3c 0x7e 0x7e 0x7e 0x7e 0x3c 0x00} \
		"circle2"   {0x00 0x3c 0x7e 0x66 0x66 0x7e 0x3c 0x00} \
		"circle3"   {0x00 0x3c 0x76 0x66 0x66 0x6e 0x3c 0x00} \
		"circle4"   {0x00 0x3c 0x42 0x42 0x42 0x42 0x3c 0x00} \
		"circle5"   {0x00 0x3c 0x1e 0x6e 0x7e 0x7e 0x3c 0x00} \
		"bear"      {0xc3 0xff 0x5a 0x7e 0x5a 0x66 0x3c 0x00} \
		"heart"     {0xC0 0x60 0x30 0x18 0x0C 0x06 0x02 0x00} \
		"plus"      {0x3c 0x3c 0xff 0xff 0xff 0xff 0x3c 0x3c} \
		"diagonal"  {0xc0 0xe0 0xf8 0x7c 0x3e 0x1f 0x07 0x03} \
		"vertical"  {0x3c 0x3c 0x3c 0x3c 0x3c 0x3c 0x3c 0x3c} \
		"horizontal" {0x00 0x00 0xff 0xff 0xff 0xff 0x00 0x00} \
		"plus"       {0x3c 0x3c 0xff 0xff 0xff 0xff 0x3c 0x3c} ]

		puts "There are [expr [llength $font_data] /2] items in the default font"
		set device(font_data) $font_data

	} else {

		set device(font_data) $font_data
	}
	
	# This package is designed with a scrolling display in mind.  
	# To make this simpler (and faster for these scripts to process),
	# all the hex images are  rotated by 270 degrees so that each hex
	# value represents a column of pixel data that is pasted to the side
	# of the existing display columns.
	# However, we want the users to be able to define images
	# and fonts 'upright' so these scripts can consume fonts and images
	# from elsewhere.  So, iterate over each font item and rotate it 270 degrees
	# for storage.

	set old_font $device(font_data)
	# puts "font data is now:$old_font"

	set new_font ""
	foreach {i j} $old_font {

		# puts "rotating font item $i"
		# Note the space on the end is important. TO DO: figure out why...
		lappend new_font $i "[rotate_hex $j 270] "
	}

	# puts "font data is now:$new_font"
	set device(font_data) $new_font
	return
}

# -------------------------------------------------------------------------
# SCRIPTS FOR GRAPHICS DISPLAY BASED ON FONT DEFINITIONS
# -------------------------------------------------------------------------

# proc set_pixel {x y colour device bpp width} {
# 	catch {eval {exec printf "$colour" | dd bs=$bpp seek=[expr $y * $width + $x] > $device}} err
# }

# A procedure to add a column (scroll mode) or a full page (page mode) of pixels (8 columns) to the display, replacing its contents
proc add_page {output_var sequence_var input_var {mode "scroll"}} {

	# puts "inside proc add_page"
	global device

	set bg_colour [colour_lookup $device(bg_colour)]
	set fg_colour [colour_lookup $device(fg_colour)]

	set device(mode) $mode

	case $mode {
	  {scroll} {set col_increment 1}
	  {page}   {set col_increment 8}
	  {default} {puts "incorrect display mode: $mode.  Valid values: scroll and page"}
	}

	upvar $input_var display_hex 
	upvar $output_var output_frame 
	# puts "output frame has elements: [array names output_frame]"
	upvar $sequence_var sequence

	# set a counter for the columns to be added
	set temp_sequence $sequence

	# Handle rotation
	if {$device(rotation) !=0} {

		# Grab the next appropriate sequence of $device(width) columns

		# find the first column in sequence
		set col_start [expr $sequence + $col_increment - $device(width)] 
		set col_end [expr $sequence + $col_increment]
		set column_hex [lrange $display_hex $col_start $col_end]

		# transform this data and fill the array with colour data
		set column_hex [rotate_hex $column_hex $device(rotation)]

		set pixel_data ""
		# Iterate over each of the column definitions in this set of columns

		set output_frame(0) ""
		set output_frame(1) ""
		set output_frame(2) ""
		set output_frame(3) ""
		set output_frame(4) ""
		set output_frame(5) ""
		set output_frame(6) ""
		set output_frame(7) ""

		foreach i $column_hex {

			set binary_string [format %08b $i]

			# Iterate over each vertical pixel
			for {set y 0} {$y < 8} {incr y} {

				append output_frame([expr 7 - $y]) [string index $binary_string $y]
			}
		}

		# compose the pixel string.  Replace the 0's and 1's with the appropriate colours
# 		set pixel_data ""

		set row_list [lsort -increasing -integer [array names output_frame]] 
		set my_map [list 0 [colour_lookup $device(bg_colour)] 1 [colour_lookup $device(fg_colour)]]

		foreach i $row_list {

			# puts "working on output_frame($i)=$output_frame($i)"
			set output_frame($i) [string map $my_map $output_frame($i)] 
		}

	} else {

		# Fetch the next group of columns (single or multiple)
		for {set temp_sequence $sequence} {$temp_sequence < [expr $sequence + $col_increment]} {incr temp_sequence} {

			set column_hex [lrange $display_hex $temp_sequence $temp_sequence]
			# puts "column_hex=$column_hex"

			# puts "Displaying column $temp_sequence ([format %2.2x $column_hex]=[format %08b $column_hex]"

			#set pixel_data ""

				for {set y 0} {$y < 8} {incr y 1} {

					# iterate over the digits of this hex character and append the digit colour to each of the 8 rows
					set digit [string index [format %08b $column_hex] $y]
					# puts "($sequence of [llength $display_hex]) -  working on digit (y=$y): $digit"
	
					# Append this digit to the row			
					case $digit {
		
					  {0} {append output_frame([expr 7 - $y]) "$bg_colour"}
					  {1} {append output_frame([expr 7 - $y]) "$fg_colour"}
					  {default} {puts "non-binary input: '$digit' in sequence '$column_hex'";break}
					}
		 
					# Remove the first digit (we are starting with a frame full of background pixels)
					# puts "stripping off 2 bytes:[string range $output_frame($y) 0 7]"
					set colour_length [string length $bg_colour]
					# puts "colour_length = $colour_length"
					set output_frame($y) [string range $output_frame($y) $colour_length end]
				}
		}
	}

	incr sequence $col_increment
}

proc new_frame {output_var sequence_var} {

	global device

	upvar $output_var output_frame 
	upvar $sequence_var sequence

	set bg_colour [colour_lookup $device(bg_colour)]
	set fg_colour [colour_lookup $device(fg_colour)]

	# puts "seeding the frame"
	#seed the column output array
	for {set y 0} {$y < $device(width)} {incr y} {

		set output_frame($y) ""
		for {set x 0} {$x < $device(width)} {incr x} {

			append output_frame($y) $bg_colour
			# puts "output_frame($y)=$output_frame($y)"
		}
	}

	# puts "output_frame(1)=$output_frame(1)"

	# set sequence 0
	return
}

# a procedure to remove multiple blank columns (2 or 3, but not more as these are needed to properly display  spaces)
proc clean data {

	global device
	# Look for multiple column instances of the 'zero column', and replace them with a single instance
	set exp "(0x00(\[ \])+){2,3}"
	# puts "exp=$exp"
	set substitution "0x00 "
	# puts "sub=$substitution"
	set return_value [regsub -all $exp $data $substitution data]
	# puts "regsub had a return value:$return_value"
	return $data 
}

# A procedure to check up front if the user-inputted colours are not valid, and modify
# them once at the beginning to a default value instead of every time a pixel is coloured.
proc check_valid_colours {} {

	global device

	set bg_check [colour_lookup $device(bg_colour)]
	if {$bg_check ==-1} {
		puts "Background colour '$device(bg_colour)' not valid.  Substituting 'black'"
		set device(bg_colour) "black"
	}

	set fg_check [colour_lookup $device(fg_colour)]
	if {$fg_check ==-1} {
		puts "Foreground colour '$device(fg_colour) not valid.  Substituting 'white'"
		set device(fg_colour) "white"
	}
}

proc display display_text {

	global device
	set mode $device(mode)
	set endless $device(endless)
	set rotation $device(rotation)
	# puts "inside proc display.  rotation is:$rotation, mode=$mode, endless=$endless"

	check_valid_colours

	set trailing_space false

	# Do we have a font loaded?
	if {$device(font_data)==""} {load_font $device(font)}

	# It is possible that the input given to this proc is a string of hex data.  If this is the case, we can skip some of the next steps.
	set exp {(0x[0-9a-fA-F]{2})}
	set result [regexp -all $exp $display_text]
	set group_count [llength $display_text] 
	# puts "display_text=$display_text"
	# puts "result=$result, group_count=$group_count"
	# puts "list length = [llength [split $display_text]]"

	# If the number of hex values found equals the number of items in the comma-delimited input, we must have a list of hex values
	if {$result > 0 && $result == [llength [split $display_text ","]]} {

		puts "The input was a comma-delimited list of hex values" 
		# (such as what you might get from making your own icon at the web-page: http://gurgleapps.com/tools/matrix.  Remember if you do, that the icon should be rotated, top to the right)
		set display_hex [split $display_text ","]
		
		# This package is set up primarily as a scrolling display, for speed of display, all the image definitions are rotated 270 degrees so that the hex characters each define a column of the image).  We want the users to be able to define the images "upright", so we will rotate the user-specified hex data by 270 degrees here.
		# This allows users to provide input bitmaps in "upright" format.
		set display_hex [rotate_hex $display_hex 270]

	} elseif {$result > 0 && $result == $group_count} {

		# puts "The text entered was in hex format, list format already."
		set display_hex $display_text
		set display_hex [rotate_hex $display_hex 270]

	} else {

		puts "The input was a string of regular old text"
		# Map the letters in the display text to hex definitions and do some housekeeping
		if {[string range $display_text end end] == " "} {set trailing_space "true"} else {set training_space false} 
		# Add a space at the end of the string (so we can scroll to blank)
		append display_text " "
		if {$device(font) == "default"} {set display_text [string tolower $display_text]}
		# puts "Displaying text: \"$display_text\""
	
		set display_hex [string map $device(font_data) "${display_text}"]
		# puts "display_hex: $display_hex"
		
		# Delete any characters that weren't mapped to hex
		# TODO: THIS DOES NOT SEEM TO WORK.  INVALID CHARACTERS WILL CAUSE A FAILURE 
		set exp {!(\\x([0-9a-fA-F]){2})}
		# set exp {!(0x[0-9a-fA-F]{2})}
		set sub {}
		regsub -all $exp $display_hex $sub display_hex
	}

	# We now have a list of hex characters, one per column of display
	# puts "There are [llength $display_hex] columns to display"

	if {$device(mode)=="scroll"} {
	
		set delay [expr $device(pause) / $device(width)]
	
		# We can clean multiple zero columns when scrolling text
		set display_hex [clean $display_hex]

		# If there was a space on the end of the original text, add  a device-width of empty columns
		# This is important for scrolling text so that the text can disappear after display if the user has chosen this.
		if {$trailing_space} {
			for {set i 0} {$i < $device(width)} {incr i} {

				lappend display_hex "0x00"
			}
		}

	} else {
	
		set delay $device(pause)
	}

	# puts "padding input text with blank columns so there is a full frame of data available ahead of the text."
		set display_hex [linsert $display_hex 0 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00]
		set sequence 8

	# create the first frame of colour data to send to the LED frame buffer
	# We do not worry about rotation for this frame, as it is a full frame of colour
	# TODO: The sequence variable is not needed in the proc new_frame.  remove it.
	new_frame frame_data sequence

	# puts "display_hex has [llength $display_hex] columns" 
	# puts "current column:$sequence"

	while {$sequence < [llength $display_hex]} {
		add_page frame_data sequence display_hex $mode
		# add_column frame_data sequence display_hex
		
		# display the current frame
		set data ""
		append data $frame_data(0)$frame_data(1)$frame_data(2)$frame_data(3)$frame_data(4)$frame_data(5)$frame_data(6)$frame_data(7)
		# puts $data

		# Send this data to the frame buffer
		set_pixel 0 0 $data $device(syspath) $device(bpp) $device(width)
		if {$device(record)} {fb2gif}

		set test 0; after $delay {set test 1}; vwait test

		# if this is the last column, reset the pointer to the first column
		# puts 8 "endless = $endless.  sequence=$sequence display_length=[llength $display_hex]"
		if {$endless && $sequence >= [expr [llength $display_hex] - 1]} {

			# puts "restarting the sequence because we are in 'endless' mode"
			
			# if we are in scroll mode, we have padded the sequence with a frame of blanks to accomodate rotation calculations.  The sequence must be reset to the device(width) in that case.
			if {$mode == "page"} {set sequence 0} else {set sequence $device(width)}
		}
	}

	return "done."
}

# A procedure to generate a display from a list of named font characters.  
# This ususally requires a specially built font.  This procedure will lsearch the names in the font definition instead of string mapping them.
proc display_list display_text {

	global device

	# Create a list of hex codes
	set hex_display ""
	foreach i $display_text {
	
		set hex_code [lsearch $device(font_data) $i]
		# puts "($i):code found:$hex_code"
		if {$hex_code !=""} {
			append hex_display " " [lindex $device(font_data) [expr $hex_code + 1]]
		}
	}
	# puts $hex_display

	display $hex_display page 1
}

# See the Ceylon eyes!  Use one of the 4 built-in path definitions. 
# random
# display_path [lindex $device(path_list) end] true

# Make your own path.  Look at the examples below
# random
#display_path [list 00 09 18 27 36 45 54 63] true

######################################################################
# SCRIPTS FOR GRAPHICS DISPLAY NOT BASED ON FONT DEFINITIONS
######################################################################

# Find out some basic information about this frame buffer
proc fb_list {fb} {

  	set name "/sys/class/graphics/fb${fb}"
	set item_list [glob -directory $name *]
	puts "item_list = $item_list"

	foreach i $item_list {

		set command [list exec cat [file join $name $i]]
		# puts "command=$command"
		if {![catch {set data [eval $command]} ]} {
			puts "[file tail $i]: data was $data"
		}
	}
}

# fb_list

# ------------------------------------------------------------
# Investigate the contents of the memory

# set device(syspath)  "/dev/fb1"
# set device(bpp)   2
# set device(width) 8

proc set_pixel {x y colour device bpp width} {
	catch {eval {exec printf "$colour" | dd bs=$bpp seek=[expr $y * $width + $x] > $device}} err
	dump_screen
}

# A procedure that builds a single-colour screen and fills the LED frame buffer in a single operation 
proc wipe {{colour "black"}} {

	global device

	set colour [colour_lookup $colour]
	# puts "colour is now $colour"

	# Build the string
	set str ""
	for {set counter 0} {$counter<[expr pow($device(width),2)]} {incr counter} {append str $colour}
	# Write the whole string to the frame buffer (starting at 0,0)
	# Note that this does not account for rotation 
	set_pixel 0 0 $str $device(syspath) $device(bpp) $device(width)

	return
}

# Fill the matrix with random pixels 
proc random {} {
	
	global device
	catch {eval {exec cat /dev/urandom > $device(syspath)}} err
	dump_screen
}

# a procedure to create a display of graded colour, rotated at the given angle
proc colour_transition {{angle 45}} {

	global device

	# convert angle to radians
	set angle [expr $angle * 3.14159 /180.]

	set row_increment    [expr sin($angle) / $device(width)]
 	set column_increment [expr abs(cos($angle)) / $device(height)]
	# puts "increments: (row=$row_increment, col=$column_increment"

	set h ""
	for {set i 0} {$i < [expr $device(height) * $device(width)]} {incr i} {

		set row    [expr int($i / $device(height))]
		# puts "row=$row"
		set column [expr $i % $device(width)]
		# puts "colummn=$column"
		set value [expr ($column * $column_increment + $row * $row_increment)]

		if {$value > 1} {
	
			set value [expr $value - int($value)]
			
		} elseif {$value < -1.}  {

			set value [expr $value + abs(int($value)) +1.]			

		} elseif {$value < 0} {

			set value [expr $value +1]
		}
		
		lappend h $value
	}

	return $h
}

proc set_pixel_id {id colour fb bpp width} {

	global device

	# if the colour is a list with more than 3 elements (TODO: handle colours that are passed as 3-value list of rgb), assume that it is a string of properly formatted set of colour values that can be dumped directly to the frame buffer
	set exp {\\x([0-9a-fA-F]){2}}
	set result [regexp -all $exp $colour]
	# puts "result=$result"
	if {$result == [expr $device(height) * $device(width)* $device(bpp)]} {
		
			# puts "Received a full frame buffer of colour data"
			#this was a complete set of
			#redundant, do nothing			
			# set colour $colour

	} else { 
		# Look up the colour value (which takes into account the brighntess value)
		set colour [colour_lookup $colour]
	}

	# puts "inside proc set_pixel_id.  Colour=$colour"
	# check the rotation.  If non-zero, rotate the location for this pixel before display

	if {$device(rotation)==0} {

		if {[catch {eval {exec printf "$colour" | dd bs=$bpp seek=$id > $fb}} err]} {
			
			# puts $err
			
		} else {
		
				dump_screen			
		}

	} else {

		# puts "rotation=$device(rotation)"
		set rotation_matrix  [lindex [lsearch -index 0 -inline -integer -sorted $device(rotation_definitions) $device(rotation) ] 1]
		# puts "rotation_matrix=$rotation_matrix"
		set new_id [lsearch -inline $rotation_matrix $id]
		# puts "old_id=$id"
		# puts "new_id was: $new_id"
		if {[catch {eval {exec printf "$colour" | dd bs=$bpp seek=$new_id > $fb}} err]} {
			
			puts $err
			
		} else {
		
				dump_screen
		}		
	}
}

# A procedure to take an input list of hue values (0<= hue <=1) and display to the pixel matrix
proc set_pixel_list pixel_list {

	set counter 0
	global device
	set pixel_str ""

	foreach i $pixel_list {

		# puts "i=$i"
		set rgb_colour [hsv2rgb $i 1.0 1.0]
		# puts "rgb_colour=$rgb_colour"
		set colour [colour888to565 $rgb_colour]
		# puts "hex_colour=$colour"
		
		append pixel_str "$colour"

		# set_pixel_id $counter $colour $device(syspath) $device(bpp) $device(width) 
		
		incr counter
	}
	
		# puts "length of pixel list: [llength $pixel_str]"
		# Send the whole pixel list to the frame buffer starting at position 0
		set_pixel_id 0 $pixel_str $device(syspath) $device(bpp) $device(width) 
}

# Define some default paths.  In this case, they are paths that clear the entire board.
# These paths do not have to end at the same spot.
# Pixel Numbering used to define paths (and used by the memory buffer for displaying pixels)
# 00 0} 02 03 04 05 06 07
# 08 09 10 11 12 13 14 15
# 16 17 18 19 20 21 22 23
# 24 25 26 27 28 29 30 31
# 32 33 34 35 36 37 38 39
# 40 41 42 43 44 45 46 47
# 48 49 50 51 52 53 54 55
# 56 57 58 59 60 61 62 63
proc define_paths {} {

	global device
	set device(path_list) [list]
	# sequential path
	lappend device(path_list) [list 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63]
	# zig-zag from top to bottom
	lappend device(path_list)  [list 0 1 2 3 4 5 6 7 15 14 13 12 11 10 9 8 16 17 18 19 20 21 22 23 31 30 29 28 27 26 25 24 32 33 34 35 36 37 38 39 47 46 45 44 43 42 41 40 48 49 50 51 52 53 54 55 63 62 61 60 59 58 57 56]
	# spiral from outside to inside
	lappend device(path_list)  [list 000 8 16 24 32 40 48 56 57 58 59 60 61 62 63  55 47 39 31 23 15 7 6 5 4 3 2 1 009 17 25 33 41 49 50 51 52 53 54 46 38 30 22 14 13 12 11 10 018 26 34 42 43 44 45 37 29 21 20  19 027 35 36 28]
	# Ceylon eyes back and forth...
	lappend device(path_list) [list 17 18 19 20 21 22]
	# add more here!

	set path [list 0 1 2 3 4 5 6 7 14 21 28 35 42 49 56 57 58 59 60 61 62 63 54 45 36 27 18 9 0 8 16 24 32 40 48 56 49 42 35  28 21 14 7 15 23 31 39 47 55 63 54 45 36 27 18 9 0 1 2 3 4 5 6 7 15 23 31 39 47 55 63 62 61 60 59 58 57 56 48 40 32 24 16 8 0  8 16 24 25 26 27 28 29 30 31 23 15 7 6 5 4 12 20 28 36 44 52 60 61 62 63 55 47 39 38 37 36 35 34 33 32 40 48 56 57 58 59 51 43 35 27 19 11 3 2 1 0 1 2 3 4 5 6 7 15 14 13 12 11 10 9 8 16  17 18 19 20 21 22 23 31 30 29 28 27 26 25 24 32 33 34 35 36 37 38 39 47 46 45 44 43 42 41 40 48 49 50 51 52 53 54 55 63 62 61 60 59 58 57 56]
	append path " [lreverse [lrange $path 0 end-1]]"
	lappend device(path_list) $path

	# puts "[llength $device(path_list)] default paths defined."
	return
}

# A procedure to display a path variable
proc display_path {{path_list ""}} {

	global device	
	set path_list $device(path)
	set endless $device(endless)
	puts "endless path=$endless"
	set fade_steps $device(fade_steps)
	set fg_colour  $device(fg_colour)
	set bg_colour  $device(bg_colour)
	puts "fg_colour=$fg_colour.  bg_colour=$bg_colour"
	set pause      [expr $device(pause) / 8]

	# If the used didn't pass any list, grab all the default paths and use them.
	if {$path_list ==""} {

		puts "no path was passed to the 'display_path' procedure.  Using the [llength $device(path_list)] paths loaded in default."
		set path_list $device(path_list)
	}

	# We could be receiving a list of lists (multiple paths passed).  
	# Check for this case.  If not, then force the single list we have received into a nested list and continue
	# We are assuming that we haven't been passed a single pixel...

	if {[llength [lindex $path_list 0]] == 1} {

		puts "A single list of paths was provided as input"
		set path_list [list $path_list]
	}

	set counter 1
	set total_paths [llength $path_list]
	puts "The length of the path_list=$total_paths"
	# The loop parameter is only useful for the last item in a list.
	set loop_this_one false
	foreach path $path_list {

		# puts "working on path $counter of $total_paths paths"
		#  Is it the last path? Is the 'repeat forever' flag set?  
		if {$counter == $total_paths && $endless} {

			puts "Conditions set to loop this path"
			set loop_this_one true
		}

		# puts "Displaying path definition: $path"

		# If this path does not finish at its starting place, 
		# append it's reverse so that it returns to the starting place
		if {[lindex $path 0] != [lindex $path end]} {
			
			append path " "
			append path  " [lreverse [lrange $path 0 end-1]] " 
			# append path " [lreverse $path]"
			
		} else {
			
			# set path [lrange $path 0 end-1]
		}

		# puts "Displaying path definition: $path"

		# Iterate over each pixel and display the new pixel, 
		# TODO: figure out how to query the colour of a pixel, 
		# so the moving pixel can move through and replace the colour behind it.
		set element_counter 0
		set first_loop true
		for {set element_counter 0} {$element_counter <= [llength $path]} {incr element_counter} {

			set i [lindex $path $element_counter]
			set_pixel_id $i $fg_colour $device(syspath) $device(bpp) $device(width)
			if {$device(record)} {fb2gif}
			set test 0; after [expr $device(pause)/8] {set test 1}; vwait test	

			# Display the fading tail following the drawn pixel		
			# recolour the remaining pixels of the tail.  This works best when device(brighntess) = 10
			set temp_brightness $device(brightness)

			set drawn_list [list]
			for {set fade_counter 1} {$fade_counter <= $fade_steps} {incr fade_counter} {

				set brightness [expr round(($device(brightness) / ($fade_steps) * (($fade_steps + 0.) - ($fade_counter)))*10.)/10.]
				set device(brightness) $brightness

				#if it's not the first loop and fade_counter < $fade_steps, we should be erasing the tail at the end of the last loop
				if {!$first_loop && $element_counter <= [expr $fade_steps -1]} {

					# puts "erasing tail pixels left on the end of the last loop (element_counter=$element_counter<=[expr $fade_steps-1], fade_counter=$fade_counter)"
					set temp_id [lindex $path end-[expr - $fade_counter +1]]

				} elseif {$first_loop && $element_counter <= [expr $fade_steps -1]} {
					
					# puts "this tail pixel does not exist because it was never drawn (this is the first loop)"
					set temp_id [lindex $path [expr $element_counter - $fade_counter]]	
					
				} else {
					
					# puts "this is a pixel completely inside the current loop ($element_counter = $element_counter, fade_counter=$fade_counter)"
					set temp_id [lindex $path [expr $element_counter - $fade_counter]]	
				}

				# if this point has been drawn already, don't over-draw it (this is a case where the tail folds back on itself)
				pause_to_debug "did we draw this tail pixel already? '[lsearch -exact $drawn_list $temp_id]'"
				if {[lsearch -integer $drawn_list $temp_id] < 0} {

						lappend drawn_list $temp_id 
					
				} else {

						# puts "found an overlapping tail point.  Skipping"
						# jump to the next tail point
						# continue
				}

				# puts "fade (element:${element_counter},fade_counter:$fade_counter/$fade_steps): id=$temp_id brightness=$brightness (temp_id=$temp_id)"
				# puts "temp_id=$temp_id"

				# don't overwrite the current pixel, and don't draw this pixel if we are at a tail point before the beginning of the path
				if {$temp_id != [lindex $path $i] && $temp_id !=-1} {
					# Draw the pixel
					set_pixel_id $temp_id $fg_colour $device(syspath) $device(bpp) $device(width)
				}

				# Return the pixel after the tail to background colour
				if {$fade_counter == [expr $fade_steps -1]} {
					# Do something for the last fade step
					pause_to_debug "working on last pixel in fade_steps"
					set_pixel_id $temp_id $bg_colour $device(syspath) $device(bpp) $device(width)					
				}		

				# pause_to_debug "finished drawing an individual tail pixel.  Press enter to continue"
				pause_to_debug "fade (element:${element_counter},fade_counter:$fade_counter/$fade_steps): id=$temp_id brightness=$brightness (temp_id=$temp_id)"
			}

			# pause_to_debug "finished drawing tail"
			# return the brighntess variable to its initial value
			set device(brightness) $temp_brightness

			# set test 0; after $pause {set test 1}; vwait test

			if {$loop_this_one && $element_counter == [llength $path] && $first_loop} {

				# puts "FINISHED FIRST LOOP ####################################################################"

				set first_loop false
				set element_counter 0

			} elseif {$loop_this_one && $element_counter == [llength $path]} {
				
				# puts "FINISHED A SUBSEQUENT LOOP *************************************************"
				set element_counter 0				
			}

			# pause_to_debug "Finished element_counter:$element_counter.  Press enter to continue"
		}


		incr counter

	}

	puts "displayed paths"
	return
}

# -----------------------------------------------------------------------------------
# ROTATION PROCEDURES
# -----------------------------------------------------------------------------------

# Define what we mean by rotating the 8x8 matrix of bits

# Rotation lists are defined in the setup procedure, comments left here for documentation 
# rotation = 0
# 00 01 02 03 04 05 06 07
# 08 09 10 11 12 13 14 15
# 16 17 18 19 20 21 22 23
# 24 25 26 27 28 29 30 31
# 32 33 34 35 36 37 38 39
# 40 41 42 43 44 45 46 47
# 48 49 50 51 52 53 54 55
# 56 57 58 59 60 61 62 63
# set rotation_list(0) [list # 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63]

# rotation = 90
# 07 15 23 31 39 47 55 63
# 06 14 22 30 38 46 54 62
# 05 13 21 29 37 45 53 61
# 04 12 20 28 36 44 52 60
# 03 11 19 27 35 43 51 59
# 02 10 18 26 34 42 50 58
# 01 09 17 25 33 41 49 57
# 00 08 16 24 32 40 48 56

# set rotation_list(90) [list 7 15 23 31 39 47 55 63 6 14 22 30 38 46 54 62 5 13 21 29 37 45 53 61 4 12 20 28 36 44 52 60 3 11 19 27 35 43 51 59 2 10 18 26 34 42 50 58 1 9 17 25 33 41 49 57 0 8 16 24 32 40 48 56]

# rotation = 180
# 63 62 61 60 59 58 57 56
# 55 54 53 52 51 51 49 48
# 47 46 45 44 43 42 41 40
# 39 38 37 36 35 34 33 32
# 31 30 29 28 27 26 25 24
# 23 22 21 20 19 18 17 16
# 15 14 13 12 11 10 09 08
# 07 06 05 04 03 02 01 00
# set rotation_list(180) [list 63 62 61 61 59 58 57 56 55 54 53 52 51 51 49 48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0]

# rotation = 270
# 56 48 40 32 24 16 08 00
# 57 49 41 33 25 17 09 01
# 58 50 42 34 26 18 10 02
# 59 51 43 35 27 19 11 03
# 60 52 44 36 28 20 12 04
# 61 53 45 37 29 21 13 05
# 62 54 46 38 30 22 14 06
# 63 55 47 39 31 23 15 07
# set rotation_list(270) [list 56 48 40 32 24 16 8 0 57 49 41 33 25 17 9 1 58 50 42 34 26 18 10 2 59 51 43 35 27 19 11 3 60 52 44 36 28 20 12 4 61 53 45 37 29 21 13 5 62 54 46 38 30 22 14 6 63 55 47 39 31 23 15 7]

# This proc takes a list of 8, 2-byte characters
proc rotate_hex {input_hex rotation} {

	global device

	# convert hex to a 64-bit string
	set input_bin ""
	for {set x 0} {$x < 8} {incr x} {
	
		append input_bin [format %08b [lindex $input_hex $x]]
	} 

	# puts "input_hex=$input_hex"
	# puts "input_bin=$input_bin"
	
	set output_bin ""
	set rotation_list [lindex $device(rotation_definitions) [lsearch -index 0 $device(rotation_definitions) $rotation] 1]
	# puts "rotation_list = $rotation_list"

	foreach i $rotation_list {
	
		# puts "working on i=$i"
		append output_bin [string range $input_bin $i $i]
	}
	
	# puts "output_bin=$output_bin"

	# Convert back to 8-bit hex	
	set output_hex ""
	for {set x 0} {$x < 63} {incr x 8} {
		# puts "working on x=$x"

		set decimal_value [format %d [bin2int [string range $output_bin $x [expr $x+7]]]]
		# puts "decimal_value=$decimal_value"
		set hex_value [format "0x%2.2x" $decimal_value]
		# puts "hex_value=$hex_value"
		lappend output_hex $hex_value
	}
	
	# puts "output_hex=$output_hex"
	return $output_hex
}

# -----------------------------------------------------------------------------------
# IMAGE CAPTURE UTILITIES
# -----------------------------------------------------------------------------------

# dump the contents of the frame buffer to a file.
proc dump_screen {} {

	global device
	if {$device(record)} {

		# set command "cat $device(syspath) > image_$device(dump_counter).raw"
		set raw_file "$device(gif_tempname)[format %05d $device(dump_counter)].raw"
		# puts "Attempting to dump frame buffer to file:cat $device(syspath) > $raw_file"
		catch {eval {exec cat $device(syspath) > $raw_file} err}
		incr device(dump_counter)
	}
}

# A procedure to read the frame buffer dump file
# modified after http://wiki.tcl.tk/1599
proc fbfile_read filename {

	global device
	set line_length [expr $device(bpp) * $device(width)]
	set fp [open $filename]
	fconfigure $fp -translation binary
	set n 0
	set rows 0
	set image_data [list]
	while {![eof $fp]} {
		
		# Read one line of data
		set bytes [read $fp $line_length]
		incr rows
		set row_data [list]

		if {$bytes !=""} {
        
			set hex_list [hexdump $bytes]

				# Convert the colour, if necessary, and append to the row of colour
				switch -- $device(bpp) {

				  {2} {

					  # Colours are in 2-byte format
					  foreach {i j} $hex_list {
							set colour [colour565to888 ${i}${j}]
							lappend row_data #$colour	  
					  }
				  }	

				  {3} {

					# The colours are rgb format
					  foreach {r g b} $hex_list {
						# puts "colour=$colour"
						lappend row_data [list $r $g $b]
					  }
				  }

				  {4} {

					  # The colours are in 4-byte format (RGB?)
					  foreach {r g b x} $hex_list {
						lappend row_data [list $r $g $b $x]
					  }
				  }
				}

			incr n $line_length
			if {[expr $n % 1000] == 0} {puts "read $n byes read (in $rows rows) from the screen dump file. There are now [llength $image_data] rows of pixel definitions in the image data."}

			# Append this list to the master list of image data
			lappend image_data [string map {\{ "" \} ""} $row_data]
			# puts "read $n bytes.  This row has [llength $row_data] pixels.  Image now has [llength $image_data] rows"
		}
    }
 
    close $fp
    # puts "There are [llength $image_data] rows of pixel definitions in the input file.  Read $rows rows."
    return $image_data
 }
 
 proc hexdump string {
    binary scan $string H* hex
    regexp -all -inline .. $hex
 }

# bin2hex --
#   converts binary to hex number
# Arguments:
#   bin		number in binary format
# Returns:
#   hexadecimal number
#
# from http://code.activestate.com/recipes/146037-bits-to-hex-and-back/
proc bin2hex bin {
    ## No sanity checking is done
    array set t {
	0000 0 0001 1 0010 2 0011 3 0100 4
	0101 5 0110 6 0111 7 1000 8 1001 9
	1010 a 1011 b 1100 c 1101 d 1110 e 1111 f
    }
    set diff [expr {4-[string length $bin]%4}]
    if {$diff != 4} {
        set bin [format %0${diff}d$bin 0]
    }
    regsub -all .... $bin {$t(&)} hex
    return [subst $hex]
}

# hex2bin --
#   converts hex number to bin
# Arguments:
#   hex		number in hex format
# Returns:
#   binary number (in chars, not binary format)
# from http://code.activestate.com/recipes/146037-bits-to-hex-and-back/
#
proc hex2bin hex {
    set t [list 0 0000 1 0001 2 0010 3 0011 4 0100 \
	    5 0101 6 0110 7 0111 8 1000 9 1001 \
	    a 1010 b 1011 c 1100 d 1101 e 1110 f 1111 \
	    A 1010 B 1011 C 1100 D 1101 E 1110 F 1111]
    regsub {^0[xX]} $hex {} hex
    return [string map -nocase $t $hex]
}

# hex2bin-alternate --
#   converts hex number to bin
# Arguments:
#   hex		number in hex format
# Returns:
#   binary number (in chars, not binary format)
#
# from http://code.activestate.com/recipes/146037-bits-to-hex-and-back/
proc bin2hex-alternate bin {
    ## No sanity checking is done
    set t {
	0000 0 0001 1 0010 2 0011 3 0100 4
	0101 5 0110 6 0111 7 1000 8 1001 9
	1010 a 1011 b 1100 c 1101 d 1110 e 1111 f
    }
    set diff [expr {4-[string length $bin]%4}]
    if {$diff != 4} {
        set bin [format %0${diff}d$bin 0]
    }
    return [string map $t $hex]
}

# A procedure to take a colour in 2-byte hex format and turn it to 3-byte hex format
proc colour565to888 colour {

	# swap the hex digits
	set old_colour $colour
	set colour [string range $colour 2 3][string range $colour 0 1]
	# puts "old_colour=$old_colour, colour=$colour"

	# puts "got colour=$colour to convert"
	# convert hex characters to binary format
	set bin [hex2bin $colour]
	# set bin [format "%016b" ${colour}]
	# puts "bin=$bin (length=[string length $bin]"

	# extract 5-bits, 6-bits 5-bits
	set r [string range $bin 0 4]
	set r [bin2int $r]
	set r [expr round($r * 255. / 31.)]
#	set r [format \\x"%2.2x" $r]
	# puts "r=$r"

	set g [string range $bin 5 10]
	set g [bin2int $g]
	set g [expr round($g * 255. / 63.)]
#	set g [format \\x"%2.2x" $g]
#	puts "g=$g"

	set b [string range $bin 11 15]
	set b [bin2int $b]
	set b [expr round($b * 255. / 31.)]
#	set b [format \\x"%2.2x" $b]
#	puts "b=$b"
	
	# RGB FORMAT
	set hex [format %2.2X $r][format %2.2X $g][format %2.2X $b]
	# puts "input=$colour, rgb=($r,$g,$b), hex=$hex"
	return $hex
}

# A script to render individual pixels in a tiny display into a larger image when
# saved to an image file, according to a given template. If no template supplied,
# a circle is used.
 
proc custom_pixel {pixel_data {template ""}} {
	 
	global device
	set height $device(height)
	set width $device(width)	
	set bg_colour "#000000"
	if {$template == ""} {set template $device(pixel_render)}
	
	# Check whether the render template is a reference to a font item
	# Look this up in the font file.  If it is found, use it.

	# It is possible that the font file has not been loaded because we are doing a font lookup out of sequence
	if {$device(font_data) ==""} {load_font $device(font)}
	
	if {[set check [lsearch  $device(font_data) $template]]!=-1} {
		# puts "Found the pixel_render template ($template) in the font file (check=$check)"

		# Use the lookup value, but but only if it is a lookup value (even numbered list entries).  
		# The template provided might also be one of the hex definitions already in the file. 
		if {[expr $check % 2]==0} {

			# Fonts are stored in memory rotated by 270 degrees.  Rotate back 90 degrees to use them here.
			set template [rotate_hex [lindex $device(font_data) [expr $check + 1]] 90 ]
		}

	} else {

		# puts "didn't fine '$template' in the font definition"
		# Assume that the default value is a valid hex definition
		# Do nothing
	}
	# puts "pixel template=$template"

	set template_rows [llength $template]
	# puts "template=$template"

	set new_pixels ""
	# iterate over each row of pixels in the original file
	for {set row 0} {$row < $height} {incr row} {
		
		# puts "row=$row"
		# grab the current row of pixel data
		set current_row [lindex $pixel_data $row]
		
		# iterate over each row of the template
		for {set template_row 0} {$template_row < $template_rows} {incr template_row} {

			set new_row ""

			# iterate over each individual pixel in this row			
			# puts "template_row=$template_row"

			# iterate over each of the pixels in our current row of pixel data
			for {set pixel 0} {$pixel < $width} {incr pixel} {

				# what is the colour of this pixel?
				set fg_colour [lindex $current_row $pixel]
				# puts "fg_colour=$fg_colour"

				# what is the hex value for this row definition in the template?
				set hex_val [lindex $template $template_row]
				set bin_val [hex2bin $hex_val]
				set bin_val [split $bin_val ""]
				# puts "bin_val=$bin_val"

				# map the colours to the zeros and ones of this pixel definition
				set this_pixel [lmap temp $bin_val {string map "0 $bg_colour 1 $fg_colour" $temp}]
				# puts "this_pixel=$this_pixel"

				foreach i $this_pixel {	lappend new_row $i}
			}

			# puts "new_row is now:$new_row"
			# We now have a complete row of pixel data.  Append it to the image data
			lappend new_pixels $new_row 				
		}
	}
	
	return $new_pixels
}

# A script to export the current frame buffer to a .gif file
proc fb2gif {{filename ""}} {

	global device	

	if {$filename == ""} {

		# The raw file does not exist already, create one by dumping the frame buffer to file
		# create the dump file
		incr device(dump_counter)
		puts "device(dump_counter) is now: $device(dump_counter)"
		set raw_file "[file root $device(gif_tempname)][format %05d $device(dump_counter)].raw"
		set gif_file "[file root $device(gif_tempname)][format %05d $device(dump_counter)].gif"
		catch {eval {exec cat $device(syspath) > $raw_file} err}

	} else {

		# We received the name of a raw file that exists on disk already.
		set raw_file $filename
		set gif_file "[file rootname $filename].gif"
	}

	# puts "raw_file=$raw_file"
	# puts "gif file=$gif_file"

	set image_data [fbfile_read $raw_file]

	# The calling procedure has already called the Tk package
	# Create an image handle and fill it with data
	set my_image [image create photo]
	
	# Render each input pixel according to a template.  
	set image_data [custom_pixel $image_data]	

	# load the image data into our image handle
	$my_image put $image_data
	$my_image write -format gif $gif_file

#	# Make another new image, and copy our original image at the size that we want
#	# (The original image is only 8x8 pixels)
# 	set new_image [image create photo]
#	$new_image copy $my_image -zoom $device(gif_zoom)

#	# Save this to file
#	$new_image write -format gif $gif_file

	# Delete the dump file
	catch {file delete $raw_file} err

	# Clear the image data from memory
	unset image_data

	return
}

# ----------------------------------------------------
# Create the final animated .gif file
# dependency: imagmagick
proc gif_assemble {} {

	puts "Processing the output gif animation,"
	global device

	# Convert all the raw files into individual gif files, if it has not been done already
	# If the user manually called fb2gif during execution, this is not necessary.
	if {![catch {set convert_list [lsort -increasing -dictionary [glob [file root $device(gif_tempname)]*.raw]]   } err ]} {
		
		foreach i  $convert_list {
		
			fb2gif $i
		}		
	}

	# Call the ImageMagick executable to stitch all the individual files together
	# If you don't have this installed, use 'sudo apt-get install imagemagick'
	# to install it

	set output_file [file root $device(gif_output)].gif

	# delay is different, depending on the mode
	if {$device(mode) == "page"} {set delay 100} else {set delay 4}

	# Other options: -layers OptimizePlus
	set command [list exec convert -loop 0  -set delay $delay -transparent-color black "[file root $device(gif_tempname)]*.gif" $output_file]
	if {[catch {eval $command} err ]} {

		puts "can't run ImageMagick to create animated gif.  Error was:$err"	

	} else {
	
		puts "display exported to animated gif: $output_file"

		# Delete any temporary gif files (if they still exist)
		set pattern "[file root $device(gif_tempname)]*.gif"
		puts "file delete pattern:$pattern"	
		set delete_list [lsort -increasing -dictionary [glob $pattern]]
		puts "There are [llength $delete_list] .gif files in the delete_list"
		
		if {![catch { set delete_list [lsort -increasing -dictionary [glob $pattern]] } err]} {
		
			foreach i $delete_list {

				if {[catch {file delete $i} err ]} {

					puts "couldn't delete the temporary gif file:$i.  Error was:$err"
				}
			}
		} else {
			
				puts "didn't find any .gif files of the pattern '$pattern' to delete"
			
		}
		
	}

	return
}

# This function is available to allow calling scripts to reset defaults as necessary.
load_defaults

