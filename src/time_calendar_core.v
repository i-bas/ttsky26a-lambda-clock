`timescale 1ns / 1ps

module time_calendar_core(
    input clk,
    input rst,
    input tick_1hz,
    input inc_pulse,     // From button
    input [1:0] mode,    // 00: Time, 01: Date, 10: Year, 11: Alarm
    
    output reg [3:0] t0, t1, t2, t3,             // Time/Alarm Digits
    output reg [3:0] dt0, dt1, dt2, dt3, dt4, dt5, // Date Digits (DD.MM.YY)
    
    output wire blink_time, // Whether time DP should blink
    output wire alarm_match
    );

    // Time Regs (BCD)
    reg [3:0] m0, m1, h0, h1;
    reg [3:0] sec0, sec1; 
    
    // Date Regs (BCD)
    reg [3:0] D0, D1, M0, M1; 
    reg [3:0] Y0, Y1;         
    
    // Alarm Regs (BCD)
    reg [3:0] am0, am1, ah0, ah1;
    
    reg dp_blink;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {h1, h0, m1, m0} <= {4'h1, 4'h2, 4'h0, 4'h0};
            {sec1, sec0} <= 0;
            {D1, D0, M1, M0} <= {4'h0, 4'h1, 4'h0, 4'h1};
            {Y1, Y0} <= {4'h2, 4'h4};
            {ah1, ah0, am1, am0} <= {4'h0, 4'h0, 4'h0, 4'h0};
            dp_blink <= 0;
        end else begin
            if (tick_1hz) dp_blink <= ~dp_blink;

            // --- 1. Real Time Clock Update ---
            if (tick_1hz) begin
                if (sec0 == 9) begin
                    sec0 <= 0;
                    if (sec1 == 5) begin
                        sec1 <= 0;
                        if (m0 == 9) begin
                            m0 <= 0;
                            if (m1 == 5) begin
                                m1 <= 0;
                                if (h1 == 2 && h0 == 3) begin
                                    {h1, h0} <= {4'h0, 4'h0};
                                    if (D1 == 3 && D0 == 0) begin
                                        {D1, D0} <= {4'h0, 4'h1};
                                        if (M1 == 1 && M0 == 2) begin
                                            {M1, M0} <= {4'h0, 4'h1};
                                            if (Y0 == 9) begin
                                                Y0 <= 0;
                                                if (Y1 == 9) Y1 <= 0;
                                                else Y1 <= Y1 + 1;
                                            end else Y0 <= Y0 + 1;
                                        end else if (M0 == 9) begin
                                            M0 <= 0;
                                            M1 <= M1 + 1;
                                        end else M0 <= M0 + 1;
                                    end else if (D0 == 9) begin
                                        D0 <= 0;
                                        D1 <= D1 + 1;
                                    end else D0 <= D0 + 1;
                                end else if (h0 == 9) begin
                                    h0 <= 0;
                                    h1 <= h1 + 1;
                                end else h0 <= h0 + 1;
                            end else m1 <= m1 + 1;
                        end else m0 <= m0 + 1;
                    end else sec1 <= sec1 + 1;
                end else sec0 <= sec0 + 1;
            end
            
            // --- 2. Manual Increment ---
            if (inc_pulse) begin
                case (mode)
                    2'b00: begin // Increment Minutes
                        {sec1, sec0} <= 0; 
                        if (m0 == 9) begin
                            m0 <= 0;
                            if (m1 == 5) begin
                                m1 <= 0;
                                if (h1 == 2 && h0 == 3) {h1, h0} <= {4'h0, 4'h0};
                                else if (h0 == 9) {h1, h0} <= {h1 + 4'd1, 4'h0};
                                else h0 <= h0 + 1;
                            end else m1 <= m1 + 1;
                        end else m0 <= m0 + 1;
                    end
                    2'b01: begin // Increment Day
                        if (D1 == 3 && D0 == 0) {D1, D0} <= {4'h0, 4'h1};
                        else if (D0 == 9) {D1, D0} <= {D1 + 4'd1, 4'h0};
                        else D0 <= D0 + 1;
                    end
                    2'b10: begin // Increment Year
                        if (Y0 == 9) begin
                            Y0 <= 0;
                            if (Y1 == 9) Y1 <= 0;
                            else Y1 <= Y1 + 1;
                        end else Y0 <= Y0 + 1;
                    end
                    2'b11: begin // Increment Alarm (Minutes)
                        if (am0 == 9) begin
                            am0 <= 0;
                            if (am1 == 5) begin
                                am1 <= 0;
                                if (ah1 == 2 && ah0 == 3) {ah1, ah0} <= {4'h0, 4'h0};
                                else if (ah0 == 9) {ah1, ah0} <= {ah1 + 4'd1, 4'h0};
                                else ah0 <= ah0 + 1;
                            end else am1 <= am1 + 1;
                        end else am0 <= am0 + 1;
                    end
                endcase
            end
        end
    end

    // Concurrent Outputs for 10-Digits
    always @(*) begin
        // Time section: Show real time UNLESS in Alarm mode
        if (mode == 2'b11) {t3, t2, t1, t0} = {ah1, ah0, am1, am0};
        else               {t3, t2, t1, t0} = {h1, h0, m1, m0};
        
        // Date section: Always show DD.MM.YY
        {dt5, dt4, dt3, dt2, dt1, dt0} = {D1, D0, M1, M0, Y1, Y0};
    end
    
    // Time colon blinking (on when active time displayed)
    assign blink_time = (mode == 2'b00) ? dp_blink : 1'b1;
    
    // Alarm Match logic
    assign alarm_match = ({h1, h0, m1, m0} == {ah1, ah0, am1, am0}) & ({sec1,sec0} == 0);

endmodule
