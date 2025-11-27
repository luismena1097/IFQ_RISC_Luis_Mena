`timescale 1ns / 1ps

module cache_tb;

  // ---------------------------------------------------------
  // Localparam
  // ---------------------------------------------------------
  localparam DATA_WIDTH        = 32;
  localparam CACHE_LINE_WIDTH  = 128;
  localparam CACHE_DEPTH       = 64;
  localparam CLK_PERIOD        = 10;

  // ---------------------------------------------------------
  // Signals
  // ---------------------------------------------------------
  logic clk;
  logic [DATA_WIDTH-1:0] PC_in;
  logic rd_en;
  logic abort;
  logic [CACHE_LINE_WIDTH-1:0] D_out;
  logic d_out_valid;

  // ---------------------------------------------------------
  // DUT
  // ---------------------------------------------------------
  i_cache #(
    .DATA_WIDTH(DATA_WIDTH),
    .CACHE_LINE_WIDTH(CACHE_LINE_WIDTH),
    .CACHE_DEPTH(CACHE_DEPTH)
  ) dut (
    .PC_in(PC_in),
    .rd_en(rd_en),
    .abort(abort),
    .D_out(D_out),
    .d_out_valid(d_out_valid)
  );

  // ---------------------------------------------------------
  // CLK
  // ---------------------------------------------------------
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // ---------------------------------------------------------
  // Testbench
  // ---------------------------------------------------------
  initial begin
    $display("============================================================");
    $display("TESTBENCH: i_cache");
    $display("============================================================");

    // Init
    PC_in  = 32'h400_000;
    rd_en  = 0;
    abort  = 0;
    #20;
	 // -----------------------------------------------------
    // Reading first cache line
    // -----------------------------------------------------
	 rd_en = 1;
	 $display("PC_in = 0x%08h  -> CACHE_LINE[%0d] = %h  (valid=%0b)", PC_in, PC_in[9:4], D_out, d_out_valid);
	 #10;


    // -----------------------------------------------------
    // Abort enabled
    // -----------------------------------------------------
    $display("\n--- Abort enabled ---");
    PC_in = 32'h400_004;
    rd_en = 1;
    abort = 1;
    #5;
    $display("PC_in = 0x%08h -> CACHE_LINE[%0d]  -> D_out = %h  valid=%0b (esperado: invalidado)",  PC_in, PC_in[9:4], D_out, d_out_valid);
    #10;

    // -----------------------------------------------------
    // RD Disabled
    // -----------------------------------------------------
    $display("\n--- RD Disabled ---");
    PC_in = 32'h400_008;
    rd_en = 0;
    abort = 0;
    #5;
    $display("PC_in = 0x%08h -> CACHE_LINE[%0d] -> D_out = %h  valid=%0b (esperado: invalidado)",  PC_in, PC_in[9:4], D_out, d_out_valid);
    #10;

    // -----------------------------------------------------
    // Reading other line different from first one
    // -----------------------------------------------------
    $display("\n--- Reading other line different from first one ---");
    PC_in = 32'h400_0FC; 
    rd_en = 1;
    abort = 0;
    #5;
    $display("PC_in = 0x%08h  -> CACHE_LINE[%0d] = %h  (valid=%0b)", PC_in, PC_in[9:4], D_out, d_out_valid);
    #10;
	 
	 // -----------------------------------------------------
    //Second Line
    // -----------------------------------------------------	 
    PC_in  = 32'h400_040;
	 $display("\n--- Reading other line different from first one ---");
    rd_en  = 1;
    abort  = 0;
    #5;
	 $display("PC_in = 0x%08h  -> CACHE_LINE[%0d] = %h  (valid=%0b)", PC_in, PC_in[9:4], D_out, d_out_valid);
	 #10;


    // -----------------------------------------------------
    // Finalizaci�n
    // -----------------------------------------------------
    $display("\n============================================================");
    $display("END");
    $display("============================================================");
  end

endmodule

