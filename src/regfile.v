module regfile (
    input clk,
    input we,
    input [4:0] rs1, rs2, rd,
    input [31:0] wd,
    output [31:0] rd1, rd2
);
    reg [31:0] regs[31:0];

    // Initialize registers to zero
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 0;
    end

    // Read ports (combinational)
    assign rd1 = (rs1 == 0) ? 32'b0 : regs[rs1];
    assign rd2 = (rs2 == 0) ? 32'b0 : regs[rs2];

    // Write port (synchronous)
    always @(posedge clk) begin
        if (we && rd != 0) begin
            regs[rd] <= wd;
            $display("Register x%0d <= %h at time %0t", rd, wd, $time);
        end
    end
endmodule