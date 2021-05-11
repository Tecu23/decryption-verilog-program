`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:13:49 11/23/2020 
// Design Name: 
// Module Name:    decryption_regfile 
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
module decryption_regfile #(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16
		)(
			// Clock and reset interface
			input clk, 
			input rst_n,
			
			// Register access interface
			input[addr_witdth - 1:0] addr,
			input read,
			input write,
			input [reg_width -1 : 0] wdata,
			output reg [reg_width -1 : 0] rdata,
			output reg done,
			output reg error,
			
			// Output wires
			output reg[reg_width - 1 : 0] select,
			output reg[reg_width - 1 : 0] caesar_key,
			output reg[reg_width - 1 : 0] scytale_key,
			output reg[reg_width - 1 : 0] zigzag_key
    );

// TODO implementati bancul de registre.
reg [reg_width - 1 : 0 ] select_register, caesar_key_register, scytale_key_register, zigzag_key_register;

always @(posedge clk or negedge rst_n) begin
		
	//verificarea semnalului de reset si atribuirea valorilor de reset pentru fiecare registru	
	if(!rst_n) begin // 
			
		select_register <= 16'h00_00;
		caesar_key_register <= 16'h00_00;
		scytale_key_register <= 16'hff_ff;
		zigzag_key_register <= 16'h00_02;	
	
	end else 
	//verificarea semnalului de write si atribuirea valorilor registrelor in functie de adresa
		if (write) begin 
		
			case (addr) 
				8'h00_00: select_register <= wdata[1:0];
				8'h00_10: caesar_key_register <= wdata;
				8'h00_12: scytale_key_register <= wdata;
				8'h00_14: zigzag_key_register <= wdata;
				default: error <= 1;//eror ia valoarea 1 in cazul in care adresa e diferita de adresele de baza ale registrelor
			endcase
			
			//atribuirea lui done valoarea de 1 dupa atribuirea de valori
			done <= 1;
			
		end else
	
		//verificarea semnalului de read si atribuirea valorilor registrelor in rdata in functie de adresa	
			if(read) begin 
			
				case (addr)				
					8'h00: rdata <= select_register;
					8'h10: rdata <= caesar_key_register;
					8'h12: rdata <= scytale_key_register;
					8'h14: rdata <= zigzag_key_register;
					default: error <= 1; //eror ia valoarea 1 in cazul in care adresa e diferita de adresele de baza ale registrelor
				endcase
				
				//atribuirea lui done valoarea de 1 dupa atribuirea de valori 
				done <= 1;
				
			end else begin //done si error sunt reinitializate dupa fiecare ciclu de ceas
				done <= 0;
				error <= 0;
				rdata <= 0;
			end
		 
end
	
	//partea combinationala prin atribuirea out-urilor valorile registrelor
always @(*) begin
	
	select = select_register;
	caesar_key = caesar_key_register;
	scytale_key = scytale_key_register;
	zigzag_key = zigzag_key_register;
		
end
	
endmodule
