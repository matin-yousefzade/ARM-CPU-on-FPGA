 module SRAM_Controller (clk, rst, wr_en, rd_en, address, readData, writeData, ready,
                         SRAM_DQ, SRAM_ADDR, SRAM_UB_N, SRAM_LB_N, SRAM_WE_N, SRAM_CE_N, SRAM_OE_N);
  
  input clk, rst, wr_en, rd_en;
  input [31:0] address, writeData;
  output reg [31:0] readData;
  output reg ready;
  inout [15:0] SRAM_DQ;
  output [17:0] SRAM_ADDR;
  output reg SRAM_WE_N;
  output SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N;
  
  parameter [1:0] idle = 3'h0, LHW = 3'h1, SHW = 3'h2, finish = 3'h3;
  
  wire [15:0] DQ;
  reg sel_Data, sel_Addr, Load_LW, Load_HW;
  
  assign SRAM_DQ = SRAM_WE_N ? 16'bz : DQ;
  assign {SRAM_UB_N, SRAM_LB_N, SRAM_CE_N, SRAM_OE_N} = 4'b0;
  assign DQ = sel_Data ? writeData[31:16] : writeData[15:0];
  assign SRAM_ADDR = sel_Addr ? ({address[18:2], 1'b0} - 18'h1FF) : ({address[18:2], 1'b0} - 18'h200);
  
  always @(posedge clk, posedge rst) begin
    if(rst) readData <= 32'h0;
    else begin
      if(Load_LW) readData[15:0] <= SRAM_DQ;
      if(Load_HW) readData[31:16] <= SRAM_DQ;
    end
  end
  
  reg [1:0] ps, ns;
  always @(ps, wr_en, rd_en) begin
    begin ns = idle; {Load_HW, Load_LW, sel_Addr, sel_Data, ready, SRAM_WE_N} = 6'h1; end
    case(ps)
      idle: begin ns = wr_en ? SHW : rd_en ? LHW : idle; SRAM_WE_N = ~wr_en; Load_LW = rd_en; ready = ~(wr_en || rd_en); end
      LHW: begin ns = finish; sel_Addr = 1'h1; Load_HW = 1'h1; end
      SHW: begin ns = finish; SRAM_WE_N = 1'h0; sel_Addr = 1'h1; sel_Data = 1'h1; end
      finish: begin ns = idle; ready = 1'h1; end
      default: begin ns = idle; {Load_HW, Load_LW, sel_Addr, sel_Data, ready, SRAM_WE_N} = 6'h1; end
    endcase
  end
  
  always @(posedge clk, posedge rst) begin
    if(rst) ps <= idle;
    else ps <= ns;
  end
  
endmodule