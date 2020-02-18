`timescale 1ns / 100ps

module IAS_datapath (
  input [7:0] data_in,
  output [7:0] data_out,
  input clk,
  input reset,

  input add_sub,
  input scan_ce,
  input reg_en_1,
  input reg_en_2,

  input sin,
  output sout,
  input sen
  
);
  wire [7:0] data_1;
  wire [7:0] data_1_p;

  wire ce1;
  wire ce2;

  assign ce1 = sen ? scan_ce : reg_en_1;
  assign ce2 = sen ? scan_ce : reg_en_2;

  ScanReg8 inputreg (
    .d(data_in),
    .q(data_1),
    .sin(sin),
    .sout(sout_1),
    .sen(sen),
    .clk(clk),
    .clr(reset),
    .ce(ce1)
  );

  assign data_1_p = add_sub ? (data_1 + 1) : (data_1 - 1);

  ScanReg8 outputreg (
    .d(data_1_p),
    .q(data_out),
    .sin(sout_1),
    .sout(sout),
    .sen(sen),
    .clk(clk),
    .clr(reset),
    .ce(ce2)
  );

endmodule // 