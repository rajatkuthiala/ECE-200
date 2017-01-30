module RegFile(ra1, rd1 , ra2 , rd2 , clk , RegWrite , wa ,wd );
input[4:0] ra1;
output[15:0] rd1;
input[4:0] ra2;
output[15:0] rd2;
input clk;
input werf ;
input[4:0] wa;
input[15:0] wd;
reg [15:0] registers[15:0];

assign rd1 = registers[ra1];
assign rd2 = registers[ra2];

always@ ( posedge clk )
    if (RegWrite)
        registers[wa] <= wd;
endmodule
