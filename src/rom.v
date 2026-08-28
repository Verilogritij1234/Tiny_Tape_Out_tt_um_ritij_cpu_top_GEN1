module rom #(
    parameter DEPTH = 64, 
    parameter WIDTH = 32
) (
    input clk,
    input [5:0] addr_rd, 
    output [WIDTH-1:0] data_rom_out
);
    reg [WIDTH-1:0] rom_mem [0:DEPTH-1];

    integer i;
    initial begin
        // 1. Pre-fill the ROM with RISC-V NOP instructions (addi x0, x0, 0)
        // This clears the $readmemh warning and prevents 'x' values entirely
        for (i = 0; i < DEPTH; i = i + 1) begin
            rom_mem[i] = 32'h00000013; 
        end
        
        // 2. Load your compiled C program over the top
        $readmemh("instruction_set.hex", rom_mem);
    end

    // 3. THE FIX: Asynchronous (combinational) read. 
    // The instruction must appear instantly when addr_rd changes.
    assign data_rom_out = rom_mem[addr_rd];

endmodule





// module rom
// // #(parameter DEPTH  = 16,
// #(parameter DEPTH  = 64,
//  parameter WIDTH = 32,
//  parameter DEPTH_LOG  = $clog2(DEPTH))(clk,addr_rd,data_rom_out);
//  input clk;
//  input [(DEPTH_LOG-1):0]addr_rd;
//  output reg  [(WIDTH-1):0]data_rom_out;
// // declare a ROM array
//  reg [(WIDTH-1):0] rom[0:(DEPTH-1)];


//  // load the rom with data from rom_init.hex file 
//  initial begin
//     //   $readmemh("program.hex",rom,0,DEPTH-1);  // for reading hexadecimal data from the file
//       $readmemh("instruction_set.hex",rom,0,DEPTH-1);  // for reading hexadecimal data from the file
//     //   $readmemb("rom_init.txt",rom,0,DEPTH-1);  //  for reading  binary data from the file 
//  end

// // read is synchronous
// always@(posedge clk) begin
//     data_rom_out <= rom[addr_rd];
// end
// endmodule






