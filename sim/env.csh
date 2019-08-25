##===============================================================
## Set global variables for the project 
##===============================================================
## setenv CUR_PROJ_DIR  $hdir/projects/PNW_HSI_OCP_Rev1.9_May10_10_B0
setenv CUR_PROJ_DIR  $PWD/.. 
setenv CUR_RTL_DIR   $CUR_PROJ_DIR/rtl
setenv CUR_MODEL_DIR $CUR_PROJ_DIR/models 
setenv CUR_SIM_DIR   $CUR_PROJ_DIR/sim 

##===============================================================
## All user project specific aliases 
##===============================================================
alias cdr   "cd $CUR_RTL_DIR"
alias cdm   "cd $CUR_MODEL_DIR"
alias cdt   "cd $CUR_PROJ_DIR/testcases"
alias cdsim "cd $CUR_SIM_DIR"
