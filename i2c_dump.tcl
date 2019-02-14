# i2c_dump.tcl
# A script to iterate over all i2c busses, addresses and registers in sequence and dump their contents to stdout
# vh, 12 Apr 2017

set result [package require piio]
puts "package piio loaded: $result"

proc scan_i2cbus {bus_low {bus_high ""}} {

   if  {$bus_high == ""} {set bus_high $bus_low}

      # Iterate over the busses (specified by user) 
      for {set bus $bus_low} {$bus<=$bus_high} {incr bus} {

        puts "working on bus: $bus"

        # check all the addresses from zero to 256
        for {set address 0} {$address < 256} {incr address} {

                scan_i2caddress $bus $address
       }
    }

    puts "Scan finished."
    return
}

proc scan_i2caddress {bus address} {

        # puts "working on bus: $bus, address=$address"

        # if we can get a handle to this address, also search for registers
        if {![catch {set i2c_h [twowire twowire $bus $address]} err ]} {

                # puts "found device at address=$address (handle=$i2c_h)"

                # Check all registers from 0 to 255
                for {set register 0} {$register <=256} {incr register} {

                        if {![catch {set value [twowire readregbyte $i2c_h $register]} err ]} {

                                if {$value > 0} {

                                        puts "bus=$bus, address=[format %3d $address] (0x[format %2.2X $address]), register=[format %3d $register] (0x[format %2.2X $register]), data byte = [format %4d $value] = 0x[format %2.2X $value] = [format %08b $value]"
                                          } else {

                                        # We didn't find any data at that register
                                        # puts "no data at register value $register (no error)"
                                }

                        } else {
                                
                                # We didn't find any data at that register
                                #puts "no data at register value $register (err=$err)"
                        }
                 }

                close $i2c_h
        }

        return
}

puts "Scanning all busses, addresses and registers..."
scan_i2cbus 0 1
puts "--------------------------"

# Scan only one specific address
# set bus 1
# set address 92; aka 0x5c
# puts "Scanning the bus#$bus, address $address"
# scan_i2caddress $bus $address

puts "done."
