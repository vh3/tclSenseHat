# lps25h.tcl - script to exercise the temperature/pressure functions of the ST Electonics LSP25H sensor
# Device: LPS25H temperature/pressure sensor at i2c bus 1 address 0x5c.  
# The sensor tested here is part of the SenseHat (https://www.raspberrypi.org/products/sense-hat/) for a Raspberry Pi.
# I2C scripting example using piio package
# vh, 15 April 2017
# 
# Reference material - st.com has created great reference material.  This script was made with the documentation provided here:
# A.  LPS25H data sheet - http://www.st.com/resource/en/datasheet/lps25h.pdf
# B.  How to interpret temperature and pressure reading for the LPS25H - http://www.st.com/resource/en/technical_note/dm00242306.pdf
# C.  Hardware and software guidelines for use of LPS25H pressure sensor http://www.st.com/content/ccc/resource/technical/document/application_note/a0/f2/a5/e7/58/c8/49/b9/DM00108837.pdf/files/DM00108837.pdf/jcr:content/translations/en.DM00108837.pdf
# ---------------------------------------------------------------------------------------------------------------

# a procedure to round a real input value to a specified number of decimal places
proc round {value {num_dec 1}} {

        return [expr round($value * pow(10, $num_dec)) / pow(10,$num_dec)]
}

# A procedure to add two unsigned binary numbers (after https://wiki.tcl-lang.org/21842)
# this procedures assumes input values in big-endian format
proc bin_add {n1 n2} {
    set sum {}
    set carry 0 
    # reverse the binary string into little-endian format and work through all digits from smallest-to-largest digit
    # puts "[lreverse [split $n1 ""]]  [lreverse [split $n2 ""]]" 
    foreach d1 [lreverse [split $n1 ""]] d2 [lreverse [split $n2 ""]] {
        switch -- [string map {0 ""} "$d1$d2$carry"] { 
            ""  { lappend sum 0; set carry 0}
            1   { lappend sum 1; set carry 0}
            11  { lappend sum 0; set carry 1}
            111 { lappend sum 1; set carry 1}
        } 
    } 

    lappend sum $carry 
    return [string trimleft [join [lreverse $sum] ""] 0] 
}

# convert binary (unsigned binary format) to decimal integer (after https://wiki.tcl-lang.org/1591)
# this proc checks for sign bit set, and performs 2's complement if necessary
proc bin2dec bin {

    if {$bin == 0} {
        return 0 
    } elseif  {[string index $bin 0] == 1} {
        # If the first bit is set, it means that this is a negative number.  Take the 2's complement.
        set sign "-"
        set bin [string map {0 1 1 0}  $bin]
        set bin [bin_add $bin "1"]

    } else {
        set sign +
    }
  
    set mod [expr {[string length $bin]%8}]
    if {$mod} {
        set mod [expr {8-$mod}]
    }
    set bin [string repeat 0 $mod]$bin
    set len [string length $bin]
    set bin [binary format B* $bin]
    #the else block could do it all, but for illustration...
    if {$len<=8} {
        binary scan $bin cu res
    } elseif {$len <=16} {
        binary scan $bin Su res
    } elseif {$len <=32} {
        if {$len <= 24} {
            set bin [binary format B* 0]$bin
        }
        binary scan $bin Iu res
    } else {
        set res 0
        set blen [expr {$len/8}]
        set pos -1
        while {$blen} {
            incr blen -1
            binary scan $bin x[incr pos]cu next
            set res [expr {$res + $next*(2**($blen*8))} ]
        }
    }
    return $sign$res
}

# A formula provided in reference #3 for calculating altitude from pressure based on US standard atmosphere, 1976
proc From_Pressure_hPa_To_Altitude_US_Std_Atmosphere_1976_m {pressure} {

        set altitude_ft [expr (1. - pow( ($pressure / 1013.25) , 0.190284) ) * 145366.45]
        set altitude_m [expr $altitude_ft / 3.280839895]
        return $altitude_m
}

set result [package require piio]
puts "package piio loaded: $result"

# Get a handle to this device
set bus 1
set address 0x5c; # aka 0x5c
if {[catch {set i2c_h [twowire twowire $bus $address]} err ]} {

        puts "Couldn't get a handle to device at address $address"
        return
}

puts "found device at address=$address (handle=$i2c_h)"

#1  Power down the device (clean start) – WriteByte(CTRL_REG1_ADDR = 0x00); // @0x20 = 0x00  
twowire writeregbyte $i2c_h 0x20 0x00

#2 Turn on the pressure sensor analog front end in single shot mode – WriteByte(CTRL_REG1_ADDR = 0x84); // @0x20 = 0x84
twowire writeregbyte $i2c_h 0x20 0x84

#3 Run one-shot measurement (temperature and pressure), the set bit will be reset by the sensor itself after execution (self-clearing bit) – WriteByte(CTRL_REG2_ADDR = 0x01); // @0x21 = 0x01
twowire writeregbyte $i2c_h 0x21 0x01

#4 Wait until the measurement is completed – ReadByte(CTRL_REG2_ADDR = 0x00); // @0x21 = 0x00

set result 0
while {!$result} {
        after 50 {set data [twowire readregbyte $i2c_h 0x21]}
        vwait data
        # puts "byte read=[format %08b $data]"
        if {$data == 0} {set result 1}
}

puts "TEMPERATURE"

# 5. Read the temperature measurement (2 bytes to read) – Read((u8*)pu8, TEMP_OUT_ADDR, 2); // @0x2B(OUT_L)~0x2C(OUT_H)
set register_0x2b [twowire readregbyte $i2c_h 0x2b]
set register_0x2c [twowire readregbyte $i2c_h 0x2c]
puts "  register_0x2b=[format %2.2X $register_0x2b]([format %08b $register_0x2b]), register_0x2c=[format %2.2X $register_0x2c]([format %08b $register_0x2c])"

# – Temp_Reg_s16 = ((u16) pu8[1]<<8) | pu8[0]; // make a SIGNED 16 bit variable
puts "  register data: 0x[format %2.2X $register_0x2c][format %2.2X $register_0x2b]=[format %08b $register_0x2c][format %08b $register_0x2b]"
puts "  output=[set output [bin2dec [format %08b $register_0x2c][format %08b $register_0x2c]]]"

# Alternative: readregword - this does not seem to work (both bytes 'read' are identical)
# set temp_registers [twowire readregword $i2c_h 0x2b]
# puts "  register data: 0x[format %4.4X $temp_registers]=[format %016b $temp_registers]"
# puts "  output2=[set output [bin2dec [format %08b $temp_registers]]]"

# – Temperature_DegC = 42.5 + Temp_Reg_s16 / 480; // offset and scale
puts "  temperature value=[round [expr 42.5 + $output/480.]] degrees Celcius"

puts "PRESSURE"

# 6.  Read the pressure measurement – Read((u8*)pu8, PRESS_OUT_ADDR, 3); // @0x28(OUT_XL)~0x29(OUT_L)~0x2A(OUT_H)
set register_0x28 [twowire readregbyte $i2c_h 0x28]
set register_0x29 [twowire readregbyte $i2c_h 0x29]
set register_0x2a [twowire readregbyte $i2c_h 0x2a]
puts "  register_0x28=[format %4.4X $register_0x28]([format %08b $register_0x28]), register_0x29=[format %4.4X $register_0x29]([format %08b $register_0x29]), register_0x2a=[format %4.4X $register_0x2a]([format %08b $register_0x2a])"

# – Pressure_Reg_s32 = ((u32)pu8[2]<<16)|((u32)pu8[1]<<8)|pu8[0]; // make a SIGNED 32 bit
puts "  output=[set output [bin2dec [format %08b $register_0x2a][format %08b $register_0x29][format %08b $register_0x28]]]"

# – Pressure_mb = Pressure_Reg_s32 / 4096; // scale
puts "  pressure value=[set pressure [round [expr $output / 4096.] 2 ]] hPa (1 atmosphere at sea level =1013.25 hPa)"
# According to https://www.thoughtco.com/low-and-high-pressure-1434434, normal global pressure ranges are 980 to 1050 hPa

# 7. Check the temperature and pressure values make sense – Reading fixed 760 hPa, means the sensing element is damaged.
if {$output == 760} {puts "  the pressure meter is reading 760 hPa.  It is possibly damaged."}

puts "ALTITUDE"

# Convert pressure to altitude
puts "  Approximate altitude: [round [From_Pressure_hPa_To_Altitude_US_Std_Atmosphere_1976_m $pressure]]m"
# These calculations jive with those at: https://www.weather.gov/epz/wxcalc_pressurealtitude

puts "done."
 
close $i2c_h
