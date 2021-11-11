module calc#(parameter DATA_WIDTH = 8, parameter MATRIX_SIZE = 3)(
    input wire clock,
    input wire reset,
    input wire [DATA_WIDTH - 1:0] A,
    input wire [DATA_WIDTH - 1:0] B,
    output reg [DATA_WIDTH - 1:0] res
);

always @(posedge clock or negedge reset) begin
    if(~reset)begin
        res<=0;
    end
    else begin
        res<= res + A*B; 
    end
end

endmodule