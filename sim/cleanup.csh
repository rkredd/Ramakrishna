#!/bin/csh
##--------------------------------------------------
## Cshell script that cleans up the test case
## directory structure and prepares for a regression
##--------------------------------------------------
#set test_file = "test_array.txt"
#set test_file = "standalone.txt"
#set x=`more $test_file`

@ rtl   = 0
@ gates  = 0
@ cover  = 0
@ clean  = 0

while ($#argv > 0) 
  set arg = $1; 

  switch ($arg) 
    case "-rtl" : 
      @ rtl = 1; breaksw
    case "-gates" : 
      @ gates = 1; breaksw
    case "-cover" : 
      @ cover = 1; breaksw
    case "-clean" : 
      @ clean = 1; breaksw
    case "-help" : 
      echo "./cleanup.csh -rtl    -- to clean rtl regression dump";
      echo "./cleanup.csh -gates  -- to clean gates regression dump";
      echo "./cleanup.csh -cover  -- to clean the coverage related dump"; exit
      echo "./cleanup.csh -clean  -- to clean all logs and dumps without creating link"; exit
    default : 
      echo "Argument '$arg' not supported; try $scr_name -help for more details on the arguments"; exit
  endsw
  shift
end
     
if ($gates == 1) then
 set test_file = `more test_array_gls.txt`
 set         x = `more test_array_gls.txt`
else 
 set test_file = `more test_array.txt`
 set         x = `more test_array.txt`
endif

##-----------------------------------------------------------------
## Create the link to the simulation directory
##-----------------------------------------------------------------
if ($rtl == 1) then
   set rmf='file.lst file_gates.lst msft_afe_file.lst *.csh *.do *.fl *.o transcript* comp.log sim_*.log *.vstf *.wlf sim_*.csh* *.shm work *.key INCA_libs *.o.* *.e.* *.swp yuv_*.dat xdeco*.dat usd*.dat seed_*.txt rgb*.dat raw*.dat gen*.dat comp*.dat .simvis* DVEfiles csrc simv.* simv ucli.key inter.vpd *.pl time.txt ncverilog.log testcases_*.log freq.dat' 
endif

if ($gates == 1) then
   set rmf='file.lst file_gates.lst msft_afe_file.lst *.csh *.do *.fl *.o transcript* comp.log gates_*.log *.vstf *.wlf sim_*.csh* *.shm work *.key INCA_libs *.o.* *.e.* *.swp yuv_*.dat xdeco*.dat usd*.dat seed_*.txt rgb*.dat raw*.dat gen*.dat comp*.dat .simvis* DVEfiles csrc simv.* simv ucli.key inter.vpd *.pl time.txt freq.dat' 
endif

if ($cover == 1) then
   set rmf='file.lst  file_gates.lst msft_afe_file.lst *.csh *.do *.fl *.o *.ucdb transcript* *.log *.vstf *.wlf sim_*.csh* *.shm work *.key INCA_libs *.o.* *.e.* *.swp yuv_*.dat xdeco*.dat usd*.dat seed_*.txt rgb*.dat raw*.dat gen*.dat comp*.dat .simvis* DVEfiles csrc simv.* simv ucli.key inter.vpd *.pl time.txt freq.dat cov_work' 
endif

if ($clean == 1) then
   set rmf='file.lst file_gates.lst msft_afe_file.lst *.csh *.do *.fl *.o *.ucdb transcript* *.log *.vstf *.wlf sim_*.csh* *.shm work *.key INCA_libs *.o.* *.e.* *.swp yuv_*.dat xdeco*.dat usd*.dat seed_*.txt rgb*.dat raw*.dat gen*.dat comp*.dat .simvis* DVEfiles csrc simv.* simv ucli.key inter.vpd *.pl time.txt freq.dat' 
endif
##-----------------------------------------------------------------
## Create the link to the simulation directory
##-----------------------------------------------------------------
foreach y($x)
  ## Remove the files
  echo " Changing to the proj_dir"
  chdir ${CUR_PROJ_DIR}
  echo " Changing to the test_dir"
  echo $y
  chdir ./$y
  rm -rf $rmf
if ($cover == 1) then
  rm -fr cov_work
endif

#The link creation is moved to regression script
#if ($clean != 1) then
  ## Create the links to the specified files
#  ln -s $CUR_PROJ_DIR/sim/sim_*.csh ./ 
#  ln -s $CUR_PROJ_DIR/sim/file.lst ./
#  ln -s $CUR_PROJ_DIR/sim/msft_afe_file.lst ./ 
  ## Data file links
	##ln -s $CUR_PROJ_DIR/sim/*.dat ./
	##ln -s $CUR_PROJ_DIR/sim/*.pl ./	

##	perl csi1_txr_bfm_convertor.pl
##	perl csi2_txr_bfm_convertor.pl
##	perl csi3_txr_bfm_convertor.pl
##	perl ahb_model_convertor.pl
##	perl rand_seed.pl
endif

  chdir {$CUR_PROJ_DIR/sim}

end


