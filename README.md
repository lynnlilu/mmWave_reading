# mmWave_reading

This is a Matlab program for data reading from TI mmWave Demo.
Specifically, the TI mmWave is AWR1642, and the data is outputted by record function of mmWave Demo Visualizer.

The mmwave_read_complete.m is the main program, which would invoke header_reading.m, parseTLV.m and padding_read.m.
Before you use the code to parse the dat file, you need to change the file name in mmwave_read_complete.m as the correct name of your outputted file, so as to ensure a successful running.

Li
