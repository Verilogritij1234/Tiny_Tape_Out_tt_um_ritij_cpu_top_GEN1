`default_nettype none

module alu_8bit (
    input  wire       clk,
    input  wire       rst_n,   // Active-low reset
    input  wire [7:0] data_in,
    input  wire [2:0] opcode,
    output reg  [7:0] accum    // Sequential output register
);

    reg [7:0] comb_result; // Combinational intermediate wire

    // 1. COMBINATIONAL BLOCK
    // Determines what the next state should be based on opcode
    always @(*) begin
        case (opcode)
            3'b000: comb_result = accum + data_in; // ADD
            3'b001: comb_result = accum - data_in; // SUB
            3'b010: comb_result = accum & data_in; // BITWISE AND
            3'b011: comb_result = accum | data_in; // BITWISE OR
            3'b100: comb_result = accum ^ data_in; // BITWISE XOR
            3'b101: comb_result = data_in;         // LOAD new data
            3'b110: comb_result = accum << 1;      // SHIFT LEFT
            3'b111: comb_result = accum >> 1;      // SHIFT RIGHT
            default: comb_result = accum;
        endcase
    end

    // 2. SEQUENTIAL BLOCK
    // Updates the accumulator register on the clock edge
    always @(posedge clk) begin
        if (!rst_n) begin
            accum <= 8'b0000_0000;
        end else begin
            accum <= comb_result;
        end
    end

endmodule
