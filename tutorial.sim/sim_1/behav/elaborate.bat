@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.3\\bin
call %xv_path%/xelab  -wto afae4e186f14488ba958afd9015cbcb1 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot tutorial_behav xil_defaultlib.tutorial -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
