`default_nettype none

module tt_um_alu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // We are using the bidirectional pins as inputs only for the opcode.
    // Therefore, we set output enable (uio_oe) to 0 and drive uio_out to 0.
    assign uio_oe  = 8'b0000_0000;
    assign uio_out = 8'b0000_0000;

    // Instantiate the core ALU logic
    alu_8bit my_alu (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(ui_in),
        .opcode(uio_in[2:0]),
        .accum(uo_out)
    );

endmodule
