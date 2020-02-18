`timescale 1ns / 100ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yixiao Du
//
// Create Date:   16:03:20 02/09/2020
// Design Name:   SIPO_buf_256B
// Module Name:   H:/Documents/CREA/FPGA/Scanchain/src/test/test_SIPO.v
// Project Name:  scanchain
// Target Device:  xc6lsx9-2ftg256
// Tool versions:  ISE 14.7
// Description: 
//
// Verilog Test Fixture created by ISE for module: SIPO_buf_256B
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_SIPO;

  //--------------------------------------------------------------
  //  Netlisting
  //--------------------------------------------------------------  

	// Inputs
	reg clk;
	reg reset;
	reg sin;
	reg val_op;
	reg op;

	// Outputs
	wire [31:0] pout;
	wire op_ack;
	wire op_commit;
  

	// Instantiate the Unit Under Test (UUT)
	SIPO_buf_256B uut (
		.clk(clk), 
		.reset(reset), 
		.sin(sin), 
		.pout(pout), 
		.val_op(val_op), 
		.op(op), 
		.op_ack(op_ack), 
		.op_commit(op_commit)
	);
   
  //--------------------------------------------------------------
  //  User-defined parameters
  //--------------------------------------------------------------
  localparam clk_halfperiod = 1;
  localparam y = 1'b1;
  localparam n = 1'b0;
  localparam wr = 1'b0;
  localparam rd = 1'b1;
  localparam timeover_cycleN = 200;
  
  //--------------------------------------------------------------
  //  User-defined Tasks
  //--------------------------------------------------------------
  
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


  // initialize
  task initialize; //initialize;
  begin
    reset = 0;
    sin = 0;
    val_op = 0;
    op = 0;
    timer = 0;
    #(2*clk_halfperiod);
    reset = 1;
    #(21*clk_halfperiod);
    reset = 0;
    #(2*clk_halfperiod);
  end
  endtask
  
  // send operation request
  integer i;
  reg [31:0] seq_REG;
  task opreq; //opreq(sequence, transaction);
  input [31:0] seq;
  input transaction;
    begin
    if (transaction == wr) 
    begin
        val_op = y;
        op = wr;
        seq_REG = seq;
        timer = 0;
        while (!op_ack) begin #(2*clk_halfperiod); timeover; end
        val_op = n;
        for(i = 0;i < 32;i = i+1) 
        begin
          sin = seq_REG[0];
          seq_REG = seq_REG >> 1;
          #(2*clk_halfperiod);
        end
        timer = 0;
        while (!op_commit) begin #(2*clk_halfperiod); timeover; end
    end else if (transaction == rd) 
    begin
        val_op = y;
        op = rd;
        timer = 0;
        while (!op_ack) begin #(2*clk_halfperiod); timeover; end
        val_op = n;
        timer = 0;
        while (!op_commit) begin #(2*clk_halfperiod); timeover; end
        pout_REG = pout;
        $display("Collected output: Hex:%8h \tASCII:%4s \tDec:%0d",pout_REG,pout_REG,pout_REG);
        #(2*clk_halfperiod);
    end else 
    begin
        val_op = n;
    end  
  end
endtask
  


  //--------------------------------------------------------------
  //  Simulation stimuli
  //--------------------------------------------------------------
  reg [31:0] pout_REG;
  //User-defined stimuli constants
  localparam seq1 = 32'h07020106;
  localparam seq2 = "7216";
  localparam seq3 = 32'hdeadbeef;
  localparam seq4 = 32'd7216;

  // clock generate
  initial clk = 1'b0;
  always #clk_halfperiod clk = ~clk;
  
  // start simulation
  initial begin
    // Initialize Inputs
       initialize;

    // Add stimulus here
      //opreq(sequence,transaction);
        opreq(seq1,wr);
        opreq(seq2,wr);
        opreq(seq3,wr);
        opreq(seq4,wr);
        reset = 1;
        #(4*clk_halfperiod);
        reset = 0;
        opreq(32'dx,rd);
        opreq(32'dx,rd);
        opreq(32'dx,rd);
        opreq(32'dx,rd);

    $stop;
	end
      
endmodule

