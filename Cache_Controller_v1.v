module Cache_Controller_v1 (clk, rst, address, wdata, MEM_R_EN, MEM_W_EN, rdata, ready,
                         sram_address, sram_wdata, sram_read, sram_write, sram_rdata, sram_ready);
                         
  input clk, rst, MEM_R_EN, MEM_W_EN;
  input [31:0] address, wdata;                 
  output reg ready;
  output [31:0] rdata;                   

  input sram_ready;
  input [31:0] sram_rdata;
  output reg sram_write, sram_read;
  output [31:0] sram_address, sram_wdata;
  
  parameter [1:0] idle = 2'h0, read1 = 2'h1, read2 = 2'h2, write = 2'h3;
  
  reg [74:0] block0 [0:63];
  reg [74:0] block1 [0:63];
  reg [0:0] LRU [0:63];
  reg [63:0] block;
  reg update, load1, load2, invalid, sel_addr;
  wire offset = address[2];
  wire [5:0] index = address[8:3];
  wire [9:0] tag = address[18:9];
  wire hit, hit0, hit1;
  integer i;
  
  assign hit0 = block0[index][74] && (tag == block0[index][73:64]);
  assign hit1 = block1[index][74] && (tag == block1[index][73:64]);
  assign hit = hit0 || hit1;
  
  always @(block0, block1, index, hit0, hit1) begin
    case({hit1, hit0})
      2'b01: block = block0[index][63:0];
      2'b10: block = block1[index][63:0];
      default: block = 64'h0;
    endcase
  end
  
  assign rdata = offset ? block[63:32] : block[31:0];
  assign sram_wdata = wdata;
  assign sram_address = sel_addr ? {address[31:3], ~address[2:0]} : address;
  
  always @(posedge clk, posedge rst) begin
    if(rst) begin
      for(i = 0; i < 64; i = i + 1) begin
        block0[i] <= 75'h0;
        block1[i] <= 75'h0;
        LRU[i] <= 1'b0;
      end
    end
    
    else begin
      if(update) begin
        case({hit1, hit0})
          2'b01: LRU[index] <= 1'b1;
          2'b10: LRU[index] <= 1'b0;
          default: LRU[index] <= LRU[index];
        endcase
      end
      
      if(load1) begin
        case(LRU[index])
          1'b0: begin block0[index][74] <= 1'b1; block0[index][73:64] <= tag; end
          1'b1: begin block1[index][74] <= 1'b1; block1[index][73:64] <= tag; end
          default: begin block0[index] <= block0[index]; block1[index] <= block1[index]; end
        endcase
        case({LRU[index], offset})
          1'b00: block0[index][31:0] <= sram_rdata;
          1'b01: block0[index][63:32] <= sram_rdata;
          1'b10: block1[index][31:0] <= sram_rdata;
          1'b11: block1[index][63:32] <= sram_rdata;
          default: begin block0[index] <= block0[index]; block1[index] <= block1[index]; end
        endcase 
      end
    
      if(load2) begin
        case({LRU[index], offset})
          1'b00: block0[index][63:32] <= sram_rdata;
          1'b01: block0[index][31:0] <= sram_rdata;
          1'b10: block1[index][63:32] <= sram_rdata;
          1'b11: block1[index][31:0] <= sram_rdata;
          default: begin block0[index] <= block0[index]; block1[index] <= block1[index]; end
        endcase
        LRU[index] <= ~LRU[index];
      end
      
      if(invalid) begin
        case({hit1, hit0})
          2'b01: begin block0[index][74] <= 1'b0; LRU[index] <= 1'b0; end
          2'b10: begin block1[index][74] <= 1'b0; LRU[index] <= 1'b1; end
          default: begin block0[index] <= block0[index]; block1[index] <= block1[index]; LRU[index] <= LRU[index]; end
        endcase
      end
    end
  end
  
  reg [1:0] ps, ns;
  always @(ps, MEM_R_EN, MEM_W_EN, hit, sram_ready) begin
    begin ns = idle; {sram_read, sram_write, ready, update, load1, load2, invalid, sel_addr} = 8'h0; end
    case(ps)
      idle: begin ns = MEM_W_EN ? write : (MEM_R_EN && ~hit) ? read1 : idle; ready = ~(MEM_W_EN || (MEM_R_EN && ~hit)); update = (MEM_R_EN && hit); end
      read1: begin ns = sram_ready ? read2 : read1; sram_read = 1'h1; load1 = sram_ready; end
      read2: begin ns = sram_ready ? idle : read2; sram_read = 1'h1; sel_addr = 1'h1; load2 = sram_ready; ready = sram_ready; end
      write: begin ns = sram_ready ? idle : write; sram_write = 1'h1; invalid = hit; ready = sram_ready; end
      default: begin ns = idle; {sram_read, sram_write, ready, update, load1, load2, invalid, sel_addr} = 8'h0; end
    endcase
  end
  
  always @(posedge clk, posedge rst) begin
    if(rst) ps <= idle;
    else ps <= ns;
  end
                         
endmodule