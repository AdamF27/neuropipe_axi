// An example AXI-Lite master module
`timescale 1ns/1ps

module axi_lite_master_ex #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH / 8
) (
    input clk_i,
    input rstn_i,

    /*
        Temporary instruction ports for testing and demonstration
        Will need to add logic to decode RISC instructions
    */
    input inst_i,
    input addr_i,
    input [DATA_WIDTH-1:0] data_i, // Data to be written to slave 
    input inst_valid,

    AXI_LITE axil
);
    localparam READ = 0;
    localparam WRITE = 1;

    logic [DATA_WIDTH-1:0] rdata_reg;

    logic inst_write, inst_read;

    logic busy;

    assign busy = axil.bready || axil.rready;

    // Inst
    assign inst_write = inst_valid && !busy && inst_i;
    assign inst_read = inst_valid && !busy && !inst_i;

    // Strobe
    assign axil.wstrb = 4'b1111;

    // Protection not implemented
    assign axil.awprot = 0;
    assign axil.arprot = 0;

    // Address
    always_ff @(posedge clk_i) begin
         if(!rstn_i) begin
            axil.awaddr <= 0;
            axil.araddr <= 0;
         end else begin
            axil.awaddr <= addr_i;
            axil.araddr <= addr_i;
         end
    end

    // Write signaling
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
           axil.bready  <= 0;
           axil.awvalid <= 0;
           axil.wvalid <= 0;
        end else if (inst_write) begin
            axil.bready <= 1;
            axil.awvalid <= 1;
            axil.wvalid <= 1;
        end else if (axil.bready) begin
            // Resetting when valid/ready handshake occurs
            if (axil.bvalid) begin
                axil.bready <= 0;
            end

            if (axil.awready) begin
                axil.awvalid <= 0;
            end

            if (axil.wready) begin
                axil.wvalid <= 0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axil.wdata <= 0;
        end else begin
            if (inst_write) begin
                axil.wdata <= data_i;
            end
        end
    end

    // Read signalling
    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            axil.rready <= 0;
            axil.arvalid <= 0;
        end else if (inst_read) begin
            // Signal to read
            axil.rready <= 1;
            axil.arvalid <= 1;
        end else if (axil.rready) begin
            if (axil.rvalid) begin
                axil.rready <= 0;
            end

            if (axil.arready) begin
                axil.arvalid <= 0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            rdata_reg <= 0;
        end else begin
            if (axil.rvalid && axil.rready) begin
                rdata_reg <= axil.rdata;
            end
        end
    end

endmodule