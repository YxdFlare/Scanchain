module dft_top(
  input [7:0] data_in,
  output [7:0] data_out,
  input a_s,

  input dut_val_op,
  output dut_op_ack,
  output dut_op_commit,

  output [31:0] dft_out,

  input dft_val_op,
  output dft_op_ack,
  output dft_op_commit,
  output dft_out_strobe,
  input dft_commit_ack,

  input clk,
  input reset
  
);

localparam chain_len = 32'd64;
localparam dump_nbr = 27'd2;

dft_datapath datapath (
    .clk(clk), 
    .reset(buf_reset), 
    .dft_sin(dft_sin), 
    .dft_out(dft_out), 
    .sc_sen(sc_sen), 
    .buf_op(buf_op), 
    .buf_val_op(buf_val_op), 
    .buf_sin_sel(buf_sin_sel), 
    .buf_op_commit(buf_op_commit),
    .buf_scaning(buf_scaning), 
    .buf_op_ack(buf_op_ack)
    );
dft_ctrl ctrl (
    .clk(clk), 
    .reset(reset), 
    .val_op(dft_val_op), 
    .op_ack(dft_op_ack), 
    .op_commit(dft_op_commit), 
    .commit_ack(dft_commit_ack),
    .dft_out_strobe(dft_out_strobe), 
    .chain_len(chain_len), 
    .dump_nbr(dump_nbr), 
    .sc_sen(sc_sen),
    .sc_ce(sc_ce), 
    .buf_op(buf_op), 
    .buf_sin_sel(buf_sin_sel), 
    .buf_val_op(buf_val_op), 
    .buf_reset(buf_reset),
    .buf_scaning(buf_scaning), 
    .buf_op_commit(buf_op_commit), 
    .buf_op_ack(buf_op_ack)
    );
incr_decr dut (
    .data_in(data_in), 
    .data_out(data_out), 
    .clk(clk), 
    .reset(reset), 
    .a_s(a_s), 
    .val_op(dut_val_op), 
    .op_ack(dut_op_ack), 
    .op_commit(dut_op_commit), 
    .scan_ce(sc_ce),
    .sen(sc_sen), 
    .sout(dft_sin), 
    .sin(dft_sin)
    );
endmodule // dft_top