#!/bin/bash -f
xv_path="/remote/Xilinx/2017.1/Vivado/2017.1"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 7a18c6c4fb08473c9b71c5bc61409ab8 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot Top_Level_func_impl xil_defaultlib.Top_Level -log elaborate.log
