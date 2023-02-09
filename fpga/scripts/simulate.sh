#!/bin/bash

filename=$(echo "$1" | sed -E "s/.+\/([A-Za-z0-9]+)(_tb)?\.vhd/\1/")
tb_file=$(echo "$1" | sed -E "s/.+\/([A-Za-z0-9]+)(_tb)?\.vhd/\1_tb/")

ghdl -a --workdir=simulations/work/ "$filename.vhd" "$tb_file.vhd" &&
ghdl --elab-run --workdir=simulations/work/ -o "simulations/work/$tb_file" "$tb_file" --fst="./simulations/$filename.fst"

if test -f "./simulations/$filename.gtkw"; then
    gtkwave --save="./simulations/$filename.gtkw" --rcfile="./scripts/gtkwaverc" "./simulations/$filename.fst" > /dev/null 2>&1
else
    gtkwave --wish --tcl_init="./scripts/gtkwave_startup.tcl" --rcfile="./scripts/gtkwaverc" "./simulations/$filename.fst" > /dev/null 2>&1
fi