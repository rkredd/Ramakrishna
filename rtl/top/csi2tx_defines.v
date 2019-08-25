`timescale 1 ns / 1 ps

`define FRAME_START       6'h00
`define FRAME_END         6'h01
`define LINE_START        6'h02
`define LINE_END          6'h03
`define GEN_SH_PKT1       6'h08
`define GEN_SH_PKT2       6'h09
`define GEN_SH_PKT3       6'h0A
`define GEN_SH_PKT4       6'h0B
`define GEN_SH_PKT5       6'h0C
`define GEN_SH_PKT6       6'h0D
`define GEN_SH_PKT7       6'h0E
`define GEN_SH_PKT8       6'h0F
`define NULL_PKT          6'h10
`define BLK_DATA          6'h11
`define EMBEDDED_DATA     6'h12
`define YUV420_8B         6'h18
`define YUV420_10B        6'h19
`define LYUV420_8B        6'h1A
`define YUV420_8B_CSPS    6'h1C
`define YUV420_10B_CSPS   6'h1D
`define YUV422_8B         6'h1E
`define YUV422_10B        6'h1F
`define RGB444            6'h20
`define RGB555            6'h21
`define RGB565            6'h22
`define RGB666            6'h23
`define RGB888            6'h24
`define RAW6              6'h28
`define RAW7              6'h29
`define RAW8              6'h2A
`define RAW10             6'h2B
`define RAW12             6'h2C
`define RAW14             6'h2D
`define USD_TYPE1         6'h30
`define USD_TYPE2         6'h31
`define USD_TYPE3         6'h32
`define USD_TYPE4         6'h33
`define USD_TYPE5         6'h34
`define USD_TYPE6         6'h35
`define USD_TYPE7         6'h36
`define USD_TYPE8         6'h37

// Values for different compression scheme
`define C_10_6_10 3'b001
`define C_10_7_10 3'b010
`define C_10_8_10 3'b011
`define C_12_6_12 3'b100
`define C_12_7_12 3'b101
`define C_12_8_12 3'b110

/*****************************************************************************/
// The following parameter is compile time attributes used to control the
// size of the SENSOR FIFO. The SENSOR FIFO can be configured to any size that is re
// quired as per user application. However the minimum size of the FIFO should 
// be 16-deep.
// The current Implementation is store and Forward- In this mode the size of
// the FIFO should be 2*times the MAX Packet lenght support
// For R0919 - The MAX Packet length is 16K and hence the Overall size of the
// FIFO is 32K bytes
// Data Width is 64bit - 8 Bytes
// Size = 8 * (2**SENSOR_FIFO_ADDR_WIDTH0
`define SENSOR_FIFO_ADDR_WIDTH  'd12 // 2**SENSOR_FIFO_ADDR_WIDTH
