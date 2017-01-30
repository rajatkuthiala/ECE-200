module shiftReg (CLK, clr, shift, ld, Din, SI, Dout);
input CLK;
input clr; // clear register
input shift; // shift
input ld; // load register from Din
input [7:0] Din; // Data input for load
input SI; // Input bit to shift in
output [7:0] Dout;
reg [7:0] Dout;
always @(posedge CLK) begin
if (clr) Dout <= 0;
else if (ld) Dout <= Din;
else if (shift) Dout <= { Dout[6:0], SI };
end
endmodule 