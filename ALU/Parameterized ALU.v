module alu #(
    parameter DATA_WIDTH = 32
)(
    input  wire [DATA_WIDTH-1:0] a,
    input  wire [DATA_WIDTH-1:0] b,
    input  wire [2:0]            opera,
    input  wire                  cin,
    output reg  [DATA_WIDTH-1:0] y,
    output wire                  carry_flag,
    output wire                  zero_flag,
    output wire                  negative_flag,
    output wire                  overflow_flag
);
    localparam SHIFT_WIDTH = $clog2(DATA_WIDTH);
    wire                  sub_op;
    wire                  slt_op;
    wire                  sub_or_slt;
    wire [DATA_WIDTH-1:0] b_operand;
    wire                  cin_effective;
    wire [DATA_WIDTH:0]   sum_result;
    wire                  slt_result;
    assign sub_op        = (opera == 3'b001);
    assign slt_op        = (opera == 3'b111);
    assign sub_or_slt    = sub_op | slt_op;
    assign b_operand     = sub_or_slt ? ~b : b;
    assign cin_effective = sub_or_slt ? 1'b1 : cin;
    
    assign sum_result    = a + b_operand + cin_effective;
    assign zero_flag     = (y == {DATA_WIDTH{1'b0}});
    assign negative_flag = y[DATA_WIDTH-1];
    assign carry_flag    = (opera == 3'b000 || sub_op) ? sum_result[DATA_WIDTH] : 1'b0;
    assign overflow_flag = (opera == 3'b000 || sub_or_slt) ?
                           ((a[DATA_WIDTH-1] == b_operand[DATA_WIDTH-1]) &&
                            (sum_result[DATA_WIDTH-1] != a[DATA_WIDTH-1])) : 1'b0;
    assign slt_result    = sum_result[DATA_WIDTH-1] ^ overflow_flag;
    always @(*) begin
        case (opera)
            3'b000:  y = sum_result[DATA_WIDTH-1:0];
            3'b001:  y = sum_result[DATA_WIDTH-1:0];
            3'b010:  y = a & b;
            3'b011:  y = a | b;
            3'b100:  y = a ^ b;
            3'b101:  y = ~(a | b);
            3'b110:  y = a << b[SHIFT_WIDTH-1:0];
            3'b111:  y = {{DATA_WIDTH-1{1'b0}}, slt_result};
            default: y = {DATA_WIDTH{1'b0}};
        endcase
    end