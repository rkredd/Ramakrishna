merge -runfile runfile -out all_cov
load -run ./cov_work/scope/all_cov
load -refinement coverage.vRefine
report -detail -html -all -out code_cov -overwrite -inst *.u_csi2tx_mipi_top...
quit
