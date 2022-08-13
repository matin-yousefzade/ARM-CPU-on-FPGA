module Status_Register (status, S, clk, rst, SR);
  
  input [3:0] status;
  input S, clk, rst;
  output reg [3:0] SR;
  
  always @(negedge clk, posedge rst) begin
    if (rst) SR <= 4'h0;
    else if(S) SR <= status;
  end
  
endmodule