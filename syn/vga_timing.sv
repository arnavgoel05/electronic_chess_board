// vga_timing.sv - 640x480 @ 60 Hz timing generator
// Advances one pixel each cycle that pix_en is high (25 MHz rate).
module vga_timing (
  input  logic       clk,
  input  logic       rst_n,
  input  logic       pix_en,
  output logic [9:0] x,        // current pixel column (0..799)
  output logic [9:0] y,        // current line (0..524)
  output logic       active,   // high inside the visible 640x480 area
  output logic       hsync_n,  // active-low sync pulses
  output logic       vsync_n
);
  localparam int H_VIS = 640, H_FP = 16, H_SYNC = 96, H_BP = 48;
  localparam int V_VIS = 480, V_FP = 10, V_SYNC = 2,  V_BP = 33;
  localparam int H_TOTAL = H_VIS + H_FP + H_SYNC + H_BP; // 800
  localparam int V_TOTAL = V_VIS + V_FP + V_SYNC + V_BP; // 525

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      x <= '0;
      y <= '0;
    end else if (pix_en) begin
      if (x == H_TOTAL - 1) begin
        x <= '0;
        y <= (y == V_TOTAL - 1) ? '0 : y + 1'b1;
      end else begin
        x <= x + 1'b1;
      end
    end
  end

  assign active  = (x < H_VIS) && (y < V_VIS);
  assign hsync_n = ~((x >= H_VIS + H_FP) && (x < H_VIS + H_FP + H_SYNC));
  assign vsync_n = ~((y >= V_VIS + V_FP) && (y < V_VIS + V_FP + V_SYNC));
endmodule
