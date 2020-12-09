//`include "cache_mem.v"
//`include "main_mem.v"
//`include "cache_controller.v"

module main(clk,address,dataOut,hit,read);
    input clk;
    input [31:0] address;

    output [31:0] dataOut;
    output hit;

    output read;
    wire [511:0] dataIn;

    // assign read = 1'b1;

    main_mem u0(clk,address,dataIn);
    cache_mem u1(clk,address,read,dataIn,dataOut,hit);
    cache_controller u2(clk,hit,read);

endmodule