class pkt_base_test extends uvm_test;

  `uvm_component_utils(pkt_base_test)

  pkt_env env;
  virtual apb_if vif;

  function new(string name = "pkt_base_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = pkt_env::type_id::create("env", this);

    if (!uvm_config_db#(virtual apb_if)::get(
          this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF",
                 "Virtual interface 'vif' was not configured")
    end
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    `uvm_info("ELABORATION",
              "UVM testbench elaboration completed",
              UVM_LOW)

    uvm_top.print_topology();
  endfunction

  virtual task run_phase(uvm_phase phase);
    pkt_base_seq seq;

    super.run_phase(phase);

    phase.raise_objection(this, "RAL sequence started");

    seq = pkt_base_seq::type_id::create("seq");

    seq.reg_model = env.reg_model;

    seq.start(null);

    phase.drop_objection(this, "RAL sequence completed");
  endtask

endclass


// 1. DEVICE_ID TEST
class pkt_device_id_test extends pkt_base_test;
  `uvm_component_utils(pkt_device_id_test)

  function new(string name = "pkt_device_id_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    device_id_seq seq;

    phase.raise_objection(this);

    seq = device_id_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);

    phase.drop_objection(this);
  endtask
endclass


// 2. VERSION TEST
class pkt_version_test extends pkt_base_test;
  `uvm_component_utils(pkt_version_test)

  function new(string name = "pkt_version_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    version_seq seq;

    phase.raise_objection(this);

    seq = version_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);

    phase.drop_objection(this);
  endtask
endclass


// 3. SWITCH_STATUS TEST
class pkt_switch_status_test extends pkt_base_test;
  `uvm_component_utils(pkt_switch_status_test)

  function new(string name = "pkt_switch_status_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    switch_status_seq seq;

    phase.raise_objection(this);

    seq = switch_status_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);

    phase.drop_objection(this);
  endtask
endclass


// 4. PORT_STATUS TEST
class pkt_port_status_test extends pkt_base_test;
  `uvm_component_utils(pkt_port_status_test)

  function new(string name = "pkt_port_status_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    port_status_seq seq;

    phase.raise_objection(this);

    seq = port_status_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);

    phase.drop_objection(this);
  endtask
endclass


// 5. GEN_STATUS TEST
class pkt_gen_status_test extends pkt_base_test;
  `uvm_component_utils(pkt_gen_status_test)

  function new(string name = "pkt_gen_status_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    gen_status_seq seq;

    phase.raise_objection(this);

    seq = gen_status_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);

    phase.drop_objection(this);
  endtask
endclass


// 6. STAT_RX TEST
class pkt_stat_rx_test extends pkt_base_test;
  `uvm_component_utils(pkt_stat_rx_test)

  function new(string name = "pkt_stat_rx_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    stat_rx_seq seq;

    phase.raise_objection(this);

    seq = stat_rx_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);

    phase.drop_objection(this);
  endtask
endclass


// 7. STAT_TX TEST
class pkt_stat_tx_test extends pkt_base_test;
  `uvm_component_utils(pkt_stat_tx_test)

  function new(string name = "pkt_stat_tx_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    stat_tx_seq seq;

    phase.raise_objection(this);

    seq = stat_tx_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);

    phase.drop_objection(this);
  endtask
endclass


// 8. STAT_DROP TEST
class pkt_stat_drop_test extends pkt_base_test;
  `uvm_component_utils(pkt_stat_drop_test)

  function new(string name = "pkt_stat_drop_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    stat_drop_seq seq;

    phase.raise_objection(this);

    seq = stat_drop_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);

    phase.drop_objection(this);
  endtask
endclass


// 9. SWITCH_CTRL TEST
class pkt_switch_ctrl_test extends pkt_base_test;
  `uvm_component_utils(pkt_switch_ctrl_test)

  function new(string name = "pkt_switch_ctrl_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    switch_ctrl_seq seq;

    phase.raise_objection(this);

    seq = switch_ctrl_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);

    phase.drop_objection(this);
  endtask
endclass


// 10. PORT_ENABLE TEST
class pkt_port_enable_test extends pkt_base_test;
  `uvm_component_utils(pkt_port_enable_test)

  function new(string name = "pkt_port_enable_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    port_enable_seq seq;

    phase.raise_objection(this);

    seq = port_enable_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);

    phase.drop_objection(this);
  endtask
endclass


// 11. FWD_ENABLE TEST
class pkt_fwd_enable_test extends pkt_base_test;
  `uvm_component_utils(pkt_fwd_enable_test)

  function new(string name = "pkt_fwd_enable_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    fwd_enable_seq seq;

    phase.raise_objection(this);
    seq = fwd_enable_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 12. GEN_CTRL TEST
class pkt_gen_ctrl_test extends pkt_base_test;
  `uvm_component_utils(pkt_gen_ctrl_test)

  function new(string name = "pkt_gen_ctrl_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    gen_ctrl_seq seq;

    phase.raise_objection(this);
    seq = gen_ctrl_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 13. GEN_PKT_CFG TEST
class pkt_gen_pkt_cfg_test extends pkt_base_test;
  `uvm_component_utils(pkt_gen_pkt_cfg_test)

  function new(string name = "pkt_gen_pkt_cfg_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    gen_pkt_cfg_seq seq;

    phase.raise_objection(this);
    seq = gen_pkt_cfg_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 14. GEN_INTERVAL TEST
class pkt_gen_interval_test extends pkt_base_test;
  `uvm_component_utils(pkt_gen_interval_test)

  function new(string name = "pkt_gen_interval_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    gen_interval_seq seq;

    phase.raise_objection(this);
    seq = gen_interval_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 15. GEN_COUNT TEST
class pkt_gen_count_test extends pkt_base_test;
  `uvm_component_utils(pkt_gen_count_test)

  function new(string name = "pkt_gen_count_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    gen_count_seq seq;

    phase.raise_objection(this);
    seq = gen_count_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 16. IRQ_STATUS TEST
class pkt_irq_status_test extends pkt_base_test;
  `uvm_component_utils(pkt_irq_status_test)

  function new(string name = "pkt_irq_status_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    irq_status_seq seq;

    phase.raise_objection(this);
    seq = irq_status_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 17. IRQ_ENABLE TEST
class pkt_irq_enable_test extends pkt_base_test;
  `uvm_component_utils(pkt_irq_enable_test)

  function new(string name = "pkt_irq_enable_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    irq_enable_seq seq;

    phase.raise_objection(this);
    seq = irq_enable_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 18. IRQ_FORCE TEST
class pkt_irq_force_test extends pkt_base_test;
  `uvm_component_utils(pkt_irq_force_test)

  function new(string name = "pkt_irq_force_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    irq_force_seq seq;

    phase.raise_objection(this);
    seq = irq_force_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 19. ERR_STATUS TEST
class pkt_err_status_test extends pkt_base_test;
  `uvm_component_utils(pkt_err_status_test)

  function new(string name = "pkt_err_status_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    err_status_seq seq;

    phase.raise_objection(this);
    seq = err_status_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 20. ERR_ENABLE TEST
class pkt_err_enable_test extends pkt_base_test;
  `uvm_component_utils(pkt_err_enable_test)

  function new(string name = "pkt_err_enable_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    err_enable_seq seq;

    phase.raise_objection(this);
    seq = err_enable_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 21. ERR_INJECT TEST
class pkt_err_inject_test extends pkt_base_test;
  `uvm_component_utils(pkt_err_inject_test)

  function new(string name = "pkt_err_inject_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    err_inject_seq seq;

    phase.raise_objection(this);
    seq = err_inject_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 22. ERR_COUNT TEST
class pkt_err_count_test extends pkt_base_test;
  `uvm_component_utils(pkt_err_count_test)

  function new(string name = "pkt_err_count_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    err_count_seq seq;

    phase.raise_objection(this);
    seq = err_count_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 23. ERR_INFO TEST
class pkt_err_info_test extends pkt_base_test;
  `uvm_component_utils(pkt_err_info_test)

  function new(string name = "pkt_err_info_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    err_info_seq seq;

    phase.raise_objection(this);
    seq = err_info_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 24. LOCK TEST
class pkt_lock_test extends pkt_base_test;
  `uvm_component_utils(pkt_lock_test)

  function new(string name = "pkt_lock_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    lock_seq seq;

    phase.raise_objection(this);
    seq = lock_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


// 25. SOFT_RESET TEST
class pkt_soft_reset_test extends pkt_base_test;
  `uvm_component_utils(pkt_soft_reset_test)

  function new(string name = "pkt_soft_reset_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    soft_reset_seq seq;

    phase.raise_objection(this);
    seq = soft_reset_seq::type_id::create("seq");
    seq.reg_model = env.reg_model;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass


