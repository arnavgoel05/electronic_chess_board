// chess_top.sv - DE2-115 top level for step 1 (VGA board display)
// Port names match the DE2-115 System Builder / standard pin assignment file.
module chess_top (
  input  logic       CLOCK_50,
  input  logic [3:0] KEY,          // KEY[0] = reset (active low)
  output logic [7:0] VGA_R,
  output logic [7:0] VGA_G,
  output logic [7:0] VGA_B,
  output logic       VGA_CLK,
  output logic       VGA_BLANK_N,
  output logic       VGA_SYNC_N,
  output logic       VGA_HS,
  output logic       VGA_VS
);
  logic rst_n;
  assign rst_n = KEY[0];

  // 25 MHz pixel rate from the 50 MHz clock.
  // Logic updates when clk25 falls; the DAC samples on VGA_CLK's rising edge, half a pixel later.
  logic clk25;
  always_ff @(posedge CLOCK_50 or negedge rst_n)
    if (!rst_n) clk25 <= 1'b0;
    else        clk25 <= ~clk25;

  logic pix_en;
  assign pix_en  = clk25;
  assign VGA_CLK = clk25;

  logic [9:0]       x, y;
  logic             active, hs_n, vs_n;
  logic [63:0][3:0] board;

  vga_timing u_timing (
    .clk(CLOCK_50), .rst_n(rst_n), .pix_en(pix_en),
    .x(x), .y(y), .active(active), .hsync_n(hs_n), .vsync_n(vs_n)
  );

  board_state u_board (
    .clk(CLOCK_50), .rst_n(rst_n), .board(board)
  );

  board_renderer u_render (
    .clk(CLOCK_50), .pix_en(pix_en), .x(x), .y(y), .active(active),
    .board(board), .r(VGA_R), .g(VGA_G), .b(VGA_B)
  );

  // Delay sync and blank by one pixel to line up with the registered colour
  always_ff @(posedge CLOCK_50) begin
    if (pix_en) begin
      VGA_HS      <= hs_n;
      VGA_VS      <= vs_n;
      VGA_BLANK_N <= active;
    end
  end

  assign VGA_SYNC_N = 1'b0;
endmodule
