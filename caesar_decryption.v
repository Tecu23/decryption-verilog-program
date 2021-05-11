`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:17:08 11/23/2020 
// Design Name: 
// Module Name:    ceasar_decryption 
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
module caesar_decryption #(
				parameter D_WIDTH = 8,
				parameter KEY_WIDTH = 16
			)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
         output reg busy,
				
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o
    );

// TODO: Implement Caesar Decryption here
reg [D_WIDTH-1 : 0] letter = 0;

always @(posedge clk) begin

	//semnalul busy va fi 0 mereu
	busy <= 0;

	//daca valid_i este 1 inseamna ca avem caractere de citit si vom atribui valoarea caracterului lui letter
		if(valid_i) begin
			letter <= data_i;
		end else begin //daca valid_i e 0 letter va avea valoarea 0 semnaland ca nu este niciun caracter citit
			letter <= 0;
		end
		
	if(letter != 0) begin //daca letter are caractere de citit atunci out data_o ii va fi atribuita valoarea lui letter decriptata si vali_o va fi 1
		data_o <= letter - key;
		valid_o <= 1;
	end else begin  //daca letter e 0 , valid_o va fi 0 , iar data_o va fi 0
		valid_o <= 0;
		data_o <= 0;
	end

end

endmodule
