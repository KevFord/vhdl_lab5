# Lab 5 do file:

#Restart simulation
restart -f

# Define all input signals, reset active
force clk_50 0 0, 1 10 ns -r 20 ns
force reset_n 0

run 500 ns

# Release reset
force reset_n 1

# Set rx_in high for a while
force rx_in 1

run 200 us

# 1 valid number: bin 00110011, hex 33, dec 3
# Start bit
force rx_in 0
run 104 us

# LSB 
force rx_in 1
run 104 us
force rx_in 1
run 104 us
force rx_in 0
run 104 us
force rx_in 0
run 104 us
force rx_in 1
run 104 us
force rx_in 1
run 104 us
force rx_in 0
run 104 us
force rx_in 0
run 104 us

# Stop bit
force rx_in 1
run 200 us

# 1 valid number: bin 00110111, hex 37, dec 7
# Start bit
force rx_in 0
run 104 us

# LSB 
force rx_in 1
run 104 us
force rx_in 1
run 104 us
force rx_in 1
run 104 us
force rx_in 0
run 104 us
force rx_in 1
run 104 us
force rx_in 1
run 104 us
force rx_in 0
run 104 us
force rx_in 0
run 104 us

# Stop bit
force rx_in 1
run 200 us

# Invalid input: bin 01000001, hex 41, ascii A
# Start bit
force rx_in 0
run 104 us

# LSB
force rx_in 1
run 104 us
force rx_in 0
run 104 us
force rx_in 0
run 104 us
force rx_in 0
run 104 us
force rx_in 0
run 104 us
force rx_in 0
run 104 us
force rx_in 1
run 104 us
force rx_in 0
run 104 us

# Stop bit
force rx_in 1
run 200 us