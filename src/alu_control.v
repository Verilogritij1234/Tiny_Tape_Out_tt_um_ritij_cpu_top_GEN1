module alu_control (
    input [2:0] funct3,
    input [6:0] funct7,
    input [2:0] alu_op,        // from control unit
    output reg [3:0] alu_opcode // to ALU
);

    always @(*) begin
        alu_opcode = 4'd0; // default invalid

        case (alu_op)
            3'b010: begin // R-type
                case (funct3)
                    3'b000: alu_opcode = (funct7 == 7'b0100000) ? 4'd3 : 4'd1; // SUB : ADD
                    3'b111: alu_opcode = 4'd6;  // AND
                    3'b110: alu_opcode = 4'd10; // FIXED: OR is now 10
                    3'b100: alu_opcode = 4'd11; // NEW: XOR is 11
                    3'b001: alu_opcode = 4'd8;  // Shift to left side   
                    3'b101: alu_opcode = 4'd9;  // Shift to right side 
                    default: alu_opcode = 4'd0;
                endcase
            end
            3'b011: begin // I-type
                case (funct3)
                    3'b000: alu_opcode = 4'd1;  // ADDI
                    3'b111: alu_opcode = 4'd6;  // ANDI
                    3'b110: alu_opcode = 4'd10; // FIXED: ORI is now 10
                    3'b100: alu_opcode = 4'd11; // NEW: XORI is 11
                    default: alu_opcode = 4'd0;
                endcase
            end
            3'b000: alu_opcode = 4'd1; // address calc for LOAD/STORE = ADD
            3'b001: alu_opcode = 4'd3; // branch compare = SUB
            default: alu_opcode = 4'd0;
        endcase
    end
endmodule






// module alu_control (
//     input [2:0] funct3,
//     input [6:0] funct7,
//     input [2:0] alu_op,        // from control unit
//     output reg [3:0] alu_opcode // to ALU
// );

//     always @(*) begin
//         alu_opcode = 4'd0; // default invalid

//         case (alu_op)
//             3'b010: begin // R-type
//                 case (funct3)
//                     3'b000: alu_opcode = (funct7 == 7'b0100000) ? 4'd3 : 4'd1; // SUB : ADD
//                     3'b111: alu_opcode = 4'd6; // AND
//                     3'b110: alu_opcode = 4'd7; // OR (mapped to NOT in your ALU, but you can extend)
//                   //   3'b001: alu_opcode = 4'd8; // SLL -> ROL   
//                   //   3'b101: alu_opcode = 4'd9; // SRL -> ROR


//                          3'b001: alu_opcode = 4'd8; // Shift to left side   
//                     3'b101: alu_opcode = 4'd9; // shift to right side 
//                     default: alu_opcode = 4'd0;
//                 endcase
//             end
//             3'b011: begin // I-type
//                 case (funct3)
//                     3'b000: alu_opcode = 4'd1; // ADDI
//                     3'b111: alu_opcode = 4'd6; // ANDI
//                     3'b110: alu_opcode = 4'd7; // ORI
//                     default: alu_opcode = 4'd0;
//                 endcase
//             end
//             3'b000: alu_opcode = 4'd1; // address calc for LOAD/STORE = ADD
//             3'b001: alu_opcode = 4'd3; // branch compare = SUB
//             default: alu_opcode = 4'd0;
//         endcase
//     end
// endmodule