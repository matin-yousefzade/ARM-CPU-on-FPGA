module Register_File (clk, rst, src1, src2, Dest_wb, Resault_WB, writeBackEn, reg1, reg2);
  
  input [31:0] Resault_WB;
  input [3:0] src1, src2, Dest_wb;
  input clk, rst, writeBackEn;
  output [31:0] reg1, reg2;
  
  reg [31:0] array [0:14];
  integer i;
  
  assign reg1 = array[src1];
  assign reg2 = array[src2];
  
  always @(negedge clk, posedge rst) begin
    if(rst) begin
      for(i = 0; i < 15; i = i + 1) array[i] = 32'h0;
    end
    else if(writeBackEn) begin
      array[Dest_wb] = Resault_WB;
    end
  end
  
endmodule