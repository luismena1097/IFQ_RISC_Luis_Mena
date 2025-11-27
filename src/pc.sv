/*
	Description: Parametric register with modifications for Program Counter module
	Author: Luis Alberto Mena González
*/

module pc #(
    parameter int WIDTH = 32
)(
    input  logic              clk,
    input  logic              rst,
    input  logic              enable,
    input  logic [WIDTH-1:0]  Data_i,
    output logic [WIDTH-1:0]  Data_o
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            Data_o <= 32'h400_000;  // Program counter start address for RISC-V
        else if (enable)
            Data_o <= Data_i;
		  else Data_o <= Data_o;
        // else implícito: mantiene el valor de Data_o
    end

endmodule