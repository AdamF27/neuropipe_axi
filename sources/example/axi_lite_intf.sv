interface AXI_LITE #(
	parameter int unsigned ADDR_WIDTH = 0,
	parameter int unsigned DATA_WIDTH = 0
);
	localparam int unsigned STRB_WIDTH = DATA_WIDTH / 8;

	// Write addr channel
	logic [ADDR_WIDTH-1:0] awaddr;
	logic [2:0]            awprot;
	logic                  awvalid;
	logic 				   awready;

	// Write channel
	logic [DATA_WIDTH-1:0] wdata;
	logic [STRB_WIDTH-1:0] wstrb;
	logic 				   wvalid;
	logic				   wready;

	// Write response channel
	logic [1:0] 		   bresp;
	logic 				   bvalid;
	logic 				   bready;

	// Read addr channel
	logic [ADDR_WIDTH-1:0] araddr;
	logic [2:0] 		   arprot;
	logic 				   arvalid;
	logic 				   arready;

	// Read channel
	logic [DATA_WIDTH-1:0] rdata;
	logic [1:0] 		   rresp;
	logic 				   rvalid;
	logic 				   rready;

	modport Master (
		output awaddr, awprot, awvalid, input awready,
		output wdata, wstrb, wvalid, input wready,
		input bresp, bvalid, output bready,
		output araddr, arprot, arvalid, input arready,
		input rdata, rresp, rvalid, output rready
	);

	modport Slave (
		input awaddr, awprot, awvalid, output awready,
		input wdata, wstrb, wvalid, output wready,
		output bresp, bvalid, input bready,
		input araddr, arprot, arvalid, output arready,
		output rdata, rresp, rvalid, input rready
	);

endinterface