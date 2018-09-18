module full_adder (input x, y, z, output s, c);
	assign s = x^y^z;
	assign c = (x&y) | (y&z) | (x&z);
endmodule
