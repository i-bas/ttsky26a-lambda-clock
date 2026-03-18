`timescale 1ns / 1ps

module alarm_module(
    input clk,
    input rst,
    input [3:0] d0,
    input [3:0] d1,
    input [3:0] d2,
    input [3:0] d3,
    output reg buzzer
    );

    // Alarm Condition: 0010 (d3=0, d2=0, d1=1, d0=0)
    wire alarm_active;
    assign alarm_active = (d1 == 4'd1);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            buzzer <= 0;
        end else begin
            // Active Buzzer just needs logic HIGH to sound
            if (alarm_active)
                buzzer <= 1;
            else
                buzzer <= 0;
        end
    end

endmodule
