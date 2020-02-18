`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yixiao Du
//
// Create Date:   00:10:24 02/11/2020
// Design Name:   dft_top
// Module Name:   H:/Documents/CREA/FPGA/Scanchain/src/test/test_dft_top.v
// Project Name:  scanchain
// Target Device:  xc6lsx9-2fgt256
// Tool versions:  ISE 14.7
// Description: 
//
// Verilog Test Fixture created by ISE for module: dft_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_dft_top;
  
  //--------------------------------------------------------------
  //  Netlisting
  //--------------------------------------------------------------  

	// Inputs
	reg [7:0] data_in;
	reg a_s;
	reg dut_val_op;
	reg dft_val_op;
	reg dft_commit_ack;
	reg clk;
	reg reset;

	// Outputs
	wire [7:0] data_out;
  wire [31:0] dft_out;
	wire dut_op_ack;
	wire dut_op_commit;
	wire dft_op_ack;
	wire dft_op_commit;

	// Instantiate the Unit Under Test (UUT)
	dft_top uut (
		.data_in(data_in), 
		.data_out(data_out), 
		.a_s(a_s), 
		.dut_val_op(dut_val_op), 
		.dut_op_ack(dut_op_ack), 
		.dut_op_commit(dut_op_commit),

    .dft_out(dft_out),
		.dft_val_op(dft_val_op), 
		.dft_op_ack(dft_op_ack), 
		.dft_op_commit(dft_op_commit), 
    .dft_out_strobe(dft_out_strobe),
		.dft_commit_ack(dft_commit_ack), 
		.clk(clk), 
		.reset(reset)
	);

	//--------------------------------------------------------------
  //  User-defined parameters
  //--------------------------------------------------------------
  // test parameters
  localparam chain_len = 64;
  localparam dumpNbr = 2;
  localparam timeover_cycleN = 200;
  localparam dut_itemN = 55;
  localparam dft_itemN = 55;
  localparam max_cycle_limit = 10000;
  
  // system parameters
  localparam clk_halfperiod = 1;
  localparam y = 1'b1;
  localparam n = 1'b0;
  localparam add = 1'b1;
  localparam sub = 1'b0;

  //--------------------------------------------------------------
  //  Simulation control variables
  //--------------------------------------------------------------
  integer cycleN;
  
  integer dut_srcaddr;
  integer dut_sinkaddr;

  integer dft_srcaddr;
  integer dft_sinkaddr;

  reg dut_passing = 1'b1;
  reg dft_passing = 1'b1;

  reg dut_sim_finish = 1'b0;
  reg dft_sim_finish = 1'b0;
  
  reg sim_finish = 1'b0;
  always @* sim_finish = dut_sim_finish && dft_sim_finish;
  
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
      $display("[ERROR]: Waiting Timed Out! (Max waiting cycle : %0d)",timeover_cycleN);
      $stop;
    end
    else  timer = timer + 1;
  end
  endtask
  
  // disable DFT
  task DFT_disable;
  begin
    dft_val_op = n;
    dft_commit_ack = n;
  end
  endtask

  // initialize DUT
  task DUT_ini;
  begin
    dut_val_op = n;
    data_in = 0;
    a_s = sub;
  end
  endtask

  // initialize
  task initialize; //initialize;
  begin
    cycleN = 0;
    DUT_ini;
    DFT_disable;
    dut_sinkaddr = 0;
    dut_srcaddr = 0;
    dft_sinkaddr = 0;
    dft_srcaddr = 0;
    reset = n;
    tick(1);
    reset = y;
    tick(5);
    #(clk_halfperiod);
    reset = n;
  end
  endtask

  // send request to DUT
  task DUT_sendreq;
  input [7:0] msg;
  input op;
  begin
    data_in = msg;
    a_s = op;
    dut_val_op = y;
    timer = 0;
    while (!dut_op_ack) begin tick(1); timeover; end  
    dut_val_op = n;
    tick(1);
  end
  endtask

  // perform operation on DFT
  task DFT_operate;
  begin
    dft_val_op = y;
    timer = 0;
    while (!dft_op_ack) begin tick(1); timeover; end
    dft_val_op = n;
    timer = 0;
    while (!dft_op_commit) begin tick(1); timeover; end
    dft_commit_ack = y;
    tick(1);
    dft_commit_ack = n;
  end
  endtask  
  
  //--------------------------------------------------------------
  //  Test source
  //--------------------------------------------------------------
  //User-defined stimuli constants
  reg [7:0] dut_req_seq  [dut_itemN-1:0];
  reg [7:0] dut_resp_seq [dut_itemN-1:0];
  reg [chain_len-1:0] dft_resp_seq [dft_itemN-1:0];
  reg [dut_itemN-1:0] dut_req_op;
  integer i;
  initial
    for (i = 0; i < dut_itemN; i = i + 1) begin
      dut_req_seq[i] = $random;
      dut_req_op[i] = $random;
      dut_resp_seq[i] = dut_req_op[i] ? (dut_req_seq[i] + 1) : (dut_req_seq[i] - 1);
      dft_resp_seq[i] = {dut_req_seq[i],dut_resp_seq[i],dut_req_seq[i],dut_resp_seq[i],dut_req_seq[i],dut_resp_seq[i],dut_req_seq[i],dut_resp_seq[i]};
    end

  // clock generate
  initial clk = 1'b0;
  always #clk_halfperiod clk = ~clk;
  
  // start simulation
  initial begin
    // Initialize 
       initialize;

    // Add stimulus here
    for (dut_srcaddr = 0; dut_srcaddr < dut_itemN; dut_srcaddr = dut_srcaddr + 1)
    begin
      DUT_sendreq(dut_req_seq[dut_srcaddr],dut_req_op[dut_srcaddr]);
      DFT_operate;
    end

    // stop simulation
    while (!sim_finish) #(10);
    $stop;
	end

  //--------------------------------------------------------------
  //  Test sink
  //--------------------------------------------------------------

  // Max cycle limitation
  
  always @(posedge clk) begin
    if (reset)
      cycleN = 0;
    else if (cycleN < max_cycle_limit)
      cycleN <= cycleN + 1;
    else begin
      $display("[ERROR]: Max Cycle Limit Expired! (Max cycle : %0d)",max_cycle_limit);
      $stop;
    end 
  end

  // DUT verification
  always @(dut_op_commit) begin
    if (dut_op_commit)
      if (dut_sinkaddr < dut_itemN) begin
        if (data_out == dut_resp_seq[dut_sinkaddr]) 
          dut_passing = dut_passing & 1'b1;
        else
          dut_passing = 1'b0;
        dut_sinkaddr = dut_sinkaddr + 1;
      end

    if (dut_sinkaddr >= dut_itemN)
        if (!dut_sim_finish) begin
          if (dut_passing)
            $display("DUT : Simulation finished. Test PASSED");
          else
            $display("DUT : Simulation finished. Test FAILED");
        dut_sim_finish = 1'b1;
        end
  end

  // DFT sink
  integer j;
  reg [chain_len-1:0] k = 0;
  initial j = 0;
  reg [31:0] dft_tmp [dumpNbr-1:0];
  reg [chain_len-1:0] dft_result = 0;
  always @(dft_op_commit,dft_out_strobe) begin
    if (dft_out_strobe) 
      if (j < dumpNbr - 1) begin
        dft_tmp[j] = dft_out;
        j = j + 1;
      end
      else begin
        dft_tmp[j] = dft_out;
        dft_result = dft_result >> (chain_len + 1);
        for (j = 0;j < dumpNbr;j = j + 1) begin
          k = j*32;
          dft_result = dft_result + (dft_tmp[j] << k);
        end
        j = 0;
        if (dft_result == dft_resp_seq[dft_sinkaddr]) begin
            dft_passing = dft_passing & 1'b1; 
            $display("Collected Value: %h, MATCHED",dft_result);
          end
          else begin
            dft_passing = 1'b0;
            $display("Expected Value : %h, Collected Value: %h, MISMATCH",dft_resp_seq[dft_sinkaddr], dft_result);
          end
      end

    if (dft_op_commit)
      if (dft_sinkaddr < dft_itemN) begin
        dft_sinkaddr = dft_sinkaddr + 1;
      end
    
    if (dft_sinkaddr >= dft_itemN)
        if (!dft_sim_finish) begin
          if (dft_passing)
            $display("DFT : Simulation finished. Test PASSED");
          else
            $display("DFT : Simulation finished. Test FAILED");
        dft_sim_finish = 1'b1;
        end
  end
      
endmodule

