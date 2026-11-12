// board_state.sv - holds the 64 squares of the board
// Step 1: loads the starting position on reset and holds it.
// Later steps add a write port so the game controller can move pieces.
module board_state
  import chess_pkg::*;
(
  input  logic             clk,
  input  logic             rst_n,
  output logic [63:0][3:0] board
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) board <= start_position();
  end
endmodule
