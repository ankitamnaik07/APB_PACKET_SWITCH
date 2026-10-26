package pkt_ral_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---- 0x00 DEVICE_ID
  class reg_device_id extends uvm_reg;
    `uvm_object_utils(reg_device_id)
    rand uvm_reg_field REVISION;
    rand uvm_reg_field VENDOR_ID;
    rand uvm_reg_field PRODUCT_ID;
    function new(string name = "reg_device_id");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      REVISION = uvm_reg_field::type_id::create("REVISION");
      REVISION.configure(this, 8, 24, "RO", 0, 'h2, 1, 0, 0);
      VENDOR_ID = uvm_reg_field::type_id::create("VENDOR_ID");
      VENDOR_ID.configure(this, 8, 16, "RO", 0, 'hA5, 1, 0, 0);
      PRODUCT_ID = uvm_reg_field::type_id::create("PRODUCT_ID");
      PRODUCT_ID.configure(this, 16, 0, "RO", 0, 'h5357, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x04 VERSION
  class reg_version extends uvm_reg;
    `uvm_object_utils(reg_version)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field MAJOR;
    rand uvm_reg_field MINOR;
    rand uvm_reg_field PATCH;
    function new(string name = "reg_version");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 8, 24, "RO", 0, 'h0, 1, 0, 0);
      MAJOR = uvm_reg_field::type_id::create("MAJOR");
      MAJOR.configure(this, 8, 16, "RO", 0, 'h1, 1, 0, 0);
      MINOR = uvm_reg_field::type_id::create("MINOR");
      MINOR.configure(this, 8, 8, "RO", 0, 'h2, 1, 0, 0);
      PATCH = uvm_reg_field::type_id::create("PATCH");
      PATCH.configure(this, 8, 0, "RO", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x08 SWITCH_STATUS
  class reg_switch_status extends uvm_reg;
    `uvm_object_utils(reg_switch_status)
    rand uvm_reg_field RESERVED_HI;
    rand uvm_reg_field GEN_FSM;
    rand uvm_reg_field RESERVED_LO;
    rand uvm_reg_field ERR_PENDING;
    rand uvm_reg_field GEN_RUNNING;
    rand uvm_reg_field PORT_ENABLED;
    rand uvm_reg_field LOCKED;
    rand uvm_reg_field SWITCH_ENABLED;
    rand uvm_reg_field BUSY;
    rand uvm_reg_field READY;
    function new(string name = "reg_switch_status");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED_HI = uvm_reg_field::type_id::create("RESERVED_HI");
      RESERVED_HI.configure(this, 14, 18, "RO", 0, 'h0, 1, 0, 0);
      GEN_FSM = uvm_reg_field::type_id::create("GEN_FSM");
      GEN_FSM.configure(this, 2, 16, "RO", 1, 'h0, 1, 0, 0);
      RESERVED_LO = uvm_reg_field::type_id::create("RESERVED_LO");
      RESERVED_LO.configure(this, 6, 10, "RO", 0, 'h0, 1, 0, 0);
      ERR_PENDING = uvm_reg_field::type_id::create("ERR_PENDING");
      ERR_PENDING.configure(this, 1, 9, "RO", 1, 'h0, 1, 0, 0);
      GEN_RUNNING = uvm_reg_field::type_id::create("GEN_RUNNING");
      GEN_RUNNING.configure(this, 1, 8, "RO", 1, 'h0, 1, 0, 0);
      PORT_ENABLED = uvm_reg_field::type_id::create("PORT_ENABLED");
      PORT_ENABLED.configure(this, 4, 4, "RO", 1, 'hF, 1, 0, 0);
      LOCKED = uvm_reg_field::type_id::create("LOCKED");
      LOCKED.configure(this, 1, 3, "RO", 1, 'h1, 1, 0, 0);
      SWITCH_ENABLED = uvm_reg_field::type_id::create("SWITCH_ENABLED");
      SWITCH_ENABLED.configure(this, 1, 2, "RO", 1, 'h0, 1, 0, 0);
      BUSY = uvm_reg_field::type_id::create("BUSY");
      BUSY.configure(this, 1, 1, "RO", 1, 'h0, 1, 0, 0);
      READY = uvm_reg_field::type_id::create("READY");
      READY.configure(this, 1, 0, "RO", 1, 'h1, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x0C PORT_STATUS
  class reg_port_status extends uvm_reg;
    `uvm_object_utils(reg_port_status)
    rand uvm_reg_field PORT3_LEVEL;
    rand uvm_reg_field PORT2_LEVEL;
    rand uvm_reg_field PORT1_LEVEL;
    rand uvm_reg_field PORT0_LEVEL;
    function new(string name = "reg_port_status");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      PORT3_LEVEL = uvm_reg_field::type_id::create("PORT3_LEVEL");
      PORT3_LEVEL.configure(this, 8, 24, "RO", 1, 'h0, 1, 0, 0);
      PORT2_LEVEL = uvm_reg_field::type_id::create("PORT2_LEVEL");
      PORT2_LEVEL.configure(this, 8, 16, "RO", 1, 'h0, 1, 0, 0);
      PORT1_LEVEL = uvm_reg_field::type_id::create("PORT1_LEVEL");
      PORT1_LEVEL.configure(this, 8, 8, "RO", 1, 'h0, 1, 0, 0);
      PORT0_LEVEL = uvm_reg_field::type_id::create("PORT0_LEVEL");
      PORT0_LEVEL.configure(this, 8, 0, "RO", 1, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x10 GEN_STATUS
  class reg_gen_status extends uvm_reg;
    `uvm_object_utils(reg_gen_status)
    rand uvm_reg_field RESERVED_HI;
    rand uvm_reg_field REMAINING;
    rand uvm_reg_field RESERVED_LO;
    rand uvm_reg_field FSM;
    rand uvm_reg_field DONE;
    rand uvm_reg_field RUNNING;
    function new(string name = "reg_gen_status");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED_HI = uvm_reg_field::type_id::create("RESERVED_HI");
      RESERVED_HI.configure(this, 8, 24, "RO", 0, 'h0, 1, 0, 0);
      REMAINING = uvm_reg_field::type_id::create("REMAINING");
      REMAINING.configure(this, 16, 8, "RO", 1, 'h0, 1, 0, 0);
      RESERVED_LO = uvm_reg_field::type_id::create("RESERVED_LO");
      RESERVED_LO.configure(this, 4, 4, "RO", 0, 'h0, 1, 0, 0);
      FSM = uvm_reg_field::type_id::create("FSM");
      FSM.configure(this, 2, 2, "RO", 1, 'h0, 1, 0, 0);
      DONE = uvm_reg_field::type_id::create("DONE");
      DONE.configure(this, 1, 1, "RO", 1, 'h0, 1, 0, 0);
      RUNNING = uvm_reg_field::type_id::create("RUNNING");
      RUNNING.configure(this, 1, 0, "RO", 1, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x14 STAT_RX
  class reg_stat_rx extends uvm_reg;
    `uvm_object_utils(reg_stat_rx)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field RX_PACKETS;
    function new(string name = "reg_stat_rx");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 16, 16, "RO", 0, 'h0, 1, 0, 0);
      RX_PACKETS = uvm_reg_field::type_id::create("RX_PACKETS");
      RX_PACKETS.configure(this, 16, 0, "RO", 1, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x18 STAT_TX
  class reg_stat_tx extends uvm_reg;
    `uvm_object_utils(reg_stat_tx)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field TX_PACKETS;
    function new(string name = "reg_stat_tx");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 16, 16, "RO", 0, 'h0, 1, 0, 0);
      TX_PACKETS = uvm_reg_field::type_id::create("TX_PACKETS");
      TX_PACKETS.configure(this, 16, 0, "RO", 1, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x1C STAT_DROP
  class reg_stat_drop extends uvm_reg;
    `uvm_object_utils(reg_stat_drop)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field DROPPED_PACKETS;
    function new(string name = "reg_stat_drop");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 16, 16, "RO", 0, 'h0, 1, 0, 0);
      DROPPED_PACKETS = uvm_reg_field::type_id::create("DROPPED_PACKETS");
      DROPPED_PACKETS.configure(this, 16, 0, "RO", 1, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x20 SWITCH_CTRL  (lockable)
  class reg_switch_ctrl extends uvm_reg;
    `uvm_object_utils(reg_switch_ctrl)
    rand uvm_reg_field RESERVED_HI;
    rand uvm_reg_field IRQ_GLOBAL_EN;
    rand uvm_reg_field RESERVED_LO;
    rand uvm_reg_field STAT_CLEAR;
    rand uvm_reg_field ENABLE;
    function new(string name = "reg_switch_ctrl");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED_HI = uvm_reg_field::type_id::create("RESERVED_HI");
      RESERVED_HI.configure(this, 28, 4, "RO", 0, 'h0, 1, 0, 0);
      IRQ_GLOBAL_EN = uvm_reg_field::type_id::create("IRQ_GLOBAL_EN");
      IRQ_GLOBAL_EN.configure(this, 1, 3, "RW", 0, 'h0, 1, 1, 0);
      RESERVED_LO = uvm_reg_field::type_id::create("RESERVED_LO");
      RESERVED_LO.configure(this, 1, 2, "RO", 0, 'h0, 1, 0, 0);
      STAT_CLEAR = uvm_reg_field::type_id::create("STAT_CLEAR");
      STAT_CLEAR.configure(this, 1, 1, "WO", 0, 'h0, 1, 0, 0);
      ENABLE = uvm_reg_field::type_id::create("ENABLE");
      ENABLE.configure(this, 1, 0, "RW", 0, 'h0, 1, 1, 0);
    endfunction
  endclass

  // ---- 0x24 PORT_ENABLE  (lockable)
  class reg_port_enable extends uvm_reg;
    `uvm_object_utils(reg_port_enable)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field PORT3_EN;
    rand uvm_reg_field PORT2_EN;
    rand uvm_reg_field PORT1_EN;
    rand uvm_reg_field PORT0_EN;
    function new(string name = "reg_port_enable");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 28, 4, "RO", 0, 'h0, 1, 0, 0);
      PORT3_EN = uvm_reg_field::type_id::create("PORT3_EN");
      PORT3_EN.configure(this, 1, 3, "RW", 0, 'h1, 1, 1, 0);
      PORT2_EN = uvm_reg_field::type_id::create("PORT2_EN");
      PORT2_EN.configure(this, 1, 2, "RW", 0, 'h1, 1, 1, 0);
      PORT1_EN = uvm_reg_field::type_id::create("PORT1_EN");
      PORT1_EN.configure(this, 1, 1, "RW", 0, 'h1, 1, 1, 0);
      PORT0_EN = uvm_reg_field::type_id::create("PORT0_EN");
      PORT0_EN.configure(this, 1, 0, "RW", 0, 'h1, 1, 1, 0);
    endfunction
  endclass

  // ---- 0x28 FWD_ENABLE  (lockable)
  class reg_fwd_enable extends uvm_reg;
    `uvm_object_utils(reg_fwd_enable)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field FWD3_EN;
    rand uvm_reg_field FWD2_EN;
    rand uvm_reg_field FWD1_EN;
    rand uvm_reg_field FWD0_EN;
    function new(string name = "reg_fwd_enable");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 28, 4, "RO", 0, 'h0, 1, 0, 0);
      FWD3_EN = uvm_reg_field::type_id::create("FWD3_EN");
      FWD3_EN.configure(this, 1, 3, "RW", 0, 'h1, 1, 1, 0);
      FWD2_EN = uvm_reg_field::type_id::create("FWD2_EN");
      FWD2_EN.configure(this, 1, 2, "RW", 0, 'h1, 1, 1, 0);
      FWD1_EN = uvm_reg_field::type_id::create("FWD1_EN");
      FWD1_EN.configure(this, 1, 1, "RW", 0, 'h1, 1, 1, 0);
      FWD0_EN = uvm_reg_field::type_id::create("FWD0_EN");
      FWD0_EN.configure(this, 1, 0, "RW", 0, 'h1, 1, 1, 0);
    endfunction
  endclass

  // ---- 0x2C GEN_CTRL  (lockable)
  class reg_gen_ctrl extends uvm_reg;
    `uvm_object_utils(reg_gen_ctrl)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field CONTINUOUS;
    rand uvm_reg_field STOP;
    rand uvm_reg_field START;
    rand uvm_reg_field ENABLE;
    function new(string name = "reg_gen_ctrl");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 28, 4, "RO", 0, 'h0, 1, 0, 0);
      CONTINUOUS = uvm_reg_field::type_id::create("CONTINUOUS");
      CONTINUOUS.configure(this, 1, 3, "RW", 0, 'h0, 1, 1, 0);
      STOP = uvm_reg_field::type_id::create("STOP");
      STOP.configure(this, 1, 2, "WO", 0, 'h0, 1, 0, 0);
      START = uvm_reg_field::type_id::create("START");
      START.configure(this, 1, 1, "WO", 0, 'h0, 1, 0, 0);
      ENABLE = uvm_reg_field::type_id::create("ENABLE");
      ENABLE.configure(this, 1, 0, "RW", 0, 'h0, 1, 1, 0);
    endfunction
  endclass

  // ---- 0x30 GEN_PKT_CFG  (lockable)
  class reg_gen_pkt_cfg extends uvm_reg;
    `uvm_object_utils(reg_gen_pkt_cfg)
    rand uvm_reg_field RESERVED_HI;
    rand uvm_reg_field SEED;
    rand uvm_reg_field LENGTH;
    rand uvm_reg_field RESERVED_LO;
    rand uvm_reg_field SRC_PORT;
    rand uvm_reg_field DST_PORT;
    function new(string name = "reg_gen_pkt_cfg");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED_HI = uvm_reg_field::type_id::create("RESERVED_HI");
      RESERVED_HI.configure(this, 8, 24, "RO", 0, 'h0, 1, 0, 0);
      SEED = uvm_reg_field::type_id::create("SEED");
      SEED.configure(this, 8, 16, "RW", 0, 'h0, 1, 1, 0);
      LENGTH = uvm_reg_field::type_id::create("LENGTH");
      LENGTH.configure(this, 8, 8, "RW", 0, 'h4, 1, 1, 0);
      RESERVED_LO = uvm_reg_field::type_id::create("RESERVED_LO");
      RESERVED_LO.configure(this, 4, 4, "RO", 0, 'h0, 1, 0, 0);
      SRC_PORT = uvm_reg_field::type_id::create("SRC_PORT");
      SRC_PORT.configure(this, 2, 2, "RW", 0, 'h0, 1, 1, 0);
      DST_PORT = uvm_reg_field::type_id::create("DST_PORT");
      DST_PORT.configure(this, 2, 0, "RW", 0, 'h1, 1, 1, 0);
    endfunction
  endclass

  // ---- 0x34 GEN_INTERVAL  (lockable)
  class reg_gen_interval extends uvm_reg;
    `uvm_object_utils(reg_gen_interval)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field INTERVAL;
    function new(string name = "reg_gen_interval");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 16, 16, "RO", 0, 'h0, 1, 0, 0);
      INTERVAL = uvm_reg_field::type_id::create("INTERVAL");
      INTERVAL.configure(this, 16, 0, "RW", 0, 'h2, 1, 1, 0);
    endfunction
  endclass

  // ---- 0x38 GEN_COUNT  (lockable)
  class reg_gen_count extends uvm_reg;
    `uvm_object_utils(reg_gen_count)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field PACKET_COUNT;
    function new(string name = "reg_gen_count");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 16, 16, "RO", 0, 'h0, 1, 0, 0);
      PACKET_COUNT = uvm_reg_field::type_id::create("PACKET_COUNT");
      PACKET_COUNT.configure(this, 16, 0, "RW", 0, 'h4, 1, 1, 0);
    endfunction
  endclass

  // ---- 0x3C IRQ_STATUS
  class reg_irq_status extends uvm_reg;
    `uvm_object_utils(reg_irq_status)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field SW_EVENT;
    rand uvm_reg_field START_ACK;
    rand uvm_reg_field QUEUE_ALMOST_FULL;
    rand uvm_reg_field PACKET_FORWARDED;
    rand uvm_reg_field PACKET_DROPPED;
    rand uvm_reg_field QUEUE_OVERFLOW;
    rand uvm_reg_field ERROR;
    rand uvm_reg_field GEN_DONE;
    function new(string name = "reg_irq_status");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 24, 8, "RO", 0, 'h0, 1, 0, 0);
      SW_EVENT = uvm_reg_field::type_id::create("SW_EVENT");
      SW_EVENT.configure(this, 1, 7, "W1C", 0, 'h0, 1, 0, 0);
      START_ACK = uvm_reg_field::type_id::create("START_ACK");
      START_ACK.configure(this, 1, 6, "W1C", 1, 'h0, 1, 0, 0);
      QUEUE_ALMOST_FULL = uvm_reg_field::type_id::create("QUEUE_ALMOST_FULL");
      QUEUE_ALMOST_FULL.configure(this, 1, 5, "W1C", 1, 'h0, 1, 0, 0);
      PACKET_FORWARDED = uvm_reg_field::type_id::create("PACKET_FORWARDED");
      PACKET_FORWARDED.configure(this, 1, 4, "W1C", 1, 'h0, 1, 0, 0);
      PACKET_DROPPED = uvm_reg_field::type_id::create("PACKET_DROPPED");
      PACKET_DROPPED.configure(this, 1, 3, "W1C", 1, 'h0, 1, 0, 0);
      QUEUE_OVERFLOW = uvm_reg_field::type_id::create("QUEUE_OVERFLOW");
      QUEUE_OVERFLOW.configure(this, 1, 2, "W1C", 1, 'h0, 1, 0, 0);
      ERROR = uvm_reg_field::type_id::create("ERROR");
      ERROR.configure(this, 1, 1, "W1C", 1, 'h0, 1, 0, 0);
      GEN_DONE = uvm_reg_field::type_id::create("GEN_DONE");
      GEN_DONE.configure(this, 1, 0, "W1C", 1, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x40 IRQ_ENABLE  (lockable)
  class reg_irq_enable extends uvm_reg;
    `uvm_object_utils(reg_irq_enable)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field SW_EVENT_EN;
    rand uvm_reg_field START_ACK_EN;
    rand uvm_reg_field QUEUE_AF_EN;
    rand uvm_reg_field PACKET_FWD_EN;
    rand uvm_reg_field PACKET_DROP_EN;
    rand uvm_reg_field OVERFLOW_EN;
    rand uvm_reg_field ERROR_EN;
    rand uvm_reg_field GEN_DONE_EN;
    function new(string name = "reg_irq_enable");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 24, 8, "RO", 0, 'h0, 1, 0, 0);
      SW_EVENT_EN = uvm_reg_field::type_id::create("SW_EVENT_EN");
      SW_EVENT_EN.configure(this, 1, 7, "RW", 0, 'h0, 1, 1, 0);
      START_ACK_EN = uvm_reg_field::type_id::create("START_ACK_EN");
      START_ACK_EN.configure(this, 1, 6, "RW", 0, 'h0, 1, 1, 0);
      QUEUE_AF_EN = uvm_reg_field::type_id::create("QUEUE_AF_EN");
      QUEUE_AF_EN.configure(this, 1, 5, "RW", 0, 'h0, 1, 1, 0);
      PACKET_FWD_EN = uvm_reg_field::type_id::create("PACKET_FWD_EN");
      PACKET_FWD_EN.configure(this, 1, 4, "RW", 0, 'h0, 1, 1, 0);
      PACKET_DROP_EN = uvm_reg_field::type_id::create("PACKET_DROP_EN");
      PACKET_DROP_EN.configure(this, 1, 3, "RW", 0, 'h0, 1, 1, 0);
      OVERFLOW_EN = uvm_reg_field::type_id::create("OVERFLOW_EN");
      OVERFLOW_EN.configure(this, 1, 2, "RW", 0, 'h0, 1, 1, 0);
      ERROR_EN = uvm_reg_field::type_id::create("ERROR_EN");
      ERROR_EN.configure(this, 1, 1, "RW", 0, 'h0, 1, 1, 0);
      GEN_DONE_EN = uvm_reg_field::type_id::create("GEN_DONE_EN");
      GEN_DONE_EN.configure(this, 1, 0, "RW", 0, 'h0, 1, 1, 0);
    endfunction
  endclass

  // ---- 0x44 IRQ_FORCE
  class reg_irq_force extends uvm_reg;
    `uvm_object_utils(reg_irq_force)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field FORCE;
    function new(string name = "reg_irq_force");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 24, 8, "RO", 0, 'h0, 1, 0, 0);
      FORCE = uvm_reg_field::type_id::create("FORCE");
      FORCE.configure(this, 8, 0, "WO", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x48 ERR_STATUS
  class reg_err_status extends uvm_reg;
    `uvm_object_utils(reg_err_status)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field INJECTED;
    rand uvm_reg_field LENGTH_ERROR;
    rand uvm_reg_field CRC_ERROR;
    rand uvm_reg_field PROTOCOL_ERROR;
    rand uvm_reg_field UNDERSIZE;
    rand uvm_reg_field QUEUE_OVERFLOW;
    rand uvm_reg_field DEST_ERROR;
    rand uvm_reg_field BUS_ERROR;
    function new(string name = "reg_err_status");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 24, 8, "RO", 0, 'h0, 1, 0, 0);
      INJECTED = uvm_reg_field::type_id::create("INJECTED");
      INJECTED.configure(this, 1, 7, "W1C", 0, 'h0, 1, 0, 0);
      LENGTH_ERROR = uvm_reg_field::type_id::create("LENGTH_ERROR");
      LENGTH_ERROR.configure(this, 1, 6, "W1C", 0, 'h0, 1, 0, 0);
      CRC_ERROR = uvm_reg_field::type_id::create("CRC_ERROR");
      CRC_ERROR.configure(this, 1, 5, "W1C", 0, 'h0, 1, 0, 0);
      PROTOCOL_ERROR = uvm_reg_field::type_id::create("PROTOCOL_ERROR");
      PROTOCOL_ERROR.configure(this, 1, 4, "W1C", 0, 'h0, 1, 0, 0);
      UNDERSIZE = uvm_reg_field::type_id::create("UNDERSIZE");
      UNDERSIZE.configure(this, 1, 3, "W1C", 0, 'h0, 1, 0, 0);
      QUEUE_OVERFLOW = uvm_reg_field::type_id::create("QUEUE_OVERFLOW");
      QUEUE_OVERFLOW.configure(this, 1, 2, "W1C", 1, 'h0, 1, 0, 0);
      DEST_ERROR = uvm_reg_field::type_id::create("DEST_ERROR");
      DEST_ERROR.configure(this, 1, 1, "W1C", 1, 'h0, 1, 0, 0);
      BUS_ERROR = uvm_reg_field::type_id::create("BUS_ERROR");
      BUS_ERROR.configure(this, 1, 0, "W1C", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x4C ERR_ENABLE  (lockable)
  class reg_err_enable extends uvm_reg;
    `uvm_object_utils(reg_err_enable)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field INJECTED_EN;
    rand uvm_reg_field LENGTH_EN;
    rand uvm_reg_field CRC_EN;
    rand uvm_reg_field PROTOCOL_EN;
    rand uvm_reg_field UNDERSIZE_EN;
    rand uvm_reg_field OVERFLOW_EN;
    rand uvm_reg_field DEST_EN;
    rand uvm_reg_field BUS_EN;
    function new(string name = "reg_err_enable");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 24, 8, "RO", 0, 'h0, 1, 0, 0);
      INJECTED_EN = uvm_reg_field::type_id::create("INJECTED_EN");
      INJECTED_EN.configure(this, 1, 7, "RW", 0, 'h0, 1, 1, 0);
      LENGTH_EN = uvm_reg_field::type_id::create("LENGTH_EN");
      LENGTH_EN.configure(this, 1, 6, "RW", 0, 'h0, 1, 1, 0);
      CRC_EN = uvm_reg_field::type_id::create("CRC_EN");
      CRC_EN.configure(this, 1, 5, "RW", 0, 'h0, 1, 1, 0);
      PROTOCOL_EN = uvm_reg_field::type_id::create("PROTOCOL_EN");
      PROTOCOL_EN.configure(this, 1, 4, "RW", 0, 'h0, 1, 1, 0);
      UNDERSIZE_EN = uvm_reg_field::type_id::create("UNDERSIZE_EN");
      UNDERSIZE_EN.configure(this, 1, 3, "RW", 0, 'h0, 1, 1, 0);
      OVERFLOW_EN = uvm_reg_field::type_id::create("OVERFLOW_EN");
      OVERFLOW_EN.configure(this, 1, 2, "RW", 0, 'h0, 1, 1, 0);
      DEST_EN = uvm_reg_field::type_id::create("DEST_EN");
      DEST_EN.configure(this, 1, 1, "RW", 0, 'h0, 1, 1, 0);
      BUS_EN = uvm_reg_field::type_id::create("BUS_EN");
      BUS_EN.configure(this, 1, 0, "RW", 0, 'h0, 1, 1, 0);
    endfunction
  endclass

  // ---- 0x50 ERR_INJECT
  class reg_err_inject extends uvm_reg;
    `uvm_object_utils(reg_err_inject)
    rand uvm_reg_field CLEAR_COUNT;
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field INJECTED;
    rand uvm_reg_field LENGTH;
    rand uvm_reg_field CRC;
    rand uvm_reg_field PROTOCOL;
    rand uvm_reg_field UNDERSIZE;
    rand uvm_reg_field OVERFLOW;
    rand uvm_reg_field DEST;
    rand uvm_reg_field BUS;
    function new(string name = "reg_err_inject");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      CLEAR_COUNT = uvm_reg_field::type_id::create("CLEAR_COUNT");
      CLEAR_COUNT.configure(this, 1, 31, "WO", 0, 'h0, 1, 0, 0);
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 23, 8, "RO", 0, 'h0, 1, 0, 0);
      INJECTED = uvm_reg_field::type_id::create("INJECTED");
      INJECTED.configure(this, 1, 7, "WO", 0, 'h0, 1, 0, 0);
      LENGTH = uvm_reg_field::type_id::create("LENGTH");
      LENGTH.configure(this, 1, 6, "WO", 0, 'h0, 1, 0, 0);
      CRC = uvm_reg_field::type_id::create("CRC");
      CRC.configure(this, 1, 5, "WO", 0, 'h0, 1, 0, 0);
      PROTOCOL = uvm_reg_field::type_id::create("PROTOCOL");
      PROTOCOL.configure(this, 1, 4, "WO", 0, 'h0, 1, 0, 0);
      UNDERSIZE = uvm_reg_field::type_id::create("UNDERSIZE");
      UNDERSIZE.configure(this, 1, 3, "WO", 0, 'h0, 1, 0, 0);
      OVERFLOW = uvm_reg_field::type_id::create("OVERFLOW");
      OVERFLOW.configure(this, 1, 2, "WO", 0, 'h0, 1, 0, 0);
      DEST = uvm_reg_field::type_id::create("DEST");
      DEST.configure(this, 1, 1, "WO", 0, 'h0, 1, 0, 0);
      BUS = uvm_reg_field::type_id::create("BUS");
      BUS.configure(this, 1, 0, "WO", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x54 ERR_COUNT
  class reg_err_count extends uvm_reg;
    `uvm_object_utils(reg_err_count)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field ERROR_COUNT;
    function new(string name = "reg_err_count");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 16, 16, "RO", 0, 'h0, 1, 0, 0);
      ERROR_COUNT = uvm_reg_field::type_id::create("ERROR_COUNT");
      ERROR_COUNT.configure(this, 16, 0, "RO", 1, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x58 ERR_INFO
  class reg_err_info extends uvm_reg;
    `uvm_object_utils(reg_err_info)
    rand uvm_reg_field TX_SNAPSHOT;
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field DEST_PORT;
    rand uvm_reg_field SOURCE;
    rand uvm_reg_field LAST_CODE;
    function new(string name = "reg_err_info");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      TX_SNAPSHOT = uvm_reg_field::type_id::create("TX_SNAPSHOT");
      TX_SNAPSHOT.configure(this, 12, 20, "RO", 1, 'h0, 1, 0, 0);
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 2, 18, "RO", 0, 'h0, 1, 0, 0);
      DEST_PORT = uvm_reg_field::type_id::create("DEST_PORT");
      DEST_PORT.configure(this, 2, 16, "RO", 1, 'h0, 1, 0, 0);
      SOURCE = uvm_reg_field::type_id::create("SOURCE");
      SOURCE.configure(this, 8, 8, "RO", 1, 'h0, 1, 0, 0);
      LAST_CODE = uvm_reg_field::type_id::create("LAST_CODE");
      LAST_CODE.configure(this, 8, 0, "RO", 1, 'h0, 1, 0, 0);
    endfunction
  endclass

  // ---- 0x5C LOCK
  class reg_lock extends uvm_reg;
    `uvm_object_utils(reg_lock)
    rand uvm_reg_field KEY_RSVD;
    rand uvm_reg_field LOCKED;
    function new(string name = "reg_lock");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      KEY_RSVD = uvm_reg_field::type_id::create("KEY_RSVD");
      KEY_RSVD.configure(this, 31, 1, "WO", 0, 'h0, 1, 0, 0);
      LOCKED = uvm_reg_field::type_id::create("LOCKED");
      LOCKED.configure(this, 1, 0, "RW", 0, 'h1, 1, 1, 0);
    endfunction
  endclass

  // ---- 0x60 SOFT_RESET
  class reg_soft_reset extends uvm_reg;
    `uvm_object_utils(reg_soft_reset)
    rand uvm_reg_field RESERVED;
    rand uvm_reg_field PULSE;
    function new(string name = "reg_soft_reset");
      super.new(name, 32, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
      RESERVED = uvm_reg_field::type_id::create("RESERVED");
      RESERVED.configure(this, 31, 1, "RO", 0, 'h0, 1, 0, 0);
      PULSE = uvm_reg_field::type_id::create("PULSE");
      PULSE.configure(this, 1, 0, "WO", 0, 'h0, 1, 0, 0);
    endfunction
  endclass

  class pkt_reg_block extends uvm_reg_block;
    `uvm_object_utils(pkt_reg_block)
    rand reg_device_id DEVICE_ID;
    rand reg_version VERSION;
    rand reg_switch_status SWITCH_STATUS;
    rand reg_port_status PORT_STATUS;
    rand reg_gen_status GEN_STATUS;
    rand reg_stat_rx STAT_RX;
    rand reg_stat_tx STAT_TX;
    rand reg_stat_drop STAT_DROP;
    rand reg_switch_ctrl SWITCH_CTRL;
    rand reg_port_enable PORT_ENABLE;
    rand reg_fwd_enable FWD_ENABLE;
    rand reg_gen_ctrl GEN_CTRL;
    rand reg_gen_pkt_cfg GEN_PKT_CFG;
    rand reg_gen_interval GEN_INTERVAL;
    rand reg_gen_count GEN_COUNT;
    rand reg_irq_status IRQ_STATUS;
    rand reg_irq_enable IRQ_ENABLE;
    rand reg_irq_force IRQ_FORCE;
    rand reg_err_status ERR_STATUS;
    rand reg_err_enable ERR_ENABLE;
    rand reg_err_inject ERR_INJECT;
    rand reg_err_count ERR_COUNT;
    rand reg_err_info ERR_INFO;
    rand reg_lock LOCK;
    rand reg_soft_reset SOFT_RESET;
    uvm_reg_map     apb_map;
    uvm_reg_field   hw_flds[$];   // hardware-sourced / volatile fields (see header)
    uvm_reg         lockable_regs[$];

    function new(string name = "pkt_reg_block");
      super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
      apb_map = create_map("apb_map", 'h0, 4, UVM_LITTLE_ENDIAN, 1);
      default_map = apb_map;
      set_hdl_path_root("tb.dut");

      DEVICE_ID = reg_device_id::type_id::create("DEVICE_ID", , get_full_name());
      DEVICE_ID.configure(this, null, "");
      DEVICE_ID.build();
      apb_map.add_reg(DEVICE_ID, 'h00, "RW");
      VERSION = reg_version::type_id::create("VERSION", , get_full_name());
      VERSION.configure(this, null, "");
      VERSION.build();
      apb_map.add_reg(VERSION, 'h04, "RW");
      SWITCH_STATUS = reg_switch_status::type_id::create("SWITCH_STATUS", , get_full_name());
      SWITCH_STATUS.configure(this, null, "");
      SWITCH_STATUS.build();
      apb_map.add_reg(SWITCH_STATUS, 'h08, "RW");
      PORT_STATUS = reg_port_status::type_id::create("PORT_STATUS", , get_full_name());
      PORT_STATUS.configure(this, null, "");
      PORT_STATUS.build();
      apb_map.add_reg(PORT_STATUS, 'h0C, "RW");
      GEN_STATUS = reg_gen_status::type_id::create("GEN_STATUS", , get_full_name());
      GEN_STATUS.configure(this, null, "");
      GEN_STATUS.build();
      apb_map.add_reg(GEN_STATUS, 'h10, "RW");
      STAT_RX = reg_stat_rx::type_id::create("STAT_RX", , get_full_name());
      STAT_RX.configure(this, null, "");
      STAT_RX.build();
      apb_map.add_reg(STAT_RX, 'h14, "RW");
      STAT_TX = reg_stat_tx::type_id::create("STAT_TX", , get_full_name());
      STAT_TX.configure(this, null, "");
      STAT_TX.build();
      apb_map.add_reg(STAT_TX, 'h18, "RW");
      STAT_DROP = reg_stat_drop::type_id::create("STAT_DROP", , get_full_name());
      STAT_DROP.configure(this, null, "");
      STAT_DROP.build();
      apb_map.add_reg(STAT_DROP, 'h1C, "RW");
      SWITCH_CTRL = reg_switch_ctrl::type_id::create("SWITCH_CTRL", , get_full_name());
      SWITCH_CTRL.configure(this, null, "");
      SWITCH_CTRL.build();
      apb_map.add_reg(SWITCH_CTRL, 'h20, "RW");
      lockable_regs.push_back(SWITCH_CTRL);
      PORT_ENABLE = reg_port_enable::type_id::create("PORT_ENABLE", , get_full_name());
      PORT_ENABLE.configure(this, null, "");
      PORT_ENABLE.build();
      apb_map.add_reg(PORT_ENABLE, 'h24, "RW");
      lockable_regs.push_back(PORT_ENABLE);
      FWD_ENABLE = reg_fwd_enable::type_id::create("FWD_ENABLE", , get_full_name());
      FWD_ENABLE.configure(this, null, "");
      FWD_ENABLE.build();
      apb_map.add_reg(FWD_ENABLE, 'h28, "RW");
      lockable_regs.push_back(FWD_ENABLE);
      GEN_CTRL = reg_gen_ctrl::type_id::create("GEN_CTRL", , get_full_name());
      GEN_CTRL.configure(this, null, "");
      GEN_CTRL.build();
      apb_map.add_reg(GEN_CTRL, 'h2C, "RW");
      lockable_regs.push_back(GEN_CTRL);
      GEN_PKT_CFG = reg_gen_pkt_cfg::type_id::create("GEN_PKT_CFG", , get_full_name());
      GEN_PKT_CFG.configure(this, null, "");
      GEN_PKT_CFG.build();
      apb_map.add_reg(GEN_PKT_CFG, 'h30, "RW");
      lockable_regs.push_back(GEN_PKT_CFG);
      GEN_INTERVAL = reg_gen_interval::type_id::create("GEN_INTERVAL", , get_full_name());
      GEN_INTERVAL.configure(this, null, "");
      GEN_INTERVAL.build();
      apb_map.add_reg(GEN_INTERVAL, 'h34, "RW");
      lockable_regs.push_back(GEN_INTERVAL);
      GEN_COUNT = reg_gen_count::type_id::create("GEN_COUNT", , get_full_name());
      GEN_COUNT.configure(this, null, "");
      GEN_COUNT.build();
      apb_map.add_reg(GEN_COUNT, 'h38, "RW");
      lockable_regs.push_back(GEN_COUNT);
      IRQ_STATUS = reg_irq_status::type_id::create("IRQ_STATUS", , get_full_name());
      IRQ_STATUS.configure(this, null, "");
      IRQ_STATUS.build();
      apb_map.add_reg(IRQ_STATUS, 'h3C, "RW");
      IRQ_ENABLE = reg_irq_enable::type_id::create("IRQ_ENABLE", , get_full_name());
      IRQ_ENABLE.configure(this, null, "");
      IRQ_ENABLE.build();
      apb_map.add_reg(IRQ_ENABLE, 'h40, "RW");
      lockable_regs.push_back(IRQ_ENABLE);
      IRQ_FORCE = reg_irq_force::type_id::create("IRQ_FORCE", , get_full_name());
      IRQ_FORCE.configure(this, null, "");
      IRQ_FORCE.build();
      apb_map.add_reg(IRQ_FORCE, 'h44, "RW");
      ERR_STATUS = reg_err_status::type_id::create("ERR_STATUS", , get_full_name());
      ERR_STATUS.configure(this, null, "");
      ERR_STATUS.build();
      apb_map.add_reg(ERR_STATUS, 'h48, "RW");
      ERR_ENABLE = reg_err_enable::type_id::create("ERR_ENABLE", , get_full_name());
      ERR_ENABLE.configure(this, null, "");
      ERR_ENABLE.build();
      apb_map.add_reg(ERR_ENABLE, 'h4C, "RW");
      lockable_regs.push_back(ERR_ENABLE);
      ERR_INJECT = reg_err_inject::type_id::create("ERR_INJECT", , get_full_name());
      ERR_INJECT.configure(this, null, "");
      ERR_INJECT.build();
      apb_map.add_reg(ERR_INJECT, 'h50, "RW");
      ERR_COUNT = reg_err_count::type_id::create("ERR_COUNT", , get_full_name());
      ERR_COUNT.configure(this, null, "");
      ERR_COUNT.build();
      apb_map.add_reg(ERR_COUNT, 'h54, "RW");
      ERR_INFO = reg_err_info::type_id::create("ERR_INFO", , get_full_name());
      ERR_INFO.configure(this, null, "");
      ERR_INFO.build();
      apb_map.add_reg(ERR_INFO, 'h58, "RW");
      LOCK = reg_lock::type_id::create("LOCK", , get_full_name());
      LOCK.configure(this, null, "");
      LOCK.build();
      apb_map.add_reg(LOCK, 'h5C, "RW");
      SOFT_RESET = reg_soft_reset::type_id::create("SOFT_RESET", , get_full_name());
      SOFT_RESET.configure(this, null, "");
      SOFT_RESET.build();
      apb_map.add_reg(SOFT_RESET, 'h60, "RW");
      hw_flds.push_back(SWITCH_STATUS.GEN_FSM);
      hw_flds.push_back(SWITCH_STATUS.ERR_PENDING);
      hw_flds.push_back(SWITCH_STATUS.GEN_RUNNING);
      hw_flds.push_back(SWITCH_STATUS.PORT_ENABLED);
      hw_flds.push_back(SWITCH_STATUS.LOCKED);
      hw_flds.push_back(SWITCH_STATUS.SWITCH_ENABLED);
      hw_flds.push_back(SWITCH_STATUS.BUSY);
      hw_flds.push_back(SWITCH_STATUS.READY);
      hw_flds.push_back(PORT_STATUS.PORT3_LEVEL);
      hw_flds.push_back(PORT_STATUS.PORT2_LEVEL);
      hw_flds.push_back(PORT_STATUS.PORT1_LEVEL);
      hw_flds.push_back(PORT_STATUS.PORT0_LEVEL);
      hw_flds.push_back(GEN_STATUS.REMAINING);
      hw_flds.push_back(GEN_STATUS.FSM);
      hw_flds.push_back(GEN_STATUS.DONE);
      hw_flds.push_back(GEN_STATUS.RUNNING);
      hw_flds.push_back(STAT_RX.RX_PACKETS);
      hw_flds.push_back(STAT_TX.TX_PACKETS);
      hw_flds.push_back(STAT_DROP.DROPPED_PACKETS);
      hw_flds.push_back(IRQ_STATUS.START_ACK);
      hw_flds.push_back(IRQ_STATUS.QUEUE_ALMOST_FULL);
      hw_flds.push_back(IRQ_STATUS.PACKET_FORWARDED);
      hw_flds.push_back(IRQ_STATUS.PACKET_DROPPED);
      hw_flds.push_back(IRQ_STATUS.QUEUE_OVERFLOW);
      hw_flds.push_back(IRQ_STATUS.ERROR);
      hw_flds.push_back(IRQ_STATUS.GEN_DONE);
      hw_flds.push_back(ERR_STATUS.QUEUE_OVERFLOW);
      hw_flds.push_back(ERR_STATUS.DEST_ERROR);
      hw_flds.push_back(ERR_COUNT.ERROR_COUNT);
      set_idle_checks(1);
    endfunction

    // en=1 : hardware-sourced fields are compared against the (idle-datapath) mirror
    // en=0 : they are volatile (use when the generator / switch is moving packets)
    function void set_idle_checks(bit en);
      foreach (hw_flds[i]) hw_flds[i].set_volatility(!en);
    endfunction
  endclass
endpackage

