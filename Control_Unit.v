module Control_Unit (mode, opcode, S, NOP, ExeCmd, mem_read, mem_write, WB_Enable, B, new_S);
  
  input [1:0] mode;
  input [3:0] opcode;
  input S, NOP;
  output reg [3:0] ExeCmd;
  output reg WB_Enable, new_S;
  output mem_read, mem_write, B;
  
  assign mem_read = (mode == 2'h1 && opcode == 4'b0100) ? S : 1'b0;
  assign mem_write = (mode == 2'h1 && opcode == 4'b0100) ? ~S : 1'b0;
  assign B = (mode == 2'h2);
  
	always @(mode, opcode, S, NOP) begin
	 {ExeCmd, WB_Enable, new_S} = 6'b0;
	 
	 if(mode == 2'h0) begin
		case(opcode)
		  4'b1101: begin ExeCmd = 4'b0001; WB_Enable = 1'b1; new_S = S; end
		  4'b1111: begin ExeCmd = 4'b1001; WB_Enable = 1'b1; new_S = S; end
		  4'b0100: begin ExeCmd = 4'b0010; WB_Enable = 1'b1; new_S = S; end
		  4'b0101: begin ExeCmd = 4'b0011; WB_Enable = 1'b1; new_S = S; end
		  4'b0010: begin ExeCmd = 4'b0100; WB_Enable = 1'b1; new_S = S; end
		  4'b0110: begin ExeCmd = 4'b0101; WB_Enable = 1'b1; new_S = S; end
		  4'b0000: begin ExeCmd = 4'b0110; WB_Enable = ~NOP; new_S = S && ~NOP; end
		  4'b1100: begin ExeCmd = 4'b0111; WB_Enable = 1'b1; new_S = S; end
		  4'b0001: begin ExeCmd = 4'b1000; WB_Enable = 1'b1; new_S = S; end
		  4'b1010: begin ExeCmd = 4'b0100; new_S = 1'b1; end
		  4'b1000: begin ExeCmd = 4'b0110; new_S = 1'b1; end
		  default: begin ExeCmd = 4'b0000; WB_Enable = 1'b0; new_S = 1'b0; end
		endcase
	 end
	 
	 else if(mode == 2'h1 && opcode == 4'b0100) begin
		ExeCmd = 4'b0010;
		WB_Enable = S;
	 end
	end
		  
endmodule