module Mux_3s (A, B, C, D, E, F, G, H, sel, W);
  
  parameter WIDTH = 1;
  
  input [WIDTH - 1:0] A, B, C, D, E, F, G, H;
  input [2:0] sel;
  output reg [WIDTH - 1:0] W;
  
  always @(A, B, C, D, E, F, G, H, sel) begin
    case(sel)
      3'h0: W = A;
      3'h1: W = B;
      3'h2: W = C;
      3'h3: W = D;
      3'h4: W = E;
      3'h5: W = F;
      3'h6: W = G;
      3'h7: W = H;
      default: W = 0;
    endcase
  end
  
endmodule




module Mux_2s (A, B, C, D, sel, W);
  
  parameter WIDTH = 1;
  
  input [WIDTH - 1:0] A, B, C, D;
  input [1:0] sel;
  output reg [WIDTH - 1:0] W;
  
  always @(A, B, C, D, sel) begin
    case(sel)
      2'h0: W = A;
      2'h1: W = B;
      2'h2: W = C;
      2'h3: W = D;
      default: W = 0;
    endcase
  end
  
endmodule




module Mux_1s (A, B, sel, W);
  
  parameter WIDTH = 1;
  
  input [WIDTH - 1:0] A, B;
  input sel;
  output reg [WIDTH - 1:0] W;
  
  always @(A, B, sel) begin
    case(sel)
      1'h0: W = A;
      1'h1: W = B;
      default: W = 0;
    endcase
  end
  
endmodule