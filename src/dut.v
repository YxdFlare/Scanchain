`timescale 1ns / 100ps

module incr_decr(
	input [7:0] data_in,
  output [7:0] data_out,
  input clk,
  input reset,
  input a_s,

  input val_op,
  output op_ack,
  output op_commit,
  
  input sen,
  input scan_ce,
  output sout,
  input sin
); 
  IAS_datapath datapath (
    .data_in(data_in), 
    .data_out(data_out), 
    .clk(clk), 
    .reset(reset), 
    .add_sub(add_sub), 
    .reg_en_1(reg_en_1), 
    .reg_en_2(reg_en_2), 
    .sin(sin), 
    .sout(sout), 
    .sen(sen),
    .scan_ce(scan_ce)
    );
 
  IAS_ctrl ctrl (
    .clk(clk), 
    .reset(reset), 
    .val_op(val_op), 
    .op_rdy(op_commit),
    .op_ack(op_ack),
    .a_s(a_s), 
    .reg_en_1(reg_en_1), 
    .reg_en_2(reg_en_2), 
    .add_sub(add_sub), 
    .sen(sen)
    );

endmodule
