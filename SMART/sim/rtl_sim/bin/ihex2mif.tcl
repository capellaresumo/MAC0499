#!/usr/bin/tclsh

###############################################################################
#                            PARAMETER CHECK                                  #
###############################################################################

proc dec2bin i {
    #returns a string, e.g. dec2bin 10 => 1010 
    set res {} 
    while {$i>0} {
        set res [expr {$i%2}]$res
        set i [expr {$i/2}]
    }
    if {$res == {}} {set res 0}
    return $res
}

if {$argc != 6} {
  puts "ERROR   : wrong number of arguments"
  puts "USAGE   : ihex2mif.tcl -ihex <input file> -out <output file> -mem_size <memory size>"
  puts "Example : ihex2mif.tcl -ihex rom.ihex     -out rom.mem       -mem_size 2048"
  exit 1
}

# default values
set ihex      empty.in
set out       empty.out
set mem_size  -1

# parse arguments
for {set i 0} {$i < $argc} {incr i} {
    switch -exact -- [lindex $argv $i] {
	-ihex     {set ihex     [lindex $argv [expr $i+1]]; incr i}
	-out      {set out      [lindex $argv [expr $i+1]]; incr i}
	-mem_size {set mem_size [lindex $argv [expr $i+1]]; incr i}
    }
}

# Make sure arugments were specified
if {[string eq $ihex empty.in]} {
    puts "IHEX input file isn't specified"
    exit 1   
}
if {[string eq $out empty.out]} {
    puts "MEMH output file isn't specified"
    exit 1   
}
if {[string eq $mem_size -1]} {
    puts "Memory size isn't specified"
    exit 1   
}


###############################################################################
#                            CONVERSION PROCEDURE                             #
###############################################################################

#-----------------------------------------------------------------------------#
#                                 OPEN FILES                                  #
#-----------------------------------------------------------------------------#

# IHEX Input
if [catch {open $ihex r} f_ihex] {
    puts "ERROR Cannot open input file $ihex"
    exit 1
}

# MEMH Output
if { "$out"=="-"} {
   set f_out stdout
} else {
   if [catch {open $out w } f_out]  {
       puts "ERROR Cannot create output file $out"
       exit 1
   }
}


#-----------------------------------------------------------------------------#
#                                 CONVERSION                                  #
#-----------------------------------------------------------------------------#


# Conversions procedure
proc hex2dec { val  } {
  set val [format "%u" 0x[string trimleft $val]]
  return $val 
}


# Initialize memory array (16 bit words)
set num_word [expr ($mem_size/2)-1]
for {set i 0} {$i <= $num_word} {incr i} {
    set mem_arr($i) 0000
}


# Calculate Address offset (offset=(0x10000-memory_size))
set mem_offset [expr 65536-$mem_size]


# Process input file 
while {[gets $f_ihex line] >= 0} {

    # Process line
    set byte_count [hex2dec [string range $line 1 2]]
    set start_addr [expr ([hex2dec [string range $line 3 6]] - $mem_offset)]
    set rec_type   [string range $line 7 8]

    if {$rec_type == 00} {
	for {set i 0} {$i < $byte_count*2} {set i [expr $i+4]} {
	    set mem_msb  [string range $line [expr $i+11] [expr $i+12]]
            set mem_lsb  [string range $line [expr $i+9]  [expr $i+10]]
	    set addr     [expr ($start_addr+$i/2)/2]
	    set mem_arr($addr) "$mem_msb$mem_lsb"
	}
    }
}
close $f_ihex


# Writing memory array to file
# puts $f_out "memory_initialization_radix=16;"
# puts $f_out "memory_initialization_vector="

for {set i 0} {$i <= $num_word} {incr i} { 
 #    if {![expr $i%16]} {
	# puts -nonewline $f_out "\n@[format "%04x" $i] "
 #    }
    binary scan [binary format H* $mem_arr($i)] B* bits

    puts $f_out $bits
    # if { "$i" != "$num_word" } {
    #   puts $f_out ","
    # } else {
    #   puts $f_out ";"
    # }
}

puts  $f_out "\n"

if { "$out"!="-"} {
  close $f_out
}

exit 0