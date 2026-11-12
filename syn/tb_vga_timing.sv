// tb_vga_timing.sv - checks line and frame lengths of vga_timing
`timescale 1ns/1ps
module tb_vga_timing;
  logic       clk = 0, rst_n = 0, pix_en = 1;
  logic [9:0] x, y;
  logic       active, hsync_n, vsync_n;

  vga_timing dut (.*);

  always #5 clk = ~clk;

  int pix_count = 0, line_starts = 0, last_line_start = -1;
  int frame_starts = 0, last_frame_start = -1;
  logic hs_prev = 1, vs_prev = 1;
  int errors = 0;

  always @(posedge clk) if (rst_n) begin
    pix_count++;
    if (hs_prev && !hsync_n) begin            // falling edge of hsync
      if (last_line_start >= 0 && pix_count - last_line_start != 800) begin
        $error("Line length %0d, expected 800", pix_count - last_line_start);
        errors++;
      end
      last_line_start = pix_count;
      line_starts++;
    end
    if (vs_prev && !vsync_n) begin            // falling edge of vsync
      if (last_frame_start >= 0 && pix_count - last_frame_start != 800 * 525) begin
        $error("Frame length %0d, expected %0d", pix_count - last_frame_start, 800 * 525);
        errors++;
      end
      last_frame_start = pix_count;
      frame_starts++;
    end
    hs_prev <= hsync_n;
    vs_prev <= vsync_n;
  end

  initial begin
    repeat (3) @(posedge clk);
    rst_n = 1;
    repeat (800 * 525 * 2 + 1000) @(posedge clk);
    if (frame_starts < 2) begin
      $error("Saw only %0d vsync pulses", frame_starts);
      errors++;
    end
    if (errors == 0) $display("PASS: %0d lines, %0d frames checked", line_starts, frame_starts);
    else             $display("FAIL: %0d errors", errors);
    $finish;
  end
endmodule
