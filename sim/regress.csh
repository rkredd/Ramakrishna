#!/bin/csh
@ count = 0
@ max_cnt = 10
@ sleep_time = 3
@ test_count = 0
@ rtl   = 0
@ gates  = 0
@ cover  = 0
@ regress = 1
@ single = 0
@ afe = 0
@ i = 1
@ ddr_freq = 500
@ sensor_freq = 750
@ min = 0
@ max = 0
@ avg = 0
@ syncflop = 0
@ lane_cnt = 8
@ clk_mode = 0
@ server = 1
@ dphy_eot_mode = 0
@ msim = 0
@ user_freq = 0;

  while ($#argv > 0)
    switch ($argv[$i])
      case "-single" :
        @ single = 1; breaksw
      case "-rtl" :
        @ rtl = 1; breaksw
      case "-syncflop" :
        @ syncflop = 1; breaksw
      case "-min" :
        @ min = 1; breaksw
      case "-max" :
        @ max = 1; breaksw
      case "-msim" :
        @ msim = 1; breaksw
      case "-local" :
        @ server = 0; breaksw
      case "-avg" :
        @ avg = 1; breaksw
      case "-ddr_freq" :
        shift; set ddr_freq = $1; breaksw
      case "-sensor_freq" :
        shift; set sensor_freq = $1; breaksw
      case "-lane" :
        shift; set lane_cnt = $1; breaksw
      case "-clkmode" :
        shift; set clk_mode = $1; breaksw
        case "-gates"
        @ gates = 1; breaksw
      case "-force_user_freq" :
        shift; set user_freq = $1; breaksw
      case "-dphy_eot_mode" :
        shift; set dphy_eot_mode = $1; breaksw
      case "-cover" :
        @ cover = 1; breaksw
      case "-help" :
        echo "./regress.csh -single -- to run single testcase from the file standalone.txt";
        echo "./regress.csh -rtl    -- to run rtl regression from the file test_array.txt";
        echo "./regress.csh -gates  -- to run gates regression from the file test_array.txt";
        echo "./regress.csh -cover  -- to run rtl regression with coverage from the file test_array.txt"; exit
      default :
        echo "Argument '$argv[$i]' not supported; try $scr_name -help for more details on the arguments"; exit
    endsw
   shift
  end

  if ($single == 1) then
    set list=`more standalone.txt`
    set    x=`more standalone.txt`
  else if ($gates == 1) then
    set list = `more test_array_gls.txt`
    set    x = `more test_array_gls.txt`
  else
    set list=`more test_array.txt`
    set    x=`more test_array.txt`
  endif



# creates the links to the specified files
foreach y($x)
  ## Remove the files
  chdir ${CUR_PROJ_DIR}
  chdir ./$y


  ## Create the links to the specified files
  ##ln -s $CUR_PROJ_DIR/sim_nc/file_gates.lst ./
  ln -s $CUR_PROJ_DIR/sim/sim.csh ./
  ln -s $CUR_PROJ_DIR/sim/file.lst ./
  ln -s $CUR_PROJ_DIR/sim/time.txt ./
  ln -s $CUR_PROJ_DIR/sim/freq.dat ./
end

chdir ${CUR_PROJ_DIR}

foreach x($list)
  @ test_count = $test_count + 1
  @ count = `qstat -u $USER | wc -l`
  echo @ count
    while ($count > $max_cnt)
      sleep $sleep_time;
      @ count = `qstat -u $USER | wc -l`
     end
  cd $CUR_PROJ_DIR/$x
  
  # Procedure to run in server
  if ($msim == 0) then
    if ($server == 1) then
          if ($gates == 1) then
        qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -gates
      endif #gates endif
      if ($cover == 1) then
            if ($max == 1) then
          qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -cover -max
          else if ($avg == 1) then
          qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -cover -avg
        else
          qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -cover -min
        endif # max endif
      endif # cover endif

      if ($rtl == 1) then
            if ($max == 1) then
          qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -max
          else if ($avg == 1) then
          qsub -pe csi 1-cwd -V -b y -N CSI./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -avg
        else
          qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -min
        endif # max endif
      endif # rtl enif
    endif #server endif

  # Procedure to local PC - Set $server to 0
  if ($server == 0) then
        if ($gates == 1) then
      source sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -gates
      endif # gates endif

      if ($cover == 1) then
            if ($max == 1) then
        source sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -cover -max
        else if ($avg == 1) then
        source sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -cover -avg
      else
        source sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -cover -min
      endif #max endif
    endif # cover endif

    if ($rtl == 1) then
          if ($max == 1) then
        source sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -max
        else if ($avg == 1) then
        source sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -avg
      else
       source sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -testname `echo $x | sed -e 's:/:_:g'` -min
      endif # max endif
    endif # rtl endif
  endif #server endif
endif #msim endif


##To run simulation in msim
if ($msim == 1) then
      if ($server == 1) then
            if ($gates == 1) then
      qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -gates
    endif

    if ($cover == 1) then
          if ($max == 1) then
        qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -cover -max
        else if ($avg == 1) then
        qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -cover -avg
      else
        qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -cover -min
    endif
  endif

  if ($rtl == 1) then
        if ($max == 1) then
          qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -max
          else if ($avg == 1) then
          qsub -pe csi 1-cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -avg
        else
          qsub -pe csi 1 -cwd -V -b y -N CSI ./sim.csh -ddr_freq $ddr_freq -force_user_freq $user_freq -sensor_freq $sensor_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -min
      endif
  endif
endif

# Procedure to local PC - Set $server to 0
if ($server == 0) then
      if ($gates == 1) then
       source sim.csh -ddr_freq $ddr_freq -sensor_freq $sensor_freq -force_user_freq $user_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -gates
  endif

  if ($cover == 1) then
        if ($max == 1) then
        source sim.csh -ddr_freq $ddr_freq -sensor_freq $sensor_freq -force_user_freq $user_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -cover -max
        else if ($avg == 1) then
        source sim.csh -ddr_freq $ddr_freq -sensor_freq $sensor_freq -force_user_freq $user_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -cover -avg
      else
        source sim.csh -ddr_freq $ddr_freq -sensor_freq $sensor_freq -force_user_freq $user_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -cover -min
    endif
  endif

  if ($rtl == 1) then
        if ($max == 1) then
          source sim.csh -ddr_freq $ddr_freq -sensor_freq $sensor_freq -force_user_freq $user_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -max
          else if ($avg == 1) then
          source sim.csh -ddr_freq $ddr_freq -sensor_freq $sensor_freq -force_user_freq $user_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -avg
        else
          source sim.csh -ddr_freq $ddr_freq -sensor_freq $sensor_freq -force_user_freq $user_freq -dphy_eot_mode $dphy_eot_mode -lane $lane_cnt -clkmode $clk_mode -test_count $test_count -regress $regress -msim -testname `echo $x | sed -e 's:/:_:g'` -min
      endif
  endif
endif
endif

end
