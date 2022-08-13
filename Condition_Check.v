module Condition_Check (cond, SR, valid);
  
  input [3:0] cond, SR;
  output reg valid;
  
  //N, Z, C, V
  //3, 2, 1, 0
  
  always @(cond, SR) begin
    valid = 1'b0;
    case(cond)
      4'h0: valid = SR[2];
      4'h1: valid = ~SR[2];
      4'h2: valid = SR[1];
      4'h3: valid = ~SR[1];
      4'h4: valid = SR[3];
      4'h5: valid = ~SR[3];
      4'h6: valid = SR[0];
      4'h7: valid = ~SR[0];
      4'h8: valid = (SR[1] && ~SR[2]);
      4'h9: valid = (~SR[1] || SR[2]);
      4'hA: valid = (SR[3] == SR[0]);
      4'hB: valid = (SR[3] != SR[0]);
      4'hC: valid = (~SR[2] && SR[3] == SR[0]);
      4'hD: valid = (SR[2] || SR[3] != SR[0]);
      4'hE: valid = 1'b1;
      4'hF: valid = 1'b1;
      default: valid = 1'b0;
    endcase
  end
 
endmodule