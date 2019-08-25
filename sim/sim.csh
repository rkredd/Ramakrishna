#!/bin/csh -f 
## change the include directory above to the appropriate
## installation directory
#----------------------------------------------------------- 
#                Arasan Chip Systems 
#----------------------------------------------------------- 
# 2010 (c) All copy rights reserved by Arasan Chip Systems 
#----------------------------------------------------------- 
# Author : arulk
# Date   : 12/feb/2002
# Desc   : CShell script to simulate a given test case 
#          using the modelsim simulator
#----------------------------------------------------------- 

## Set project specific variables in here 
set test_arr = "test_array.txt"
set file_lst = "file.lst"
set comp_opt = "+licq +ncaccess+rwc +define+TIMESCALE_NS"
set top_mod  = "test_env"
set sim_opt  = "+licq -novopt"
set do_cmd   = "run -all;"
set scr_name = "sim_nc "
set cvr_inst_name = "-instance test_env/u_csi2tx_mipi_top "
set cvr_top_name_nc = "csi2tx_mipi_top"
set inc_dir  = "+incdir+$CUR_PROJ_DIR/rtl/top"
set cover_option = "$CUR_SIM_DIR/coverage_options"

## Default parameters for the scripts
@ nosim   = 0
@ nocomp  = 0
@ dbg     = 0
@ noclean = 0 
@ test_count = 0
@ gates = 0
@ regress = 0
@ ddr_freq = 500
@ sensor_freq = 750
@ testname = 0
@ lane_cnt = 8
@ clk_mode = 0
@ nc = 1
@ msim = 0
@ dphy_eot_mode = 0
@ user_freq = 0
@ i = 0

echo "$ddr_freq" > freq.dat
echo "$sensor_freq" >> freq.dat

## Parse the command line arguments for this script
while ($#argv > 0) 
  set arg = $1; 
## Switching statement
  switch ($arg) 
    case "-regress"    : 
      shift; set regress = $1; breaksw
    case "-nosim"      : 
      @ nosim = 1; breaksw
    case "-nocomp"     : 
      @ nocomp = 1; breaksw
    case "-gates"      : 
      set file_lst = "file_gates.lst";  @ gates = 1;  breaksw
    case "-nc"         : 
      @ nc = 1; @ msim = 0;breaksw
    case "-msim"       : 
      @ msim = 1; @ nc = 0; breaksw
    case "-test_count" : 
      shift; set test_count = $1; breaksw
    case "-ddr_freq"   : 
      shift; set ddr_freq = $1;
      echo "$ddr_freq" > freq.dat
      echo "$sensor_freq" >> freq.dat
      breaksw
    case "-dphy_eot_mode" : 
      shift; set dphy_eot_mode = $1; 
       if ($dphy_eot_mode == 1) then
         set comp_opt = "$comp_opt +define+DPHY_EOT_MODE_ENABLE"
       else 
         set comp_opt = "$comp_opt +define+DPHY_EOT_MODE_DISABLE"
       endif
       breaksw
    case "-force_user_freq" :
      shift; set user_freq = $1;
        if ($user_freq == 1) then
          set comp_opt = "$comp_opt +define+USER_FREQ"
        endif
      breaksw
    case "-sensor_freq"   : 
      shift; set sensor_freq = $1; 
      echo "$ddr_freq" > freq.dat
      echo "$sensor_freq" >> freq.dat
      breaksw
    case "-lane" :
      shift; set lane_cnt = $1;
         if ( $lane_cnt == 1) then
           set comp_opt = "$comp_opt +define+ONE_LANE"
         else if ($lane_cnt == 2) then
           set comp_opt = "$comp_opt +define+TWO_LANE"
         else if ($lane_cnt == 3) then
           set comp_opt = "$comp_opt +define+THREE_LANE"
         else if ($lane_cnt == 4) then
           set comp_opt = "$comp_opt +define+FOUR_LANE"
         else if ($lane_cnt == 5) then
           set comp_opt = "$comp_opt +define+FIVE_LANE"
         else if ($lane_cnt == 6) then
           set comp_opt = "$comp_opt +define+SIX_LANE"
         else if ($lane_cnt == 7) then
           set comp_opt = "$comp_opt +define+SEVEN_LANE"
         else
           set comp_opt = "$comp_opt +define+EIGHT_LANE"
         endif
      breaksw
    case "-clkmode"   : 
      shift; set clk_mode = $1;
        if ( $clk_mode == 1) then
           set comp_opt = "$comp_opt +define+NONCONTINUOUS_CLK_MODE"
         else
           set comp_opt = "$comp_opt +define+CONTINUOUS_CLK_MODE"
        endif
      breaksw
    case "-syncflop" : 
      set comp_opt = "$comp_opt +define+RTL_SIMULATION"; breaksw
    case "-max"      : 
      set comp_opt = "$comp_opt +define+DPHY_PARAM_MAX"; breaksw
    case "-avg"      : 
      set comp_opt = "$comp_opt +define+DPHY_PARAM_AVG"; breaksw
    case "-min"      : 
      set comp_opt = "$comp_opt"; breaksw
    case "-testname" : 
      shift; set testname = $1; @ i++; breaksw
    case "-dump"     : 
      set comp_opt = "$comp_opt +define+VCD_EN"; breaksw
    case "-cf"       : 
      set comp_opt = "$comp_opt -f comp_options.f" 
    case "-dbg"      :
      if ($msim == 1) then
        set sim_opt = "$sim_opt   -i"; 
        set do_cmd  = "log -r *; $do_cmd"
        set comp_opt = "$comp_opt +define+DBG"
        @ dbg=1; 
        breaksw
      else
        breaksw
      endif
     case "-cover" : 
       if ($msim == 1) then
        set comp_opt = "$comp_opt -novopt +cover=sbceftx"
        set sim_opt  = "$sim_opt  -novopt -coverage"
        set do_cmd   = "coverage save $cvr_inst_name -onexit -directive -cvg -codeAll cover.ucdb; $do_cmd " 
        breaksw
       else
        # $i is the testcase number
        set comp_opt = "-coverage all -coverage b -covfile $cover_option -covoverwrite +nccovtest+${test_count}"
        breaksw
       endif
     case "-top"      : 
       shift; set top_mod = $1; breaksw
     case "-flist"    : 
       shift; set file_lst = $1; breaksw 
     case "-noclean"  : 
       @ noclean = 1;
     case "-help" : 
      echo "./sim.csh         -- to run rtl without coverage";
      echo "./sim.csh -gates  -- to run gates without coverage";
      echo "./sim.csh -cover  -- to run rtl run with coverage "; exit

    ##break if the argument is not supported
    default : 
      echo "Argument '$arg' not supported; try $scr_name -help for more details on the arguments"; exit
    endsw
  shift
end

## Compilation and simulation if NCSIM is chosen
if($nc == 1) then
 if($nocomp != 1) then
   echo "$scr_name : Simulation in Progresss $inc_dir $comp_opt -f $file_lst "
   ncverilog -sv +define+TIMESCALE_NS $inc_dir $comp_opt -f $file_lst >> comp.log
   echo "$scr_name : Simulation is Done $inc_dir $comp_opt -f $file_lst "
  set x=`grep -i "*E" ncverilog.log | wc -l` 
  if ("$x" != "0") then 
    echo "$scr_name : There is a compilation error.. See ncverilog.log for more details"
    exit
  endif
 endif
endif


#----------------------------------------------------------- 
# The portion below represents the compilation procedure 
#----------------------------------------------------------- 
if ($msim == 1) then
if($nocomp != 1) then
  ## Remove any existing work library
  if(-e work && $noclean != 1) then
    echo "$scr_name : Removing existing work library"; rm -rf work;
  endif
  ## Remove any log file
  if(-e comp.log && $noclean != 1) then
    echo "$scr_name : Removing existing log file"; rm -rf comp.log;
  endif

  echo "$scr_name : Creating work library "; vlib work; 

  
  echo "$scr_name : executing vlog $inc_dir $comp_opt -f $file_lst "
  vlog +define+TIMESCALE_NS $inc_dir $comp_opt -f $file_lst >> comp.log

  set x=`grep -i "error" comp.log | wc -l` 
  if ("$x" != "0") then 
    echo "$scr_name : There is a compilation error.. See comp.log for more details"
    exit
  endif

endif

#----------------------------------------------------------- 
# The portion below represents the simulation procedure 
#----------------------------------------------------------- 
if($nosim != 1) then
   ## Remove any existing work library
  if(-e sim.log && $noclean != 1) then
    echo "$scr_name : Removing existing simulation log "; rm -rf sim.log;
  endif
 
  ## If dbg mode is not set use command prompt
  if($dbg != 1) then
    set sim_opt = "$sim_opt -c " 
    set do_cmd  = "$do_cmd quit -f"
  endif 

  # echo "$scr_name : executing vsim -do" $do_cmd "$sim_opt $top_mod"
  if($gates != 1) then
   if ($regress != 1) then
    vsim -do "$do_cmd" $sim_opt $top_mod -l sim_`date +%H%M%S`.log 
   else
    vsim -do "$do_cmd" $sim_opt $top_mod -l "${testname}_`date +%H%M%S`.log" 
   endif
  else
   if ($regress != 1) then
    vsim -do "$do_cmd" $sim_opt -multisource_delay max -sdfmax /test_env/u_mipi_top_inst/u_dfe_top_inst=$CUR_PROJ_DIR/netlist/dfe_top_wc_125.sdf +nowarnTFMPC -sdfnoerror +nowarnTSCALE -quiet -novopt test_env -l "${testname}_gates_`date +%H%M%S`.log" 
   else
   vsim -do "$do_cmd" $sim_opt -multisource_delay max -sdfmax /test_env/u_mipi_top_inst/u_dfe_top_inst=$CUR_PROJ_DIR/netlist/dfe_top_wc_125.sdf +nowarnTFMPC -sdfnoerror +nowarnTSCALE -quiet  -novopt test_env -l "${testname}_gates_`date +%H%M%S`.log" 
   endif
  endif
endif
endif
