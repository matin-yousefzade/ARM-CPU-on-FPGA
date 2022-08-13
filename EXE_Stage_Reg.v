module EXE_Stage_Reg (clk, rst, freeze, WB_EN_in, MEM_R_EN_in, MEM_W_EN_in, ALU_result_in, ST_val_in, Dest_in,
                      WB_EN, MEM_R_EN, MEM_W_EN, ALU_result, ST_val, Dest);
                
  input [31:0] ALU_result_in, ST_val_in;
  input [3:0] Dest_in;
  input clk, rst, freeze, WB_EN_in, MEM_R_EN_in, MEM_W_EN_in;
  output reg [31:0] ALU_result, ST_val;
  output reg [3:0] Dest;
  output reg WB_EN, MEM_R_EN, MEM_W_EN;
  
  always @(posedge clk, posedge rst) begin
    if(rst) {WB_EN, MEM_R_EN, MEM_W_EN, ALU_result, ST_val, Dest} <= 71'h0;
    else if(~freeze) {WB_EN, MEM_R_EN, MEM_W_EN, ALU_result, ST_val, Dest} <= {WB_EN_in, MEM_R_EN_in, MEM_W_EN_in, ALU_result_in, ST_val_in, Dest_in};
  end
  
endmodule