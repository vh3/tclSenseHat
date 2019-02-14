 # load_font.tcl
# A script to load an assembler format font file (.asm)
# and convert it to a Tcl flat list of the format:
# A {0x00  0x00  0x7C  0x12  0x12  0x7C  0x00  0x00}
# where each hex number represents a column of 8 bits in the 8x8 font character display. 

# source the output file to load the font as a string into variable 'font_data'
# which can be use in a [string map $input_text] command

# Create .asm files with the 8x8 font editor tool found at:
# https://www.min.at/prinz/o/software/pixelfont/
# vh, 24 Apr 2017

# discover font files in the current directory
set filename_list [glob *.asm]

foreach filename $filename_list {

	# load and parse the file
	# set filename "TINYTYPE_rotated.asm"
	set fh [open $filename r]
	set chardata ""
	set row_data ""
	set font_data ""

	# strip out the 3 header rows
	gets $fh; gets $fh; gets $fh

	while {![eof $fh]} {
	
		set temp_data [gets $fh]
		# get the character_id
		set index [string range $temp_data 5 7]
		set chardata [split [string range $temp_data 13 58] ","]
		set char [string range $temp_data 63 63]
		if {$char=="."} {set char {}}
		# set row_data "$char [join $chardata]"
		# puts "row_data=$row_data"
		lappend font_data $char [join $chardata]
	}

	close $fh

#	# is the last row a blank entry?
#	if {[lindex [lindex $font_data end] 0] == ""} {
#		set font_data [lrange $font_data 0 end-1]
#	}

	set output_file "${filename}.tcl"
	set fh [open $output_file w]
	puts $fh "# Font source: 	https://www.min.at/prinz/o/software/pixelfont/"
	
	puts $fh "# An 8x8 pixel ascii font definition file in Tcl list format"
	puts $fh "# Modified from fonts from:" 
	puts $fh "# 	https://www.min.at/prinz/o/software/pixelfont/"
	puts $fh "# character data is organized by columns of pixels,"
	puts $fh "# intended for a horizontal scolling display"
	puts $fh ""

	puts $fh "set font_data \[list \\"

	foreach {i j} $font_data {

		if {[string trim $j] != ""} {

			puts $fh "[list $i] [list "$j "] \\"
		}
	}

	puts $fh "\]"
	puts $fh {puts "Font character definitions loaded: [expr [llength $font_data] / 2]"}

	close $fh
	puts "font data outputted to file $output_file"
}
