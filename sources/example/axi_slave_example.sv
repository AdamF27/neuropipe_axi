// An example AXI slave module

module axi_slave_example #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
) (
    AXI_BUS.Slave axi,
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
    wire axi_read_ready;
    logic axi_write_ready;

    // Internal memory -- can be replaced with ram
    logic [DATA_WIDTH-1:0] example_reg0, example_reg1, example_reg2, example_reg3;

    // Default state for ar_ready is high (A3.2.2)
    //assign axi.ar_ready = 1'b1;

    always_ff @(posedge clk_i or posedge rstn_i) begin
        if(~rstn_i) begin
            axi.r_data <= 0;
        end else if (!axi.r_valid || axi.r_ready) begin
            case (axi.ar_addr)
                2'b00: axi.r_data <= example_reg0;
                2'b01: axi.r_data <= example_reg1;
                2'b10: axi.r_data <= example_reg2;
                2'b11: axi.r_data <= example_reg3;
                default : axi.r_data <= example_reg0;
            endcase
        end
    end

    always_ff @(posedge clk_i or posedge rstn_i) begin
        if(~rstn_i) begin
            example_reg0 <= 0;
            example_reg1 <= 0;
            example_reg2 <= 0;
            example_reg3 <= 0;
        end else if (axi_write_ready) begin
            case (axi.aw_addr)
                2'b00: example_reg0 <= axi.w_data;
                2'b01: example_reg1 <= axi.w_data;
                2'b10: example_reg2 <= axi.w_data;
                2'b11: example_reg3 <= axi.w_data;
                default: example_reg0 <= axi.w_data;
            endcase
        end
    end

    // Read signaling
    always_comb begin
        axi.ar_ready = !axi.r_valid;
    end

    assign axi_read_ready = axi.ar_valid && axi.ar_ready;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            axi.r_valid <= 1'b0; // valid must be cleared following any reset
        end else if (axi.ar_valid && axi.r_ready)
            axi.r_valid <= 1'b1;
        end else if (axi.r_ready)
            axi.r_valid <= 1'b0;
    end

    // Write signaling
    always_ff @(posedge clk_i or posedge rstn_i) begin
        if(~rstn_i) begin
            axi_write_ready <= 1'b0;
        end else begin
            axi_write_ready <= !axi_write_ready && (axi.w_valid && axi.ar_valid)
                && (axi.b_ready || !axi.b_valid);
        end
    end

    assign axi.aw_ready = axi_write_ready;
    assign axi.w_ready = axi_write_ready;

    // Write response
    always_ff @(posedge clk_i or posedge rstn_i) begin
        if(~rstn_i) begin
            axi.b_valid <= 1'b0;
        end else if (axi_write_ready) begin
            axi.b_valid <= 1'b1;
        end else if (axi.b_ready) begin
            axi.b_valid <= 1'b0;
        end
    end

    // Read response
    always_ff @(posedge clk_i or posedge rstn_i) begin
        if(~rstn_i) begin
            axi.r_valid <= 1'b0;
        end else if (axi_read_ready) begin
            axi.r_valid <= 1'b1;
        end else if (axi.r_ready) begin
            axi.r_valid <= 1'b0;
        end
    end

    assign axi.b_resp = 2'b00;
    assign axi.r_resp = 2'b00;

    // Strobe

endmodule