class apb_seq_item extends uvm_sequence_item;
  rand bit [15:0] addr;
  rand bit [31:0] data;
  rand bit        write;
  bit             slverr;      // sampled PSLVERR in the access phase

  `uvm_object_utils_begin(apb_seq_item)
    `uvm_field_int(addr,   UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(data,   UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(write,  UVM_ALL_ON)
    `uvm_field_int(slverr, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "apb_seq_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf("%s addr=0x%04h data=0x%08h slverr=%0b",
                     write ? "WR" : "RD", addr, data, slverr);
  endfunction
endclass

