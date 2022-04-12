// An example AXI slave module
`timescale 1ns/1ps

module axi_slave_example #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH / 8
) (
    input clk_i,
    input rstn_i,

    input [ADDR_WIDTH-1:0] axil_awaddr,
    input [2:0] axil_awprot,
    input axil_awvalid,
    output logic axil_awready,

    input [DATA_WIDTH-1:0] axil_wdata,
    input [STRB_WIDTH-1:0] axil_wstrb,
    input axil_wvalid,
    output logic axil_wready,

    output logic [1:0] axil_bresp,
    output logic axil_bvalid,
    input axil_bready,

    input [ADDR_WIDTH-1:0] axil_araddr,
    input [2:0] axil_arprot,
    input axil_arvalid,
    output logic axil_arready,

    output logic [DATA_WIDTH-1:0] axil_rdata,
    output logic [1:0] axil_rresp,
    output logic axil_rvalid,
    input axil_rready
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

    assign awaddr = axil_awaddr[ADDR_WIDTH-1:ADDRLSB];
    assign araddr = axil_araddr[ADDR_WIDTH-1:ADDRLSB];

    // Internal memory -- can be replaced with ram
    logic [DATA_WIDTH-1:0] example_reg0,
                           example_reg1,
                           example_reg2,
                           example_reg3;

    // Default state for arready is high (A3.2.2)
    //assign axil_arready = 1'b1;

    // Read
    always @(posedge clk_i) begin
        if(!rstn_i) begin
            axil_rdata <= 0;
        end else if (!axil_rvalid || axil_rready) begin
            case (araddr)
                2'b00: axil_rdata <= example_reg0;
                2'b01: axil_rdata <= example_reg1;
                2'b10: axil_rdata <= example_reg2;
                2'b11: axil_rdata <= example_reg3;
                default : axil_rdata <= example_reg0;
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
            case (awaddr)
                2'b00: example_reg0 <= axil_wdata;
                2'b01: example_reg1 <= axil_wdata;
                2'b10: example_reg2 <= axil_wdata;
                2'b11: example_reg3 <= axil_wdata;
                default: example_reg0 <= axil_wdata;
            endcase
        end
    end

    // Read signaling

    assign axi_read_ready = axil_arvalid && axil_arready;

    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            axil_rvalid <= 1'b0; // valid must be cleared following any reset
        end else if (axil_arvalid && axil_rready) begin
            axil_rvalid <= 1'b1;
        end else if (axil_rready) begin
            axil_rvalid <= 1'b0;
        end
    end

    assign axil_arready = !axil_rvalid;

    // Write signaling
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axi_write_ready <= 1'b0;
        end else begin
            axi_write_ready <= !axi_write_ready 
                               && (axil_wvalid && axil_awvalid)
                               && (axil_bready || !axil_bvalid);
        end
    end

    assign axil_awready = axi_write_ready;
    assign axil_wready = axi_write_ready;

    // Write response
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axil_bvalid <= 1'b0;
        end else if (axi_write_ready) begin
            axil_bvalid <= 1'b1;
        end else if (axil_bready) begin
            axil_bvalid <= 1'b0;
        end
    end

    // Read response
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axil_rvalid <= 1'b0;
        end else if (axi_read_ready) begin
            axil_rvalid <= 1'b1;
        end else if (axil_rready) begin
            axil_rvalid <= 1'b0;
        end
    end

    assign axil_bresp = 2'b00;
    assign axil_rresp = 2'b00;

    // Strobe
    /*function void funcname();
        
    endfunction : funcname*/

    // Dump waveform
    initial begin
        $dumpfile ("design.vcd");
        $dumpvars(0, axi_slave_example);
    end

endmodule