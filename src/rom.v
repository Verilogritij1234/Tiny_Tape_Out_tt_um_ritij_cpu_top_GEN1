`default_nettype none

module rom #(
    parameter DEPTH = 64, 
    parameter WIDTH = 32
) (
    /* verilator lint_off UNUSEDSIGNAL */
    input wire clk,
    /* verilator lint_on UNUSEDSIGNAL */
    input wire [5:0] addr_rd, 
    output wire [WIDTH-1:0] data_rom_out
);
    reg [WIDTH-1:0] rom_mem [0:DEPTH-1];

   //  integer i;
    // initial begin
    //     // 1. Pre-fill with a valid instruction (addi x1, x0, 5)
    //     // If the hex file fails to load, this guarantees the ALU 
    //     // and register file are forced to synthesize.
    //     for (i = 0; i < DEPTH; i = i + 1) begin
    //         rom_mem[i] = 32'h00500093; 
    //     end
        
        // 2. Load the actual hex file using the correct OpenLane path
    //   $readmemh("src/instruction_set.hex", rom_mem);
    // end
    integer i;
    initial begin
        // 1. Fill the background with a continuous increment to prevent static loops
        for (i = 0; i < DEPTH; i = i + 1) begin
            rom_mem[i] = 32'h00108093; // addi x1, x1, 1
        end
        
        // 2. Hardcode the 3-instruction dynamic loop at the start
        // This guarantees Yosys sees a constantly changing ALU output
        rom_mem[0] = 32'h00000093; // addi x1, x0, 0
        rom_mem[1] = 32'h00108093; // addi x1, x1, 1
        rom_mem[2] = 32'hffdff06f; // jal x0, -4 (jumps back to PC 1)
        
        // Remove or comment out the $readmemh completely
        // $readmemh("src/instruction_set.hex", rom_mem);
    end

    // 3. Asynchronous (combinational) read
    assign data_rom_out = rom_mem[addr_rd];

endmodule


// module rom #(
//     parameter DEPTH = 64, 
//     parameter WIDTH = 32
// ) (
//     input clk,
//     input [5:0] addr_rd, 
//     output [WIDTH-1:0] data_rom_out
// );
//     reg [WIDTH-1:0] rom_mem [0:DEPTH-1];

//     integer i;
//     initial begin
//         // 1. Pre-fill the ROM with RISC-V NOP instructions (addi x0, x0, 0)
//         // This clears the $readmemh warning and prevents 'x' values entirely
//         for (i = 0; i < DEPTH; i = i + 1) begin
//             rom_mem[i] = 32'h00000013; 
//         end
        
//         // 2. Load your compiled C program over the top
//         $readmemh("instruction_set.hex", rom_mem);
//     end

//     // 3. THE FIX: Asynchronous (combinational) read. 
//     // The instruction must appear instantly when addr_rd changes.
//     assign data_rom_out = rom_mem[addr_rd];

// endmodule




