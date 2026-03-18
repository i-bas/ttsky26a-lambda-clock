`default_nettype none

module tt_um_<github_kullanici_adin>_clock_alarm (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // Bidirectional inputs
    output wire [7:0] uio_out,  // Bidirectional outputs
    output wire [7:0] uio_oe,   // Bidirectional output enable
    input  wire       ena,      // Design enable
    input  wire       clk,      // System clock
    input  wire       rst_n     // Active-low reset
);

    wire sclk;
    wire rclk;
    wire dio;
    wire buzzer;


    top_module u_top (
        .clk(clk),
        .btn_rst(~rst_n),
        .btn_pause(ui_in[0]),
        .btn_dec(ui_in[1]),
        .btn_inc(ui_in[2]),
        .sclk(sclk),
        .rclk(rclk),
        .dio(dio),
        .buzzer(buzzer)
    );

    // Dedicated outputs
    assign uo_out[0] = sclk;
    assign uo_out[1] = rclk;
    assign uo_out[2] = dio;
    assign uo_out[3] = buzzer;
    assign uo_out[7:4] = 4'b0000;

    // Bidirectional pinleri kullanmıyoruz
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Kullanılmayan sinyaller optimize / warning açısından açık dursun
    wire _unused = &{ena, uio_in};

endmodule

`default_nettype wire
