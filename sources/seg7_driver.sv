module seg7_driver(
                        input logic clk,
                        input logic rst,
                        input logic [4:0] num_cycles,
                        input logic err,
                        output logic [6:0] Cnode,
                        output logic [7:0] AN
                 );

    logic [19:0] tmp;
    logic [4:0] digit;

    wire [2:0] s;
    assign s = tmp[19:17];

    always_comb begin
        case(digit)
            5'd0:  Cnode=7'b0000001; 
            5'd1:  Cnode=7'b1001111;
            5'd2:  Cnode=7'b0010010;
            5'd3:  Cnode=7'b0000110; 
            5'd4:  Cnode=7'b1001100; 
            5'd5:  Cnode=7'b0100100;
            5'd6:  Cnode=7'b0100000; 
            5'd7:  Cnode=7'b0001111; 
            5'd8:  Cnode=7'b0000000;
            5'd9:  Cnode=7'b0001100; 
            5'd10: Cnode=7'b0001000;
            5'd11: Cnode=7'b1100000;
            5'd12: Cnode=7'b0110001;
            5'd13: Cnode=7'b1000010;
            5'd14: Cnode=7'b0110000;
            5'd15: Cnode=7'b0111000;
            5'd16: Cnode = 7'b1111010;
            default: Cnode=7'b1111111;
        endcase
    end

    always_comb begin
        if(err) begin
            case(s)
                3'd0: digit = 5'd16;
                3'd1: digit = 5'd16;
                3'd2: digit = 5'd14;
                default: digit = 5'd17;
            endcase
        end
        else begin
            case(s)
                3'd0: digit = 5'd12;
                3'd1: digit = {1'b0, num_cycles[3:0]};
                3'd2: digit = {4'b0000, num_cycles[4]};
                default: digit = 5'd17;
            endcase
        end
    end

    always_comb begin
        case(s)
            3'd0: AN = 8'b11111110;
            3'd1: AN = 8'b11111101;
            3'd2: AN = 8'b11111011;
            3'd3: AN = 8'b11110111;
            3'd4: AN = 8'b11101111;
            3'd5: AN = 8'b11011111;
            3'd6: AN = 8'b10111111;
            3'd7: AN = 8'b01111111;
            default: AN = 8'b11111111;
        endcase
    end

    always_ff@(posedge clk) begin
        if(rst) tmp <= 0;
        else tmp <= tmp + 1;
    end


endmodule