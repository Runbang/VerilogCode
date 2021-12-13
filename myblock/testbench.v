`timescale 1ns/1ns
module testbench;
reg clock;
reg reset;
integer i,j,k;
parameter FIRST_MATRIX_ROW_SIZE = 18;
parameter MATRIX_SIZE = 60;
parameter SECOND_MATRIX_COL_SIZE = 21;

parameter FIRST_BLOCK_ROW_SIZE = 9;
parameter BLOCK_SIZE = 3;
parameter SECOND_BLOCK_COL_SIZE = 3;

parameter DATA_WIDTH = 16;
parameter OUTPUT_DATA_WIDTH = 2 * DATA_WIDTH;

matrix_mul#(.DATA_WIDTH(DATA_WIDTH),
            .FIRST_MATRIX_ROW_SIZE(FIRST_MATRIX_ROW_SIZE),
            .SECOND_MATRIX_COL_SIZE(SECOND_MATRIX_COL_SIZE),
            .MATRIX_SIZE(MATRIX_SIZE),
            .FIRST_BLOCK_ROW_SIZE(FIRST_BLOCK_ROW_SIZE),
            .SECOND_BLOCK_COL_SIZE(SECOND_BLOCK_COL_SIZE),
            .BLOCK_SIZE(BLOCK_SIZE)) mm(
    .clock(clock),
    .reset(reset)
);

 
integer itr_n, itr_m, itr_k;
    initial begin
        for(itr_m = 0; itr_m < FIRST_MATRIX_ROW_SIZE; itr_m = itr_m + 1) begin
            for(itr_n = 0; itr_n < SECOND_MATRIX_COL_SIZE; itr_n = itr_n + 1) begin
                for(itr_k = 0; itr_k < MATRIX_SIZE; itr_k = itr_k + 1) begin
                    mm.A[itr_m][itr_k] = itr_m * MATRIX_SIZE + itr_k;
                    mm.B[itr_k][itr_n] = itr_k * SECOND_MATRIX_COL_SIZE + itr_n;
                end
            end
        end
     $display("A:");
        for(itr_m = 0; itr_m < FIRST_MATRIX_ROW_SIZE; itr_m = itr_m + 1) begin
            for(itr_k = 0; itr_k < MATRIX_SIZE; itr_k = itr_k + 1) begin
                $write("%d ",mm.A[itr_m][itr_k]);
            end
            $display("");
        end

        $display("B:");
        for(itr_k = 0; itr_k < MATRIX_SIZE; itr_k = itr_k + 1) begin
            for(itr_n = 0; itr_n < SECOND_MATRIX_COL_SIZE; itr_n = itr_n + 1) begin
                $write("%d ",mm.B[itr_k][itr_n]);
            end
            $display("");
        end
end

initial begin
        clock = 0;
        reset = 1;
        for(i = 0; i <= 1000; i = i+1) begin
            #5; clock = ~clock;
            #5; clock = ~clock;
        end
    end

initial begin
    #12;reset = 0;
    #12;reset = 1;  
end
initial begin
    $dumpfile("data/dumpfile.vcd"); 
    $dumpvars(0,testbench); 
end
always @(negedge mm.done) begin
    if(reset) begin //rst high => not in reset
        $finish();
    end
end
//generate a 50Mhz clock for testing the design.
integer final_a, final_b;
final begin
       $display("Final results:");
       for(final_a = 0; final_a < FIRST_MATRIX_ROW_SIZE; final_a = final_a + 1) begin
           for(final_b = 0; final_b < SECOND_MATRIX_COL_SIZE ; final_b = final_b + 1) begin
               $write("%d ",mm.finals[(final_a * SECOND_MATRIX_COL_SIZE + final_b) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH]);
           end
           $display("");
       end
   end

endmodule
