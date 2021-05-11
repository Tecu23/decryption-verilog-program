`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:12:00 11/23/2020 
// Design Name: 
// Module Name:    demux 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module decryption_top#(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16,
			parameter MST_DWIDTH = 32,
			parameter SYS_DWIDTH = 8
		)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		// Input interface
		input [MST_DWIDTH -1 : 0] data_i,
		input 						  valid_i,
		output busy,
		
		//output interface
		output [SYS_DWIDTH - 1 : 0] data_o,
		output      					 valid_o,
		
		// Register access interface
		input[addr_witdth - 1:0] addr,
		input read,
		input write,
		input [reg_width - 1 : 0] wdata,
		output[reg_width - 1 : 0] rdata,
		output done,
		output error
		
    );
	
	// TODO: Add and connect all Decryption blocks
	
	//iesirile din regfile
	wire[reg_width-1 : 0 ] select;
	wire[reg_width-1 : 0 ] caesar_key;
	wire[reg_width-1 : 0 ] scytale_key;
	wire[reg_width-1 : 0 ] zigzag_key;
	
	//intrarile criptate
	wire [SYS_DWIDTH - 1 : 0] dataCaesar;
	wire                      validCaesar;
	wire [SYS_DWIDTH - 1 : 0] dataScytale;
	wire                      validScytale;
	wire [SYS_DWIDTH - 1 : 0] dataZigzag;
	wire                      validZigzag;
	
	//iesirile decriptate
	wire [SYS_DWIDTH - 1 : 0] dataCaesar_o;
	wire                      validCaesar_o;
	wire [SYS_DWIDTH - 1 : 0] dataScytale_o;
	wire                      validScytale_o;
	wire [SYS_DWIDTH - 1 : 0] dataZigzag_o;
	wire                      validZigzag_o;
	
	//semnalele busy
	wire busyCaesar;
	wire busyScytale;
	wire busyZigzag;
	
	
	//apelam bancul de registre
	decryption_regfile REG(clk_sys,rst_n,addr,read,write,wdata,rdata,done,error,select,caesar_key,scytale_key,zigzag_key);
	
	//demultiplexor
	demux DMUX(clk_sys,clk_mst,rst_n,select[1:0],data_i,valid_i,dataCaesar,validCaesar,dataScytale,validScytale,dataZigzag,validZigzag);
	
	
	//decritiile
	caesar_decryption CAESAR(clk_sys,rst_n,dataCaesar,validCaesar,caesar_key,busyCaesar,dataCaesar_o,validCaesar_o);
	
	scytale_decryption SCYTALE(clk_sys,rst_n,dataScytale,validScytale,scytale_key[15:8],scytale_key[7:0],dataScytale_o,validScytale_o,busyScytale);
	
	zigzag_decryption ZIGZAG(clk_sys,rst_n,dataZigzag,validZigzag,zigzag_key[7:0],busyZigzag,dataZigzag_o,validZigzag_o);
	
	//multiplexor
	mux MUX(clk_sys,rst_n,select[1:0],data_o,valid_o,dataCaesar_o,validCaesar_o,dataScytale_o,validScytale_o,dataZigzag_o,validZigzag_o);
	
	//OR
	or OR(busy,busyCaesar,busyScytale,busyZigzag);
	
	
	

endmodule
