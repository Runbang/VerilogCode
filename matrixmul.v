module Calculator(
	input Clock,
	input reset,
	input [143:0] A, 
	input [143:0] B,
	output reg[143:0] Result,
	output reg done
);
	reg [15:0] A1 [2:0][2:0];
	reg [15:0] B1 [2:0][2:0];
	reg [15:0] Res1 [2:0][2:0];
	reg finish;
	reg init;
	integer i,j,k;
	
	always@ (posedge reset)
	begin
		if(reset == 1)begin
			i = 0;
			j = 0;
			k = 0;
			init = 1;
			finish = 0;
			for(i=0;i<=2;i=i+1) begin
				for(j=0;j<=2;j=j+1) begin
					A1[i][j] = 16'd0;
					B1[i][j] = 16'd0;
					Res1[i][j] = 16'd0;
            	end 
        	end 
		end

		else if(finish ==0)begin
			if(init ==1)begin
				for(i=0;i<=2;i=i+1) begin
                    for(j=0;j<=2;j=j+1) begin
                        A1[i][j] = A[(i*3+j)*16 +:16];
                        B1[i][j] = B[(i*3+j)*16 +:16];
                        Res1[i][j] = 16'd0;
                    end 
                end
				init = 0;
				i=0; 
				j=0; 
				k=0;
			end
			else if(finish == 0) begin
				Res1[i][j] = Res1[i][j] + A1[i][k]*B1[k][j];
				if(k == 2) begin
                    k = 0;
                    if(j == 2) begin
                        j = 0;
                        if (i == 2) begin
                            i = 0;
                            finish = 1;
                        end
                        else
                            i = i + 1;
                    end
                    else
                        j = j+1;    
                end
                else
                    k = k+1;
			end
			else if(finish ==1)begin
				for(i=0;i<=2;i=i+1) begin   
                    for(j=0;j<=2;j=j+1) begin 
                        Result[(i*3+j)*16 +:16] = Res1[i][j];
                    end
                end
			end
		end
	end

endmodule