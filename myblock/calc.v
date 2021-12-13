module calc#(parameter DATA_WIDTH = 8, 
             parameter BLOCK_SIZE = 3,
             parameter M_ID = -1,
             parameter N_ID = -1,
             parameter OUTPUT_DATA_WIDTH = 2 * DATA_WIDTH)(
    input wire clock,
    input wire reset,
    input wire [DATA_WIDTH - 1:0] A[0:BLOCK_SIZE - 1],
    input wire [DATA_WIDTH - 1:0] B[0:BLOCK_SIZE - 1],
    output reg [OUTPUT_DATA_WIDTH - 1:0] res
);

integer position;

reg[OUTPUT_DATA_WIDTH - 1 :0] temp;

always @(posedge clock or negedge reset) begin
    if(~reset)begin
        res <= 0;
        temp <= 0;
    end
    else begin
        temp = 0;
        for(position = 0; position < BLOCK_SIZE; position = position + 1) begin
            temp = temp + A[position] * B[position];
        end
        res <= temp;
    end
end

endmodule
