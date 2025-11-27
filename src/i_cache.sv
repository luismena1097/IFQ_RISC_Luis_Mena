/*
	Module made by: Luis Alberto Mena
	Description : I-Cache (IFQ)		
	BRAM of 64 x 128 bits (256 instructions, 4 per cache line)	
	Output of 128 bits
	Address always aligns to 16 bytes 
*/

module i_cache #(parameter DATA_WIDTH=32, CACHE_LINE_WIDTH=128, CACHE_DEPTH=64)(
input logic [DATA_WIDTH-1:0] 			PC_in,
input logic 								rd_en,
input logic 								abort,

output logic [CACHE_LINE_WIDTH-1:0] D_out,
output logic								d_out_valid
);

//Cache 64 x 128 bits
reg [CACHE_LINE_WIDTH-1:0] cache_memory [0:CACHE_DEPTH-1];

// Init (simulation / synthesis)
initial begin
  $readmemh("..//src//CACHE_init.txt", cache_memory);
end

//4 LSB of PC are tied to 0000
//Using the bits 9:4 of the PC we can know which cache line is needed
logic [5:0] cache_line;
assign cache_line = PC_in[9:4];

always_comb begin
	if (rd_en && !abort) 
	begin
		D_out  = cache_memory[cache_line];		//Read cache line
		d_out_valid = 1'b1;        
	end 
	else
	begin
		D_out = 'b0;
		d_out_valid = 1'b0;
	end
end

endmodule
