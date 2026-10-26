class apb_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(apb_reg_adapter)

  function new(string name = "apb_reg_adapter");
    super.new(name);
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_seq_item tr = apb_seq_item::type_id::create("apb_tr");
    tr.write = (rw.kind == UVM_WRITE);
    tr.addr  = rw.addr[15:0];
    tr.data  = rw.data[31:0];
    return tr;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    apb_seq_item tr;
    if (!$cast(tr, bus_item))
      `uvm_fatal("ADAPTER", "bus_item is not an apb_seq_item")
    rw.kind    = tr.write ? UVM_WRITE : UVM_READ;
    rw.addr    = tr.addr;
    rw.data    = tr.data;
    rw.n_bits  = 32;
    rw.byte_en = 4'hF;
    rw.status  = tr.slverr ? UVM_NOT_OK : UVM_IS_OK;
  endfunction
endclass

