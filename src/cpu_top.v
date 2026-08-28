module cpu_top (
    input clk, reset,
    input irq,              // Simple edge/level interrupt request
    output [31:0] out_data
);

    // --- Minimal Interrupt State ---
    reg [7:0] mepc;         
    localparam ISR_VECTOR = 8'h04; 

    // Edge detection register
    reg prev_irq;           
    wire irq_edge = irq & ~prev_irq; // Only true for exactly 1 clock cycle

    // --- Program Counter ---
    reg [7:0] pc;
    reg [7:0] normal_pc_next; // The PC if NO interrupt occurs

    // --- Instruction Fetch ---
    wire [31:0] instr;
    rom #( .DEPTH(64), .WIDTH(32) ) instr_mem (
        .clk(clk),
        .addr_rd(pc[5:0]), 
        .data_rom_out(instr)
    );

    // --- Instruction Decode ---
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    
    // Minimal control flow decoding
    wire is_branch = (opcode == 7'b1100011);
    wire is_jal    = (opcode == 7'b1101111);
    wire is_jalr   = (opcode == 7'b1100111);
    wire is_mret   = (opcode == 7'b1110011); // Return from interrupt

    // Standard control signals
    wire reg_write, mem_write, mem_to_reg, alu_src;
    wire [2:0] alu_op;
    wire [3:0] alu_opcode;

    control_unit cu (
        .opcode(opcode),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),      
        .alu_op(alu_op)
    );

    alu_control alu_ctrl (
        .funct3(funct3),
        .funct7(instr[31:25]),
        .alu_op(alu_op),
        .alu_opcode(alu_opcode)
    );

    // --- Immediate Extraction ---
    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]}; 
    wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_b = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

    // ALU Immediate Mux
    wire [31:0] alu_imm = (opcode == 7'b0100011) ? imm_s : imm_i;

    // --- Register File & Writeback ---
    wire [31:0] reg_a, reg_b, ram_data;
    
    // JAL/JALR override: force writeback of PC+1 (return address)
    wire final_reg_write = reg_write | is_jal | is_jalr;
    wire [31:0] write_data = (is_jal | is_jalr) ? {24'b0, pc + 8'd1} : 
                             (mem_to_reg ? ram_data : out_data);

    regfile rf (
        .clk(clk),
        .we(final_reg_write),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .wd(write_data),        
        .rd1(reg_a),
        .rd2(reg_b)
    );


    
// Explicitly declare ONLY the dummy wires
    wire unused_cout, unused_borrow, unused_parity, unused_inv;

    // --- ALU ---
    ALU #( .BUS_WIDTH(32) ) myalu (
        .a(reg_a),
        .b(alu_src ? alu_imm : reg_b),
        .carry_in(1'b0),
        .opcode(alu_opcode),
        .y(out_data),            // CRITICAL FIX: Reconnect directly to the CPU output
        .zero(zero),
        .carry_out(unused_cout),
        .borrow(unused_borrow),
        .parity(unused_parity),
        .invalid_op(unused_inv)
    );


    // // --- ALU ---
    // wire zero;
    // ALU #( .BUS_WIDTH(32) ) myalu (
    //     .a(reg_a),
    //     .b(alu_src ? alu_imm : reg_b),
    //     .carry_in(1'b0),
    //     .opcode(alu_opcode),
    //     .y(out_data),
    //     .zero(zero)
    // );

    // --- Data RAM ---
    parameterized_RAM #( .DATA_WIDTH(32), .ADDR_WIDTH(6) ) dataRam (
        .clk(clk),
        .reset(reset),
        .we(mem_write),
        .address(out_data[7:2]), // Word alignment
        .data_in(reg_b),         
        .data_ram_out(ram_data)
    );

    // --- Next PC / Control Flow Multiplexer ---
    wire branch_taken = is_branch & ((funct3 == 3'b000 & zero) | (funct3 == 3'b001 & !zero));

    always @(*) begin
        // Default normal flow
        normal_pc_next = pc + 8'd1; 
        
        if (is_mret) 
            normal_pc_next = mepc;
        else if (is_jal) 
            normal_pc_next = pc + imm_j[9:2];
        else if (is_jalr) 
            normal_pc_next = reg_a[7:0] + imm_i[9:2]; // Sliced to [7:0] to prevent width mismatch
        else if (branch_taken) 
            normal_pc_next = pc + imm_b[9:2];
    end

    // --- PC and Interrupt State Update ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 8'd0;
            mepc <= 8'd0;
            prev_irq <= 1'b0;
        end else begin
            prev_irq <= irq; 
            
            if (irq_edge) begin
                // CRITICAL FIX: Save the resolved 'normal_pc_next' so we don't 
                // accidentally drop branch targets if an interrupt hits simultaneously.
                mepc <= normal_pc_next;
                pc <= ISR_VECTOR;
            end else begin
                pc <= normal_pc_next;
            end
        end
    end

endmodule








// module cpu_top (
//     input clk, reset,
//     output [31:0] out_data,
//     inout VPWR,
//     inout VGND
// );
//     // Program Counter
//     reg [7:0] pc;
//     always @(posedge clk or posedge reset) begin
//         if (reset) pc <= 0;
//         else pc <= pc + 1; // simple sequential fetch
//     end

//     // Instruction fetch
//     wire [31:0] instr;
//     // rom #( .DEPTH(16), .WIDTH(32) ) instr_mem (
//     rom #( .DEPTH(64), .WIDTH(32) ) instr_mem (
//         .clk(clk),
//         .addr_rd(pc[5:0]), 
//   //      .addr_rd(pc[3:0]), 
//         .data_rom_out(instr)
//     );

//     // Decode fields 
//     wire [4:0] rd     = instr[11:7];
//     wire [2:0] funct3 = instr[14:12];
//     wire [4:0] rs1    = instr[19:15];
//     wire [4:0] rs2    = instr[24:20];  
//     wire [6:0] funct7 = instr[31:25];    
//     wire [6:0] opcode = instr[6:0];

//     // Control signals
//     wire reg_write, mem_write, mem_to_reg, alu_src;
//     wire [2:0] alu_op;
//     wire [3:0] alu_opcode;

//     control_unit cu (
//         .opcode(opcode),
//         .reg_write(reg_write),
//         .mem_write(mem_write),
//         .mem_to_reg(mem_to_reg),
//         .alu_src(alu_src),      // NEW: Selects Imm vs Reg for ALU
//         .alu_op(alu_op)
//     );

//     alu_control alu_ctrl (
//         .funct3(funct3),
//         .funct7(funct7),
//         .alu_op(alu_op),
//         .alu_opcode(alu_opcode)
//     );

//     // Write-back Multiplexer (NEW: Allows loading from RAM)
//     wire [31:0] write_data;
//  //    wire [31:0] ram_data;
//     assign write_data = mem_to_reg ? ram_data : out_data;

//     // Register file
//     wire [31:0] reg_a, reg_b;
//     regfile rf (
//         .clk(clk),
//         .we(reg_write),
//         .rs1(instr[19:15]),
//         .rs2(instr[24:20]),
//         .rd(instr[11:7]),
//         .wd(write_data),        // FIXED: Now connects to the Write-back Mux
//         .rd1(reg_a),
//         .rd2(reg_b)
//     );

//     // Immediate generators (NEW: Added S-Type for Stores)
//     wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]}; 
//     wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};

//     // Choose which immediate to use based on opcode
//     wire [31:0] imm_val = (opcode == 7'b0100011) ? imm_s : imm_i;

//     // ALU operand B Multiplexer
//     wire [31:0] alu_b;
//     assign alu_b = alu_src ? imm_val : reg_b; // FIXED: Uses alu_src from Control Unit

//     // ALU
//     wire carry_out, borrow, zero, parity, invalid_op;
//     ALU #( .BUS_WIDTH(32) ) myalu (
//         .a(reg_a),
//         .b(alu_b),
//         .carry_in(1'b0),
//         .opcode(alu_opcode),
//         .y(out_data),
//         .carry_out(carry_out),
//         .borrow(borrow),
//         .zero(zero),
//         .parity(parity),
//         .invalid_op(invalid_op)
//     );

//     // Data RAM
//    // Data RAM
//     wire [31:0] ram_data;
//     parameterized_RAM #( .DATA_WIDTH(32), .ADDR_WIDTH(6) ) dataRam (
//         .clk(clk),
//         .reset(reset),
//         .we(mem_write),
//         .address(out_data[7:2]), // FIXED: Shift right by 2 to divide by 4 (Word Addressing)
//         .data_in(reg_b),         
//         .data_ram_out(ram_data)
//     );


// endmodule




// module cpu_top (
//     input clk, reset,
//     output [31:0] out_data,
//       inout VPWR,
//   inout VGND
// );
//     // Program Counter
//     reg [7:0] pc;
//     always @(posedge clk or posedge reset) begin
//         if (reset) pc <= 0;
//         else pc <= pc + 1; // simple sequential fetch
//     end

//     // Instruction fetch
//     wire [31:0] instr;
//     rom #( .DEPTH(16), .WIDTH(32) ) instr_mem (
//         .clk(clk),
//         .addr_rd(pc[3:0]), // lower bits as address
//         .data_rom_out(instr)
//     );

//     // Decode fields (for now, treat instr as opcode directly)
//     // RISC-V RV32I fields
// wire [4:0] rd     = instr[11:7];
// wire [2:0] funct3 = instr[14:12];
// wire [4:0] rs1    = instr[19:15];
// wire [4:0] rs2    = instr[24:20];  // for 
// wire [6:0] funct7 = instr[31:25];    // for funct7 

//     // Control signals
//     wire reg_write, mem_write, mem_to_reg;
//     wire [2:0] alu_op;
//     wire [3:0] alu_opcode;

// wire [6:0] opcode = instr[6:0];

//     control_unit cu (
//         .opcode(opcode),
//         .reg_write(reg_write),
//         .mem_write(mem_write),
//         .mem_to_reg(mem_to_reg),
//         .alu_op(alu_op)
//     );

//     alu_control alu_ctrl (
//         .funct3(funct3),
//         .funct7(funct7),
//         .alu_op(alu_op),
//         .alu_opcode(alu_opcode)
//     );

//     // Register file
//     wire [31:0] reg_a, reg_b, write_data;
//     regfile rf (
//         .clk(clk),
//         .we(reg_write),
//         .rs1(instr[19:15]), //  adjust for 8-bit ISA
//         .rs2(instr[24:20]),
//         .rd(instr[11:7]),
//         .wd(out_data),
//         .rd1(reg_a),
//         .rd2(reg_b)
//     );

//     // ALU
//     wire  [31:0] alu_b;
//     wire carry_out, borrow, zero, parity, invalid_op;
//     ALU #( .BUS_WIDTH(32) ) myalu (
//         .a(reg_a),
//         .b(alu_b),
//         .carry_in(1'b0),
//         .opcode(alu_opcode),
//         .y(out_data),
//         .carry_out(carry_out),
//         .borrow(borrow),
//         .zero(zero),
//         .parity(parity),
//         .invalid_op(invalid_op)
//     );

//     // Data RAM
//     wire [31:0] ram_data;
//     parameterized_RAM #( .DATA_WIDTH(32), .ADDR_WIDTH(6) ) dataRam (
//         .clk(clk),
//         .reset(reset),
//         .we(mem_write),
//         .address(out_data[5:0]),
//         .data_in(reg_b),
//         .data_ram_out(ram_data)
//     );



//     // Immediate generator (basic for I-type like ADDI)
// wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]}; // sign-extend

// // Choose ALU second operand: register or immediate
// assign alu_b = (alu_op == 3'b011) ? imm_i : reg_b;


// endmodule


