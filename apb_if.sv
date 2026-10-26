`timescale 1ns/1ps
interface apb_if (input logic pclk);
  logic        presetn;           
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic [15:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic        pready;
  logic        pslverr;
  logic        irq;

  initial begin
    presetn = 1'b0;
    psel = 1'b0; penable = 1'b0; pwrite = 1'b0; paddr = '0; pwdata = '0;
  end

  clocking drv_cb @(posedge pclk);
    default input #1step output #1ns;
    output psel, penable, pwrite, paddr, pwdata;
    input  prdata, pready, pslverr, irq;
  endclocking

  clocking mon_cb @(posedge pclk);
    default input #1step;
    input psel, penable, pwrite, paddr, pwdata, prdata, pready, pslverr, irq;
  endclocking

  task automatic apply_reset(int unsigned cycles = 5);
    presetn = 1'b0;
    repeat (cycles) @(posedge pclk);
    #1ns presetn = 1'b1;
  endtask

endinterface

