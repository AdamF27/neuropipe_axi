'timescale 1ns/1ps

module tb_axi_slave_example;
	localparam TB_ADDR_WIDTH = 4,
			   TB_DATA_WIDTH = 32;

	localparam CLK_FREQ = 100; // MHz
	localparam CLK_PERIOD = 1000/CLK_FREQ; 

	bit tb_clk,
		tb_rstn;

	// CLOCK
	initial begin
		tb_clk = 0;
		forever begin
			#(CLK_PERIOD/2); 
			tb_clk = ~tb_clk;
		end
	end

	AXI_LITE #(
		AXI_ADDR_WIDTH = TB_ADDR_WIDTH, 
		AXI_DATA_WIDTH = TB_DATA_WIDTH
	) tb_axi_l ();

	test_axi_slave_example #(
		ADDR_WIDTH = TB_ADDR_WIDTH,
		DATA_WIDTH = TB_DATA_WIDTH
	) test_axi_slave_example (
		.clk_i(tb_clk),
		.rstn_i(tb_rstn),
		.axi_l(tb_axi_l.Master)
	);

	axi_slave_example #(
		ADDR_WIDTH = TB_ADDR_WIDTH,
		DATA_WIDTH = TB_DATA_WIDTH
	) dfu_axi_slave (
		.clk_i(tb_clk),
		.rstn_i(tb_rstn),
		.axi_l(tb_axi_l.Slave)
	);

endmodule : tb_axi_slave_example