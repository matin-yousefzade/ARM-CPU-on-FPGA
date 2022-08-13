module ID_Stage_Reg (clk, rst, freeze, flush, WB_EN_IN, MEM_R_EN_IN, MEM_W_EN_IN, B_IN, S_IN, EXE_CMD_IN, PC_IN, Val_Rn_IN, Val_Rm_IN, imm_IN,
                     Shift_operand_IN, Signed_imm_24_IN, Dest_IN, src1_IN, src2_IN, WB_EN, MEM_R_EN, MEM_W_EN, B, S, EXE_CMD, PC,
                     Val_Rn, Val_Rm, imm, Shift_operand, Signed_imm_24, Dest, src1, src2);
                     
  input [31:0] PC_IN, Val_Rn_IN, Val_Rm_IN;
  input [23:0] Signed_imm_24_IN;
  input [11:0] Shift_operand_IN;
  input [3:0] EXE_CMD_IN, Dest_IN, src1_IN, src2_IN;
  input clk, rst, flush, WB_EN_IN, MEM_R_EN_IN, MEM_W_EN_IN, B_IN, S_IN, imm_IN, freeze;
  output reg [31:0] PC, Val_Rn, Val_Rm;
  output reg [23:0] Signed_imm_24;
  output reg [11:0] Shift_operand;
  output reg [3:0] EXE_CMD, Dest, src1, src2;
  output reg WB_EN, MEM_R_EN, MEM_W_EN, B, S, imm;
  
  always @(posedge clk, posedge rst) begin
    if(rst) {WB_EN, MEM_R_EN, MEM_W_EN, B, S, EXE_CMD, PC, Val_Rn, Val_Rm, imm, Shift_operand, Signed_imm_24, Dest, src1, src2} <= 154'h0;
    else begin
      case({freeze, flush})
        2'b00: {WB_EN, MEM_R_EN, MEM_W_EN, B, S, EXE_CMD, PC, Val_Rn, Val_Rm, imm, Shift_operand, Signed_imm_24, Dest, src1, src2} <= {WB_EN_IN, MEM_R_EN_IN, MEM_W_EN_IN, B_IN, S_IN, EXE_CMD_IN, PC_IN, Val_Rn_IN, Val_Rm_IN, imm_IN, Shift_operand_IN, Signed_imm_24_IN, Dest_IN, src1_IN, src2_IN};
        2'b01: {WB_EN, MEM_R_EN, MEM_W_EN, B, S, EXE_CMD, PC, Val_Rn, Val_Rm, imm, Shift_operand, Signed_imm_24, Dest, src1, src2} <= 154'h0;
        default: {WB_EN, MEM_R_EN, MEM_W_EN, B, S, EXE_CMD, PC, Val_Rn, Val_Rm, imm, Shift_operand, Signed_imm_24, Dest, src1, src2} <= {WB_EN, MEM_R_EN, MEM_W_EN, B, S, EXE_CMD, PC, Val_Rn, Val_Rm, imm, Shift_operand, Signed_imm_24, Dest, src1, src2};
      endcase
    end
  end
  
endmodule