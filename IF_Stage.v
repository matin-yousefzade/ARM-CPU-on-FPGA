module IF_Stage (clk, rst, freeze, Branch_taken, BranchAddr, PC, Instruction);
  
  input [31:0] BranchAddr;
  input clk, rst, freeze, Branch_taken;
  output [31:0] PC, Instruction;
  
  wire [31:0] par_PC, last_PC;
  
  Mux_1s #32 M1(PC, BranchAddr, Branch_taken, par_PC);
  Register #32 R1(par_PC, ~freeze, clk, rst, last_PC);
  Adder #32 G1(32'h4, last_PC, PC);
  Instruction_Memory G2(rst, last_PC, Instruction);
  
endmodule