module parameterized_RAM #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 6
)(
    input clk,   // clock signal
    input reset,
    input we,
    input [ADDR_WIDTH-1:0] address,
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_ram_out
);
    // Memory array
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

// Add this to parameterized_RAM.v to prevent 'x' propagation
    integer i;
    initial begin
        for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
            mem[i] = 32'd0;
        end
    end
    
    // Synchronous Write
    always @(posedge clk) begin
        if (we) begin
            mem[address] <= data_in;
        end
    end

    // Asynchronous (Combinational) Read for Single-Cycle CPU
    assign data_ram_out = mem[address];

endmodule



// module parameterized_RAM #(parameter DATA_WIDTH = 8,ADDR_WIDTH = 6)(
//     input clk,   // clock signal
//     input reset,  // reset signal
//     input we,  // write enable
//     input [ADDR_WIDTH-1:0]address,  // Address input
//     input [DATA_WIDTH-1:0]data_in,  // data input
//     output reg [DATA_WIDTH-1:0]data_ram_out);  // data ouput 
    
//     reg[DATA_WIDTH-1:0] mem[(2**ADDR_WIDTH)-1:0];

//     // always @(posedge clk,posedge reset)
//     always @(posedge clk)
//     begin
//         if(reset) begin
//             data_ram_out <=0;   // output is is zero (reset operation)
//         end

//        else  if(we)  begin
    
//             mem[address] <= data_in;  // jo bhi data_in port pe hai usko mem main feed kar do  
//         end    // write operation 

//         else begin 
//             data_ram_out <= mem[address] ;  // jo bhi data mem main hai usko output port main de do 
//         end      // read operation 
//     end
// endmodule 



