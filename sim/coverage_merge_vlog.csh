#! /bin/tcsh

find ./ -name "*.ucd" > 1
touch 2
foreach i (`cat 1`)
dirname "$i" >> 2
end

cat 2 | sort | uniq > runfile

imc -batch < imc_verilog.do
