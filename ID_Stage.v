module ID_Stage (clk, rst, Instraction, Resault_WB, writeBackEn, Dest_wb, hazard, SR, WB_EN, MEM_R_EN, MEM_W_EN, B, S, EXE_CMD,
                 Val_Rn, Val_Rm, imm, Shift_operand, Signed_imm_24, Dest, src1, src2, Two_src, MOV_MVN, NOP);
  
  input [31:0] Instraction, Resault_WB;
  input [3:0] Dest_wb, SR;
  input clk, rst, writeBackEn, hazard;
  output [31:0] Val_Rn, Val_Rm;
  output [23:0] Signed_imm_24;
  output [11:0] Shift_operand;
  output [3:0] EXE_CMD, Dest, src1, src2;
  output WB_EN, MEM_R_EN, MEM_W_EN, B, S, imm, Two_src, MOV_MVN, NOP;
  
  wire [8:0] control_signals;
  wire valid;
  
  assign imm = Instraction[25];
  assign Shift_operand = Instraction[11:0];
  assign Signed_imm_24 = Instraction[23:0];
  assign Dest = Instraction[15:12];
  assign src1 = Instraction[19:16];
  assign Two_src = ~imm || control_signals[3];
  assign MOV_MVN = (Instraction[24:21] == 4'b1101 || Instraction[24:21] == 4'b1111);
  assign NOP = ~(|Instraction);
  
  Mux_1s #9 M1(control_signals, 9'h0, (~valid || hazard), {EXE_CMD, MEM_R_EN, MEM_W_EN, WB_EN, B, S});
  Mux_1s #4 M2(Instraction[3:0], Instraction[15:12], control_signals[3], src2);

  Condition_Check G1(Instraction[31:28], SR, valid);
  Control_Unit G2(Instraction[27:26], Instraction[24:21], Instraction[20], NOP, control_signals[8:5], control_signals[4], control_signals[3], control_signals[2], control_signals[1], control_signals[0]);
  Register_File G3(clk, rst, Instraction[19:16], src2, Dest_wb, Resault_WB, writeBackEn, Val_Rn, Val_Rm);
  
endmodule