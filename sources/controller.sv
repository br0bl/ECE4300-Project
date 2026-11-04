`timescale 1ns / 1ps


module controller #(parameter NUM_MACS = 1) (       // Must be a factor of 16
    input logic clk,
    input logic rst,
    input logic start,
    input logic signed [7:0] a [0:15],
    input logic signed [7:0] b [0:15],
    output logic done,
    output logic signed [19:0] result
);

    localparam NUM_CYCLES = 16 / NUM_MACS;

    logic signed [19:0] partial_sum [0:NUM_MACS-1];
    logic signed [19:0] combined_sum;

    logic [3:0] cycle;
    logic mac_en;
    logic mac_rst;

    typedef enum logic [1:0] {
        IDLE, RUNNING, DONE
    }fsm;
    
    fsm state;

    generate
        for (genvar i = 0; i < NUM_MACS; i++) begin : gen_macs
            mac u_mac (
                .clk    (clk),
                .rst    (rst || mac_rst),
                .en     (mac_en),
                .a      (a[cycle * NUM_MACS + i]),
                .b      (b[cycle * NUM_MACS + i]),
                .result (partial_sum[i])
            );
        end
    endgenerate

    always_ff @(posedge clk) begin
        if(rst) begin 
            done <= 0;
            result <= 0;
            cycle <= 0;
            mac_en <= 0;
            mac_rst <= 0;
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    done <= 0;
                    mac_rst <= 0;
                    
                    if(start) begin
                        mac_en <= 1;
                        cycle <= 0;
                        state <= RUNNING;
                    end
                end
                RUNNING: begin
                    if(cycle == NUM_CYCLES-1) begin
                        state <= DONE;
                        mac_en <= 0;
                    end
                    else
                        cycle <= cycle + 1;
                end
                DONE: begin
                    result <= combined_sum;
                    done <= 1;
                    mac_rst <= 1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    always_comb begin
        combined_sum = 20'sd0;
        
        for (int i = 0; i < NUM_MACS; i++) begin
            combined_sum = combined_sum + partial_sum[i];
        end
    end

endmodule