module Cache_Controller_v3 (clk, rst, address, wdata, MEM_R_EN, MEM_W_EN, rdata, ready,
                         sram_address, sram_wdata, sram_read, sram_write, sram_rdata, sram_ready);
                         
  input clk, rst, MEM_R_EN, MEM_W_EN;
  input [31:0] address, wdata;                 
  output reg ready;
  output [31:0] rdata;                   

  input sram_ready;
  input [31:0] sram_rdata;
  output reg sram_write, sram_read;
  output reg [31:0] sram_address, sram_wdata;
  
  parameter [2:0] idle = 3'h0, write1 = 3'h1, write2 = 3'h2, read1 = 3'h3, read2 = 3'h4, write3 = 3'h5;
  
  reg [75:0] block0 [0:63];
  reg [75:0] block1 [0:63];
  reg [0:0] LRU [0:63];
  reg [63:0] block;
  reg [1:0] sel_addr, sel_data;
  reg update_LRU, update_cache, load1, load2;
  wire [9:0] tag = address[18:9];
  wire [5:0] index = address[8:3];
  wire offset = address[2];
  wire [63:0] wb_data = LRU[index] ? block1[index][63:0] : block0[index][63:0];
  wire [31:0] wb_address = LRU[index] ? {13'h0, block1[index][73:64], index, 3'h0} : {13'h0, block0[index][73:64], index, 3'h0};
  wire hit, hit0, hit1, dirty;
  integer i;
  
  assign hit0 = block0[index][74] && (tag == block0[index][73:64]);
  assign hit1 = block1[index][74] && (tag == block1[index][73:64]);
  assign hit = hit0 || hit1;
  assign dirty = LRU[index] ? &block1[index][75:74] : &block0[index][75:74];
  
  always @(block0, block1, index, hit0, hit1) begin
    case({hit1, hit0})
      2'b01: block = block0[index][63:0];
      2'b10: block = block1[index][63:0];
      default: block = 64'h0;
    endcase
  end
  
  assign rdata = offset ? block[63:32] : block[31:0];
  
  always @(wdata, wb_data, sel_data) begin
    case(sel_data)
      2'h0: sram_wdata = wdata;
      2'h1: sram_wdata = wb_data[31:0];
      2'h2: sram_wdata = wb_data[63:32];
      default: sram_wdata = 32'h0;
    endcase
  end
  
  always @(address, wb_address, sel_addr) begin
    case(sel_addr)
      2'h0: sram_address = address;
      2'h1: sram_address = {address[31:3], ~address[2:0]};
      2'h2: sram_address = wb_address;
      2'h3: sram_address = {wb_address[31:3], ~wb_address[2:0]};
      default: sram_address = 32'h0;
    endcase
  end
  
  always @(posedge clk, posedge rst) begin
    if(rst) begin
      for(i = 0; i < 64; i = i + 1) begin
        block0[i] <= 76'h0;
        block1[i] <= 76'h0;
        LRU[i] <= 1'b0;
      end
    end
    
    else begin
      if(update_LRU) begin
        case({hit1, hit0})
          2'b01: LRU[index] <= 1'b1;
          2'b10: LRU[index] <= 1'b0;
          default: LRU[index] <= LRU[index];
        endcase
      end
      
      if(update_cache) begin
        case({hit1, hit0, offset})
          3'b010: begin block0[index][75] <= 1'b1; block0[index][31:0] <= wdata; end
          3'b011: begin block0[index][75] <= 1'b1; block0[index][63:32] <= wdata; end
          3'b100: begin block1[index][75] <= 1'b1; block1[index][31:0] <= wdata; end
          3'b101: begin block1[index][75] <= 1'b1; block1[index][63:32] <= wdata; end
          default: begin block0[index] <= block0[index]; block1[index] <= block1[index]; end
        endcase 
      end
      
      if(load1) begin
        case(LRU[index])
          1'b0: begin block0[index][75] <= 1'b0; block0[index][74] <= 1'b1; block0[index][73:64] <= tag; end
          1'b1: begin block1[index][75] <= 1'b0; block1[index][74] <= 1'b1; block1[index][73:64] <= tag; end
          default: begin block0[index] <= block0[index]; block1[index] <= block1[index]; end
        endcase
        case({LRU[index], offset})
          2'b00: block0[index][31:0] <= sram_rdata;
          2'b01: block0[index][63:32] <= sram_rdata;
          2'b10: block1[index][31:0] <= sram_rdata;
          2'b11: block1[index][63:32] <= sram_rdata;
          default: begin block0[index] <= block0[index]; block1[index] <= block1[index]; end
        endcase 
      end
    
      if(load2) begin
        case({LRU[index], offset})
          2'b00: block0[index][63:32] <= sram_rdata;
          2'b01: block0[index][31:0] <= sram_rdata;
          2'b10: block1[index][63:32] <= sram_rdata;
          2'b11: block1[index][31:0] <= sram_rdata;
          default: begin block0[index] <= block0[index]; block1[index] <= block1[index]; end
        endcase
        LRU[index] <= ~LRU[index];
      end
    end
  end
  
  reg [2:0] ps, ns;
  always @(ps, MEM_R_EN, MEM_W_EN, hit, dirty, sram_ready) begin
    begin ns = idle; {sram_read, sram_write, ready, update_LRU, update_cache, load1, load2, sel_addr, sel_data} = 11'h0; end
    case(ps)
      idle: begin ns = (MEM_W_EN && ~hit) ? write3 : (MEM_R_EN && ~hit && dirty) ? write1 : (MEM_R_EN && ~hit && ~dirty) ? read1 : idle; update_LRU = ((MEM_R_EN || MEM_W_EN) && hit); update_cache = (MEM_W_EN && hit); ready = ~((MEM_W_EN && ~hit) || (MEM_R_EN && ~hit)); end
      write1: begin ns = sram_ready ? write2 : write1; sram_write = 1'h1; sel_addr = 2'h2; sel_data = 2'h1; end
      write2: begin ns = sram_ready ? read1 : write2; sram_write = 1'h1; sel_addr = 2'h3; sel_data = 2'h2; end
      read1: begin ns = sram_ready ? read2 : read1; sram_read = 1'h1; load1 = sram_ready; end
      read2: begin ns = sram_ready ? idle : read2; sram_read = 1'h1; sel_addr = 2'h1; load2 = sram_ready; ready = sram_ready; end
      write3: begin ns = sram_ready ? idle : write3; sram_write = 1'h1; ready = sram_ready; end
      default: begin ns = idle; {sram_read, sram_write, ready, update_LRU, update_cache, load1, load2, sel_addr, sel_data} = 11'h0; end
    endcase
  end
  
  always @(posedge clk, posedge rst) begin
    if(rst) ps <= idle;
    else ps <= ns;
  end
                         
endmodule