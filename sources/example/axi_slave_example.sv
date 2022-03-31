// An example AXI slave module

module axi_slave_example #(
    parameter ADDR_WIDTH = 0,
    parameter DATA_WIDTH = 0
) (
    input logic clk_i,
    input logic rstn_i,
    axilITE.Slave axil
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

    logic [ADDR_WIDTH-ADDRLSB-1:0] aw_addr,
                                   ar_addr;

    assign aw_addr = axil.aw_addr[ADDR_WIDTH-1:ADDRLSB];
    assign ar_addr = axil.ar_addr[ADDR_WIDTH-1:ADDRLSB];

    // Internal memory -- can be replaced with ram
    logic [DATA_WIDTH-1:0] example_reg0,
                           example_reg1,
                           example_reg2,
                           example_reg3;

    // Default state for ar_ready is high (A3.2.2)
    //assign axil.ar_ready = 1'b1;

    // Read
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axil.r_data <= 0;
        end else if (!axil.r_valid || axil.r_ready) begin
            case (ar_addr)
                2'b00: axil.r_data <= example_reg0;
                2'b01: axil.r_data <= example_reg1;
                2'b10: axil.r_data <= example_reg2;
                2'b11: axil.r_data <= example_reg3;
                default : axil.r_data <= example_reg0;
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
            case (axil.aw_addr)
                2'b00: example_reg0 <= axil.w_data;
                2'b01: example_reg1 <= axil.w_data;
                2'b10: example_reg2 <= axil.w_data;
                2'b11: example_reg3 <= axil.w_data;
                default: example_reg0 <= axil.w_data;
            endcase
        end
    end

    // Read signaling

    assign axi_read_ready = axil.ar_valid && axil.ar_ready;

    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            axil.r_valid <= 1'b0; // valid must be cleared following any reset
        end else if (axil.ar_valid && axil.r_ready)
            axil.r_valid <= 1'b1;
        end else if (axil.r_ready)
            axil.r_valid <= 1'b0;
    end

    assign axil.ar_ready = !axil.r_valid;

    // Write signaling
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axi_write_ready <= 1'b0;
        end else begin
            axi_write_ready <= !axi_write_ready 
                               && (axil.w_valid && axil.aw_valid)
                               && (axil.b_ready || !axil.b_valid);
        end
    end

    assign axil.aw_ready = axi_write_ready;
    assign axil.w_ready = axi_write_ready;

    // Write response
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axil.b_valid <= 1'b0;
        end else if (axi_write_ready) begin
            axil.b_valid <= 1'b1;
        end else if (axil.b_ready) begin
            axil.b_valid <= 1'b0;
        end
    end

    // Read response
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axil.r_valid <= 1'b0;
        end else if (axi_read_ready) begin
            axil.r_valid <= 1'b1;
        end else if (axil.r_ready) begin
            axil.r_valid <= 1'b0;
        end
    end

    assign axil.b_resp = 2'b00;
    assign axil.r_resp = 2'b00;

    // Strobe
    /*function void funcname();
        
    endfunction : funcname*/

endmodule