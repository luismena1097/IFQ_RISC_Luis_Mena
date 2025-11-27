/*
	Module made by: Luis Alberto Mena
	Description : FIFO for the IFQ			  
*/
module fifo_ifq #(parameter CACHE_LINE_WIDTH=128, FIFO_DEPTH=4)(
input logic 								clk,
input logic 								rst,
input logic [CACHE_LINE_WIDTH-1:0] 	Data_in,
input logic									flush,
input logic [1:0]							Jmp_Branch_Bits_2_3,
input logic 								fifo_write_en,
input logic									read_instruction,

output logic								fifo_full,
output logic								fifo_empty,
output logic [CACHE_LINE_WIDTH-1:0] Data_out,
output logic [4:0]						wp,rp
);

//FIFO 
logic [CACHE_LINE_WIDTH-1:0] fifo_mem[FIFO_DEPTH];

//Write
always_ff @(posedge clk or posedge rst) begin
   if (rst) begin
		wp <= 'b0;
		for (int i = 0; i < FIFO_DEPTH; i++) begin
			fifo_mem[i] <= '0;
      end
   end
	else if(fifo_write_en && !fifo_full) begin
		fifo_mem[wp[3:2]] <= Data_in;
		wp <= wp + 'h4;
	end	
		if (flush) begin
		wp <= 'h4;
		fifo_mem[0] <= Data_in;
		for (int i = 1; i < FIFO_DEPTH; i++) begin
			fifo_mem[i] <= '0;
      end
   end
end

//Read
always_ff @(posedge clk or posedge rst) begin
   if (rst) begin
		rp <= 'b0;
   end
	else if(flush) begin
		rp[4:2] <= 'b0;
		rp[1:0] <= Jmp_Branch_Bits_2_3;
	 end
	else if(rp[4:2] == 'b0)
		rp <= rp + 1'b1;
	else if (read_instruction && !fifo_empty)
		rp <= rp + 1'b1;
	else if (!read_instruction)
		rp <= rp;	
end

assign fifo_empty = (wp[4:2] == rp[4:2]);

always_comb begin
    if (flush)
        fifo_full = 1'b0;
	 else if (rst)
		  fifo_full = 1'b1;
    else
        fifo_full = (((wp[3:2] + 2'd1) & 2'd3) == rp[3:2]);
end 

assign Data_out = fifo_mem[rp[3:2]];

endmodule