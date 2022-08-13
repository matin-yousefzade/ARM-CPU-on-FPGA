module EXE_Stage (clk, EXE_CMD, MEM_R_EN, MEM_W_EN, PC, Val_Rn, Val_Rm, imm, Shift_operand, Signed_imm_24, SR, MEM_Forward_Data,
                  WB_Forward_Data, sel_src1, sel_src2, ALU_result, ST_val, Br_addr, status);
  
  input [31:0] Val_Rn, Val_Rm, PC, MEM_Forward_Data, WB_Forward_Data;
  input [23:0] Signed_imm_24;
  input [11:0] Shift_operand;
  input [3:0] EXE_CMD, SR;
  input [1:0] sel_src1, sel_src2;
  input clk, MEM_R_EN, MEM_W_EN, imm;
  output [31:0] ALU_result, ST_val, Br_addr;
  output [3:0] status;
  
  wire [31:0] Signed_imm_32 = Signed_imm_24[23] ? {6'h3F, Signed_imm_24, 2'h0} : {6'h00, Signed_imm_24, 2'h0};
  wire [31:0] ALU_A, ALU_B;
  
  Mux_2s #32 M1(Val_Rn, MEM_Forward_Data, WB_Forward_Data, 32'h0, sel_src1, ALU_A);
  Mux_2s #32 M2(Val_Rm, MEM_Forward_Data, WB_Forward_Data, 32'h0, sel_src2, ST_val);
  
  Val2_Generator G1(ST_val, imm, (MEM_R_EN || MEM_W_EN), Shift_operand, ALU_B);
  ALU G2(ALU_A, ALU_B, EXE_CMD, SR[1], ALU_result, status);
  
  Adder #32 G3(PC, Signed_imm_32, Br_addr);
  
endmodule