module risc_top (clk,reset);
input clk,reset;
wire [15:0]AOUT;
wire [3:0]opcode,alu_task,alu_fun;
wire cout,aluout_ctrl,npc_ctrl,ir_ctrl,A_ctrl,B_ctrl,lmd_ctrl,imm_ctrl,
 sel_mxa, sel_mxb, sel_mxout,write,memwr,memrd,cond_ctrl,wr_data_ins,rd_data_ins;

 wire [19:0] wr_data;
 control_unit controlpath(
clk,reset,AOUT,cout,opcode,alu_fun,aluout_ctrl,npc_ctrl,ir_ctrl,A_ctrl,B_ctrl,lmd_ctrl,imm_ctrl,
 sel_mxa, sel_mxb, sel_mxout,write,memwr,memrd,alu_task,cond_ctrl,wr_data_ins,rd_data_ins);
 risc_nonpipe datapath(
AOUT,cout,opcode,alu_fun,aluout_ctrl,clk,reset,npc_ctrl,ir_ctrl,A_ctrl,B_ctrl,lmd_ctrl,imm_ctrl,
 sel_mxa, sel_mxb,
sel_mxout,write,memwr,memrd,alu_task,cond_ctrl,wr_data,wr_data_ins,rd_data_ins);

 endmodule

module risc_nonpipe (
AOUT,cout,opcode,alu_fun,aluout_ctrl,clk,reset,npc_ctrl,ir_ctrl,A_ctrl,B_ctrl,lmd_ctrl,imm_ctrl,
 sel_mxa, sel_mxb,
sel_mxout,write,memwr,memrd,alu_task,cond_ctrl,wr_data,wr_data_ins,rd_data_ins);
input aluout_ctrl,clk,reset,npc_ctrl,ir_ctrl,A_ctrl,B_ctrl,lmd_ctrl,imm_ctrl,
 sel_mxa, sel_mxb, sel_mxout,write,memwr,memrd,cond_ctrl,wr_data_ins,rd_data_ins;

input [3:0]alu_task;
output cout;
output [3:0] opcode,alu_fun;
output [15:0] AOUT;
output [19:0] wr_data;
wire [15:0] pc_out,pc_in,npc_in,npc_out,a_out,a_in,b_out,b_in,lmd_out,lmd_in,
 imm_out,imm_in,aluout,aluout_out,alu_src1,alu_src2,reg_wr_in,xtn_out,aluout_in;

wire [19:0] ins_out;
wire [3:0] dst,src1,src2;
wire sel_cond,cond_in;
pc pcreg(clk,reset,pc_out,pc_in);
adder16 pc_adder(npc_in,pc_out,16'h1);
//NPC
latch16 NPC(npc_ctrl,npc_out,npc_in);
//IR
IR ir_reg(ir_ctrl,opcode,dst,src1,src2,alu_fun,ins_out);
//A
latch16 A(A_ctrl,a_out,a_in);
//B
latch16 B(B_ctrl,b_out,b_in);
//LMD
latch16 LMD(lmd_ctrl,lmd_out,lmd_in);
//IMM
latch16 IMM(imm_ctrl,imm_out,imm_in);
//COND
//cond COND1(cond_ctrl,sel_cond,cond_in);
alu16 alu(cout,aluout_in,alu_src1,alu_src2,alu_task);
//ALU_OUT
latch16 ALU_OUT(aluout_ctrl,aluout_out,aluout_in);
data_mem datamem(lmd_in,aluout_out,b_out,memwr,memrd);
//ins_mem insmem(ins_out,pc_out);
ins_mem insmem(ins_out,pc_out,wr_data,wr_data_ins,rd_data_ins);
mux2x1_16b muxa(sel_mxa,alu_src1,npc_out,a_out),
 muxb(sel_mxb,alu_src2,b_out,imm_out),
 muxnpc_alu(cond_ctrl,pc_in,npc_out,aluout_out),
 muxout(sel_mxout,reg_wr_in,lmd_out,aluout_out);
sign_xtnd xtender(src2,alu_fun, imm_in);
//reg_file reg_Ro_R15(write,a_in,b_in,src1,src2,dst,reg_wr_in);
reg_file_2p reg_Ro_R15(clk,write,a_in,b_in,src1,src2,dst,reg_wr_in);
//brz_check iszero(a_out,cond_in);
assign AOUT = a_out;
endmodule
//Datapath: Combinational Computational Components
//1. Sign Extension unit
module sign_xtnd (xtn_in1,xtn_in2, xtn_out);
input [3:0] xtn_in1,xtn_in2;
output [15:0] xtn_out;
reg [15:0] xtn_out;
always @ (xtn_in1 or xtn_in2)
begin
if(xtn_in1[3])
begin
 xtn_out[3:0] = xtn_in2;
 xtn_out[7:4] = xtn_in1;
 xtn_out[15:8] = 8'b11111111;
 end
else
 begin
 xtn_out[3:0] = xtn_in2;
 xtn_out[7:4] = xtn_in1;
 xtn_out[15:8] = 8'b00000000;
end
 end
endmodule

//Adder - 16 Bit
module adder16 (addout,ain,bin);
input [15:0] ain,bin;
output [15:0] addout;
assign addout = ain+bin;
endmodule
//Mux 2 by 1 : 16 bit wide
module mux2x1_16b (sel,mxout,mxin1,mxin2);
input [15:0] mxin1,mxin2;
input sel;
output [15:0] mxout;
reg [15:0] mxout;
always @ (mxin1 or mxin2 or sel)
case(sel)
1'b0: mxout=mxin1;
1'b1: mxout=mxin2;
endcase
endmodule 

module alu16(cout,aluout,ain,bin,alu_func);
input [15:0] ain,bin;
input [3:0] alu_func;
output [15:0] aluout;
output cout;
reg [15:0] aluout;
reg cout;
always @ (ain or bin or alu_func)
begin
case(alu_func)
4'b0000: {cout,aluout} = ain+bin;
4'b0001: {cout,aluout} = ain-bin;
4'b0010: aluout = ain | bin;
4'b0011: aluout = ain & bin;
4'b0100: aluout = ain ^ bin;
4'b0101: aluout = ain << bin;
4'b0110: aluout = ain >> bin;
//4'b0000: aluout = ain bin;
endcase
end
//assign cout = aluout[16];
endmodule
// Datapath : Storage Elements
//GP Register bank
//two read port and 1 write port
module reg_file(write,rdata1,rdata2,rdreg1,rdreg2,wrreg,wr_data);
input [3:0] rdreg1,rdreg2,wrreg;
input [15:0] wr_data;
input write;
output [15:0] rdata1,rdata2;
reg [15:0] rdata1,rdata2;
reg [15:0] reg_bank [0:15];
//Regs are R_0 to R_15
always @ (write or rdreg1 or rdreg2 or wrreg or wr_data)
 begin
 rdata1 = reg_bank[rdreg1];
 rdata2 = reg_bank[rdreg2];
 if(write)
 reg_bank[wrreg] = wr_data;
 end
 endmodule

//Regfile two pahse
module reg_file_2p(clk,write,rdata1,rdata2,rdreg1,rdreg2,wrreg,wr_data);
input [3:0] rdreg1,rdreg2,wrreg;
input [15:0] wr_data;
input write,clk;
output [15:0] rdata1,rdata2;
reg [15:0] rdata1,rdata2;
reg [15:0] reg_bank [0:15];
//Regs are R_0 to R_15
always @ (clk or write or rdreg1 or rdreg2 or wrreg or wr_data)
 begin
 case(clk)
 1'b1: begin
 rdata1 = reg_bank[rdreg1];
 rdata2 = reg_bank[rdreg2];
 end
 1'b0:begin
 if(write)
 reg_bank[wrreg] = wr_data;
 end
 endcase
 end
 endmodule

//Registers and latches used in datapath
module pc (clk,reset,pcout,pcin);
input [15:0] pcin;
input clk,reset;
output [15:0] pcout;
reg [15:0] pcout;
always @ (posedge clk or negedge reset)
begin
 if (~reset)
 pcout = 16'b0;
 else
 pcout = pcin;
 end
 endmodule

//will be used for
//NPC, A, B, IMM, Alu_out, LMD
module latch16 (ctrl,lth_out,lth_in);
input [15:0] lth_in;
input ctrl;
output [15:0] lth_out;
reg [15:0] lth_out;
always @ (ctrl or lth_in)
begin
if(ctrl)
 lth_out=lth_in;
 end
 endmodule

//IR Latch
module IR (ctrl,opcode,dst,src1,src2,alu_fun,ir_in);
input [19:0] ir_in;
input ctrl;
output [3:0]opcode,dst,src1,src2,alu_fun;
reg [3:0]opcode,dst,src1,src2,alu_fun;
//output [19:0] ir_out;
//reg [19:0] ir_out;
always @ (ctrl or ir_in)
begin
if(ctrl)
 begin
 opcode = ir_in[19:16];
 dst = ir_in[15:12];
 src1 = ir_in[11:8];
 src2 = ir_in[7:4];
 alu_fun = ir_in[3:0];
 end
 end
 endmodule
//CondLatch
module cond (ctrl,cond_out,cond_in);
input cond_in;
input ctrl;
output cond_out;
reg cond_out;
always @ (ctrl or cond_in)
begin
if(ctrl)
 cond_out=cond_in;
 end
 endmodule
//Instruction memery
module ins_mem(rd_data,address,wr_data,memwr,memrd);
input [15:0] address;
input [19:0] wr_data;
input memwr,memrd;
output [19:0]rd_data;
reg [19:0]rd_data;
reg [19:0] mem_data[0:31];
always @ (address or wr_data or memwr or memrd)
begin
if(memwr)
 mem_data[address] = wr_data;
if(memrd)
 rd_data = mem_data[address];

 else
 rd_data = 20'bzzzzzzzzzzzzzzzz;
 end
 endmodule
//Data memory

module data_mem(rd_data,address,wr_data,memwr,memrd);
input [15:0] address, wr_data;
input memwr,memrd;
output [15:0]rd_data;
reg [15:0]rd_data;
reg [15:0] mem_data [0:31];
always @ (address or wr_data or memwr or memrd)
begin
if(memwr)
 mem_data[address] = wr_data;
if(memrd)
 rd_data = mem_data[address];

 else
 rd_data = 16'bzzzzzzzzzzzzzzzz;
 end
 endmodule