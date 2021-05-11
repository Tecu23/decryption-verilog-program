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

module demux #(
		parameter MST_DWIDTH = 32,
		parameter SYS_DWIDTH = 8
	)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Input interface
		input [MST_DWIDTH -1  : 0]	 data_i,
		input 						 	 valid_i,
		
		//output interfaces
		output reg [SYS_DWIDTH - 1 : 0] 	data0_o,
		output reg     						valid0_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data1_o,
		output reg     						valid1_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data2_o,
		output reg     						valid2_o
    );
	
	
	// TODO: Implement DEMUX logic
	
	//variabila folosita pentru pastrarea datelor de intrare pe 32 de biti
	reg[MST_DWIDTH-1 : 0] registru;
	
	//variabile folosite pentru schimbarea starilor
	//pe starea 1 se vor scrie primii 8 biti in datai_o in functie de select
	//pe starea 2 se vor scrie urmatorii 8 biti in datai_o in functie de select
	//pe starea 3 se vor scrie urmatorii 8 biti in datai_o in functie de select
	//pe starea 4 se vor scrie ultimii 8 biti in datai_o in functie de select
	integer state = 1;
	integer next_state = 1;
	
	//pe ceasul clk_mst vom atribui valoarea lui data_i in registru si atribuim lui validi_o valoarea de 1
	always @(posedge clk_mst) begin
	
		if(data_i != 0 && valid_i) begin
		
			registru <= data_i;
			case(select)
				0: begin
					valid0_o <= 1;
				end
				1: begin
					valid1_o <= 1;
				end
				2: begin
					valid2_o <= 1;
				end
			
			endcase
		
		end else begin //altfel ii reinitializam cu 0 
			registru <= 0;
			valid0_o <= 0;
			valid1_o <= 0;
			valid2_o <= 0;
		end
		
		
	end
	
	//pe ceasul clk_sys vom face schimbarea starilor de afisare state si next_state
	always @(posedge clk_sys) begin 
	
			state<= next_state;
	
	end
	
	//in partea combinationala daca avem valorii scrise in registru , iar validi_o este 1 vom scrie in datai_o valoarea din registru in functie de stare
	always @(*) begin
		
		if(registru != 0 && ((!valid0_o) || (!valid1_o) || (!valid2_o))) begin
			case (select)
				0: begin
					data0_o = registru[31 - 8*(state-1) -: 8];
				end
				1: begin
					data1_o = registru[31 - 8*(state-1) -: 8];
				end
				2: begin
					data2_o = registru[31 - 8*(state-1) -: 8];
				end
			endcase
			
			if(state == 4) //daca am ajuns in starea 4 , next_state va lua valoarea 1 , insemnand reinitializarea starii
				next_state = 1;
			else
				next_state = next_state + 1; //altfel se va mari
				
		end else if(registru == 0) begin //cand registrul e 0 vom scrie valoarea 0
		
			data0_o = 0;
			data1_o = 0;
			data2_o = 0;
		
		end
	
	end	
	

endmodule
