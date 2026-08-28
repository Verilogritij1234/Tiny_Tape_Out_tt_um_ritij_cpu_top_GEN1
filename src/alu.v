module ALU 
#(parameter BUS_WIDTH = 32)
    (input [BUS_WIDTH-1:0]a,  // operand 1
    input [BUS_WIDTH-1:0]b,   // operand 2 
    input carry_in,  
    input [3:0]opcode,  
    output  reg [BUS_WIDTH-1:0]y,  
    output  reg carry_out,
    output  reg borrow,
    output  zero, 
    output  parity, 
    output  reg invalid_op
    );

    localparam OP_ADD = 1;
    localparam OP_ADD_CARRY = 2;
    localparam OP_SUB = 3;
    localparam OP_INC = 4;
    localparam OP_DEC = 5;
    localparam OP_AND = 6;
    localparam OP_NOT = 7;
    localparam OP_SOL = 8;
    localparam OP_SOR = 9;
    
    // NEW: Added missing RISC-V logic operations
    localparam OP_OR  = 10; 
    localparam OP_XOR = 11; 

    always @(*) begin
        y = 0;  carry_out  = 0;   borrow = 0;   invalid_op = 0; 
        
        case(opcode)
            OP_ADD:       begin y = a + b; end
            OP_ADD_CARRY: begin {carry_out,y} = a + b + carry_in; end
            OP_SUB:       begin {borrow,y}  = a - b; end
            OP_INC:       begin {carry_out,y} = a + 1'b1; end
            OP_DEC:       begin {borrow,y}  = a - 1'b1; end 
            OP_AND:       begin y = a & b; end
            OP_NOT:       begin y = ~a;  end
            OP_SOL:       begin y = {a[BUS_WIDTH-2:0], 1'b0}; end  
            OP_SOR:       begin y = {1'b0, a[BUS_WIDTH-1:1]}; end 
            OP_OR:        begin y = a | b; end   // NEW: Handles Bitwise OR
            OP_XOR:       begin y = a ^ b; end   // NEW: Handles Bitwise XOR
            default:      begin invalid_op = 1; end 
        endcase    
    end

    assign parity = ^y; 
    assign zero   = (y == 0);
endmodule






// module ALU 
// #(parameter BUS_WIDTH = 32)
//     (input [BUS_WIDTH-1:0]a,  // operand 1
//     input [BUS_WIDTH-1:0]b,   // operand 2 
//     input carry_in,  
//     input [3:0]opcode,  
//     output  reg [BUS_WIDTH-1:0]y,  
//     output  reg carry_out,
//     output  reg borrow,
//     output  zero, 
//     output  parity, 
//     output  reg invalid_op
//     );


//     localparam OP_ADD = 1;
//     localparam OP_ADD_CARRY = 2;
//     localparam OP_SUB = 3;
//     localparam OP_INC = 4;
//     localparam OP_DEC = 5;
//     localparam OP_AND = 6;
//     localparam OP_NOT = 7;
// //     localparam OP_ROL = 8;
// //     localparam OP_ROR = 9;

//     localparam OP_SOL = 8;
//     localparam OP_SOR = 9;

//     always @(*) begin
//     y = 0;  carry_out  = 0;   borrow = 0;   invalid_op = 0;  // initialisation of the output to zero
//     case(opcode)
//     OP_ADD:begin y = a+b; end
//     OP_ADD_CARRY: begin  {carry_out,y} = a+b+carry_in;     ; end
//     OP_SUB:begin  {borrow,y} = a - b;  end
//              //    borrow = a<b;  end
//     OP_INC:begin  {carry_out,y} = a+1'b1;   end
//     OP_DEC:begin  {borrow,y} = a-1'b1;   end 
//             //        borrow  = (a==0);   end
//     OP_AND:begin  y = a&b; end
//     OP_NOT:begin  y = ~a;  end
//   //  OP_ROL:begin  y = {a[BUS_WIDTH-2:0],a[BUS_WIDTH-1]};  end
//  //   OP_ROR:begin  y = {a[0],a[BUS_WIDTH-1:1]};  end 

//    OP_SOL:begin  y = {a[BUS_WIDTH-2:0],1'b0};  end  //  shift to left 
//    OP_SOR:begin  y = {1'b0,a[BUS_WIDTH-1:1]};  end   // shift to right 
//     default:begin  invalid_op = 1;  end 

//     endcase    
//     end

//  assign   parity = ^y; 
//   assign zero  = (y == 0);
// endmodule 





