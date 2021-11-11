`timescale 1ns/1ns
module testbench;
reg clock;
reg reset;
integer i,j,k;
parameter MATRIX_SIZE = 3;
parameter DATA_WIDTH = 8;
matrix_mul#(.DATA_WIDTH(DATA_WIDTH),
            .MATRIX_SIZE(MATRIX_SIZE)) mm(
    .clock(clock),
    .reset(reset)
);
 initial begin
        clock = 0;
        reset = 1;
        for(i = 0; i <= 1000; i = i+1) begin
            #5; clock = ~clock;
            #5; clock = ~clock;
        end
    end
initial begin
    for(i = 0; i < 3; i++)begin
        for(j = 0; j < 3; j++)begin
            for(k = 0; k < 3; k++)begin
                mm.A[i][k] = i + j + k;
                mm.B[k][j] = i + j + k;
            end
        end
    end
end
initial begin
    #10;reset = 0;
    #10;reset = 1;  
end
initial begin
        $dumpfile("wave.vcd"); 
		$dumpvars(0,testbench); 
	end
always @(negedge mm.k_done) begin
    if(reset) begin //rst high => not in reset
        $finish();
    end
end
//generate a 50Mhz clock for testing the design.

endmodule