@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.1\\bin
call %xv_path%/xelab  -wto 7a18c6c4fb08473c9b71c5bc61409ab8 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot LQR_Controller_func_synth xil_defaultlib.LQR_Controller -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
