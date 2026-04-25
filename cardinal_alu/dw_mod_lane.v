`include "DW_div.v"

module dw_mod_lane #(
    parameter W = 8
)(
    input  wire [W-1:0] a,
    input  wire [W-1:0] b,
    output wire [W-1:0] r,
    output wire         div_by_0
);
    wire [W-1:0] quotient;
    wire [W-1:0] remainder;

    reg  [W-1:0] b_safe_r;
    reg          div_by_0_r;

    assign div_by_0 = div_by_0_r;

    always @(*) begin
        if (b == {W{1'b0}}) begin
            div_by_0_r = 1'b1;
            b_safe_r   = {{(W-1){1'b0}}, 1'b1};
        end else begin
            div_by_0_r = 1'b0;
            b_safe_r   = b;
        end
    end

    DW_div #(W, W, 0, 1) U1 (
        .a           (a),
        .b           (b_safe_r),
        .quotient    (quotient),
        .remainder   (remainder),
        .divide_by_0 ()
    );

    assign r = div_by_0 ? {W{1'b0}} : remainder;

endmodule