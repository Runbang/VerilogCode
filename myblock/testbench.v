`timescale 1ns/1ns
module testbench;
reg clock;
reg reset;
integer i,j,k;
parameter FIRST_MATRIX_ROW_SIZE = 20;
parameter MATRIX_SIZE = 10;
parameter SECOND_MATRIX_COL_SIZE = 30;

parameter FIRST_BLOCK_ROW_SIZE = 5;
parameter BLOCK_SIZE = 5;
parameter SECOND_BLOCK_COL_SIZE = 5;
parameter DATA_WIDTH = 8;

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
 initial begin
        clock = 0;
        reset = 1;
        for(i = 0; i <= 1000; i = i+1) begin
            #5; clock = ~clock;
            #5; clock = ~clock;
        end
    end
initial begin
    for(i = 0; i < FIRST_MATRIX_ROW_SIZE; i++)begin
        for(j = 0; j < SECOND_MATRIX_COL_SIZE; j++)begin
            for(k = 0; k < MATRIX_SIZE; k++)begin
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

// `timescale 1ns / 1ps   //1 period of clk is 10ns
// module tb_ram (
//     output reg          clk_o,
//     output reg          rst_o,
//     output reg          wr_en_o,
//     output reg          rd_en_o,
//     output reg [7:0]    addr_o,
//     inout      [31:0]   data_io
//   );
//     reg[31:0] WriteRAM;      
//     initial begin
//       $monitor($time,,,  
//       "Data = %d", data_io);
//       WriteRAM= 0;
//       clk_o   = 0;
//       wr_en_o = 0;
//       rd_en_o = 0;
//       addr_o  = 0;
//       rst_o   = 1;
//       #20 rst_o = 0;
//       write(50,250);
//       write(100,500);  
//       write(200,1000); 
//       write (250,1250);
//       read(50);
//       read(100);
//       read(200);
//       read(250);

//     end

//     assign data_io = wr_en_o ? WriteRAM : 32'bz;

//     always begin
//       #5 clk_o = ~clk_o;    
//     end

//     task write(
//    input[7:0]       x_i,
//    input[31:0]      y_i
//    );
//    begin
//      #100;                  
//      @(posedge clk_o);      
//      addr_o = x_i;
//      WriteRAM = y_i;
//      #1                    
//      wr_en_o = 1'b1;
//      @(posedge clk_o);
//      #50                   
//      wr_en_o = 1'b0;
//    end
//    endtask

//    task read(             
//    input[7:0]       x_i
//    );
//     begin
//      #100;
//      @(posedge clk_o);
//      addr_o = x_i;
//      #1
//      rd_en_o = 1'b1;
//      @(posedge clk_o);
//      #50
//      rd_en_o =  1'b0;
//     end
//   endtask 

endmodule
