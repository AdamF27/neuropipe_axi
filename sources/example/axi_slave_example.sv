// An example AXI slave module
`timescale 1ns/1ps

module axi_slave_example #(
    parameter ADDR_WIDTH = 0,
    parameter DATA_WIDTH = 0
) (
    input logic clk_i,
    input logic rstn_i,
    AXI_LITE axil
);
    // Internal parameters
    /*
        ADDRLSB is the least significant bit of this slave's memory space.
        Below ADDRLSB can be used to select byte of the word.
        Addressing scheme can be adjusted later on.
    */
    localparam ADDRLSB = $clog2(DATA_WIDTH) - 3;

    // Internal signals
    logic axi_read_ready;
    logic axi_write_ready;

    logic [ADDR_WIDTH-ADDRLSB-1:0] awaddr,
                                   araddr;

    assign awaddr = axil.awaddr[ADDR_WIDTH-1:ADDRLSB];
    assign araddr = axil.araddr[ADDR_WIDTH-1:ADDRLSB];

    // Internal memory -- can be replaced with ram
    logic [DATA_WIDTH-1:0] example_reg0,
                           example_reg1,
                           example_reg2,
                           example_reg3;

    // Default state for arready is high (A3.2.2)
    //assign axil.arready = 1'b1;

    // Read
    always @(posedge clk_i) begin
        if(!rstn_i) begin
            axil.rdata <= 0;
        end else if (!axil.rvalid || axil.rready) begin
            case (araddr)
                2'b00: axil.rdata <= example_reg0;
                2'b01: axil.rdata <= example_reg1;
                2'b10: axil.rdata <= example_reg2;
                2'b11: axil.rdata <= example_reg3;
                default : axil.rdata <= example_reg0;
            endcase
        end
    end

    // Write
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            example_reg0 <= 0;
            example_reg1 <= 0;
            example_reg2 <= 0;
            example_reg3 <= 0;
        end else if (axi_write_ready) begin
            case (axil.awaddr)
                2'b00: example_reg0 <= axil.wdata;
                2'b01: example_reg1 <= axil.wdata;
                2'b10: example_reg2 <= axil.wdata;
                2'b11: example_reg3 <= axil.wdata;
                default: example_reg0 <= axil.wdata;
            endcase
        end
    end

    // Read signaling

    assign axi_read_ready = axil.arvalid && axil.arready;

    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            axil.rvalid <= 1'b0; // valid must be cleared following any reset
        end else if (axil.arvalid && axil.rready)
            axil.rvalid <= 1'b1;
        end else if (axil.rready)
            axil.rvalid <= 1'b0;
    end

    assign axil.arready = !axil.rvalid;

    // Write signaling
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axi_write_ready <= 1'b0;
        end else begin
            axi_write_ready <= !axi_write_ready 
                               && (axil.wvalid && axil.awvalid)
                               && (axil.bready || !axil.bvalid);
        end
    end

    assign axil.awready = axi_write_ready;
    assign axil.wready = axi_write_ready;

    // Write response
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axil.bvalid <= 1'b0;
        end else if (axi_write_ready) begin
            axil.bvalid <= 1'b1;
        end else if (axil.bready) begin
            axil.bvalid <= 1'b0;
        end
    end

    // Read response
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axil.rvalid <= 1'b0;
        end else if (axi_read_ready) begin
            axil.rvalid <= 1'b1;
        end else if (axil.rready) begin
            axil.rvalid <= 1'b0;
        end
    end

    assign axil.bresp = 2'b00;
    assign axil.rresp = 2'b00;

    // Strobe
    /*function void funcname();
        
    endfunction : funcname*/

endmodule