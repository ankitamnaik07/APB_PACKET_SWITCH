
class pkt_base_seq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(pkt_base_seq)

  pkt_reg_block reg_model;
  uvm_status_e status;

  function new(string name = "pkt_base_seq");
    super.new(name);
  endfunction

  task unlock_dut();
    reg_model.LOCK.write(
      .status(status),
      .value(32'hA5A5_C3C3)
    );

    if (status != UVM_IS_OK)
      `uvm_error("LOCK_SEQ", "LOCK register write failed")
  endtask

endclass


class pkt_ral_sequence extends pkt_base_seq;

  `uvm_object_utils(pkt_ral_sequence)

  function new(string name = "pkt_ral_sequence");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;

    unlock_dut();

    reg_model.PORT_ENABLE.write(status, 32'h5);
    if (status != UVM_IS_OK)
      `uvm_error("RAL", "PORT_ENABLE write failed")

    reg_model.PORT_ENABLE.read(status, read_data);

    if (status != UVM_IS_OK)
      `uvm_error("RAL", "PORT_ENABLE read failed")
    else if (read_data !== 32'h5)
      `uvm_error("RAL", "PORT_ENABLE readback mismatch")
    else
      `uvm_info("RAL", "PORT_ENABLE PASS", UVM_MEDIUM)
  endtask

endclass


class port_enable_seq extends pkt_ral_sequence;

  `uvm_object_utils(port_enable_seq)

  function new(string name = "port_enable_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;

    unlock_dut();

    reg_model.PORT_ENABLE.write(status, 32'hA);
    if (status != UVM_IS_OK)
      `uvm_error("PORT_SEQ", "PORT_ENABLE write failed")

    reg_model.PORT_ENABLE.read(status, read_data);

    if (status != UVM_IS_OK)
      `uvm_error("PORT_SEQ", "PORT_ENABLE read failed")
    else if (read_data !== 32'hA)
      `uvm_error("PORT_SEQ", "PORT_ENABLE readback mismatch")
    else
      `uvm_info("PORT_SEQ", "PORT_ENABLE PASS", UVM_MEDIUM)
  endtask

endclass


class fwd_enable_seq extends pkt_base_seq;

  `uvm_object_utils(fwd_enable_seq)

  function new(string name = "fwd_enable_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;

    unlock_dut();

    reg_model.FWD_ENABLE.write(status, 32'h3);

    if (status != UVM_IS_OK)
      `uvm_error("FWD_SEQ", "FWD_ENABLE write failed")

    reg_model.FWD_ENABLE.read(status, read_data);

    if (status != UVM_IS_OK)
      `uvm_error("FWD_SEQ", "FWD_ENABLE read failed")
    else if (read_data !== 32'h3)
      `uvm_error("FWD_SEQ",
                 $sformatf("Expected 3, got 0x%08h", read_data))
    else
      `uvm_info("FWD_SEQ", "FWD_ENABLE PASS", UVM_MEDIUM)
  endtask

endclass

