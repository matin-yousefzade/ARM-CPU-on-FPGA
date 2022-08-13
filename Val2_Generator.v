module Val2_Generator (Val_Rm, imm, mem_access, Shift_operand, Val2);
  
  input [31:0] Val_Rm;
  input imm, mem_access;
  input [11:0] Shift_operand;
  output reg [31:0] Val2;
  
  wire [63:0] Imm_Imm = {24'h0, Shift_operand[7:0], 24'h0, Shift_operand[7:0]};
  wire [63:0] Zero_Val_Rm = {32'h0, Val_Rm};
  wire [63:0] Val_Rm_Zero = {Val_Rm, 32'h0};
  wire [63:0] One_Val_Rm = {32'hFFFFFFFF, Val_Rm};
  wire [63:0] Val_Rm_Val_Rm = {Val_Rm, Val_Rm};
  
  always @(Val_Rm, imm, mem_access, Shift_operand) begin
    case({mem_access, imm})
      2'b00: begin
        case(Shift_operand[6:5])
          2'b00: Val2 = Val_Rm_Zero[63 - Shift_operand[11:7] -: 32];
          2'b01: Val2 = Zero_Val_Rm[31 + Shift_operand[11:7] -: 32];
          2'b10: Val2 = Val_Rm[31] ? One_Val_Rm[31 + Shift_operand[11:7] -: 32] : Zero_Val_Rm[31 + Shift_operand[11:7] -: 32];
          2'b11: Val2 = Val_Rm_Val_Rm[31 + Shift_operand[11:7] -: 32];
          default : Val2 = 32'h0;
        endcase
      end 
      2'b01: Val2 = Imm_Imm[31 + 2 * Shift_operand[11:8] -: 32];
      2'b10, 2'b11: Val2 = {20'h0, Shift_operand};
      default: Val2 = 32'h0;
    endcase 
  end

endmodule