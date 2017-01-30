
module mem;
	reg clk;
	reg rst;
	reg [31:0] inst,oumt;
	integer cycle;

	instruction_MEM hu (.index(inst), .instruction(oumt), .clk(clk));

	always begin
		#1
		clk=~clk;
		if(clk==1'b1) begin
			cycle=cycle+1;
		end
	end

	initial begin
	clk=0;
	cycle = 0;
	inst <= 32'b00000000000000000000000000000000;
	$display(oumt);
	end
endmodule

