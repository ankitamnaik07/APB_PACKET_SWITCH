`timescale 1ns/1ps
// Top level. Module name 'tb' and instance name 'dut' match the spec's HDL root (tb.dut).
module tb;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import pkt_tb_pkg::*;

  logic pclk;
  initial pclk = 1'b0;
  always #5 pclk = ~pclk;                 // 100 MHz

  apb_if apb (.pclk(pclk));

  // ---- DUT ------------------------------------------------------------------
  // Only the APB/irq pins named in spec section 3.2 are connected. If the RTL has more ports
  // (e.g. unused ingress ports), tie them off here.
  apb_pkt_switch dut (
    .pclk    (pclk),
    .presetn (apb.presetn),
    .psel    (apb.psel),
    .penable (apb.penable),
    .pwrite  (apb.pwrite),
    .paddr   (apb.paddr),
    .pwdata  (apb.pwdata),
    .prdata  (apb.prdata),
    .pready  (apb.pready),
    .pslverr (apb.pslverr),
    .irq     (apb.irq)
  );

  initial apb.apply_reset(5);

  initial begin
    uvm_config_db#(virtual apb_if)::set(null, "*", "vif", apb);
    run_test();
  end
endmodule

