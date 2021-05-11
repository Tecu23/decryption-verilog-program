`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:33:04 11/23/2020 
// Design Name: 
// Module Name:    zigzag_decryption 
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
module zigzag_decryption #(
				parameter D_WIDTH = 8,
				parameter KEY_WIDTH = 8,
				parameter MAX_NOF_CHARS = 50,
				parameter START_DECRYPTION_TOKEN = 8'hFA
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

// TODO: Implement ZigZag Decryption here
/* Exemplu pentru key 3

   ------------- -> 1 ciclu
	| A  _  _  _ | R  _  _  _  R  _  _  _  P  _  _  _  -> line 1
	| 1          |
	| _  N  _  A | _  E  _  E  _  E  _  I  _  E  _  E  -> line 2
	|    2     4 |   
	| _  _  A  _ | _  _  M  _  _  _  S  _  _  _  R  _  -> line 3
	|       3    |  
	-------------
	si inputul ARRP | NAEEEIEE | AMSR 
	
		Am impartit inputul in 3 linii pentru key 3 si in 2 linii pentru key 2 si am marcat 
	inceputul si sfarsitul al fiecarei linii prin 2 variabile de tipul line_x_beg si line_x_end care 
	marcheaza pozitia primului si ultimului element de pe fiecare linie in functie de nr de cicluri 
	facute si de carry-ul(elementele care nu sunt destule pentru a contine un ciclu), un ciclu este format din 4 elemente
	in cazul key 3 si 2 elemente in cazul key 2.
		Si cat timp mai exista element in oricare linie vor continua sa le trimitem pe data_o. Ordinea in care sunt trimise caracterele
	este mentinuta de o variabila order care poate avea valorile 1,2,3,4 , astfel cand order este 1 trebuie sa afisam un
	element de prima linia , cand order este 2 trebuie sa afisam unul de pe a 2 a lini , cand este 3 de pe a 3 a linie , iar cand order
	este 4 ar trebui sa afisam elementul urmator de pe linia 2
	
	
*/
reg [D_WIDTH-1: 0] text [MAX_NOF_CHARS - 1 : 0];

//nr_elements este  variabila folosita pentru pastrarea numarului de elemente din sir
reg [7:0] nr_elements = 0;

//variabilele pentru linii
reg [7:0] line_1_beg;
reg [7:0] line_1_end;
reg [7:0] line_2_beg;
reg [7:0] line_2_end;
reg [7:0] line_3_end;
reg [7:0] line_3_beg;

//nr_cycles pastreaza numarul de cicluri , iar carry nr de elemente care nu formeaza un alt ciclu
reg [7:0] nr_cycles = 0;
reg [7:0] carry;
reg [7:0] order;

always @(posedge clk) begin
	
	
	//cand busy e 0 , valid_i e 1 si data_i contine caractere vom citi caracterele, vom mari numarul de elemente
	//si vom calcula nr de cicluri si carry 
	if(!busy) begin
	
		if(data_i != START_DECRYPTION_TOKEN && data_i != 0) begin
		
			if(valid_i) begin
			
				text[nr_elements] <= data_i;
				nr_elements <= nr_elements + 1;
				
				if(key==2) begin
					
					nr_cycles <= (nr_elements+1) >> 1;
					carry <= (nr_elements) - 2*(nr_cycles);
					
				end else if(key == 3) begin
				
					nr_cycles <= (nr_elements+1) >> 2;
					carry <= (nr_elements) - 4*nr_cycles;
				
				end
				
			end
		//cand data_i va avea valoare 0xFA busy va deveni 1 si in functie de valorile lui carry si a key
		//vom da valori variabilelor liniilor si order se va initializa cu 1
		end else if(data_i == START_DECRYPTION_TOKEN) begin
			
			busy <= 1;
			case(key)
			//in cazul in care cheia e 2 vom avea 2 linii unde sunt imparitte datele
				2: begin
					order <= 1;
					case(carry)
						0:begin
						   line_1_beg <= 0;
							line_1_end <= nr_cycles;
							line_2_beg <= nr_cycles+1; 
							line_2_end <= nr_elements-1;
						end
						1:begin
						   line_1_beg <= 0;
							line_1_end <= nr_cycles-1;
							line_2_beg <= nr_cycles; 
							line_2_end <= nr_elements-1;
							
						end
					endcase
				end
			//in cazul in care cheia e 3 vom avea 3 linii unde sunt impartite datele	
				3: begin
					order <= 1;
					case(carry)
						0: begin	

							line_1_beg <= 0;
							line_1_end <= nr_cycles; 
							line_2_beg <= nr_cycles+1;
							line_2_end <= 3*nr_cycles;
							line_3_beg <= 3*nr_cycles+1;
							line_3_end <= nr_elements-1;
						end
						1: begin
						
							line_1_beg <= 0;
							line_1_end <= nr_cycles;
							line_2_beg <= nr_cycles+1; 
							line_2_end <= 3*nr_cycles+1;
							line_3_beg <= 3*nr_cycles+2;
							line_3_end <= nr_elements-1;
						end
						2: begin
						
							line_1_beg <= 0;
							line_1_end <= nr_cycles;
							line_2_beg <= nr_cycles+1;
							line_2_end <= 3*nr_cycles+1;  
							line_3_beg <= 3*nr_cycles+2;
							line_3_end <= nr_elements-1;
						end
						3: begin
						
							line_1_beg <= 0;
							line_1_end <= nr_cycles-1;
							line_2_beg <= nr_cycles;
							line_2_end <= 3*nr_cycles-1; 
							line_3_beg <= 3*nr_cycles;
							line_3_end <= nr_elements-1;
						end
						
					endcase
				end
			endcase
			
		end
	//cat timp busy e 1 vom afisa caractere din text in ordinea corecta
	end else if(busy) begin
	
		valid_o <= 1;
	
		if(key == 2) begin
		
		//pentru key 2 vom avea 2 linii de pe care sa luam valorile cu 2 pozitii
			if( line_1_beg <= line_1_end && order == 1 ) begin
				data_o <= text[line_1_beg];
				line_1_beg <= line_1_beg + 1;
				order <= order + 1;
			end else if (line_2_beg <= line_2_end && order == 2) begin
				data_o <= text[line_2_beg];
				line_2_beg <= line_2_beg + 1;
				order <= 1;
			end else begin //cand cele 2 linii au ramas fara caractere busy se va face 0 si se va astepta un nou sir a fi citit
				busy <= 0;
				valid_o <= 0;
				data_o <= 0;
				nr_elements <= 0;
			end
			
		end else if(key == 3) begin
		
		//pentru key 3 vom avea 3 linii de pe care sa luam valorile , dar 4 pozitii
			if( line_1_beg <= line_1_end && order == 1 ) begin
				data_o <= text[line_1_beg];
				line_1_beg <= line_1_beg + 1;
				order <= order + 1;
			end else if(line_2_beg <= line_2_end && order == 2) begin
				data_o <= text[line_2_beg];
				line_2_beg <= line_2_beg + 1;
				order <= order + 1;
			end else if(line_3_beg <= line_3_end && order == 3) begin
				data_o <= text[line_3_beg];
				line_3_beg <= line_3_beg +1;
				order <= order + 1;
			end else if(line_2_beg <= line_2_end && order == 4) begin
				data_o <= text[line_2_beg];
				line_2_beg <= line_2_beg + 1;
				order <= 1;
			end else begin //cand cele 3 linii au ramas fara caractere busy se va face 0 si se va astepta un nou sir a fi citit
				busy <= 0;
				valid_o <= 0;
				data_o <= 0;
				nr_elements <= 0;
			end
		
		end
	
	end else begin //ramura de inceput cand busy e nedefinit , initializarea outputurilor
		busy<=0;
		valid_o <= 0;
		data_o <= 0;
	end
end

endmodule
