module usbsnoop (
    input wire clk_48mhz,
    input wire clk_12mhz,
    input wire reset,

    inout ts_upstream_usb_dn,
    inout ts_upstream_usb_dp,

    inout ts_downstream_usb_dn,
    inout ts_downstream_usb_dp
);
    // setup our upstream usb receiver
    wire upstream_rx_bit_strobe, upstream_rx_packet_start, upstream_rx_packet_end, upstream_rx_data_pulse;
    wire [3:0] upstream_rx_pid;
    wire [6:0] upstream_rx_addr;
    wire [3:0] upstream_rx_endp;
    wire [10:0] upstream_rx_frame_num;
    wire [7:0] upstream_rx_data;
    wire upstream_rx_dp, upstream_rx_dn;
    usb_fs_rx upstream_rx(.clk_48mhz(clk_48mhz),
                          .clk(clk_12mhz),
                          .reset(reset),
                          .dp(upstream_rx_dp),
                          .dn(upstream_rx_dn),
                          // synced to posedge 48mhz clock input
                          .bit_strobe(upstream_rx_bit_strobe),
                          // synced to posedge 12mhz clock input
                          .pkt_start(upstream_rx_packet_start),
                          .pkt_end(upstream_rx_packet_end),
                          .pid(upstream_rx_pid[3:0]),
                          .addr(upstream_rx_addr[6:0]),
                          .endp(upstream_rx_endp[3:0]),
                          .frame_num(upstream_rx_frame_num[10:0]),
                          .rx_data_put(upstream_rx_data_pulse),
                          .rx_data(upstream_rx_data[7:0]));
    
    // setup our downstream usb receiver
    wire downstream_rx_bit_strobe, downstream_rx_packet_start, downstream_rx_packet_end, downstream_rx_data_pulse;
    wire [3:0] downstream_rx_pid;
    wire [6:0] downstream_rx_addr;
    wire [3:0] downstream_rx_endp;
    wire [10:0] downstream_rx_frame_num;
    wire [7:0] downstream_rx_data;
    wire downstream_rx_dp, downstream_rx_dn;
    usb_fs_rx downstream_rx(.clk_48mhz(clk_48mhz),
                          .clk(clk_12mhz),
                          .reset(reset),
                          .dp(downstream_rx_dp),
                          .dn(downstream_rx_dn),
                          // synced to posedge 48mhz clock input
                          .bit_strobe(downstream_rx_bit_strobe),
                          // synced to posedge 12mhz clock input
                          .pkt_start(downstream_rx_packet_start),
                          .pkt_end(downstream_rx_packet_end),
                          .pid(downstream_rx_pid[3:0]),
                          .addr(downstream_rx_addr[6:0]),
                          .endp(downstream_rx_endp[3:0]),
                          .frame_num(downstream_rx_frame_num[10:0]),
                          .rx_data_put(downstream_rx_data_pulse),
                          .rx_data(downstream_rx_data[7:0]));

    // setup our upstream usb transmitter
    wire upstream_tx_bit_strobe, upstream_tx_packet_start, upstream_tx_data_avail, upstream_tx_packet_end, upstream_tx_data_get;
    wire [3:0] upstream_tx_pid;
    wire [7:0] upstream_tx_data;
    wire upstream_tx_dn, upstream_tx_dp, upstream_tx_oe;
    usb_fs_tx upstream_tx(.clk_48mhz(clk_48mhz),
                          .clk(clk_12mhz),
                          .reset(reset),
                          .bit_strobe(upstream_tx_bit_strobe),
                          .oe(upstream_tx_oe),
                          .dp(upstream_tx_dp),
                          .dn(upstream_tx_dn),
                          .pkt_start(upstream_tx_packet_start),
                          .pkt_end(upstream_tx_packet_end),
                          .pid(upstream_tx_pid[3:0]),
                          .tx_data_avail(upstream_tx_data_avail),
                          .tx_data_get(upstream_tx_data_get),
                          .tx_data(upstream_tx_data[7:0]));
    
    // setup our downstream usb transmitter
    wire downstream_tx_bit_strobe, downstream_tx_packet_start, downstream_tx_data_avail, downstream_tx_packet_end, downstream_tx_data_get;
    wire [3:0] downstream_tx_pid;
    wire [7:0] downstream_tx_data;
    wire downstream_tx_dn, downstream_tx_dp, downstream_tx_oe;
    usb_fs_tx downstream_tx(.clk_48mhz(clk_48mhz),
                          .clk(clk_12mhz),
                          .reset(reset),
                          .bit_strobe(downstream_tx_bit_strobe),
                          .oe(downstream_tx_oe),
                          .dp(downstream_tx_dp),
                          .dn(downstream_tx_dn),
                          .pkt_start(downstream_tx_packet_start),
                          .pkt_end(downstream_tx_packet_end),
                          .pid(downstream_tx_pid[3:0]),
                          .tx_data_avail(downstream_tx_data_avail),
                          .tx_data_get(downstream_tx_data_get),
                          .tx_data(downstream_tx_data[7:0]));

    // setup tristate pins for upstream
    assign upstream_rx_dn = ts_upstream_usb_dn;
    assign upstream_rx_dp = ts_upstream_usb_dp;
    assign ts_upstream_usb_dn = upstream_tx_oe ? upstream_tx_dn : 1'bz;
    assign ts_upstream_usb_dp = upstream_tx_oe ? upstream_tx_dp : 1'bz;
    
    // setup tristate pins for downstream
    assign downstream_rx_dn = ts_downstream_usb_dn;
    assign downstream_rx_dp = ts_downstream_usb_dp;
    assign ts_downstream_usb_dn = downstream_tx_oe ? downstream_tx_dn : 1'bz;
    assign ts_downstream_usb_dp = downstream_tx_oe ? downstream_tx_dp : 1'bz;

    // route upstream rx -> downstream tx
    assign downstream_tx_bit_strobe = upstream_rx_bit_strobe;
    assign downstream_tx_packet_start = upstream_rx_packet_start;
    assign downstream_tx_pid = upstream_rx_pid[3:0]; 
    assign downstream_tx_data_avail = upstream_rx_data_pulse;
    assign downstream_tx_data = upstream_rx_data[7:0];
    
    // route downstream rx -> upstream tx
    assign upstream_tx_bit_strobe = downstream_rx_bit_strobe;
    assign upstream_tx_packet_start = downstream_rx_packet_start;
    assign upstream_tx_pid = downstream_rx_pid[3:0]; 
    assign upstream_tx_data_avail = downstream_rx_data_pulse;
    assign upstream_tx_data = downstream_rx_data[7:0];

    //// state machine for routing the packets
    //// but maybe we dont even need this
    //reg [7:0] state = 0;
    //localparam UPSTREAM_RX   = 0;
    //localparam UPSTREAM_TX   = 1;
    //localparam DOWNSTREAM_RX = 2;
    //localparam DOWNSTREAM_TX = 3;
    //always @(posedge clk_48mhz) begin
    //    if (reset) begin
    //        state <= UPSTREAM_RX;
    //    end else begin
    //        case (state)
    //        endcase
    //    end
    //end

endmodule