`default_nettype none

module tt_um_cpu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // Tie off bidirectional pins (configured as inputs)
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Map TinyTapeout signals to CPU signals
    wire reset = ~rst_n;      // TinyTapeout reset is active low, cpu_top is active high
    wire irq = ui_in[0];      // Use input pin 0 for interrupts
    wire [1:0] mux_sel = ui_in[2:1]; // Use input pins 1 and 2 to select which output byte to read

    wire [31:0] full_out_data;

    // Output multiplexer to view 32-bit data on an 8-bit port
    assign uo_out = (mux_sel == 2'b00) ? full_out_data[7:0]   :
                    (mux_sel == 2'b01) ? full_out_data[15:8]  :
                    (mux_sel == 2'b10) ? full_out_data[23:16] :
                                         full_out_data[31:24];

    // Instantiate your CPU
    cpu_top core (
        .clk(clk),
        .reset(reset),
        .irq(irq),
        .out_data(full_out_data)
    );

endmodule