// An example AXI slave module

module axi_slave_example #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
) (
    AXI_LITE.Slave axi_l,
    input logic clk_i,
    input logic rstn_i
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

    // Internal memory -- can be replaced with ram
    logic [DATA_WIDTH-1:0] example_reg0, example_reg1, example_reg2, example_reg3;

    // Default state for ar_ready is high (A3.2.2)
    //assign axi_l.ar_ready = 1'b1;

    // Read
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axi_l.r_data <= 0;
        end else if (!axi_l.r_valid || axi_l.r_ready) begin
            case (axi_l.ar_addr)
                2'b00: axi_l.r_data <= example_reg0;
                2'b01: axi_l.r_data <= example_reg1;
                2'b10: axi_l.r_data <= example_reg2;
                2'b11: axi_l.r_data <= example_reg3;
                default : axi_l.r_data <= example_reg0;
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
            case (axi_l.aw_addr)
                2'b00: example_reg0 <= axi_l.w_data;
                2'b01: example_reg1 <= axi_l.w_data;
                2'b10: example_reg2 <= axi_l.w_data;
                2'b11: example_reg3 <= axi_l.w_data;
                default: example_reg0 <= axi_l.w_data;
            endcase
        end
    end

    // Read signaling

    assign axi_read_ready = axi_l.ar_valid && axi_l.ar_ready;

    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            axi_l.r_valid <= 1'b0; // valid must be cleared following any reset
        end else if (axi_l.ar_valid && axi_l.r_ready)
            axi_l.r_valid <= 1'b1;
        end else if (axi_l.r_ready)
            axi_l.r_valid <= 1'b0;
    end

    assign axi_l.ar_ready = !axi_l.r_valid;

    // Write signaling
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axi_write_ready <= 1'b0;
        end else begin
            axi_write_ready <= !axi_write_ready && (axi_l.w_valid && axi_l.ar_valid)
                && (axi_l.b_ready || !axi_l.b_valid);
        end
    end

    assign axi_l.aw_ready = axi_write_ready;
    assign axi_l.w_ready = axi_write_ready;

    // Write response
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axi_l.b_valid <= 1'b0;
        end else if (axi_write_ready) begin
            axi_l.b_valid <= 1'b1;
        end else if (axi_l.b_ready) begin
            axi_l.b_valid <= 1'b0;
        end
    end

    // Read response
    always_ff @(posedge clk_i) begin
        if(!rstn_i) begin
            axi_l.r_valid <= 1'b0;
        end else if (axi_read_ready) begin
            axi_l.r_valid <= 1'b1;
        end else if (axi_l.r_ready) begin
            axi_l.r_valid <= 1'b0;
        end
    end

    assign axi_l.b_resp = 2'b00;
    assign axi_l.r_resp = 2'b00;

    // Strobe
    /*function void funcname();
        
    endfunction : funcname*/

endmodule