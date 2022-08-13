module ALU (A, B, EXE_CMD, C, W, SR);
  
  input [31:0] A, B;
  input [3:0] EXE_CMD;
  input C;
  output [31:0] W;
  output [3:0] SR;
  
  reg [32:0] temp;
  wire [32:0] SEA = {A[31], A};
  wire [32:0] SEB = {B[31], B};
  
  assign W = temp[31:0];
  
  always @(A, B, EXE_CMD, C) begin
    case(EXE_CMD)
      4'b0001 :  temp = SEB;
      4'b1001 :  temp = ~SEB;
      4'b0010 :  temp = SEA + SEB;
      4'b0011 :  temp = SEA + SEB + C;
      4'b0100 :  temp = SEA - SEB;
      4'b0101 :  temp = SEA - SEB - C;
      4'b0110 :  temp = SEA & SEB;
      4'b0111 :  temp = SEA | SEB; 
      4'b1000 :  temp = SEA ^ SEB; 
      default :  temp = 33'h0;
    endcase
  end 
  
  //N, Z, C, V
  //3, 2, 1, 0
  
  assign SR[0] = (EXE_CMD == 4'b0010 || EXE_CMD == 4'b0011 || EXE_CMD == 4'b0100 || EXE_CMD == 4'b0101) ? temp[32] ^ temp[31] : 1'b0;
  assign SR[1] = (EXE_CMD == 4'b0010 || EXE_CMD == 4'b0011 || EXE_CMD == 4'b0100 || EXE_CMD == 4'b0101) ? temp[32] : 1'b0;
  assign SR[2] = ~(|temp[31:0]);
  assign SR[3] = temp[31];
  
endmodule