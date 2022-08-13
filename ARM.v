module ARM (clk, rst, SRAM_ADDR, SRAM_DQ, SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N);
  
  input clk, rst;
  output [17:0] SRAM_ADDR;
  inout [15:0] SRAM_DQ;
  output SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N;
  
  
  wire [31:0] IF_PC, ID_PC, EXE_PC, IF_Instruction, ID_Instruction, EXE_ALU_result, MEM_ALU_result, WB_ALU_result, BranchAddr, Result_WB;
  wire [31:0] MEM_Mem_read_value, WB_Mem_read_value, ID_Val_Rn, EXE_Val_Rn, ID_Val_Rm, EXE_Val_Rm, EXE_ST_val, MEM_ST_val;
  wire [31:0] sram_address, sram_wdata, sram_rdata;
  wire [23:0] ID_Signed_imm_24, EXE_Signed_imm_24;
  wire [11:0] ID_Shift_operand, EXE_Shift_operand;
  wire [3:0] ID_Dest, EXE_Dest, MEM_Dest, WB_Dest, ID_EXE_CMD, EXE_EXE_CMD, ID_src1, EXE_src1, ID_src2, EXE_src2, status, SR;
  wire [1:0] sel_src1, sel_src2;
  wire ID_WB_EN, EXE_WB_EN, MEM_WB_EN, WB_WB_EN, ID_MEM_R_EN, EXE_MEM_R_EN, MEM_MEM_R_EN, WB_MEM_R_EN, ID_MEM_W_EN, EXE_MEM_W_EN, MEM_MEM_W_EN;
  wire ID_B, EXE_B, ID_S, EXE_S, ID_imm, EXE_imm, Two_src, MOV_MVN, NOP, hazard, MEM_Ready;
  wire sram_read, sram_write, sram_ready;
  
  //Status Register
  Status_Register R1(status, EXE_S, clk, rst, SR);
  
  //IF
  IF_Stage G1(clk, rst, (~MEM_Ready || hazard), EXE_B, BranchAddr, IF_PC, IF_Instruction);
  IF_Stage_Reg G2(clk, rst, (~MEM_Ready || hazard), EXE_B, IF_PC, IF_Instruction, ID_PC, ID_Instruction);
  
  //ID
  ID_Stage G3(clk, rst, ID_Instruction, Result_WB, WB_WB_EN, WB_Dest, hazard, SR, ID_WB_EN, ID_MEM_R_EN, ID_MEM_W_EN, ID_B, ID_S,
              ID_EXE_CMD, ID_Val_Rn, ID_Val_Rm, ID_imm, ID_Shift_operand, ID_Signed_imm_24, ID_Dest, ID_src1, ID_src2, Two_src, MOV_MVN, NOP);
  ID_Stage_Reg G4(clk, rst, ~MEM_Ready, EXE_B, ID_WB_EN, ID_MEM_R_EN, ID_MEM_W_EN, ID_B, ID_S, ID_EXE_CMD, ID_PC, ID_Val_Rn, ID_Val_Rm, ID_imm,
                  ID_Shift_operand, ID_Signed_imm_24, ID_Dest, ID_src1, ID_src2, EXE_WB_EN, EXE_MEM_R_EN, EXE_MEM_W_EN, EXE_B, EXE_S,
                  EXE_EXE_CMD, EXE_PC, EXE_Val_Rn, EXE_Val_Rm, EXE_imm, EXE_Shift_operand, EXE_Signed_imm_24, EXE_Dest, EXE_src1, EXE_src2);
                
  //EXE
  EXE_Stage G5(clk, EXE_EXE_CMD, EXE_MEM_R_EN, EXE_MEM_W_EN, EXE_PC, EXE_Val_Rn, EXE_Val_Rm, EXE_imm, EXE_Shift_operand, EXE_Signed_imm_24,
               SR, MEM_ALU_result, Result_WB, sel_src1, sel_src2, EXE_ALU_result, EXE_ST_val, BranchAddr, status);
  EXE_Stage_Reg G6(clk, rst, ~MEM_Ready, EXE_WB_EN, EXE_MEM_R_EN, EXE_MEM_W_EN, EXE_ALU_result, EXE_ST_val, EXE_Dest,
                   MEM_WB_EN, MEM_MEM_R_EN, MEM_MEM_W_EN, MEM_ALU_result, MEM_ST_val, MEM_Dest);

  //MEM
  Cache_Controller_v1 G7(clk, rst, MEM_ALU_result, MEM_ST_val, MEM_MEM_R_EN, MEM_MEM_W_EN, MEM_Mem_read_value, MEM_Ready,
                      sram_address, sram_wdata, sram_read, sram_write, sram_rdata, sram_ready);
  SRAM_Controller G8(clk, rst, sram_write, sram_read, sram_address, sram_rdata, sram_wdata, sram_ready,
                     SRAM_DQ, SRAM_ADDR, SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N);
  MEM_Stage_Reg G9(clk, rst, ~MEM_Ready, MEM_WB_EN, MEM_MEM_R_EN, MEM_ALU_result, MEM_Mem_read_value, MEM_Dest,
                    WB_WB_EN, WB_MEM_R_EN, WB_ALU_result, WB_Mem_read_value, WB_Dest);
                      
  //WB
  WB_Stage G10(WB_ALU_result, WB_Mem_read_value, WB_MEM_R_EN, Result_WB);
  
  //Forwarding Unit
  Forwarding_Unit G11(EXE_src1, EXE_src2, MEM_Dest, MEM_WB_EN, WB_Dest, WB_WB_EN, sel_src1, sel_src2);
  
  //Hazard Detection Unit
  Hazard_Detection_Unit G12(ID_src1, ID_src2, EXE_Dest, EXE_MEM_R_EN, MOV_MVN, Two_src, NOP, hazard);
  
endmodule