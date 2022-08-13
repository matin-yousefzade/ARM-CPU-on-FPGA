module Forwarding_Unit (src1, src2, MEM_Dest, MEM_WB_EN, WB_Dest, WB_WB_EN, sel_src1, sel_src2);
  
  input [3:0] src1, src2, MEM_Dest, WB_Dest;
  input MEM_WB_EN, WB_WB_EN;
  output reg [1:0] sel_src1, sel_src2;
  
  always @(src1, MEM_Dest, MEM_WB_EN, WB_Dest, WB_WB_EN) begin
    sel_src1 = 2'h0;
    if(MEM_WB_EN && src1 == MEM_Dest) sel_src1 = 2'h1;
    else if(WB_WB_EN && src1 == WB_Dest) sel_src1 = 2'h2;
  end
  
  always @(src2, MEM_Dest, MEM_WB_EN, WB_Dest, WB_WB_EN) begin
    sel_src2 = 2'h0;
    if(MEM_WB_EN && src2 == MEM_Dest) sel_src2 = 2'h1;
    else if(WB_WB_EN && src2 == WB_Dest) sel_src2 = 2'h2;
  end
  
endmodule