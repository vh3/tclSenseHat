# ex5.tcl
# A demo with moving pixels managed by threads
# vh, 9 May 2017

# Dependency: package Thread (to get it on the Raspberry Pi: sudo apt-get install tclthread)
puts "thread package: [package require Thread]"
# set device(record) true

# Create a set of threads
set num_threads 6
for {set i 1} {$i <= $num_threads} {incr i} {	
	set threads($i) [thread::create {source device.tcl; thread::wait}]
}

# Execute some concurrent pixel movement.  We will use a single path and successively launch pixels on this path. 

set path [list 0 1 2 3 4 5 6 7 14 21 28 35 42 49 56 57 58 59 60 61 62 63 54 45 36 27 18 9 0 8 16 24 32 40 48 56 49 42 35  28 21 14 7 15 23 31 39 47 55 63 54 45 36 27 18 9 0 1 2 3 4 5 6 7 15 23 31 39 47 55 63 62 61 60 59 58 57 56 48 40 32 24 16 8 0  8 16 24 25 26 27 28 29 30 31 23 15 7 6 5 4 12 20 28 36 44 52 60 61 62 63 55 47 39 38 37 36 35 34 33 32 40 48 56 57 58 59 51 43 35 27 19 11 3 2 1 0 1 2 3 4 5 6 7 15 14 13 12 11 10 9 8 16  17 18 19 20 21 22 23 31 30 29 28 27 26 25 24 32 33 34 35 36 37 38 39 47 46 45 44 43 42 41 40 48 49 50 51 52 53 54 55 63 62 61 60 59 58 57 56]; append path " [lreverse [lrange $path 0 end-1]]"
set colours [list white red pink orange yellow green blue indigo violet purple]

foreach i [lsort -integer -increasing [array names threads]] {

	set test 0;after 1000 {set test 1};vwait test	
	set command [list set device(pause) 1]
	thread::send $threads($i) $command
	thread::send $threads($i) {set device(fade_steps) 1}
	set colour [lindex $colours $i]
	set command [list device display -endless -path $path -fg_colour $colour]
	thread::send -async $threads($i) $command
}

#  Now, create a thread to display some text
set text_thread [thread::create {source device.tcl;thread::wait}]
thread::send -async $text_thread {device display -data "This is some text" -fg_colour "white" -bg_colour "black"}

vwait forever
