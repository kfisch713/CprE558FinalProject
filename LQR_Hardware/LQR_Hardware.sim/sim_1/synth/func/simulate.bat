@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.1\\bin
call %xv_path%/xsim LQR_Controller_func_synth -key {Post-Synthesis:sim_1:Functional:LQR_Controller} -tclbatch LQR_Controller.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
