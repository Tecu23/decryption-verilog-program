`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:12 11/27/2020 
// Design Name: 
// Module Name:    scytale_decryption 
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
module scytale_decryption#(
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
			input[KEY_WIDTH - 1 : 0] key_N,
			input[KEY_WIDTH - 1 : 0] key_M,
			
			// Output interface
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o,
			
			output reg busy
    );

// TODO: Implement Scytale Decryption here
/* Exemplu pentru key_N = 4 si key_M = 4

	-------------------------
	|  A  |  N  |  A  |  A  |
	-------------------------
	|  R  |  E  |  M  |  E  |
	-------------------------
	|  R  |  E  |  S  |  I  |
	-------------------------
	|  P  |  E  |  R  |  E  |
	-------------------------
 
 si inputul ARRP | NEEE | AMSR | AEIE 
 
	Cu ajutorul variabilelor i si j mi-am construit in text inputul deja decriptat folosind formula i*M+j astfel, pana cand 
		introducem N numar de caractere le vom pune la poziile 0,1*M,2*M...., dupa care vom mari j , urmatoarele N numar
		de caractere le vom pune pe pozitiile 1,1*M+1,2*M+1... si asa mai departe pana cand terminam de citit caractere rezultand
		in text sirul de caractere decriptat
		
		text se va decripta astfel pentru ex:
		
		0  0  0  0  0  0  0  0  0  0   0   0   0   0   0   0   
		0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15
		
		- vom pune primele N(4) caractere pe pozitiile M*0(0),M*1(4),M*2(8),M*3(12)
		
		A  0  0  0  R  0  0  0  R  0   0   0   P   0   0   0   
		0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15
		
		-dupa care vom mari j cu 1 si vom pune urmatoarele N(4) caractere pe pozitiile 1,5,9,13
		
		A  N  0  0  R  E  0  0  R  E   0   0   P   E   0   0   
		0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15
		
		-dupa care vom mari j cu 1 si vom pune urmatoarele N(4) caractere pe pozitiile 2,6,10,14
		
		A  N  A  0  R  E  M  0  R  E   S   0   P   E   R   0   
		0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15
		
		-dupa care vom mari j cu 1 si vom pune urmatoarele N(4) caractere pe pozitiile 3,7,11,15
		
		A  N  A  A  R  E  M  E  R  E   S   I   P   E   R   E   
		0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15
		
		-dupa care vom ramane fara caractere si vom fi terminat de citit
*/

integer i=0;
integer j=0;

integer k=0;
//nr_elements este  variabila folosita pentru pastrarea numarului de elemente din sir
integer nr_elements = 0;
//read_elements e o variabila cu care parcurgem la citire textul decriptat
integer read_elements = 0;

reg [D_WIDTH-1: 0] text [MAX_NOF_CHARS - 1 : 0];


always @(posedge clk) begin

	//cand busy e 0 , valid_i e 1 si data_i contine caractere vom citi caracterele si ne vom crea textul decriptat folosind
	//algoritmul de mai devreme, cu i pargurgand liniile si j coloanele
	if(!busy) begin
	
		if(data_i != START_DECRYPTION_TOKEN && data_i != 0) begin
	
			//read_elements este initializat cu 0 pentru ca la citire sa fie 0
			read_elements <= 0;
			
			if(valid_i) begin
				text[ i * key_M + j ] <= data_i;
				nr_elements <= nr_elements + 1;
				i <= i + 1;
			
			end
			//folosind acest for verificam daca cumva am ajuns la un capat de coloana sa marim j si sa ii redam lui i 0
			//in cazul in care sunt 50 de caractere si N e 2 vom avea 25 de coloare
			for(k = 1 ; k <= 25 ; k = k+1) begin
				if(nr_elements == k*key_N-1) begin
					j <= j + 1 ;
					i <= 0;
				end
			end  
		//cand data_i e 0xFA busy devine 1 si se reinitializeaza i si j
		end else if(data_i == START_DECRYPTION_TOKEN) begin
			busy <= 1;
			i <= 0;
			j <= 0;
		end 
	
	//cand busy e 1 vom incepe citirea , read_elements fiind initializat mai devreme ca incepe cu 0
	//si va creste progresiv
	end else if (busy) begin
		if(nr_elements != read_elements) begin
		
			valid_o <= 1;
			data_o <= text[read_elements];
			read_elements <= read_elements + 1;
			
		end else begin //cand numarul de elemente afisare va ajunge la fel de mare cu numarul de elemente citite in nr_elements 
							//inseamna ca am terminat de afisat tot sirul si ar trebui sa dam valorile corespunzatoare semnalelor de out
			nr_elements <= 0;
			busy <= 0;
			valid_o <= 0;
			data_o <= 0;
			
		end
				
	end else begin //ramura de inceput cand busy e nedefinit , initializarea outputurilor
		busy <= 0;
		valid_o <= 0;
		data_o <= 0;
	end
	
end 

endmodule
