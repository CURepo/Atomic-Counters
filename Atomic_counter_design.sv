/* *********************************
************************************
******* Atomic counter design ******
************************************
********************************* */
module atomic_counters (
  input                   clk,
  input                   reset,
  input                   trig_i,
  input                   req_i,
  input                   atomic_i,
  output logic            ack_o,
  output logic[31:0]      count_o
);

  // --------------------------------------------------------
  // Internal Counter update 
  // --------------------------------------------------------
  logic [63:0] count_q;
  logic [63:0] count;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      count_q[63:0] <= 64'h0;
    else
      count_q[63:0] <= count;
  // --------------------------------------------------------
  // Intermediate Signals for internal logic computation
  
  logic req_q, atm_q;
  logic [31:0] MSB;
  
  // Logic for updating the count value
  assign count = count_q + {{63{1'b0}},trig_i};
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      req_q <= 1'b0;
      atm_q <= 1'b0;
    end
    else begin
      req_q <= req_i;
      atm_q <= atomic_i;
    end
  end
  // MSB logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      MSB <= 32'b0;
    else if (atm_q) begin
      MSB <= count_q [63:32];
    end
  end
  // outputs assignments and logic 
  assign ack_o = req_q;
  assign count_o = (req_q) ? (atm_q) ? count_q [31:0] : MSB : 32'h0;
  
endmodule



