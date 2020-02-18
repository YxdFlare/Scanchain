`timescale 1ns / 100ps

module IAS_ctrl (
  input clk,
  input reset,
  input val_op,
  output op_rdy,
  output op_ack,

  input a_s,

  output reg_en_1,
  output reg_en_2,
  output add_sub,

  input sen
);

  // state def
  localparam IDLE = 2'd0;
  localparam START = 2'd1;
  localparam CALC = 2'd2;
  localparam FINISH = 2'd3;
  
  // state reg
  reg [1:0] current_state;
  reg [1:0] next_state;

  // state transition
  always @(posedge clk)
    if (reset)
      current_state <= IDLE;
    else if (sen)
      current_state <= current_state;
    else
      current_state <= next_state;

  // next state logic
  always @*
    case (current_state)
      IDLE:
        if (val_op)
          next_state = START;
        else
          next_state = IDLE;
      START:
        next_state = CALC;
      CALC:
        next_state = FINISH;
      FINISH:
        next_state = IDLE;
      default:
        next_state = IDLE;
    endcase

  // output logic
  localparam add = 1'b1;
  localparam sub = 1'b0;
  localparam y = 1'b1;
  localparam n = 1'b0;

  reg op_ack_REG, op_rdy_REG, reg_en_1_REG, reg_en_2_REG, add_sub_REG;
  assign op_rdy = op_rdy_REG;
  assign op_ack = op_ack_REG;
  assign reg_en_1 = reg_en_1_REG;
  assign reg_en_2 = reg_en_2_REG;
  assign add_sub = add_sub_REG;

  task cbout (op_ack_CB,op_rdy_CB,reg_en_1_CB,reg_en_2_CB,add_sub_CB);
  begin
    op_rdy_REG = op_rdy_CB;
    op_ack_REG = op_ack_CB;
    reg_en_1_REG = reg_en_1_CB;
    reg_en_2_REG = reg_en_2_CB;
    add_sub_REG = add_sub_CB;
  end
  endtask
    
  always @*
    case (current_state)
                  //    op    op    reg   reg   add
                  //    ack   rdy   en1   en2   sub
      IDLE:       cbout(n,    n,    n,    n,    add);
      START:      cbout(y,    n,    y,    n,    add);
      CALC:     
        if (a_s)  cbout(n,    n,    n,    y,    add);
        else      cbout(n,    n,    n,    y,    sub);
      FINISH:     cbout(n,    y,    n,    n,    add);
      default:    cbout(n,    n,    n,    n,    add);
    endcase

endmodule // IAS_ctrl 