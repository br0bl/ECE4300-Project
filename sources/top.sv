`timescale 1ns / 1ps

module top(
    input logic clk,
    input logic btnc,
    input logic btnd,
    input logic [2:0] sw,
    output logic [2:0] led,
    output logic [6:0] seg,
    output logic [7:0] an
);

    logic rst;
    assign rst = btnd;

    logic valid;

    logic [4:0] num_cycles;
    logic err;

    logic start;
    logic start_1, start_2, start_4;
    logic controller_start;

    logic signed [7:0] a [0:15];
    logic signed [7:0] b [0:15];
    logic signed [19:0] expected;

    logic done_1, done_2, done_4;
    logic done;

    logic signed [19:0] result_1;
    logic signed [19:0] result_2;
    logic signed [19:0] result_4;

    logic [1:0] state;

    localparam [1:0]
        IDLE = 2'd0,
        LOAD = 2'd1,
        RUNNING = 2'd2,
        DONE = 2'd3;

    logic [2:0] locked_mac;

    assign valid = (sw == 3'd1) || (sw == 3'd2) || (sw == 3'd4);
    assign led = sw & {3{valid}};
    assign controller_start = start_1 || start_2 || start_4;
    assign done = done_1 || done_2 || done_4;

    assign a = '{8'sd0,  8'sd1,  8'sd2,  8'sd3,
                8'sd4,  8'sd5,  8'sd6,  8'sd7,
                8'sd8,  8'sd9,  8'sd10, 8'sd11,
                8'sd12, 8'sd13, 8'sd14, 8'sd15};

    assign b = '{8'sd16, 8'sd15, 8'sd14, 8'sd13,
                8'sd12, 8'sd11, 8'sd10, 8'sd9,
                8'sd8,  8'sd7,  8'sd6,  8'sd5,
                8'sd4,  8'sd3,  8'sd2,  8'sd1};

    assign expected = 20'sd680;

    debounce dut_btnc(
                        .clk(clk),
                        .rst(rst),
                        .btn_raw(btnc),
                        .btn_pulse(start)
                     );

    seg7_driver seg7_dut(
                            .clk(clk),
                            .rst(rst),
                            .num_cycles(num_cycles),
                            .err(err),
                            .Cnode(seg),
                            .AN(an)
                        );

    controller #(.NUM_MACS(1)) one_mac(
                                        .clk(clk),
                                        .rst(rst),
                                        .start(start_1),
                                        .a(a),
                                        .b(b),
                                        .done(done_1),
                                        .result(result_1)
                                    );

    controller #(.NUM_MACS(2)) two_macs(
                                        .clk(clk),
                                        .rst(rst),
                                        .start(start_2),
                                        .a(a),
                                        .b(b),
                                        .done(done_2),
                                        .result(result_2)
                                        );

    controller #(.NUM_MACS(4)) four_macs(
                                        .clk(clk),
                                        .rst(rst),
                                        .start(start_4),
                                        .a(a),
                                        .b(b),
                                        .done(done_4),
                                        .result(result_4)
                                        );

    always_ff@(posedge clk) begin
        if(rst) begin
            state      <= IDLE;
            start_1    <= 1'b0;
            start_2    <= 1'b0;
            start_4    <= 1'b0;
            locked_mac <= 3'd0;
            num_cycles <= 5'd0;
            err        <= 1'b0;
        end
        else begin

            start_1 <= 1'b0;
            start_2 <= 1'b0;
            start_4 <= 1'b0;

            case(state)
                IDLE: begin
                    if(start) begin
                        if(valid) begin
                            err <= 1'b0;
                            num_cycles <= 5'd0;
                            locked_mac <= sw[2:0];
                            state <= LOAD;    
                        end
                        else begin
                            err <= 1'b1;
                        end
                    end
                end
                LOAD: begin
                    case(locked_mac)
                        3'd1: begin 
                            start_1 <= 1; 
                            state <= RUNNING; 
                        end
                        3'd2: begin 
                            start_2 <= 1; 
                            state <= RUNNING; 
                        end
                        3'd4: begin 
                            start_4 <= 1; 
                            state <= RUNNING; 
                        end
                        default: begin
                            err <= 1; 
                            state <= IDLE;
                        end
                    endcase
                end
                RUNNING: begin
                    if(done) state <= DONE;
                    else if (!controller_start) num_cycles <= num_cycles + 4'd1;
                end
                DONE: begin
                    case(locked_mac)
                        3'd1: if(result_1 != expected) err <= 1;
                        3'd2: if(result_2 != expected) err <= 1;    
                        3'd4: if(result_4 != expected) err <= 1;
                        default:err <= 1;
                    endcase
                    
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule