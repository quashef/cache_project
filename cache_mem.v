`define BLOCKS 256      // #blocks in cache (hence 8 bit index)
`define WORDS 16        // #Words in a block (hence 4 bit offset)
`define SIZE 32         // 32 bit processor (word size)
`define BLOCK_SIZE 512  // size of one block in bits = 16*32
`define TAG 20          // address(32)-index(8)-offset(4)


module cache_memory (clk, address, read, dataIn, dataOut, hit);

    input clk;
    input [31:0] address;  
    input read;
    input [`BLOCK_SIZE-1: 0] dataIn;  // 16 words at once comes from RAM

    output reg hit;
    output reg [31:0] dataOut;        // SINGLE word read out from cache

    reg [`BLOCK_SIZE + `TAG: 0] buffer;
    reg [7:0] index;
    reg [3:0] blockOffset;
    reg [`BLOCK_SIZE + `TAG: 0] cache [`BLOCKS-1: 0];

    // initialize cache flags
    initial begin 
         for(i=0; i<`BLOCKS; i=i+1) begin
        cache[i][0] = 0;  // all blocks are invalid at first
         end
    end

    always@(posedge clk)
    begin
        index = address[11:4];
        blockOffset = address[3:0];
        if(read == 0) begin           // !read was asserted upon a miss, start filling cache @ addressed block
            valid = 1;                // assert valid bit
            buffer[0] = valid;
            buffer[`TAG:1] = address[31:12];
            buffer[512+`TAG: 21] = dataIn;   // fill from main mem
            cache[index] = buffer;
            dataOut = cache[index][`SIZE*blockOffset+ `SIZE+ `TAG -: 32];   // send out data from cache in cycle after miss
            hit = 1;
        end
        if(read == 1) begin
            if((address[31:12] == cache[index][`TAG:1]) && (cache[index][0] == 1)) begin   // valid and hit
                hit = 1;
                dataOut = cache[index][`SIZE*blockOffset+ `SIZE+ `TAG -: 32];
            end
            else begin   // invalid or miss
                hit = 0;
            end
            //dataOut = cache[index][`SIZE*blockOffset+ `SIZE+ `TAG -: 32];
        end
        else begin      // since at first, read is undefined
            hit = 0;
        end
    end

endmodule
