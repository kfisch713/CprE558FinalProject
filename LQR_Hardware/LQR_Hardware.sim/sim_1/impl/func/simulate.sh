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
ExecStep $xv_path/bin/xsim Top_Level_func_impl -key {Post-Implementation:sim_1:Functional:Top_Level} -tclbatch Top_Level.tcl -view /home/ericm/Documents/Classes/cpre583/final_project/InvertedPedulum/LQR_Hardware/Top_Level_behav.wcfg -log simulate.log
