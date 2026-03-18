`timescale 1ns / 1ps

module display_scanner(
    input clk,
    input rst,
    input tick_scan,        
    input blink_time,         
    input [3:0] t0, t1, t2, t3,
    input [3:0] dt0, dt1, dt2, dt3, dt4, dt5,         
    output reg [23:0] shift_data, 
    output reg update_req   
    );

    reg [3:0] scan_idx; // 0 to 9     
    reg [7:0] next_segments;
    reg [7:0] next_u2_sel;
    reg [7:0] next_u3_sel;
    reg [3:0] current_hex;
    reg dp_on;

    // Combinational MUX for active digit mapping
    // User verified strict left-to-right continuous wiring mapping:
    // U3 Q0 = Date D1 (blank, Gün Onlar) -> dt5
    // U3 Q1 = Date D2 (0, Gün Birler) -> dt4 (DP on here)
    // U2 Q4 = Date D3 (4, Ay Onlar) -> dt3
    // U2 Q5 = Date D4 (2, Ay Birler) -> dt2 (DP on here)
    // U2 Q6 = Date D5 (1, Yıl Onlar) -> dt1
    // U2 Q7 = Date D6 (0, Yıl Birler) -> dt0
    // Time wiring follows:
    // U2 Q3 = Time D1 -> t3
    // U2 Q2 = Time D2 -> t2 
    // U2 Q1 = Time D3 -> t1
    // U2 Q0 = Time D4 -> t0 
    
    always @(*) begin
        next_u2_sel = 8'hFF;
        next_u3_sel = 8'hFF;
        current_hex = 0;
        dp_on = 0;
        
        case(scan_idx)
            // Time digits (U2 Q3..0)
            4'd0: begin current_hex = t0; next_u2_sel[0] = 0; end  
            4'd1: begin current_hex = t1; next_u2_sel[1] = 0; end  
            4'd2: begin current_hex = t2; next_u2_sel[2] = 0; end // DP disabled for Time
            4'd3: begin current_hex = t3; next_u2_sel[3] = 0; end 
            
            // Date digits (U2 Q4..7, U3 Q0..1)
            // Matching schematic: U2_Q4=M0, U2_Q5=M1, U2_Q6=D0, U2_Q7=D1, U3_Q0=Y0, U3_Q1=Y1
            4'd4: begin current_hex = dt0; next_u3_sel[0] = 0; end // Y0 (Yıl Birler)
            4'd5: begin current_hex = dt1; next_u3_sel[1] = 0; end // Y1 (Yıl Onlar)
            4'd6: begin current_hex = dt2; next_u2_sel[4] = 0; dp_on = 1'b1; end // M0 (Ay Birler + DP)
            4'd7: begin current_hex = dt3; next_u2_sel[5] = 0; end // M1 (Ay Onlar)
            4'd8: begin current_hex = dt4; next_u2_sel[6] = 0; dp_on = 1'b1; end // D0 (Gün Birler + DP)
            4'd9: begin current_hex = dt5; next_u2_sel[7] = 0; end // D1 (Gün Onlar) 
        endcase
    end

    // ROM
    always @(*) begin
        case(current_hex)
            4'h0: next_segments = 8'b00111111; 4'h1: next_segments = 8'b00000110;
            4'h2: next_segments = 8'b01011011; 4'h3: next_segments = 8'b01001111;
            4'h4: next_segments = 8'b01100110; 4'h5: next_segments = 8'b01101101;
            4'h6: next_segments = 8'b01111101; 4'h7: next_segments = 8'b00000111;
            4'h8: next_segments = 8'b01111111; 4'h9: next_segments = 8'b01101111;
            default: next_segments = 8'b00000000;
        endcase
        if (dp_on) next_segments[7] = 1'b1;
    end

    // Scanner
    reg update_trigger;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_idx <= 0;
            update_req <= 0;
            shift_data <= 0;
            update_trigger <= 0;
        end else begin
            update_req <= 0; 

            if (tick_scan) begin
                if (scan_idx == 9) scan_idx <= 0;
                else scan_idx <= scan_idx + 1;
                
                update_trigger <= 1; // Wait 1 clock cycle for ROM to settle
            end else if (update_trigger) begin
                update_trigger <= 0;
                // Pack the perfectly calculated variables into shift data instantly
                shift_data <= {next_u3_sel, next_u2_sel, next_segments};
                update_req <= 1; // Send exact stabilized data to 595
            end
        end
    end

endmodule
