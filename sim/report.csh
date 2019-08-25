#!/bin/csh
set list=`more test_array.txt`
set total_cases = `wc -l < test_array.txt`

if (-e report_passed.txt) then
 rm -rf report_passed.txt
endif

if (-e report_failed.txt) then
 rm -rf report_failed.txt 
endif

if (-e report_hanged.txt) then
 rm -rf report_hanged.txt 
endif


foreach x($list)
  grep -e "PASSED" -l $CUR_PROJ_DIR/$x/ncverilog.log >> report_passed.txt 
  grep -e "FAILED" -l $CUR_PROJ_DIR/$x/ncverilog.log >> report_failed.txt
  grep -e "HANGED" -l $CUR_PROJ_DIR/$x/ncverilog.log >> report_hanged.txt
  grep -e "PASSED" -l $CUR_PROJ_DIR/$x/testcases_*.log >> report_passed.txt 
  grep -e "FAILED" -l $CUR_PROJ_DIR/$x/testcases_*.log >> report_failed.txt
  grep -e "HANGED" -l $CUR_PROJ_DIR/$x/testcases_*.log >> report_hanged.txt
end

echo "Total Number of Test Cases : $total_cases"

set passed = `wc -l < report_passed.txt`
echo "Number of Test Cases passed : $passed"

set failed = `wc -l < report_failed.txt`
echo "Number Of Test Cases Failed : $failed"

set hanged = `wc -l < report_hanged.txt`
echo "Number Of Test Cases Hanged : $hanged"


echo "To check the testcases passed.. See report_passed.txt for more details"
echo "To check the testcases failed.. See report_failed.txt for more details"
echo "To check the testcases hanged.. See report_hanged.txt for more details"

