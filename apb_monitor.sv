
class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)
  virtual apb_if vif;
  uvm_analysis_port #(apb_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual apb_if)::get(
          this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF",
        "apb_monitor: virtual interface 'vif' was not configured")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    apb_seq_item t;
    forever begin
      @(vif.mon_cb);
      if (vif.presetn !== 1'b1)
        continue;
      if ((vif.mon_cb.psel    === 1'b1) &&
          (vif.mon_cb.penable === 1'b1) &&
          (vif.mon_cb.pready  === 1'b1)) begin

        t = apb_seq_item::type_id::create("mon_item");

        t.addr   = vif.mon_cb.paddr;
        t.write  = vif.mon_cb.pwrite;
        t.slverr = vif.mon_cb.pslverr;

        if (t.write)
          t.data = vif.mon_cb.pwdata;
        else
          t.data = vif.mon_cb.prdata;

        if ($test$plusargs("APB_TRACE")) begin

          `uvm_info("APB_TRACE",
            $sformatf(
              "%0t APB %s addr=0x%04h wdata=0x%08h rdata=0x%08h PSLVERR=%0b",
              $time,
              t.write ? "WRITE" : "READ",
              t.addr,
              t.write ? t.data : 32'h0,
              t.write ? 32'h0 : t.data,
              t.slverr
            ),
            UVM_LOW
          )

        end
        ap.write(t);
      end
    end
  endtask
endclass
