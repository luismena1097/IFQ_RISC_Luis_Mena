`timescale 1ns/1ps

module ifq_tb;

    //====================================================================
    // Localparam
    //====================================================================
    localparam DATA_WIDTH       = 32;
    localparam CACHE_LINE_WIDTH = 128;
    localparam FIFO_DEPTH       = 4;
    localparam CLK_PERIOD       = 10;
	 localparam CACHE_DEPTH       = 64;

    //====================================================================
    // Signals
    //====================================================================
    logic clk;
    logic rst;

    logic [CACHE_LINE_WIDTH-1:0] D_out;
    logic                        d_out_valid;
    logic                        rd_en;
    logic [DATA_WIDTH-1:0]       Jmp_branch_address;
    logic                        jmp_branch_valid;

    logic [DATA_WIDTH-1:0]       PC_in;
    logic [DATA_WIDTH-1:0]       PC_out;
    logic [DATA_WIDTH-1:0]       Instr;
    logic                        rd_en_o;
    logic                        abort;
    logic                        empty;
	 
	 //Adding cache for testing IFQ module
	 i_cache #(
    .DATA_WIDTH(DATA_WIDTH),
    .CACHE_LINE_WIDTH(CACHE_LINE_WIDTH),
    .CACHE_DEPTH(CACHE_DEPTH)
	 ) i_cache (
    .PC_in({PC_in[31:4],4'b0}),
    .rd_en(rd_en_o),
    .abort(abort),
    .D_out(D_out),
    .d_out_valid(d_out_valid)
	 );
	 
    //====================================================================
    // DUT (Device Under Test)
    //====================================================================
    ifq #(
        .DATA_WIDTH(DATA_WIDTH),
        .CACHE_LINE_WIDTH(CACHE_LINE_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .D_out(D_out),
        .d_out_valid(d_out_valid),
        .rd_en(rd_en),
        .Jmp_branch_address(Jmp_branch_address),
        .jmp_branch_valid(jmp_branch_valid),

        .PC_in(PC_in),
        .PC_out(PC_out),
        .Instr(Instr),
        .rd_en_o(rd_en_o),
        .abort(abort),
        .empty(empty)
    );

    //====================================================================
    // CLK
    //====================================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    //====================================================================
    // Testbench
    //====================================================================
    initial begin
		  rst = 0;
		  rd_en = 0;
		  #(CLK_PERIOD+1);
        rst = 1;
        #15;
        rst = 0;
		  Jmp_branch_address = 0;
		  jmp_branch_valid = 0;
		  rd_en = 1;
		  #103;
		  Jmp_branch_address = 'h00400b0;
		  jmp_branch_valid = 1;
		  #10;
		  jmp_branch_valid = 0;	  
		  #20;
		  Jmp_branch_address = 'h0040048;
		  jmp_branch_valid = 1;
		  #10;
		  jmp_branch_valid = 0;
    end
	
    //====================================================================
    // Monitoreo
    //====================================================================
    initial begin
        $display("Tiempo | PC_in | PC_out | Instr | empty | rd_en_o | jmp_branch_valid");
        $monitor("%0t | %h | %h | %h | %b | %b | %b",
                 $time, PC_in, PC_out, Instr, empty, rd_en_o, jmp_branch_valid);
    end

endmodule
