module matrix_mul#(parameter DATA_WIDTH = 8, 

                   parameter FIRST_MATRIX_ROW_SIZE = 3,
                   parameter SECOND_MATRIX_COL_SIZE = 3,
                   parameter MATRIX_SIZE = 3,

                   parameter FIRST_BLOCK_ROW_SIZE = 3,
                   parameter SECOND_BLOCK_COL_SIZE = 3,
                   parameter BLOCK_SIZE = 3,

                   parameter OUTPUT_DATA_WIDTH = DATA_WIDTH * 2)(
    input wire clock,
    input wire reset
);

reg [DATA_WIDTH - 1:0] A[0:FIRST_MATRIX_ROW_SIZE ][0:MATRIX_SIZE ];
reg [DATA_WIDTH - 1:0] B[0:MATRIX_SIZE ][0:SECOND_MATRIX_COL_SIZE ];


localparam timesA = ((FIRST_MATRIX_ROW_SIZE - 1) / FIRST_BLOCK_ROW_SIZE) + 1;  //Ceiling of block count
localparam timesB = ((SECOND_MATRIX_COL_SIZE - 1) / SECOND_BLOCK_COL_SIZE) + 1; 
localparam timesK = ((MATRIX_SIZE - 1) / BLOCK_SIZE) + 1; 

reg[$clog2(timesA + 1) - 1:0] first_block_signal;
reg[$clog2(timesA + 1)-1:0] first_block_signal_last;
reg[$clog2(timesB + 1) - 1:0] second_block_signal;
reg[$clog2(timesB + 1)-1:0] second_block_signal_last;
reg[$clog2(timesK + 1) - 1:0] k_signal;
reg[$clog2(timesK + 1)-1:0] k_signal_last;

wire [FIRST_BLOCK_ROW_SIZE * SECOND_BLOCK_COL_SIZE * OUTPUT_DATA_WIDTH - 1:0] thread_outputs;

genvar block1_position,block2_position,k_position;

generate
for(block1_position = 0; block1_position < FIRST_BLOCK_ROW_SIZE; block1_position = block1_position + 1) begin
    for(block2_position = 0; block2_position < SECOND_BLOCK_COL_SIZE; block2_position = block2_position + 1) begin

        wire [DATA_WIDTH-1:0] BLOCK_A [0:BLOCK_SIZE-1];
        wire [DATA_WIDTH-1:0] BLOCK_B [0:BLOCK_SIZE-1];

        for(k_position = 0; k_position < BLOCK_SIZE; k_position = k_position + 1)begin
            assign BLOCK_A[k_position] = A[first_block_signal * FIRST_BLOCK_ROW_SIZE + block1_position][k_signal * BLOCK_SIZE + k_position];
            assign BLOCK_B[k_position] = B[k_signal * BLOCK_SIZE + k_position][second_block_signal * SECOND_BLOCK_COL_SIZE + block2_position];
        end

        calc #(.DATA_WIDTH(DATA_WIDTH),
                .BLOCK_SIZE(BLOCK_SIZE),
                .M_ID(block1_position),
                .N_ID(block2_position),
                .OUTPUT_DATA_WIDTH(OUTPUT_DATA_WIDTH)
                )cal(
                    .clock(clock),
                    .reset(reset),
                    .A(BLOCK_A),
                    .B(BLOCK_B),
                    .res(thread_outputs[(block1_position * SECOND_BLOCK_COL_SIZE + block2_position) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH])
                );
    end
end
endgenerate

reg[FIRST_MATRIX_ROW_SIZE * SECOND_MATRIX_COL_SIZE * OUTPUT_DATA_WIDTH - 1:0] finals;

integer A_index,B_index;

always @(posedge clock or negedge reset) begin
    if(!reset) begin
        finals <= 0;
    end
    else begin
        for(A_index = 0; A_index < FIRST_BLOCK_ROW_SIZE; A_index = A_index + 1) begin
            for(B_index = 0; B_index < SECOND_BLOCK_COL_SIZE; B_index = B_index + 1) begin
                finals[((first_block_signal_last * FIRST_BLOCK_ROW_SIZE + A_index) * SECOND_MATRIX_COL_SIZE + (second_block_signal_last * SECOND_BLOCK_COL_SIZE) + B_index) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <=
                finals[((first_block_signal_last * FIRST_BLOCK_ROW_SIZE + A_index) * SECOND_MATRIX_COL_SIZE + (second_block_signal_last * SECOND_BLOCK_COL_SIZE) + B_index) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH]
                 + thread_outputs[((A_index * SECOND_BLOCK_COL_SIZE) + B_index) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];   
            end
        end
    end
end

wire A_done,B_done,k_done;
reg done;
assign A_done = (first_block_signal == timesA - 1);
assign B_done = (second_block_signal == timesB - 1);
assign k_done = (k_signal == timesK - 1);

always @(posedge clock or negedge reset) begin
    if (!reset) begin
        done <= 0;
    end
    else if (done) begin
        done <= 0;
    end
    else begin
        done <= (k_done & A_done & B_done);
    end
end

always @(posedge clock or negedge reset) begin
    if(~reset)begin
        k_signal <= 0;
        first_block_signal <= 0;
        second_block_signal <= 0;
        k_signal_last <= 0;
        first_block_signal_last <= 0;
        second_block_signal_last <= 0;
    end
    else begin
        if(k_done)begin
            k_signal <= 0;
            if(B_done) begin
                second_block_signal <= 0;
                if(A_done) begin
                    first_block_signal <= 0;
                end
                else begin
                    first_block_signal <= first_block_signal + 1;
                end
            end
            else begin
                second_block_signal <= second_block_signal + 1;
            end
        end
        else begin
           k_signal <= k_signal + 1'b1; 
       end
    end
    first_block_signal_last <= first_block_signal;
    second_block_signal_last <= second_block_signal;
    k_signal_last <= k_signal;
end

endmodule
