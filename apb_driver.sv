class apb_driver extends uvm_driver #(apb_seq_item);
  `uvm_component_utils(apb_driver)
  virtual apb_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "apb_driver: virtual interface 'vif' not set")
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  task drive(apb_seq_item t);
    while (vif.presetn !== 1'b1) @(vif.drv_cb);     // should not drive during reset
    @(vif.drv_cb);
    // SETUP phase
    vif.drv_cb.psel    <= 1'b1;
    vif.drv_cb.penable <= 1'b0;
    vif.drv_cb.pwrite  <= t.write;
    vif.drv_cb.paddr   <= t.addr;
    vif.drv_cb.pwdata  <= t.write ? t.data : 32'h0;
    @(vif.drv_cb);
    // ACCESS phase
    vif.drv_cb.penable <= 1'b1;
    @(vif.drv_cb);
    while (vif.drv_cb.pready !== 1'b1) @(vif.drv_cb);   // PREADY is always 1 in this design (no wait states)
    t.slverr = vif.drv_cb.pslverr;
    if (!t.write) t.data = vif.drv_cb.prdata;
    //IDLE state
    vif.drv_cb.psel    <= 1'b0;
    vif.drv_cb.penable <= 1'b0;
  endtask
endclass

