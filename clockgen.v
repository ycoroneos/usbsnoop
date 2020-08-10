// this design has been modified from the original one inside
// the TinyFPGA bootloader, git hash 97f6353540bf7c0d27f5612f202b48f41da75299
module clockgen (
    input wire clk_16mhz,
    output wire clk_48mhz,
    output wire clk_24mhz,
    output wire clk_12mhz,
    output wire locked
);
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    ////////
    //////// generate 48 mhz clock
    ////////
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////

    SB_PLL40_CORE #(
      .DIVR(4'b0000),
      .DIVF(7'b0101111),
      .DIVQ(3'b100),
      .FILTER_RANGE(3'b001),
      .FEEDBACK_PATH("SIMPLE"),
      .DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
      .FDA_FEEDBACK(4'b0000),
      .DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
      .FDA_RELATIVE(4'b0000),
      .SHIFTREG_DIV_MODE(2'b00),
      .PLLOUT_SELECT("GENCLK"),
      .ENABLE_ICEGATE(1'b0)
    ) usb_pll_inst (
      .REFERENCECLK(clk_16mhz),
      .PLLOUTCORE(clk_48mhz),
      .PLLOUTGLOBAL(),
      .EXTFEEDBACK(),
      .DYNAMICDELAY(),
      .RESETB(1'b1),
      .BYPASS(1'b0),
      .LATCHINPUTVALUE(),
      .LOCK(locked),
      .SDI(),
      .SDO(),
      .SCLK()
    );

	reg rclk_24mhz;
	reg rclk_12mhz;
	always @(posedge clk_48mhz) rclk_24mhz = !rclk_24mhz;
	always @(posedge clk_24mhz) rclk_12mhz = !rclk_12mhz;

	assign clk_24mhz = rclk_24mhz; // half speed clock
	assign clk_12mhz = rclk_12mhz; // quarter speed clock

endmodule