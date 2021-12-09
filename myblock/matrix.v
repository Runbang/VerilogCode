module matrix_mul#(parameter DATA_WIDTH = 8, 
                   parameter FIRST_MATRIX_ROW_SIZE = 3,
                   parameter SECOND_MATRIX_COL_SIZE = 3,
                   parameter MATRIX_SIZE = 3,
                   parameter FIRST_BLOCK_ROW_SIZE = 3,
                   parameter SECOND_BLOCK_COL_SIZE = 3,
                   parameter BLOCK_SIZE = 3)(
    input wire clock,
    input wire reset
);
reg [DATA_WIDTH - 1:0] A[0:FIRST_MATRIX_ROW_SIZE - 1][0:MATRIX_SIZE - 1];
reg [DATA_WIDTH - 1:0] B[0:MATRIX_SIZE - 1][0:SECOND_MATRIX_COL_SIZE - 1];
wire [FIRST_MATRIX_ROW_SIZE * SECOND_MATRIX_COL_SIZE * 2 * DATA_WIDTH - 1:0] thread_outputs;

localparam timesA = ((FIRST_MATRIX_ROW_SIZE) / FIRST_BLOCK_ROW_SIZE) + 1; 
localparam timesB = ((SECOND_MATRIX_COL_SIZE) / SECOND_BLOCK_COL_SIZE) + 1; 
localparam timesK = ((MATRIX_SIZE) / BLOCK_SIZE) + 1; 

reg[$clog2(timesA) - 1:0] first_block_signal;
reg[$clog2(timesK) - 1:0] second_block_signal;
reg[$clog2(timesB) - 1:0] k_signal;

wire A_done,B_done,k_done,done;

genvar block1_position,block2_position,k_position;

generate
for(block1_position = 0; block1_position < FIRST_BLOCK_ROW_SIZE; block1_position = block1_position + 1) begin
    for(block2_position = 0; block2_position < SECOND_BLOCK_COL_SIZE; block2_position = block2_position + 1) begin

        // wire [DATA_WIDTH-1:0] BLOCK_A [0:BLOCK_SIZE-1];
        // wire [DATA_WIDTH-1:0] BLOCK_B [0:BLOCK_SIZE-1];
        for(k_position = 0; k_position < BLOCK_SIZE; k_position = k_position + 1)begin
            assign BLOCK_A[k_position] = A[first_block_signal * FIRST_BLOCK_ROW_SIZE + block1_position][k_signal * BLOCK_SIZE + k_position];
            assign BLOCK_B[k_position] = B[k_signal * BLOCK_SIZE + k_position][second_block_signal * SECOND_BLOCK_COL_SIZE + block2_position];
        end

        calc #(.DATA_WIDTH(DATA_WIDTH),
                .MATRIX_SIZE(MATRIX_SIZE),
                .BLOCK_SIZE(BLOCK_SIZE)
                )cal(
                    .clock(clock),
                    .reset(reset),
                    .A(BLOCK_A),
                    .B(BLOCK_B),
                    .res(thread_outputs[(block1_position * BLOCK_SIZE + block2_position) * DATA_WIDTH +: DATA_WIDTH])
                );
    end
end
endgenerate

assign k_done = (k_signal == timesK - 1);
assign A_done = (first_block_signal == timesA - 1);
assign B_done = (second_block_signal == timesB - 1);

assign done = (A_done && B_done && k_done);
always @(posedge clock or negedge reset) begin
    if(~reset)begin
        k_signal = 0;
        first_block_signal = 0;
        second_block_signal = 0;
    end
    if(done)begin
        k_signal = 0;
        first_block_signal = 0;
        second_block_signal = 0;
    end
    else begin
        if(k_done)begin
            k_signal <= 0;
            second_block_signal <= second_block_signal + 1;
        end
       k_signal <= k_signal + 1'b1; 
    end
end
endmodule
