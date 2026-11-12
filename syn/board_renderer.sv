// board_renderer.sv - draws the chess board and pieces on VGA
// Output colour is registered, so it lags x/y by one pixel;
// the top level delays the sync signals to match.
module board_renderer
  import chess_pkg::*;
(
  input  logic             clk,
  input  logic             pix_en,
  input  logic [9:0]       x,
  input  logic [9:0]       y,
  input  logic             active,
  input  logic [63:0][3:0] board,
  output logic [7:0]       r, g, b
);
  localparam int SQ     = 56;            // square size in pixels
  localparam int X0     = 96;            // board top-left corner
  localparam int Y0     = 16;
  localparam int BSIZE  = 8 * SQ;        // 448
  localparam int MARGIN = 12;            // sprite is 8x8 scaled x4 = 32 px, centred

  logic       in_board;
  logic [9:0] bx, by;
  logic [2:0] file, screen_row, rank;
  logic [5:0] px, py;
  logic [5:0] sq;
  logic [3:0] piece;
  logic       light_sq, in_sprite, sprite_bit;
  logic [2:0] sx, sy;
  logic [7:0] sprite_bits;

  assign in_board   = (x >= X0) && (x < X0 + BSIZE) && (y >= Y0) && (y < Y0 + BSIZE);
  assign bx         = x - X0;
  assign by         = y - Y0;
  assign file       = 3'(bx / SQ);
  assign screen_row = 3'(by / SQ);
  assign px         = 6'(bx % SQ);
  assign py         = 6'(by % SQ);

  assign rank     = 3'd7 - screen_row;   // rank 8 at the top, white at the bottom
  assign sq       = {rank, file};
  assign piece    = board[sq];
  assign light_sq = rank[0] ^ file[0];   // a1 is a dark square

  assign in_sprite  = (px >= MARGIN) && (px < MARGIN + 32) && (py >= MARGIN) && (py < MARGIN + 32);
  assign sx         = 3'((px - MARGIN) >> 2);
  assign sy         = 3'((py - MARGIN) >> 2);
  assign sprite_bits = sprite_row(piece[2:0], sy);
  assign sprite_bit  = sprite_bits[3'd7 - sx];

  always_ff @(posedge clk) begin
    if (pix_en) begin
      if (!active)
        {r, g, b} <= 24'h000000;
      else if (!in_board)
        {r, g, b} <= 24'h202020;                                  // background
      else if (piece[2:0] != EMPTY && in_sprite && sprite_bit)
        {r, g, b} <= (piece[3] == WHITE) ? 24'hFFFFFF : 24'h000000;
      else
        {r, g, b} <= light_sq ? 24'hD8B07A : 24'h8A5A30;          // light / dark square
    end
  end
endmodule
