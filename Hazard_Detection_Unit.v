module Hazard_Detection_Unit (src1, src2, Exe_Dest, Exe_Mem_R_EN, MOV_MVN, Two_src, NOP, hazard_Detected);
  
  input [3:0] src1, src2, Exe_Dest;
  input Exe_Mem_R_EN, MOV_MVN, Two_src, NOP;
  output reg hazard_Detected;
  
  always @(src1, src2, Exe_Dest, Exe_Mem_R_EN, MOV_MVN, Two_src, NOP) begin
    hazard_Detected = 1'b0;
    if(~NOP && Exe_Mem_R_EN && ((~MOV_MVN && src1 == Exe_Dest) || (Two_src && src2 == Exe_Dest))) hazard_Detected = 1'b1;
  end
  
endmodule