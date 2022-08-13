module IF_Stage_Reg (clk, rst, freeze, flush, PC_in, Instruction_in, PC, Instruction);
  
  input [31:0] PC_in, Instruction_in;
  input clk, rst, freeze, flush;
  output reg [31:0] PC, Instruction;
  
  always @(posedge clk, posedge rst) begin
    if(rst) {PC, Instruction} <= 64'h0;
    else begin
      case({freeze, flush})
        2'b00: {PC, Instruction} <= {PC_in, Instruction_in};
        2'b01: {PC, Instruction} <= 64'h0;
        default: {PC, Instruction} <= {PC, Instruction};
      endcase
    end
  end
  
endmodule