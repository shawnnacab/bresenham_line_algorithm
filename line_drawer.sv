module line_drawer(
	input logic clk, reset,
	input logic delay,
	input logic [10:0]	x0, y0, x1, y1, //the end points of the line
	output logic [10:0]	x, y, //outputs corresponding to the pair (x, y)
	output logic finished_drawing
	);
	
	/*
	 * You'll need to create some registers to keep track of things
	 * such as error and direction
	 * Example: */
	logic is_steep;
	logic signed [10:0] error;
	logic signed [10:0] deltax, deltay, abs_deltax, abs_deltay;
	logic signed [10:0] tempx0, tempx1, tempy0, tempy1, write_x, write_y;
	logic signed [1:0] ystep;
	logic [2:0] state;
	
	parameter [2:0] assign_temps = 1,
				swap_values = 2,
				prepare_output = 3,
				write_to_output = 4;
	
	abs absdeltax (.in(deltax), .out(abs_deltax));
	abs absdeltay (.in(deltay), .out(abs_deltay));
	
	always_ff @(posedge clk) begin
		if(reset||delay) begin
			deltax <= 0;
			deltay <= 0;
			error <= 0;
			ystep <= 1;
			is_steep <= 0;
			finished_drawing <= 1;
			state <= assign_temps;
		end
		else if(state == assign_temps) begin
			finished_drawing <= 0;
			deltax <= x1 - x0;
			deltay <= y1 - y0;
			is_steep <= abs_deltay > abs_deltax;
			tempx0 <= x0;
			tempx1 <= x1;
			tempy0 <= y0;
			tempy1 <= y1;
			state <= swap_values;
		end
		else if(state == swap_values) begin
			if(is_steep) begin
				if(tempy0 > tempy1) begin
					tempx0 <= tempy1; 
					tempx1 <= tempy0;
					tempy0 <= tempx1;
					tempy1 <= tempx0;
					deltax <= tempy0 - tempy1;
					deltay <= (tempx1 > tempx0 ? tempx1-tempx0 : tempx0-x1);
				end
				else begin 
					tempx0 <= tempy0;
					tempx1 <= tempy1; 
					tempy0 <= tempx0;
					tempy1 <= tempx1;
					deltax <= tempy1 - tempy0;
					deltay <= (tempx1 > tempx0 ? tempx1-tempx0 : tempx0-tempx1);
				end
			end
			else begin
				if(tempx0 > x1) begin
					tempx0 <= tempx1;
					tempx1 <= tempx0;
					tempy0 <= tempy1;
					tempy1 <= tempy0;
					deltax <= tempx0-tempx1;
					deltay <= (tempy1 > tempy0 ? tempy1-tempy0 : tempy0-tempy1);
				end
				else begin 
					deltax <= tempx1 - tempx0;
					deltay <= (tempy1 > tempy0 ? tempy1-tempy0 : tempy0-tempy1);
				end
				state <= prepare_output;
			end
		end
		else if (state == prepare_output) begin
			error <= deltax/2;
			ystep <= (y0 < y1 ? 1 : -1);
			write_x <= x0;
			write_y <= y0;
			state <= write_to_output;
		end
		
		else if(state == write_to_output) begin
			if(is_steep) begin
				x <= write_y;
				y <= write_x;
			end
			else begin
				x <= write_x;
				y <= write_y;
			end
			
			write_x <= write_x + 1;
			
			if(error - deltay <0) begin
					error <= error - deltay + deltax;
					write_y <= write_y + ystep;
			end
			else begin
				error <= error - deltay;
			end
			
			if(x == x1) begin
				finished_drawing <= 1;
				state <= assign_temps;
			end
		end
		
	end	//end of always_ff
	 
	 
endmodule
	
module abs(in, out);
	input logic [10:0] in;
	output logic [10:0] out;
	
	assign out = in[10] ? -in : in;
endmodule

module line_drawer_testbench();
	reg clk, reset, delay;
	reg [10:0] x0, y0, x1, y1;
	reg [10:0] x, y;
	
	line_drawer dut (clk, reset, delay, x0, y0, x1, y1, x, y);
	
		// Set up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; 
		delay <= 0;
		x0 <= 11'b00000000001; y0 <= 11'b00000000001; x1 <= 11'b00000001100; y1 <= 11'b00000000101; 	@(posedge clk); // diagonal
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
//																																	delay <= 1; @(posedge clk);
		reset <= 1; @(posedge clk);
		reset <= 0;
		x0 <= 11'b00000000001; y0 <= 11'b00000000001; x1 <= 11'b00000000100; y1 <= 11'b00000000001; @(posedge clk); // horizontal
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
		
		reset <= 1; @(posedge clk);
		reset <= 0;
		x0 <= 11'b00000000001; y0 <= 11'b00000000001; x1 <= 11'b0000000001; y1 <= 11'b00000001111; 	@(posedge clk); // vertical 
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
																																	@(posedge clk);
		$stop;
	end
endmodule
	
