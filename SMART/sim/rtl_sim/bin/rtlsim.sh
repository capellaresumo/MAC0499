#!/bin/bash
#------------------------------------------------------------------------------
# Copyright (C) 2001 Authors
#
# This source file may be used and distributed without restriction provided
# that this copyright statement is not removed from the file and that any
# derivative work contains the original copyright notice and the associated
# disclaimer.
#
# This source file is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# This source is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this source; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
#------------------------------------------------------------------------------
#
# File Name: rtlsim.sh
#
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#             - Mihai M.,	   mmihai@delajii.net
#
#------------------------------------------------------------------------------
# $Rev: 212 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2015-11-17 12:05:53 +0100 (Tue, 17 Nov 2015) $
#------------------------------------------------------------------------------

###############################################################################
#                            Parameter Check                                  #
###############################################################################
EXPECTED_ARGS=2
if [ $# -ne $EXPECTED_ARGS ]; then
  echo "ERROR    : wrong number of arguments"
  echo "USAGE    : rtlsim.sh <verilog stimulus file> <memory file> <submit file>"
  echo "Example  : rtlsim.sh ./stimulus.v            pmem.mem      ../src/submit.f"
  echo "OMSP_SIMULATOR env keeps simulator name iverilog/cver/verilog/ncverilog/vsim/vcs"
  exit 1
fi


###############################################################################
#                     Check if the required files exist                       #
###############################################################################

if [ ! -e $1 ]; then
    echo "Verilog stimulus file $1 doesn't exist"
    exit 1
fi

if [ ! -e $2 ]; then
    echo "Verilog submit file $2 doesn't exist"
    exit 1
fi


###############################################################################
#                         Start verilog simulation                            #
###############################################################################

if [ "${OMSP_SIMULATOR:-iverilog}" = iverilog ]; then

    rm -rf simv

    NODUMP=${OMSP_NODUMP-0}
    if [ $NODUMP -eq 1 ]
      then
        iverilog -o simv -c $2 -D NODUMP
      else
        iverilog -o simv -c $2
    fi

    if [[ $(uname -s) == CYGWIN* ]];
      then
	    vvp.exe ./simv
      else
        ./simv
    fi

else

    NODUMP=${OMSP_NODUMP-0}
    if [ $NODUMP -eq 1 ] ; then
       vargs="+define+NODUMP"
    else
       vargs=""
    fi

   case $OMSP_SIMULATOR in
    cver* )
       vargs="$vargs +define+VXL +define+CVER" ;;
    verilog* )
       vargs="$vargs +define+VXL" ;;
    ncverilog* )
       rm -rf INCA_libs
       #vargs="$vargs +access+r +nclicq +ncinput+../bin/cov_ncverilog.tcl -covdut openMSP430 -covfile ../bin/cov_ncverilog.ccf -coverage all +define+TRN_FILE" ;;
       vargs="$vargs +access+r  +nclicq +define+TRN_FILE" ;;
    vcs* )
       rm -rf csrc simv*
       vargs="$vargs -R -debug_pp +vcs+lic+wait +v2k +define+VPD_FILE" ;;
    vsim* )
       # Modelsim
       if [ -d work ]; then  vdel -all; fi
       vlib work
       exec vlog +acc=prn -f $2 $vargs -R -c -do "run -all" ;;
    isim )
       # Xilinx simulator
       rm -rf fuse* isim*
       export LD_LIBRARY_PATH=/opt/lib/libcX:/lib/:/usr/lib:/usr/share/lib
       fuse work.glbl tb_openMSP430_fpga -prj $2 -o isim.exe -i ../../../bench/verilog/ -i ../../../rtl/verilog/ -i ../../../rtl/verilog/openmsp430/ -i ../../../rtl/verilog/openmsp430/periph/ -L unisims_ver -L unimacro_ver -L xilinxcorelib_ver
       echo "run all" > isim.tcl
       ./isim.exe -tclbatch isim.tcl
       exit
   esac

   echo "Running: $OMSP_SIMULATOR -f $2 $vargs"
   exec $OMSP_SIMULATOR -f $2 $vargs
fi
