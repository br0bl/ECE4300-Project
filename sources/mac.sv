`timescale 1ns / 1ps


module mac (
    input  logic clk,
    input  logic rst,
    input  logic en,

    input  logic signed [7:0] a,
    input  logic signed [7:0] b,

    output logic signed [19:0] result
);

    // Stores the accumulated result
    logic signed [15:0] product;

    assign product = a * b;

    always_ff @(posedge clk) begin
        if (rst)
            result <= 20'sd0;
        else if (en)
            result <= result + {{4{product[15]}}, product};
    end

endmodule