module Adder (A, B, W);
  
  parameter WIDTH = 1;
  
  input [WIDTH - 1:0] A, B;
  output [WIDTH - 1:0] W;
  
  assign W = A + B;
  
endmodule




module Adder_co (A, B, W, co);
  
  parameter WIDTH = 1;
  
  input [WIDTH - 1:0] A, B;
  output [WIDTH - 1:0] W;
  output co;
  
  assign {co, W} = A + B;
  
endmodule