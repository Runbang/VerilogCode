module matrix_mul#(parameter DATA_WIDTH = 8, parameter MATRIX_SIZE = 3)(
    input wire clock,
    input wire reset
);
reg [DATA_WIDTH - 1:0] A[0:MATRIX_SIZE - 1][0:MATRIX_SIZE - 1];
reg [DATA_WIDTH - 1:0] B[0:MATRIX_SIZE - 1][0:MATRIX_SIZE - 1];
wire [MATRIX_SIZE * MATRIX_SIZE * DATA_WIDTH - 1:0] thread_outputs;

genvar m, n;
reg[$clog2(MATRIX_SIZE + 1):0] k_signal;
wire k_done;

generate
for(m = 0; m < 3; m = m + 1) begin
    for(n = 0; n < 3; n = n + 1) begin
        calc #(.DATA_WIDTH(DATA_WIDTH),
                .MATRIX_SIZE(MATRIX_SIZE)
                )cal(
                    .clock(clock),
                    .reset(reset),
                    .A(A[m][k_signal]),
                    .B(B[k_signal][n]),
                    .res(thread_outputs[(m * MATRIX_SIZE + n) * DATA_WIDTH +: DATA_WIDTH])
                );
    end
end
endgenerate

assign k_done = (k_signal == MATRIX_SIZE - 1);

always @(posedge clock or negedge reset) begin
    if(~reset)begin
        k_signal = 0;
    end
    if(k_done)begin
        k_signal <= 0;
    end
    else begin
       k_signal <= k_signal + 1'b1; 
    end
end
endmodule
