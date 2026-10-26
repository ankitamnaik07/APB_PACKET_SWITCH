class pkt_env extends uvm_env;
  `uvm_component_utils(pkt_env)

  apb_agent          agent;
  pkt_reg_block      regmodel;
  apb_reg_adapter    adapter;
  pkt_reg_predictor  predictor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent     = apb_agent::type_id::create("agent", this);
    predictor = pkt_reg_predictor::type_id::create("predictor", this);
    adapter   = apb_reg_adapter::type_id::create("adapter");

    regmodel = pkt_reg_block::type_id::create("regmodel");
    regmodel.build();
    regmodel.lock_model();
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    regmodel.default_map.set_sequencer(agent.sqr, adapter);
    regmodel.default_map.set_auto_predict(0);        // explicit prediction through the predictor
    regmodel.default_map.set_check_on_read(1);       // every read is compared with the mirror

    predictor.map     = regmodel.default_map;
    predictor.adapter = adapter;
    predictor.rm      = regmodel;
    agent.mon.ap.connect(predictor.bus_in);
  endfunction
endclass

