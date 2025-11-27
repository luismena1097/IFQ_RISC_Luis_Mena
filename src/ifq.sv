/*
	Module made by: Luis Alberto Mena
	Description : Instruction Fetch Queue (IFQ)				  
*/

module ifq #(parameter DATA_WIDTH=32, CACHE_LINE_WIDTH=128, FIFO_DEPTH=4)(
input logic 								clk,
input logic 								rst,
input logic [CACHE_LINE_WIDTH-1:0] 	D_out,
input logic									d_out_valid,
input logic 								rd_en,
input logic [DATA_WIDTH-1:0]			Jmp_branch_address,
input logic 								jmp_branch_valid,

output logic [DATA_WIDTH-1:0]			PC_in, 								
output logic [DATA_WIDTH-1:0]			PC_out, 		
output logic [DATA_WIDTH-1:0]			Instr,
output logic 								rd_en_o,
output logic								abort,
output logic 								empty 		
);

logic [CACHE_LINE_WIDTH-1:0] FIFO_out;		//FIFO OUT
logic [4:0]   rp,wp;			//Pointers
//logic			  fifo_empty;	//FIFO is empty
logic [DATA_WIDTH-1:0] IFQ_mux_2_bypass_mux; //Output of IFQ mux to input of bypass mux
logic [DATA_WIDTH-1:0] IFQ_mux_1st_instr; //Output of mux 1st instruction to input of bypass mux
logic [DATA_WIDTH-1:0] IFQ_mux_1st_or_FIFO_inst;//Instruction from the bypass mux
logic [DATA_WIDTH-1:0] IFQ_mux_branch_not_taken;
logic [DATA_WIDTH-1:0] PC_in_Plus_16;
logic [DATA_WIDTH-1:0] PC_in_reg;
logic 					  fifo_full;
logic [DATA_WIDTH-1:0] PC_out_i_w;
/**************************************************************** PC ****************************************************************/

//Program Counter to be used depending if there is a Jump or a Branch
assign PC_in = jmp_branch_valid ? Jmp_branch_address : PC_in_reg;

//To brin the next 4 instructions from the cache
assign PC_in_Plus_16 = PC_in + 'h10;

//Program Counter to fetch instructions
pc #(.WIDTH(DATA_WIDTH))program_counter_fetch(.clk(clk), .rst(rst), .enable(~fifo_full), .Data_i(PC_in_Plus_16), .Data_o(PC_in_reg));

assign PC_out_i_w = jmp_branch_valid ? Jmp_branch_address : (PC_out + 'h4);

//Program Counter to do the calculation of the jump/branch
pc #(.WIDTH(DATA_WIDTH))program_counter_out(.clk(clk), .rst(rst), .enable(rd_en | jmp_branch_valid ), .Data_i(PC_out_i_w), .Data_o(PC_out));

/**************************************************************** PC ****************************************************************/

//FIFO sync module
fifo_ifq #(.CACHE_LINE_WIDTH(CACHE_LINE_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) ifq_FIFO(
.clk(clk),
.rst(rst),
.Data_in(D_out),							//From cache
.flush(jmp_branch_valid),
.Jmp_Branch_Bits_2_3(Jmp_branch_address[3:2]),
.fifo_write_en(d_out_valid),
.read_instruction(rd_en),

.fifo_full(fifo_full),
.fifo_empty(empty),
.Data_out(FIFO_out),
.rp(rp), .wp(wp)
);

//MUX for Data of the FIFO Output
mux4_1 #(.WIDTH(32)) mux_ifq_output (
.Data0(FIFO_out[31:0]), 
.Data1(FIFO_out[63:32]), 
.Data2(FIFO_out[95:64]),
.Data3(FIFO_out[127:96]), 
.sel(rp[1:0]),  
.Data_o(IFQ_mux_2_bypass_mux) 
);

//MUX in case FIFO is empty, this avoids wasting cycles
mux4_1 #(.WIDTH(32)) mux_1st_instr (
.Data0(D_out[31:0]), 
.Data1(D_out[63:32]), 
.Data2(D_out[95:64]),
.Data3(D_out[127:96]), 
.sel(rp[1:0]),  
.Data_o(IFQ_mux_1st_instr) 
);

//Bypass MUX between the output of the FIFO or the first instruction in case the FIFO is empty
always_comb begin IFQ_mux_1st_or_FIFO_inst = empty ? IFQ_mux_1st_instr : IFQ_mux_2_bypass_mux; end

assign Instr = IFQ_mux_1st_or_FIFO_inst;
assign rd_en_o = ~fifo_full;
assign abort = 1'b0;

endmodule
