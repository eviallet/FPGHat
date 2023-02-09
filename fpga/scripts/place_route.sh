nextpnr-ice40 --package hx1k --pcf pins.pcf --json build/fpghat.json --asc build/bitstream.asc 2>&1 | tee pnr_output && # --placed-svg build/placed.svg --routed-svg build/routed.svg 
icepack build/bitstream.asc build/bitstream.bin 

echo
awk -v RS='' -v ORS='\n\n' '/Info: Device utilisation:/' pnr_output
rm pnr_output

