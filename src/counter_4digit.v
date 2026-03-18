`timescale 1ns / 1ps

module counter_4digit(
    input clk,
    input rst,
    input inc,      // Increment signal
    input dec,      // Decrement signal
    output reg [3:0] dig0, // Ones
    output reg [3:0] dig1, // Tens
    output reg [3:0] dig2, // Hundreds
    output reg [3:0] dig3  // Thousands
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dig0 <= 0;
            dig1 <= 0;
            dig2 <= 0;
            dig3 <= 0;
        end else if (inc) begin
            if (dig0 == 9) begin
                dig0 <= 0;
                if (dig1 == 9) begin
                    dig1 <= 0;
                    if (dig2 == 9) begin
                        dig2 <= 0;
                        if (dig3 == 9) begin
                            dig3 <= 0;
                        end else begin
                            dig3 <= dig3 + 1;
                        end
                    end else begin
                        dig2 <= dig2 + 1;
                    end
                end else begin
                    dig1 <= dig1 + 1;
                end
            end else begin
                dig0 <= dig0 + 1;
            end
        end else if (dec) begin
            if (dig0 == 0) begin
                dig0 <= 9;
                if (dig1 == 0) begin
                    dig1 <= 9;
                    if (dig2 == 0) begin
                        dig2 <= 9;
                        if (dig3 == 0) begin
                            dig3 <= 9;
                        end else begin
                            dig3 <= dig3 - 1;
                        end
                    end else begin
                        dig2 <= dig2 - 1;
                    end
                end else begin
                    dig1 <= dig1 - 1;
                end
            end else begin
                dig0 <= dig0 - 1;
            end
        end
    end
endmodule
