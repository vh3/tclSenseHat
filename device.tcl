 # device.tcl - a script to parse parameters from device calls
# vh, 30 April 2017
# ----------------------------------------------------------------------
source SenseHat.tcl

package require cmdline

proc device {action args} {
	
		global device
	
		# TODO: implement a namespace for configuration variables

		# The first arg could be a data string. Check this out.  
		set first_arg [lindex $args 0]
		if {[string index $first_arg 0] != "-"} {
		
			puts "This call had a data item as its first argument: data"
			set device(data) $first_arg
			set args [lrange $args 1 end]			
			puts "args are now:$args"			
		}

		set user_args $args
		puts $args

		set options {
			{name.arg         ""       "Name to be used to refer to this device.  TODO: auto setup various parameters from the name"}
            {data.arg         ""       "Data to be displayed.  If data is specified, will consume all other parameters, then attempt to display data."}
            {font.arg         1        "font name to load. Will look for a filename called font${arg}.tcl to load.  Font will be loaded immediately."}
			{font_file.arg    ""        "A filename from which to load font data.  Font will be loaded immediately."}
			{font_data.arg    ""        "The font definition data, a list of 2-parameter list \{charname \{8 X hex, format(0x%4.4X)\}\}).  Usually set by software"}
            {fg_colour.arg    "white"  "colour name"}
            {bg_colour.arg    "white"  "colour name"}
            {pause.arg        500      "pause after display, milliseconds for page display.  pause/8 is used for scrolling display."}
            {delay.arg        500      "delay before display, milliseconds"}
            {bpp.arg              2        "bytes of colour per pixel"}
            {colour_bytes.arg     2        "count of bytes used to define colours"}
            {colour_data.arg      ""       "colour data"}
			{rotation.arg         "0"        "rotation of screen.  Valid values: 0, 90, 180, 270"}
			{transform_matrix.arg  ""     "raw transformation mapping matrix data."}
			{syspath.arg             "/graphics/fb1" "path to frame buffer.  Usually set by software"}
			{reset.arg        ""        "reset the given arg parameter to default"}
			{reset            ""        "reset all parameters to default"}
			{font_data.arg    ""        "The font definition data, a list of 2-parameter list \{charname \{8 X hex, format(0x%4.4X)\}\}).  Usually set by software"}
			{width.arg        ""        "device width, which is also the frame buffer width.  Usually set by software."}
			{height.arg       ""        "device width, which is also the frame buffer width.  Usually set by software."}
			{method.arg       ""        "Communication method for this device.  Allowable values: fb, gpio, i2c, spi"}
			{package_gpio.arg "piio"    "The package used to interface with gpio hardware"}
			{package_i2c.arg  "piio"    "The package used to interface with i2c hardware"}
			{package_spi.arg  "piio"    "The package used to interface with spi hardware"}
			{brightness.arg   8         "pixel brighness, on a scale from 1 to  \$device(max_brighness)."}
			{brightness_max.arg 10         "The max pixel brighness.  This allows the users to define the brighness scale"}
			{mode.arg         "scroll"    "display mode.  valid value: scroll, page"}
			{endless          "false"    "repeat the display of input data endlessly? boolean"}
			{record            "false"  "capture the output of this action to an animated gif. boolean"}
			{path.arg          ""       "current user-defined pixel display path"}
			{path_list         ""       "a nested list of predefined pixel display paths"}
			{fade_steps.arg       "1"     "for path display, the number of pixels it takes to fade to zero brightness"}
			{debug             "false"   "this flag will stop the execution of scripts at predefined points and display appropriate messages."}
        }

        # puts "options=$options"

        set usage ": device <action>  \[options] ...\noptions:"

#		# If the user selected the help option, display the useage text.
#		if {[catch {array set options [cmdline::getoptions ::argv $parameters $usage]}]} {puts [cmdline::usage $parameters $usage]}
        
        try {
            array set params [::cmdline::getoptions args $options $usage]

        } trap {CMDLINE USAGE} {msg o} {
            # Trap the usage signal, print the message, and exit the application.
            # Note: Other errors are not caught and passed through to higher levels!
			puts $msg
			exit 1
        }

		# strip out any parameter items that were not provided by the user
		# puts "attempting to remove unspecified parameters from cmdline return"
		foreach i [array names params] {

				# puts "checking $i: [lsearch $user_args -$i]"
				if {[lsearch $user_args "-${i}"] ==-1} {
					
					# puts "removing parameter $i because it was not specified by the user"
					unset params($i)					
				}
		}

        puts "parameters received: [array names params]"

		set action_flag 0

		# If the action requested it "get", display whatever was requested and end.
		if {$action=="get"} {

			foreach i [array names params] {				
					# This parameter might not be set, so we have to catch the error
					if {[catch {puts -nonewline "$device($i) "} err ]} {puts ""}
			}

			puts ""
			exit 1
		}
		
		# Cycle through each of the input parameters and do what is required with it.
        foreach i [array names params] {
		
				switch -exact -- $i {
				  {data} {

					  # puts "working on $i: $params($i)"

					  set device(data) $params($i)
					  # data has been provided, so continue to display function after all other parameters have been considered."
					  set action_flag 1
				  }

				  {font} {

					  # puts "working on $i: $params($i)"
					  set device(font) $params($i)
					  # TODO: load the font
				  }

				  {font_file} {
					  
						puts "working on $i: $params($i)"
						set device(font) $params($i)
						# TODO: load the font file
				  }

				  {font_data} {
					  
					  puts "working on $i: $params($i)"
					  # TODO: Figure out what we want to do.  Should we validate, then replace the font definitions?
				  }				  

				  {fg_colour} {
					  
					  puts "working on $i: $params($i)"
					  # TODO: validate the colour entered
					  set device(fg_colour) $params($i)					  
				  }

				  {bg_colour} {
					  
					  puts "working on $i: $params($i)"
					  # TODO: validate the colour entered
					  set device(bg_colour) $params($i)
				  }

				  {pause} {
					  
					  # puts "working on $i: $params($i)"
					  set device(pause) $params($i)
					  
				  }

				  {bpp} {puts "working on $i: $params($i)"}

				  {colour_bytes} {puts "working on $i: $params($i)"}

				  {colour_data} {puts "working on $i: $params($i)"}

				  {rotation} {

					  puts "working on $i: $params($i)"
					  set device(rotation) $params($i)					  
				  }

				  {transform_matrix} {puts "working on $i: $params($i)"}


				  {syspath} {
					  
					  # puts "working on $i: $params($i)"
					  set device(syspath $params($i)
				  }


				  {path} {
					  
					  # puts "working on $i: $params($i)"
					  
					  # if we have received non-integer, this must be a call for a pre-defined path definition
					  # TODO: add this check
					  
					  # if this is a list of integers, add this as a path definition
					  set device(path) $params($i)

					  # take note that we will action this command once we have consumed all the parameters 
					  set action_flag true
				  }

				  {path_list} {

					  # puts "working on $i: $params($i)"	
					  # TODO: do we need this?
				  }

				  {delay} {puts "working on $i: $params($i)"}

				  {reset} {puts "working on $i: $params($i)"}
				  
				  {height} {puts "working on $i: $params($i)"}

				  {width} {puts "working on $i: $params($i)"}
				  
				  {method} {puts "working on $i: $params($i)"}
				  
				  {package_gpio} {puts "working on $i: $params($i)"}
				  {package_i2c} {puts "working on $i: $params($i)"}
				  {package_spi} {puts "working on $i: $params($i)"}
				  {name} {
					  
					  # puts "working on $i: $params($i)"
					  set device(name) $params($i)
				  }

				  {bg_brightness} {

					  # puts "working on $i: $params($i)"					  
						set device(bg_brighness) $params($i)
				  }

				  {fg_frightness} {

					  # puts "working on $i: $params($i)"
						set device(fg_brighness) $params($i)
				   }

				  {brightness} {

					  puts "working on $i: $params($i)"
					  set device(brightness) $params($i)
				  }
				  {brightness_max} {
					  
					  puts "working on $i: $params($i)"
					  set device(brightness_max) $params($i)					  
				  }
				  
				  {endless} {
					  
					  puts "working on $i: $params($i)"
					  set device(endless) $params($i)
				  }
				  
				  {mode} {

					  # TODO: validate mode
					  puts "working on $i: $params($i)"
					  set device(mode) $params($i)
				  }
				  
				  {record} {
					  
					  puts "working on $i: $params($i)"
					  set device(record) $params($i)
					  
					  # load the Tk package (needed for the gif file manipulation
					  package require Tk
					  wm withdraw .
				  }

				  {fade_steps} {
					  
					  # puts "working on $i: $params($i)"
					  set device(fade_steps) $params($i)					  
				  }
				  
				  {debug} {
					
					set device(debug) $params($i)  

				  }
		
				  {default} {return -code error "discovered parameter $i: should not be able to get here."}
				}				
		}		

		# Consistency checks - some parameters cannot be used together	
		# -data and -path - we can only do one at a time...
		
		# Do something for each action
		switch -exact $action {
		  {config} {
			  
			  puts "action received is config"
			  # No more action is required.
			  
			  # TODO: If a -data item was received, should we just go ahead and display?
			  if {[info exists $params(data)} {puts "a display -data item was given."}
		  }
		  
		  {get} {
			  
			  # TODO: figure out how to properly implement the get command (the way the cmdline procedure is implemented, it demands parameters for all the values, so this command cannot be used... )
			  puts "action received is get"
			  
		  }
		  
		  {display} {
			  
			  set action_flag 1

			  puts "action received is display"			  
			  if {$action_flag} {
				
				# The input received includes a request for action.  Execute
				# the display function with all the parameters that have been set.


				if {[lsearch [array names params] "path"] !=-1} {

					# puts "executing the 'display' command with -path attribute"
					# puts "rotation is:$device(rotation)"
					# puts "path is: $device(path)"
					display_path $device(path)
					
				} else {
					
					puts "executing the 'display' command with -data attribute"
					puts "rotation is:$device(rotation)"
					display $device(data)
				}
								
				# Cleanup after the display is finished				
				if {$device(record)} {
					
					# look for .raw frame buffer dump files and assemble them into an animated gif
					if {[catch {gif_assemble} err]} {
				
							puts "unable to assemble animated gif file.  Error was:$err"					
					}
				}
			  }
		  }
		  
		  {default} {error "Error: valid keywords for 'device' command are:  config, get, display.  Got '${action}'"}     
		}

		return	
}

# -----------------------------------------------------------------------------------------------
# Testing examples

# device display -help

# device display

# device display -data "Example" -font 1 -fg_colour blue -bg_colour black -pause 100 -rotation 0

# device display "example text" -fg_colour red -bg_colour "white" -pause 500 -rotation 90

# device config -font 1 -fg_colour blue -bg_colour black -pause  100 -sleep 222 -colour_bytes 2 -rotation 0

# ----------------------------------------------------------------------
