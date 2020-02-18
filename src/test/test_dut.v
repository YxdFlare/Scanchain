`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yixiao Du
//
// Create Date:   17:29:22 02/16/2020
// Design Name:   incr_decr
// Module Name:   H:/Documents/CREA/FPGA/Scanchain/src/test/test_dut.v
// Project Name:  scanchain
// Target Device:  xc6lsx9-2fgt256
// Tool versions:  ISE 14.7
// Description: 
//
// Verilog Test Fixture created by ISE for module: incr_decr
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_dut;

  //--------------------------------------------------------------
  //  Netlisting
  //--------------------------------------------------------------  

	// Inputs
	reg [7:0] data_in;
	reg clk;
	reg reset;
	reg a_s;
	reg val_op;
	reg sen;
	reg scan_ce;
	reg sin;

	// Outputs
	wire [7:0] data_out;
	wire op_ack;
	wire op_commit;
	wire sout;

	// Instantiate the Unit Under Test (UUT)
	incr_decr uut (
		.data_in(data_in), 
		.data_out(data_out), 
		.clk(clk), 
		.reset(reset), 
		.a_s(a_s), 
		.val_op(val_op), 
		.op_ack(op_ack), 
		.op_commit(op_commit), 
		.sen(sen), 
		.scan_ce(scan_ce), 
		.sout(sout), 
		.sin(sin)
	);

	//--------------------------------------------------------------
  //  User-defined parameters
  //--------------------------------------------------------------
  localparam clk_halfperiod = 1;
  localparam y = 1'b1;
  localparam n = 1'b0;
  localparam add = 1'b1;
  localparam sub = 1'b0;
  localparam itemN = 10;
  localparam timeover_cycleN = 200;
 
  
  //--------------------------------------------------------------
  //  User-defined Tasks
  //--------------------------------------------------------------

  // tick cycles
  task tick;
  input [31:0] Ncycle;
    #(2*Ncycle*clk_halfperiod);
  endtask
  
  // waiting timeover
  integer timer; 
  task timeover; //timeover;
  begin
    if (timer >= timeover_cycleN)
    begin
      $display("[ERROR]: Response Timed Out! (%0d)",timeover_cycleN);
      $stop;
    end
    else  timer = timer + 1;
  end
  endtask
  
  // scan control
  task scan_disable;
  begin
      sen = n;
      scan_ce = n;
      sin = 0;
  end
  endtask

  // send request
  task send_req;
  input [7:0] msg;
  input op;
  begin
    data_in = msg;
    a_s = op;
    val_op = y;
    timer = 0;
    while (!op_ack) begin tick(1); timeover; end
    val_op = n;
    timer = 0;
    while (!op_commit) begin tick(1); timeover; end
  end
  endtask

  // request disable
  task req_disable;
  begin
    data_in = 0;
    a_s = sub;
    val_op = n;
  end
  endtask

  // initialize
  task initialize; //initialize;
  begin
      req_disable;
      scan_disable;
      reset = n;
      tick(1);
      reset = y;
      tick(5);
      #(clk_halfperiod);
      reset = n;
  end
  endtask

  //--------------------------------------------------------------
  //  Test source
  //--------------------------------------------------------------
  //User-defined stimuli constants
  reg [7:0] req_seq  [itemN-1:0];
  reg [7:0] resp_seq [itemN-1:0];
  reg [itemN-1:0] req_op;
  integer i;
  initial
    for (i = 0; i < itemN; i = i + 1) begin
      req_seq[i] = $random;
      req_op[i] = $random;
      resp_seq[i] = req_op[i] ? (req_seq[i] + 1) : (req_seq[i] - 1);
    end
  

  // clock generate
  initial clk = 1'b0;
  always #clk_halfperiod clk = ~clk;
  
  // start simulation
  initial begin
    // Initialize Inputs
       initialize;

    // Add stimulus here
    for (i = 0; i < itemN; i = i + 1) begin
      send_req(req_seq[i],req_op[i]);
    end

    $stop;
	end
      
endmodule

