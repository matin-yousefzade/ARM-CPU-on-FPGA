module MEM_Stage_Reg (clk, rst, freeze, WB_en_in, MEM_R_en_in, ALU_result_in, Mem_read_value_in, Dest_in,
                      WB_en, MEM_R_en, ALU_result, Mem_read_value, Dest);
                      
  input [31:0] ALU_result_in, Mem_read_value_in;
  input [3:0] Dest_in;
  input clk, rst, freeze, WB_en_in, MEM_R_en_in;
  output reg [31:0] ALU_result, Mem_read_value;
  output reg [3:0] Dest;
  output reg WB_en, MEM_R_en;
  
  always @(posedge clk, posedge rst) begin
    if(rst) {WB_en, MEM_R_en, ALU_result, Mem_read_value, Dest} <= 70'h0;
    else if(~freeze) {WB_en, MEM_R_en, ALU_result, Mem_read_value, Dest} <= {WB_en_in, MEM_R_en_in, ALU_result_in, Mem_read_value_in, Dest_in};
  end
  
endmodule