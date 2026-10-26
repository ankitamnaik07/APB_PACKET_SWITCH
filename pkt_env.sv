
class pkt_env extends uvm_env;

  `uvm_component_utils(pkt_env)

  apb_agent                       agent;
  pkt_reg_block                   reg_model;
  apb_reg_adapter                 adapter;
  uvm_reg_predictor #(apb_seq_item) predictor;

  function new(string name = "pkt_env",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent     = apb_agent::type_id::create("agent", this);
    adapter   = apb_reg_adapter::type_id::create("adapter");
    predictor = uvm_reg_predictor#(apb_seq_item)::type_id::create(
                  "predictor", this
                );

    reg_model = pkt_reg_block::type_id::create("reg_model");
    reg_model.build();
    reg_model.lock_model();

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    reg_model.default_map.set_sequencer(agent.sqr, adapter);

    reg_model.default_map.set_auto_predict(0);

    predictor.map     = reg_model.default_map;
    predictor.adapter = adapter;

    agent.mon.ap.connect(predictor.bus_in);

  endfunction

endclass


