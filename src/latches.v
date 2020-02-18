`timescale 1ns / 100ps

module d_latch(
  input d,
  input len,
  output q  
);
  reg q_REG;
  always @*
	if (len == 1'b1)
		q_REG <= d;
	else 
		q_REG <= q;
	assign q = q_REG;

endmodule // d_latch
