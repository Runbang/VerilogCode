`timescale 1ns / 1ns
module test_bench;
	
	reg [143:0] A;
	reg [143:0] B;
	wire [143:0] Answer;
	reg reset;
	reg Clock;
	reg[15:0] matC[2:0][2:0];
	integer i,j;
	parameter Clock_period = 2;
	initial
	begin
		Clock = 1;
		reset = 1;
		#5;   
		reset = 0; 
		#Clock_period;
		A = {8'd9,8'd8,8'd7,8'd6,8'd5,8'd4,8'd3,8'd2,8'd1};
		B = {8'd1,8'd9,8'd8,8'd7,8'd6,8'd5,8'd4,8'd3,8'd2};
		#(Clock_period/2); 
		for(i=0;i<=2;i=i+1) begin
			for(j=0;j<=2;j=j+1) begin
				matC[i][j] = Answer[(i*3+j)*8+:8];
			end
		end
		#5;
		$stop;  
	end
    initial begin 
        $dumpfile("wave.vcd");        
        $dumpvars(0, test_bench);
    end
	always #(Clock_period/2) Clock <= ~Clock;

	Calculator calculator 
        (.Clock(Clock), 
        .reset(reset), 
        .A(A),
        .B(B), 
        .Result(Answer),
        .done(done));

endmodule