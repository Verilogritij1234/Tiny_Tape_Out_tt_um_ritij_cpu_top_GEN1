module control_unit (
    input [6:0] opcode,       
    output reg reg_write,
    output reg mem_write,
    output reg mem_to_reg,
    output reg alu_src,       // NEW: 1 = Immediate, 0 = Register
    output reg [2:0] alu_op   
);
    // Opcodes (RV32I subset)
    localparam OP_RTYPE = 7'b0110011;
    localparam OP_ITYPE = 7'b0010011;
    localparam OP_LOAD  = 7'b0000011;
    localparam OP_STORE = 7'b0100011;
    localparam OP_BRANCH= 7'b1100011;

  always @(*) begin
    // Defaults
    reg_write  = 0;
    mem_write  = 0;
    mem_to_reg = 0;
    alu_src    = 0;           // Default to reading Register B
    alu_op     = 3'b000;

    case (opcode)
        OP_RTYPE: begin
            reg_write  = 1;
            alu_src    = 0;
            alu_op     = 3'b010; // R-type ALU ops
        end
        OP_ITYPE: begin
            reg_write  = 1;
            alu_src    = 1;      // FIXED: Use Immediate
            alu_op     = 3'b011; // I-type ALU ops
        end
        OP_LOAD: begin
            reg_write  = 1;
            mem_to_reg = 1;
            alu_src    = 1;      // FIXED: Use Immediate for Address
            alu_op     = 3'b000; // Force ADD for address calc
        end
        OP_STORE: begin
            mem_write  = 1;
            alu_src    = 1;      // FIXED: Use Immediate for Address
            alu_op     = 3'b000; // Force ADD for address calc
        end
        OP_BRANCH: begin
            alu_src    = 0;
            alu_op     = 3'b001; // compare (SUB)
 
 
        end
        default: begin
            // keep defaults
        end
    endcase
end
endmodule



// module control_unit (
//     input [6:0] opcode,       // instr[6:0] in reference with RISC architecture 
//     output reg reg_write,
//     output reg mem_write,
//     output reg mem_to_reg,
//     output reg [2:0] alu_op   // coarse ALU control
// );
//     // Opcodes (RV32I subset)
//     localparam OP_RTYPE = 7'b0110011;
//     localparam OP_ITYPE = 7'b0010011;
//     localparam OP_LOAD  = 7'b0000011;
//     localparam OP_STORE = 7'b0100011;
//     localparam OP_BRANCH= 7'b1100011;

//   always @(*) begin
//     // Defaults
//     reg_write  = 0;
//     mem_write  = 0;
//     mem_to_reg = 0;
//     alu_op     = 3'b000;

//     case (opcode)
//         OP_RTYPE: begin
//             reg_write  = 1;
//             alu_op     = 3'b010; // R-type ALU ops
//         end
//         OP_ITYPE: begin
//             reg_write  = 1;
//             alu_op     = 3'b011; // I-type ALU ops
//         end
//         OP_LOAD: begin
//             reg_write  = 1;
//             mem_to_reg = 1;
//             alu_op     = 3'b000; // address calc
//         end
//         OP_STORE: begin
//             mem_write  = 1;
//             alu_op     = 3'b000; // address calc
//         end
//         OP_BRANCH: begin
//             alu_op     = 3'b001; // compare (SUB)
//         end
//         default: begin
//             // keep defaults
//         end
//     endcase
// end
// endmodule

