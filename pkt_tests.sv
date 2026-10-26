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
    pkt_ral_sequence seq;

    super.run_phase(phase);

    phase.raise_objection(this, "RAL sequence started");

    seq = pkt_ral_sequence::type_id::create("seq");

    seq.reg_model = env.reg_model;

    seq.start(null);

    phase.drop_objection(this, "RAL sequence completed");
  endtask

endclass
