ALU
module alu #(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  [3:0]        opcode,
    output reg [WIDTH-1:0] result,
    output reg           zero_flag,
    output reg           carry_flag,
    output reg           overflow_flag
);

    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND_ = 4'b0010;
    localparam OR_  = 4'b0011;
    localparam XOR_ = 4'b0100;
    localparam NOT_ = 4'b0101;
    localparam SHL  = 4'b0110;
    localparam SHR  = 4'b0111;
    localparam EQ   = 4'b1000;
    localparam GT   = 4'b1001;

    reg [WIDTH:0] add_ext;

    always @(*) begin
        carry_flag    = 1'b0;
        overflow_flag = 1'b0;
        add_ext       = {1'b0, {WIDTH{1'b0}}};

        case (opcode)
            ADD: begin
                add_ext = {1'b0, a} + {1'b0, b};
                result     = add_ext[WIDTH-1:0];
                carry_flag = add_ext[WIDTH];
                overflow_flag = (a[WIDTH-1] == b[WIDTH-1]) &&
                                 (result[WIDTH-1] != a[WIDTH-1]);
            end

            SUB: begin
                add_ext = {1'b0, a} - {1'b0, b};
                result     = add_ext[WIDTH-1:0];
                carry_flag = add_ext[WIDTH];
                overflow_flag = (a[WIDTH-1] != b[WIDTH-1]) &&
                                 (result[WIDTH-1] != a[WIDTH-1]);
            end

            AND_: result = a & b;
            OR_ : result = a | b;
            XOR_: result = a ^ b;
            NOT_: result = ~a;
            SHL : result = a << b[2:0];
            SHR : result = a >> b[2:0];
            EQ  : result = (a == b) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
            GT  : result = (a >  b) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};

            default: result = {WIDTH{1'bx}};
        endcase

        zero_flag = (result == {WIDTH{1'b0}});
    end

  >tb_alu.v

`timescale 1ns/1ps

module tb_alu;

    localparam WIDTH = 8;

    reg  [WIDTH-1:0] a, b;
    reg  [3:0]        opcode;
    wire [WIDTH-1:0] result;
    wire              zero_flag, carry_flag, overflow_flag;

    integer pass_count = 0;
    integer fail_count = 0;

    alu #(.WIDTH(WIDTH)) dut (
        .a(a), .b(b), .opcode(opcode),
        .result(result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag)
    );

    task drive(input [WIDTH-1:0] in_a, input [WIDTH-1:0] in_b, input [3:0] op);
        begin
            a = in_a;
            b = in_b;
            opcode = op;
            #5;
        end
    endtask

    task check(input [WIDTH-1:0] expected, input [127:0] op_name);
        begin
            if (result === expected) begin
                pass_count = pass_count + 1;
                $display("PASS | %-4s a=%0d b=%0d opcode=%0d -> result=%0d (expected %0d)",
                           op_name, a, b, opcode, result, expected);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL | %-4s a=%0d b=%0d opcode=%0d -> result=%0d (expected %0d)",
                           op_name, a, b, opcode, result, expected);
            end
        end
    endtask

    initial begin
        $display("========== ALU Self-Checking Testbench ==========");

        drive(8'd15, 8'd10, 4'b0000); check(8'd25, "ADD");
        drive(8'd200, 8'd100, 4'b0000); check((8'd200+8'd100) & 8'hFF, "ADD");

        drive(8'd20, 8'd5, 4'b0001); check(8'd15, "SUB");
        drive(8'd5, 8'd20, 4'b0001); check((8'd5-8'd20) & 8'hFF, "SUB");

        drive(8'b10101010, 8'b01010101, 4'b0010); check(8'b00000000, "AND");
        drive(8'b10101010, 8'b01010101, 4'b0011); check(8'b11111111, "OR");
        drive(8'b10101010, 8'b11110000, 4'b0100); check(8'b01011010, "XOR");
        drive(8'b00001111, 8'b00000000, 4'b0101); check(8'b11110000, "NOT");

        drive(8'b00000001, 8'd3, 4'b0110); check(8'b00001000, "SHL");
        drive(8'b10000000, 8'd3, 4'b0111); check(8'b00010000, "SHR");

        drive(8'd42, 8'd42, 4'b1000); check(8'd1, "EQ");
        drive(8'd42, 8'd41, 4'b1000); check(8'd0, "EQ");
        drive(8'd50, 8'd10, 4'b1001); check(8'd1, "GT");
        drive(8'd10, 8'd50, 4'b1001); check(8'd0, "GT");

        drive(8'd5, 8'd5, 4'b0001);
        if (zero_flag !== 1'b1) begin
            fail_count = fail_count + 1;
            $display("FAIL | zero_flag not set when result is 0");
        end else begin
            pass_count = pass_count + 1;
            $display("PASS | zero_flag correctly set when result is 0");
        end

        $display("===================================================");
        $display("TEST SUMMARY: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED - see log above");
        $display("===================================================");

        $finish;
    end

endmodule
