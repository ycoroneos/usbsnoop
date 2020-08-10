// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPUA,  // USB pull-up resistor
    inout USBPA,
    inout USBNA,
    
    output USBPUB,  // USB pull-up resistor
    inout USBPB,
    inout USBNB,
    
    output USBPUC,  // USB pull-up resistor
    inout USBPC,
    inout USBNC,
    
    output USBPUD,  // USB pull-up resistor
    inout USBPD,
    inout USBND,

    inout DUSBPA,
    inout DUSBNA,

    inout DUSBPB,
    inout DUSBNB,

    inout DUSBPC,
    inout DUSBNC,

    inout DUSBPD,
    inout DUSBND
);

    // generate USB 48mhz clock and various system clocks from the 16mhz input.
    // Blocks will be held in reset until the 48mhz clock is stable
    wire clk_48mhz, clk_24mhz, clk_12mhz, reset, pll_locked;
    clockgen cg0(.clk_16mhz(CLK),
                 .clk_48mhz(clk_48mhz),
                 .clk_24mhz(clk_24mhz),
                 .clk_12mhz(clk_12mhz),
                 .locked(pll_locked));
    assign reset = !pll_locked;

    assign LED=1'b1;

    // drive USB pull-up resistor to '1' to enable usb when the PLL is locked
    assign USBPUA = !reset;
    assign USBPUB = !reset;
    assign USBPUC = !reset;
    assign USBPUD = !reset;

    // instantiate 4 USB snoopers since my KVM has 4 upstream ports

    usbsnoop dogg(.clk_48mhz(clk_48mhz),
                  .clk_12mhz(clk_12mhz),
                  .reset(reset),
                  .ts_upstream_usb_dn(USBNA),
                  .ts_upstream_usb_dp(USBPA),
                  .ts_downstream_usb_dn(DUSBNA),
                  .ts_downstream_usb_dp(DUSBPA));
    
    usbsnoop lion(.clk_48mhz(clk_48mhz),
                  .clk_12mhz(clk_12mhz),
                  .reset(reset),
                  .ts_upstream_usb_dn(USBNB),
                  .ts_upstream_usb_dp(USBPB),
                  .ts_downstream_usb_dn(DUSBNB),
                  .ts_downstream_usb_dp(DUSBPB));
    
    usbsnoop zilla(.clk_48mhz(clk_48mhz),
                  .clk_12mhz(clk_12mhz),
                  .reset(reset),
                  .ts_upstream_usb_dn(USBNC),
                  .ts_upstream_usb_dp(USBPC),
                  .ts_downstream_usb_dn(DUSBNC),
                  .ts_downstream_usb_dp(DUSBPC));
    
    usbsnoop rock(.clk_48mhz(clk_48mhz),
                  .clk_12mhz(clk_12mhz),
                  .reset(reset),
                  .ts_upstream_usb_dn(USBND),
                  .ts_upstream_usb_dp(USBPD),
                  .ts_downstream_usb_dn(DUSBND),
                  .ts_downstream_usb_dp(DUSBPD));

endmodule
