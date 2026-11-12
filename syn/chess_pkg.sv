// chess_pkg.sv - shared definitions for the FPGA chess board
package chess_pkg;

  // Square encoding: {color, type}, 4 bits per square
  //   color: 0 = white, 1 = black
  //   type : 0 = empty, 1 = pawn, 2 = knight, 3 = bishop,
  //          4 = rook,  5 = queen, 6 = king
  // Square index 0..63 = {rank[2:0], file[2:0]}
  //   index 0 = a1, 7 = h1, 56 = a8, 63 = h8
  //   +8 = one rank up, +/-1 = one file sideways

  localparam logic WHITE = 1'b0;
  localparam logic BLACK = 1'b1;

  localparam logic [2:0] EMPTY  = 3'd0;
  localparam logic [2:0] PAWN   = 3'd1;
  localparam logic [2:0] KNIGHT = 3'd2;
  localparam logic [2:0] BISHOP = 3'd3;
  localparam logic [2:0] ROOK   = 3'd4;
  localparam logic [2:0] QUEEN  = 3'd5;
  localparam logic [2:0] KING   = 3'd6;

  function automatic logic [3:0] make_piece(input logic color, input logic [2:0] ptype);
    return {color, ptype};
  endfunction

  // Standard starting position
  function automatic logic [63:0][3:0] start_position();
    logic [63:0][3:0] b;
    logic [7:0][2:0]  back_rank;
    back_rank = {ROOK, KNIGHT, BISHOP, KING, QUEEN, BISHOP, KNIGHT, ROOK}; // index 7..0 = h..a
    b = '0;
    for (int f = 0; f < 8; f++) begin
      b[f]      = make_piece(WHITE, back_rank[f]);
      b[8  + f] = make_piece(WHITE, PAWN);
      b[48 + f] = make_piece(BLACK, PAWN);
      b[56 + f] = make_piece(BLACK, back_rank[f]);
    end
    return b;
  endfunction

  // 8x8 piece bitmaps, row 0 = top, bit 7 = leftmost pixel
  function automatic logic [7:0] sprite_row(input logic [2:0] ptype, input logic [2:0] row);
    logic [0:7][7:0] bmp;
    case (ptype)
      PAWN:   bmp = {8'b00000000, 8'b00011000, 8'b00111100, 8'b00011000,
                     8'b00111100, 8'b00011000, 8'b01111110, 8'b00000000};
      KNIGHT: bmp = {8'b00000000, 8'b00111000, 8'b01111100, 8'b11011100,
                     8'b00011100, 8'b00111100, 8'b01111110, 8'b00000000};
      BISHOP: bmp = {8'b00011000, 8'b00111100, 8'b00110100, 8'b00111100,
                     8'b00011000, 8'b00111100, 8'b01111110, 8'b00000000};
      ROOK:   bmp = {8'b00000000, 8'b01011010, 8'b01111110, 8'b00111100,
                     8'b00111100, 8'b00111100, 8'b01111110, 8'b00000000};
      QUEEN:  bmp = {8'b10011001, 8'b01011010, 8'b00111100, 8'b00111100,
                     8'b00011000, 8'b00111100, 8'b01111110, 8'b00000000};
      KING:   bmp = {8'b00011000, 8'b01111110, 8'b00011000, 8'b00111100,
                     8'b00111100, 8'b00111100, 8'b01111110, 8'b00000000};
      default: bmp = '0;
    endcase
    return bmp[row];
  endfunction

endpackage
