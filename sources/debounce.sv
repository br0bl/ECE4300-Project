`timescale 1ns / 1ps

module debounce(
                    input logic clk,
                    input logic rst,
                    input logic btn_raw,
                    output logic btn_pulse
               );
    
    logic btn_clean;
    logic btn_prev;
    logic [2:0] state;
        
    assign btn_pulse = btn_clean && !btn_prev;
    
    always @(posedge clk) begin
        if(rst) begin
            state <= 3'b000;
            btn_clean <= 1'b0;
            btn_prev <= 1'b0;
        end
        else begin
            state <= {state[1:0], btn_raw};            
            if(state == 3'b000) btn_clean <= 1'b0;
            else if (state == 3'b111) btn_clean <= 1;
            btn_prev <= btn_clean;
        end
    end
    
endmodule