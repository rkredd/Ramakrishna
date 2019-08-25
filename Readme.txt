======================================================
Readme 
======================================================

The release includes
1. docs             - contains CSI2-TX userguide, CSI2-TX Test Environment document and testcases xls
2. models           - contains all *.v and *.sv model files.
3. rtl              - contains all *.v design files.
4. sim              - contains all the files necessary for simulation in NCSIM
5. testcases        - contains 209 testcases.
6. synthesis_scripts - contains the RC scripts for synthesis
----------------------------------------------------------------------------------------------
Script usage for simulation
----------------------------------------------------------------------------------------------
 All the scripts are inside the $CUR_PROJ_DIR/sim
 Before running the run of any script follow the below steps:

 A. source env.csh

 B. Run the cleanup script with the option desired from below 
 1. Clean RTL logs 
  a. To clean the RTL run files use ./cleanup.csh -rtl. Cleans all dumps related to rtl run.
  a. To clean the RTL run files use ./cleanup.csh -cover. Cleans all dumps related to coverage.

 C.Run the desired script with the options as below:
 2. Automated Scripts for RTL/Gates, Standalone, Regression
  a. RTL - Standalone and Regression

   a.a. To run Standalone Testcase 
        copy the *.v files of the testcase into the sim directory and run ./sim.csh. 

   a.b. For Regression run: ./regress.csh -rtl. (default SENSOR Frequnecy is 750MHz and DDR is 500MHz) This creates a log file with ncverilog.log

   The regression can be done with the below command 

          source ./regress.csh  -rtl -sensor_freq sensor_freq -ddr_freq ddr_freq -force_user_freq  user_freq -lane lane_count 
                 
                 where
                 -sensor_freq  sensor_freq    : SENSOR Frequency (350MHz to 750MHz) 
                 -ddr_freq  ddr_freq          : D-PHY TxDDRClk (96MHz to 1120MHz)
                 -lane      lane_count        : The value could be from 1 to 8
                 -force_user_freq user_freq   : The user can configure the frequency value.If the user did not provide the frequency value then the 
                                              clk generation module will generate the DDR and SENSOR frequency as per the testcase configuration.
                 -lane      lane_count : The value could be from 1 to 8
  b. COVER - Standalone and Regression
   
   b.a. To run Standalone Testcase   
      copy the *.v files of the testcase into the sim directory and run ./sim.csh. 

   a.b. For Regression run: ./regress.csh -cover. (default SENSOR Frequnecy is 750MHz and DDR is 500MHz) This creates a log file with ncverilog.log

    The regression can be done with the below command 

          source ./regress.csh  -cover -sensor_freq sensor_freq -ddr_freq ddr_freq -force_user_freq  user_freq -lane lane_count -dphy_eot_mode 0|1  
           where
             - cover          : Enable the coverage.

 3. To see the regression report run - source report.csh from sim directory

 4. To generate coverage report use the following procedure

     a) Run the regression with coverage option

          source ./regress.csh  -cover -sensor_freq sensor_freq -ddr_freq ddr_freq -force_user_freq  user_freq -lane lane_count -dphy_eot_mode 0|1 

     b) Copy the following below files from sim directory to testcases directory.

             i) coverage_merge_vlog.csh
            ii) imc_verilog.do
           iii) coverage.vRefine

     c) From the testcase directory to generate report use the below command

             ./coverage_merge_vlog.csh

     d) This script file (coverage_merge_vlog.csh) will merge all the coverage related files and generate the report in code_cov folder in the testcase directory.
