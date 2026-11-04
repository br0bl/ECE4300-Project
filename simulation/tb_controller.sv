
`timescale 1ns / 1ps

module tb_controller;

    // Clock and control signals
    logic clk = 0;
    logic rst = 0;
    logic start = 0;

    // 16 signed 8-bit inputs
    logic signed [7:0] a [0:15];
    logic signed [7:0] b [0:15];

    // Outputs for each architecture
    logic done1, done2, done4;
    logic signed [19:0] result1, result2, result4;

    // Generate 100 MHz simulation clock (10 ns period)
    always #5 clk = ~clk;

    // -----------------------------------------
    // Instantiate 1 MAC architecture
    // -----------------------------------------
    controller #(.NUM_MACS(1)) dut1 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .b(b),
        .done(done1),
        .result(result1)
    );

    // -----------------------------------------
    // Instantiate 2 MAC architecture
    // -----------------------------------------
    controller #(.NUM_MACS(2)) dut2 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .b(b),
        .done(done2),
        .result(result2)
    );

    // -----------------------------------------
    // Instantiate 4 MAC architecture
    // -----------------------------------------
    controller #(.NUM_MACS(4)) dut4 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .b(b),
        .done(done4),
        .result(result4)
    );

    // -----------------------------------------
    // Task: Run one test vector on all designs
    // -----------------------------------------
    task automatic run_test(
        input string test_name,
        input integer expected
    );
        integer cycles;
        integer c1, c2, c4;
        bit seen1, seen2, seen4;

        begin
            // Reset designs before each test
            @(negedge clk);
            start = 0;
            rst = 1;

            repeat (2) @(negedge clk);
            rst = 0;
            start = 1;

            // Start accepted at next rising edge
            @(negedge clk);
            start = 0;

            cycles = 0;
            c1 = 0;
            c2 = 0;
            c4 = 0;
            seen1 = 0;
            seen2 = 0;
            seen4 = 0;

            // Wait for all architectures to finish
            while (!(seen1 && seen2 && seen4) && cycles < 25) begin
                @(posedge clk);
                #1; // Wait for nonblocking assignments
                cycles++;

                if (done1 && !seen1) begin
                    seen1 = 1;
                    c1 = cycles;

                    if (result1 !== expected)
                        $fatal(1,
                            "1 MAC FAILED: expected %0d, got %0d",
                            expected, result1);
                end

                if (done2 && !seen2) begin
                    seen2 = 1;
                    c2 = cycles;

                    if (result2 !== expected)
                        $fatal(1,
                            "2 MAC FAILED: expected %0d, got %0d",
                            expected, result2);
                end

                if (done4 && !seen4) begin
                    seen4 = 1;
                    c4 = cycles;

                    if (result4 !== expected)
                        $fatal(1,
                            "4 MAC FAILED: expected %0d, got %0d",
                            expected, result4);
                end
            end

            if (!(seen1 && seen2 && seen4))
                $fatal(1,
                    "TIMEOUT: one or more architectures did not finish");

            $display("-----------------------------------------");
            $display("TEST: %s | Expected: %0d",
                     test_name, expected);
            $display("1 MAC  : PASS | Cycles: %0d", c1);
            $display("2 MACs : PASS | Cycles: %0d", c2);
            $display("4 MACs : PASS | Cycles: %0d", c4);
        end
    endtask

    // -----------------------------------------
    // Main tests
    // -----------------------------------------
    initial begin

        // Test 1: All ones
        for (int i = 0; i < 16; i++) begin
            a[i] = 1;
            b[i] = 1;
        end
        run_test("All Ones", 16);

        // Test 2: All zeros
        for (int i = 0; i < 16; i++) begin
            a[i] = 0;
            b[i] = 0;
        end
        run_test("All Zeros", 0);

        // Test 3: Maximum positive values
        for (int i = 0; i < 16; i++) begin
            a[i] = 127;
            b[i] = 127;
        end
        run_test("All Maximum", 258064);

        // Test 4: Negative inputs
        for (int i = 0; i < 16; i++) begin
            a[i] = -128;
            b[i] = 127;
        end
        run_test("Negative Inputs", -260096);

        $display("=========================================");
        $display("ALL HARDWARE SIMULATION TESTS PASSED");
        $display("=========================================");

        $finish;
    end

endmodule
