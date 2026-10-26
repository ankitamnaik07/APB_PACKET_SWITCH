// -----------------------------------------------------------------------------
// Tests. Use +UVM_TESTNAME=<test>. Plusargs:
//   +PKT_ERR_SAT              Run the ERR_COUNT saturation check
//   +SOFT_RESET_KEEPS_STICKY  Keep sticky registers over SOFT_RESET
// -----------------------------------------------------------------------------

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

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if ($test$plusargs("SOFT_RESET_KEEPS_STICKY"))
      env.predictor.soft_reset_clears_sticky = 0;
  endfunction

  // ---------------------------------------------------------------------------
  // Test execution
  // ---------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);

    `uvm_info("TEST_START",
      $sformatf(
        "\n========================================\nSTART TEST : %s\n========================================",
        get_type_name()
      ),
      UVM_NONE
    )

    phase.raise_objection(this, "Register test running");

    wait (vif.presetn === 1'b1);
    repeat (5) @(vif.mon_cb);

    // Initialize the RAL mirror to the specified reset values.
    env.regmodel.reset();

    run_body();

    repeat (10) @(vif.mon_cb);

    phase.drop_objection(this, "Register test completed");

  endtask

  virtual task run_body();
  endtask

  // ---------------------------------------------------------------------------
  // Sequence helper
  // ---------------------------------------------------------------------------
  task start_seq(pkt_base_seq s);

    s.model   = env.regmodel;
    s.apb_sqr = env.agent.sqr;
    s.vif     = vif;

    s.start(null);

  endtask

  // ---------------------------------------------------------------------------
  // Apply hard reset
  // ---------------------------------------------------------------------------
  task hard_reset();

    `uvm_info("RESET",
      "Applying hard reset",
      UVM_LOW
    )

    vif.apply_reset(3);

    repeat (3) @(vif.mon_cb);

    env.regmodel.reset();

    `uvm_info("RESET",
      "Hard reset completed",
      UVM_LOW
    )

  endtask

  // ---------------------------------------------------------------------------
  // Run UVM built-in hardware reset sequence
  // ---------------------------------------------------------------------------
  task run_builtin_hw_reset();

    uvm_reg_hw_reset_seq hw;

    hw = uvm_reg_hw_reset_seq::type_id::create("hw_reset_seq");

    hw.model = env.regmodel;

    `uvm_info("RESET_CHECK",
      "Starting UVM hardware reset register check",
      UVM_LOW
    )

    hw.start(null);

    `uvm_info("RESET_CHECK",
      "UVM hardware reset register check completed",
      UVM_LOW
    )

  endtask

  // ---------------------------------------------------------------------------
  // Final test summary
  // ---------------------------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);

    uvm_report_server rs;

    int unsigned n_info;
    int unsigned n_warning;
    int unsigned n_error;
    int unsigned n_fatal;

    super.report_phase(phase);

    rs = uvm_report_server::get_server();

    n_info    = rs.get_severity_count(UVM_INFO);
    n_warning = rs.get_severity_count(UVM_WARNING);
    n_error   = rs.get_severity_count(UVM_ERROR);
    n_fatal   = rs.get_severity_count(UVM_FATAL);

    `uvm_info("TEST_SUMMARY",
      $sformatf(
        "\n========================================\nTEST NAME : %s\nINFO      : %0d\nWARNING   : %0d\nERROR     : %0d\nFATAL     : %0d\n========================================",
        get_type_name(),
        n_info,
        n_warning,
        n_error,
        n_fatal
      ),
      UVM_NONE
    )

    if ((n_error + n_fatal) == 0) begin

      `uvm_info("TEST_RESULT",
        "RESULT: PASS - no UVM_ERROR or UVM_FATAL messages",
        UVM_NONE
      )

    end
    else begin

      `uvm_info("TEST_RESULT",
        $sformatf(
          "RESULT: FAIL - errors=%0d, fatals=%0d. Search for the first UVM_ERROR.",
          n_error,
          n_fatal
        ),
        UVM_NONE
      )

    end

    `uvm_info("TEST_SUMMARY",
      "=============== END SUMMARY ===============",
      UVM_NONE
    )

  endfunction

endclass


// -----------------------------------------------------------------------------
// Macro to create and start a sequence
// -----------------------------------------------------------------------------
`define PKT_RUN(SEQ_T) \
  begin \
    SEQ_T s_; \
    s_ = SEQ_T::type_id::create(`"SEQ_T`"); \
    start_seq(s_); \
  end


// -----------------------------------------------------------------------------
// Reset test
// -----------------------------------------------------------------------------
class pkt_reset_test extends pkt_base_test;

  `uvm_component_utils(pkt_reset_test)

  function new(string name = "pkt_reset_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_body();

    pkt_reset_value_seq rv;

    `uvm_info("RESET_TEST",
      "Checking hardware reset register values",
      UVM_LOW
    )

    run_builtin_hw_reset();

    `PKT_RUN(pkt_reset_value_seq)

    `uvm_info("RESET_TEST",
      "Checking hard reset after configuration",
      UVM_LOW
    )

    `PKT_RUN(pkt_dirty_seq)

    hard_reset();

    `PKT_RUN(pkt_reset_value_seq)

    `uvm_info("RESET_TEST",
      "Checking soft reset",
      UVM_LOW
    )

    `PKT_RUN(pkt_dirty_seq)
    `PKT_RUN(pkt_soft_reset_seq)

    rv = pkt_reset_value_seq::type_id::create("rv_soft");

    rv.skip_sticky =
      $test$plusargs("SOFT_RESET_KEEPS_STICKY");

    start_seq(rv);

  endtask

endclass


// -----------------------------------------------------------------------------
// Register lock test
// -----------------------------------------------------------------------------
class pkt_lock_test extends pkt_base_test;

  `uvm_component_utils(pkt_lock_test)

  function new(string name = "pkt_lock_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_body();
    `PKT_RUN(pkt_lock_seq)
  endtask

endclass


// -----------------------------------------------------------------------------
// Register read/write test and bit-bash test
// -----------------------------------------------------------------------------
class pkt_rw_test extends pkt_base_test;

  `uvm_component_utils(pkt_rw_test)

  function new(string name = "pkt_rw_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Only allow bit-bash on the selected side-effect-free registers.
  protected function void exclude_from_bit_bash();

    uvm_reg regs[$];

    uvm_reg keep[$] = '{
      env.regmodel.PORT_ENABLE,
      env.regmodel.FWD_ENABLE,
      env.regmodel.GEN_INTERVAL,
      env.regmodel.GEN_COUNT,
      env.regmodel.IRQ_ENABLE,
      env.regmodel.ERR_ENABLE
    };

    env.regmodel.get_registers(regs);

    foreach (regs[i]) begin

      bit k = 0;

      foreach (keep[j]) begin
        if (keep[j] == regs[i])
          k = 1;
      end

      if (!k) begin
        uvm_resource_db#(bit)::set(
          {"REG::", regs[i].get_full_name()},
          "NO_REG_BIT_BASH_TEST",
          1,
          this
        );
      end

    end

  endfunction

  virtual task run_body();

    uvm_reg_bit_bash_seq bb;

    `uvm_info("RW_TEST",
      "Starting custom register read/write patterns",
      UVM_LOW
    )

    `PKT_RUN(pkt_rw_seq)

    `uvm_info("RW_TEST",
      "Checking soft reset",
      UVM_LOW
    )

    `PKT_RUN(pkt_soft_reset_seq)

    `PKT_RUN(pkt_unlock_seq)

    `uvm_info("BIT_BASH",
      "Configuring registers for bit-bash test",
      UVM_LOW
    )

    exclude_from_bit_bash();

    bb = uvm_reg_bit_bash_seq::type_id::create("bb");
    bb.model = env.regmodel;

    `uvm_info("BIT_BASH",
      "Starting UVM register bit-bash sequence",
      UVM_LOW
    )

    bb.start(null);

    `uvm_info("BIT_BASH",
      "UVM register bit-bash sequence completed",
      UVM_LOW
    )

    `PKT_RUN(pkt_soft_reset_seq)

  endtask

endclass


// -----------------------------------------------------------------------------
// Read-only and write-only register test
// -----------------------------------------------------------------------------
class pkt_ro_wo_test extends pkt_base_test;

  `uvm_component_utils(pkt_ro_wo_test)

  function new(string name = "pkt_ro_wo_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_body();
    `PKT_RUN(pkt_ro_wo_seq)
  endtask

endclass


// -----------------------------------------------------------------------------
// Interrupt and error register test
// -----------------------------------------------------------------------------
class pkt_irq_err_test extends pkt_base_test;

  `uvm_component_utils(pkt_irq_err_test)

  function new(string name = "pkt_irq_err_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_body();

    pkt_irq_err_seq s;

    s = pkt_irq_err_seq::type_id::create("pkt_irq_err_seq");

    s.run_saturation = $test$plusargs("PKT_ERR_SAT");

    start_seq(s);

  endtask

endclass


// -----------------------------------------------------------------------------
// APB error-response test
// -----------------------------------------------------------------------------
class pkt_apb_err_test extends pkt_base_test;

  `uvm_component_utils(pkt_apb_err_test)

  function new(string name = "pkt_apb_err_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_body();
    `PKT_RUN(pkt_apb_err_seq)
  endtask

endclass


// -----------------------------------------------------------------------------
// Traffic test
// -----------------------------------------------------------------------------
class pkt_traffic_test extends pkt_base_test;

  `uvm_component_utils(pkt_traffic_test)

  function new(string name = "pkt_traffic_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_body();
    `PKT_RUN(pkt_traffic_seq)
  endtask

endclass


// -----------------------------------------------------------------------------
// Complete regression test
// -----------------------------------------------------------------------------
class pkt_regress_test extends pkt_rw_test;

  `uvm_component_utils(pkt_regress_test)

  function new(string name = "pkt_regress_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_body();

    pkt_irq_err_seq ie;

    `uvm_info("REGRESSION",
      "Starting complete packet-switch register regression",
      UVM_LOW
    )

    run_builtin_hw_reset();

    `PKT_RUN(pkt_reset_value_seq)
    `PKT_RUN(pkt_lock_seq)
    `PKT_RUN(pkt_ro_wo_seq)
    `PKT_RUN(pkt_apb_err_seq)

    ie = pkt_irq_err_seq::type_id::create("pkt_irq_err_seq");

    ie.run_saturation = $test$plusargs("PKT_ERR_SAT");

    start_seq(ie);

    // Custom read/write tests and bit-bash test.
    super.run_body();

    `PKT_RUN(pkt_traffic_seq)

    // Check register values again at the end.
    `PKT_RUN(pkt_reset_value_seq)

    `uvm_info("REGRESSION",
      "Complete packet-switch register regression finished",
      UVM_LOW
    )

  endtask

endclass
