module calc#(parameter DATA_WIDTH = 8, 
             parameter MATRIX_SIZE = 3,
             parameter BLOCK_SIZE = 3)(
    input wire clock,
    input wire reset,
    input wire [DATA_WIDTH - 1:0] A[0:BLOCK_SIZE - 1],
    input wire [DATA_WIDTH - 1:0] B[0:BLOCK_SIZE - 1],
    output reg [DATA_WIDTH - 1:0] res;
);

integer postion;
always @(posedge clock or negedge reset or A or B) begin
    if(~reset)begin
        res <= 0;
    end
    else begin
        for(postion = 0; postion < BLOCK_SIZE; postion = postion + 1) begin
            res = res + A[position] * B[position];
        end
    end
end

endmodule