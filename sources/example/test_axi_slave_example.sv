// Stimulus generation

module test_axi_slave_example #(
	parameter ADDR_WIDTH = 0,
	parameter DATA_WIDTH = 0
) (
	input clk_i,
	input rstn_i,
	AXI_LITE.Master axil
);
	
	initial begin
		rstn_i <= 0;
		repeat(5) @(posedge clk_i);
		rstn_i <= 1;

		// Write
		axil.aw_addr <= 4'b0000;
		axil.aw_valid <= 1;
		axil.w_valid <= 1;
		axil.w_data <= 32'h10101010;

		
		@(posedge clk_i);
		/*
		assert(axil.aw_ready && axil.w_ready)
			else $error("Slave not ready to write");
		*/
		$display("$display--@%t; axil.aw_ready=%0b; axil.w_ready=%0b", $time,
				 axil.aw_ready, axil.w_ready);
		$strobe("$strobe--@%t; axil.aw_ready=%0b; axil.w_ready=%0b", $time,
			    axil.aw_ready, axil.w_ready);

		@(posedge clk_i);
		/*
		assert(axil.b_valid)
			else $error("Write response not valid");
		*/
		$display("$display--@%t; axil.aw_ready=%0b", $time, axil.b_valid);
		$strobe("$strobe--@%t; axil.aw_ready=%0b", $time, axil.b_valid);

		axil.aw_addr <= 4'b0100;
		axil.w_data <= 32'h20202020;

		@(posedge clk_i);
		/*
		assert(axil.aw_ready && axil.w_ready)
			else $error("Slave not ready to write");
		*/
		$display("$display--@%t; axil.aw_ready=%0b; axil.w_ready=%0b", $time,
				 axil.aw_ready, axil.w_ready);
		$strobe("$strobe--@%t; axil.aw_ready=%0b; axil.w_ready=%0b", $time,
			    axil.aw_ready, axil.w_ready);

		@(posedge clk_i);
		/*
		assert(axil.b_valid)
			else $error("Write response not valid");
		*/
		$display("$display--@%t; axil.aw_ready=%0b", $time, axil.b_valid);
		$strobe("$strobe--@%t; axil.aw_ready=%0b", $time, axil.b_valid);

		axil.aw_addr <= 4'b1000;
		axil.w_data <= 32'h30303030;

		@(posedge clk_i);
		/*
		assert(axil.aw_ready && axil.w_ready)
			else $error("Slave not ready to write");
		*/
		$display("$display--@%t; axil.aw_ready=%0b; axil.w_ready=%0b", $time,
				 axil.aw_ready, axil.w_ready);
		$strobe("$strobe--@%t; axil.aw_ready=%0b; axil.w_ready=%0b", $time,
			    axil.aw_ready, axil.w_ready);

		@(posedge clk_i);
		/*
		assert(axil.b_valid)
			else $error("Write response not valid");
		*/
		$display("$display--@%t; axil.aw_ready=%0b", $time, axil.b_valid);
		$strobe("$strobe--@%t; axil.aw_ready=%0b", $time, axil.b_valid);

		axil.aw_addr <= 4'b1100;
		axil.w_data <= 32'h40404040;
	end

endmodule : test_axi_slave_example