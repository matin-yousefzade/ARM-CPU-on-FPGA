module Register (D, load, clk, rst, Q);
  
  parameter WIDTH = 1;
  
  input [WIDTH - 1:0] D;
  input load, clk, rst;
  output reg [WIDTH - 1:0] Q;
  
  always @(posedge clk, posedge rst) begin
    if (rst) Q <= 0;
    else if(load) Q <= D;
  end
  
endmodule




module Register_init (D, load, init, clk, rst, Q);
  
  parameter WIDTH = 1;
  
  input [WIDTH - 1:0] D;
  input load, init, clk, rst;
  output reg [WIDTH - 1:0] Q;
  
  always @(posedge clk, posedge rst) begin
    if (rst) Q <= 0;
    else if(init) Q <= 0;
    else if(load) Q <= D;
  end
  
endmodule