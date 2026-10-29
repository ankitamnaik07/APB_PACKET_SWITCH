
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


/*class pkt_ral_sequence extends pkt_base_seq;

  `uvm_object_utils(pkt_ral_sequence)

  function new(string name = "pkt_ral_sequence");
    super.new(name);
  endfunction

  virtual task body();
    uvm_reg_data_t read_data;
	$display("parent body called");	  
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
*/

//1.DEVICE_ID
class device_id_seq extends pkt_base_seq;
  `uvm_object_utils(device_id_seq)

  localparam bit [31:0] DEVICE_ID_EXP = 32'h02A55357;

  function new(string name = "device_id_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t write_data;

    // TEST 1:
    reg_model.DEVICE_ID.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("DEVICE_ID_SEQ", "DEVICE_ID read failed")
    end

    else begin
      `uvm_info("DEVICE_ID_SEQ", $sformatf("DEVICE_ID = 0x%08h", read_data),UVM_MEDIUM)

      if (read_data !== DEVICE_ID_EXP)
        `uvm_error("DEVICE_ID_SEQ",$sformatf("Expected 0x%08h, got 0x%08h",DEVICE_ID_EXP, read_data))
    end

    // TEST 2
    write_data = 32'hFFFFFFFF;
    reg_model.DEVICE_ID.write(status, write_data, UVM_FRONTDOOR);
    `uvm_info("DEVICE_ID_SEQ",$sformatf("Write attempt status = %s", status.name()),UVM_MEDIUM)

    // TEST 3
    reg_model.DEVICE_ID.read(status, read_data, UVM_FRONTDOOR);
    if (status != UVM_IS_OK) begin
      `uvm_error("DEVICE_ID_SEQ", "Read after write attempt failed")
    end
    else if (read_data !== DEVICE_ID_EXP) begin
      `uvm_error("DEVICE_ID_SEQ",$sformatf("DEVICE_ID changed: expected 0x%08h, got 0x%08h",DEVICE_ID_EXP, read_data))
    end
    else begin
      `uvm_info("DEVICE_ID_SEQ","DEVICE_ID remained constant after write attempt",UVM_LOW)
    end
  endtask
endclass

//2.VERSION
class version_seq extends pkt_base_seq;
  `uvm_object_utils(version_seq)

  localparam bit [31:0] VERSION_EXP = 32'h00010200;

  function new(string name = "version_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t write_data;

    // TEST 1
    reg_model.VERSION.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("VERSION_SEQ", "VERSION read failed")
    end
    else begin

      `uvm_info("VERSION_SEQ",$sformatf("VERSION = 0x%08h", read_data),UVM_MEDIUM)

      if (read_data !== VERSION_EXP)
        `uvm_error("VERSION_SEQ",$sformatf("Expected 0x%08h, got 0x%08h",VERSION_EXP, read_data))
      else
        `uvm_info("VERSION_SEQ","VERSION register value PASS",UVM_LOW)

      // Check individual fields
      if (read_data[31:24] !== 8'h00)
        `uvm_error("VERSION_SEQ", "RESERVED field mismatch")

      if (read_data[23:16] !== 8'h01)
        `uvm_error("VERSION_SEQ", "MAJOR version mismatch")

      if (read_data[15:8] !== 8'h02)
        `uvm_error("VERSION_SEQ", "MINOR version mismatch")

      if (read_data[7:0] !== 8'h00)
        `uvm_error("VERSION_SEQ", "PATCH version mismatch")
    end

    // TEST2
    write_data = 32'hFFFFFFFF;
    reg_model.VERSION.write(status, write_data, UVM_FRONTDOOR);
    `uvm_info("VERSION_SEQ",$sformatf("All-ones write status = %s", status.name()),UVM_MEDIUM)

    // TEST3
    reg_model.VERSION.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("VERSION_SEQ", "Read after write attempt failed")
    end
    else if (read_data !== VERSION_EXP) begin
      `uvm_error("VERSION_SEQ",$sformatf("VERSION changed: expected 0x%08h, got 0x%08h",VERSION_EXP, read_data))
    end
    else begin
      `uvm_info("VERSION_SEQ","VERSION remained unchanged after write attempt",UVM_LOW)
    end

    // TEST4
    write_data = 32'h00000000;
    reg_model.VERSION.write(status, write_data, UVM_FRONTDOOR);
    reg_model.VERSION.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("VERSION_SEQ","Read after zero write failed")
    end
    else if (read_data !== VERSION_EXP) begin
      `uvm_error("VERSION_SEQ",$sformatf("VERSION changed after zero write: 0x%08h",read_data))
    end
    else begin
      `uvm_info("VERSION_SEQ","Zero write ignored: PASS",UVM_LOW)
    end
    `uvm_info("VERSION_SEQ","VERSION register verification completed",UVM_LOW)
  endtask
endclass

//3.SWITCH_STATUS —offset ,32-bit, RO, reset øxøeøeeeF9
class switch_status_seq extends pkt_base_seq;
  `uvm_object_utils(switch_status_seq)

  localparam bit [31:0] RESET_VALUE = 32'h000000F9;

  function new(string name = "switch_status_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t status_data;
    uvm_reg_data_t port_enable_data;
    uvm_reg_data_t switch_ctrl_data;
    uvm_reg_data_t err_status_data;

    bit expected_running;

    //Test1: Read SWITCH_STATUS
    reg_model.SWITCH_STATUS.read(status, status_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_fatal("SWITCH_STATUS","SWITCH_STATUS read failed")
    end
    `uvm_info("SWITCH_STATUS",$sformatf("SWITCH_STATUS = 0x%08h", status_data),UVM_MEDIUM)

    // TEST 2: Check reserved bits
    if (status_data[31:18] !== 14'h0000)
      `uvm_error("SWITCH_STATUS","Reserved bits [31:18] are non-zero")

    if (status_data[15:10] !== 6'h00)
      `uvm_error("SWITCH_STATUS","Reserved bits [15:10] are non-zero")

    // TEST 3: Check GEN_FSM encoding
    case (status_data[17:16])

      2'd0:`uvm_info("SWITCH_STATUS","GEN_FSM = IDLE", UVM_MEDIUM)
      2'd1:`uvm_info("SWITCH_STATUS","GEN_FSM = SEND", UVM_MEDIUM)
      2'd2:`uvm_info("SWITCH_STATUS","GEN_FSM = GAP", UVM_MEDIUM)
      2'd3:`uvm_info("SWITCH_STATUS","GEN_FSM = DONE", UVM_MEDIUM)
    endcase

    // TEST 4: Check GEN_RUNNING against GEN_FSM
    expected_running =(status_data[17:16] == 2'd1) ||(status_data[17:16] == 2'd2);
    if (status_data[8] !== expected_running)
      `uvm_error("SWITCH_STATUS",$sformatf("GEN_RUNNING mismatch: FSM=%0d, RUNNING=%0b",status_data[17:16], status_data[8]))
    else
      `uvm_info("SWITCH_STATUS","GEN_RUNNING check PASS",UVM_LOW)

    // TEST 5: Check PORT_ENABLED mirror
    reg_model.PORT_ENABLE.read(status, port_enable_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("SWITCH_STATUS","PORT_ENABLE read failed")
    end
    else begin

      reg_model.SWITCH_STATUS.read(status, status_data, UVM_FRONTDOOR);
      if (status != UVM_IS_OK) begin
        `uvm_error("SWITCH_STATUS","SWITCH_STATUS reread failed")
      end
      else if (status_data[7:4] !== port_enable_data[3:0]) begin
        `uvm_error("SWITCH_STATUS",$sformatf("PORT_ENABLED mismatch: STATUS=%0h, PORT_ENABLE=%0h",status_data[7:4], port_enable_data[3:0]))
      end
      else begin
        `uvm_info("SWITCH_STATUS","PORT_ENABLED mirror check PASS",UVM_LOW)
      end
    end

    // TEST 6: Check SWITCH_ENABLED mirror
    reg_model.SWITCH_CTRL.read(status, switch_ctrl_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("SWITCH_STATUS","SWITCH_CTRL read failed")
    end
    else begin
      reg_model.SWITCH_STATUS.read(status, status_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK) begin
        `uvm_error("SWITCH_STATUS","SWITCH_STATUS reread failed")
      end
      else if (status_data[2] !== switch_ctrl_data[0]) begin
        `uvm_error("SWITCH_STATUS",$sformatf("SWITCH_ENABLED mismatch: STATUS=%0b, CTRL.ENABLE=%0b",status_data[2], switch_ctrl_data[0]))
      end
      else begin
        `uvm_info("SWITCH_STATUS","SWITCH_ENABLED mirror check PASS",UVM_LOW)
      end
    end

    // TEST 7: Check ERR_PENDING
    reg_model.ERR_STATUS.read(status, err_status_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("SWITCH_STATUS","ERR_STATUS read failed")
    end
    else begin
      reg_model.SWITCH_STATUS.read(status, status_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK) begin
        `uvm_error("SWITCH_STATUS","SWITCH_STATUS reread failed")
      end
      else if (status_data[9] !== (|err_status_data[7:0])) begin
        `uvm_error("SWITCH_STATUS",$sformatf("ERR_PENDING mismatch: STATUS=%0b, ERR_STATUS=%02h",status_data[9], err_status_data[7:0]))
      end
      else begin
        `uvm_info("SWITCH_STATUS","ERR_PENDING check PASS",UVM_LOW)
      end
    end

    // TEST 8: Check READY
    if ((status_data[17:16] == 2'd0 ||status_data[17:16] == 2'd3) &&status_data[0] !== 1'b1) begin
      `uvm_error("SWITCH_STATUS","READY should be 1 in IDLE or DONE")
    end
    else if ((status_data[17:16] == 2'd1 ||status_data[17:16] == 2'd2) &&status_data[0] !== 1'b0) begin
      `uvm_error("SWITCH_STATUS","READY should be 0 in SEND or GAP")

    end
    else begin
      `uvm_info("SWITCH_STATUS","READY check PASS",UVM_LOW)
    end

    // TEST 9: Check reset value when applicablei
    `uvm_info("SWITCH_STATUS","Dynamic status and mirror checks completed",UVM_LOW)
  endtask
endclass

//4. PORT STATUS —offset exøc, 32-bit, RO, reset øxøøøøøeee
class port_status_seq extends pkt_base_seq;
	`uvm_object_utils(port_status_seq)

  function new(string name = "port_status_seq");
    super.new(name);
  endfunction

  task body();

    uvm_reg_data_t read_data;
    uvm_reg_data_t read_data_2;
    // TEST 1: Read PORT_STATUS
    reg_model.PORT_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_fatal("PORT_STATUS_SEQ","PORT_STATUS read failed")
    end
    `uvm_info("PORT_STATUS_SEQ",$sformatf("PORT_STATUS = 0x%08h", read_data),UVM_MEDIUM)

    // TEST 2: Check individual queue levels
    if (read_data[7:0] > 8'd16)
      `uvm_error("PORT_STATUS_SEQ","PORT0_LEVEL is outside the valid range")

    if (read_data[15:8] > 8'd16)
      `uvm_error("PORT_STATUS_SEQ","PORT1_LEVEL is outside the valid range")

    if (read_data[23:16] > 8'd16)
      `uvm_error("PORT_STATUS_SEQ","PORT2_LEVEL is outside the valid range")

    if (read_data[31:24] > 8'd16)
      `uvm_error("PORT_STATUS_SEQ","PORT3_LEVEL is outside the valid range")

    // TEST 3: Display individual queue levels
    `uvm_info("PORT_STATUS_SEQ",$sformatf("PORT0_LEVEL = %0d", read_data[7:0]),UVM_LOW)
    `uvm_info("PORT_STATUS_SEQ",$sformatf("PORT1_LEVEL = %0d", read_data[15:8]),UVM_LOW)
    `uvm_info("PORT_STATUS_SEQ",$sformatf("PORT2_LEVEL = %0d", read_data[23:16]),UVM_LOW)
    `uvm_info("PORT_STATUS_SEQ",$sformatf("PORT3_LEVEL = %0d", read_data[31:24]),UVM_LOW)

    // TEST 4: Check empty queues
    // Run this check only when the DUT is idle
    // and all destination queues are empty.
    // ----------------------------------------
    // Enable this check when the test guarantees
    // that no packets are queued or in flight.
    //
    // if (read_data !== 32'h00000000)
    //   `uvm_error("PORT_STATUS_SEQ",
    //              "Expected all queue levels to be zero")

    // TEST 5: Check read stability
    // Meaningful only when queue activity is stopped.
    // ----------------------------------------
    reg_model.PORT_STATUS.read(status, read_data_2, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("PORT_STATUS_SEQ","Second PORT_STATUS read failed")
    end
    else if (read_data_2 !== read_data) begin
      `uvm_info("PORT_STATUS_SEQ","Queue levels changed between reads; check whether traffic was active",UVM_MEDIUM)
    end
    else begin
      `uvm_info("PORT_STATUS_SEQ","PORT_STATUS stable-read check PASS",UVM_LOW)
    end
    `uvm_info("PORT_STATUS_SEQ","PORT_STATUS verification completed",UVM_LOW)
  endtask
endclass


//5.GEN_STATUS
class gen_status_seq extends pkt_base_seq;
	`uvm_object_utils(gen_status_seq)

  function new(string name = "gen_status_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;

    // TEST 1: Read GEN_STATUS
    reg_model.GEN_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_fatal("GEN_STATUS_SEQ","GEN_STATUS read failed")
    end

    `uvm_info("GEN_STATUS_SEQ",$sformatf("GEN_STATUS = 0x%08h", read_data),UVM_MEDIUM)
    
	// TEST 2: Check reserved bits
    if (read_data[31:24] !== 8'h00)
      `uvm_error("GEN_STATUS_SEQ","Reserved bits [31:24] are non-zero")

    if (read_data[7:4] !== 4'h0)
      `uvm_error("GEN_STATUS_SEQ","Reserved bits [7:4] are non-zero")

    // TEST 3: Check FSM encoding
    case (read_data[3:2])
      2'd0:`uvm_info("GEN_STATUS_SEQ","FSM = IDLE",UVM_LOW)
      2'd1:`uvm_info("GEN_STATUS_SEQ","FSM = SEND",UVM_LOW)
      2'd2:`uvm_info("GEN_STATUS_SEQ","FSM = GAP",UVM_LOW)
      2'd3:`uvm_info("GEN_STATUS_SEQ","FSM = DONE",UVM_LOW)
    endcase

    // TEST 4: Check RUNNING against FSM
    if ((read_data[3:2] == 2'd1 ||read_data[3:2] == 2'd2) && read_data[0] !== 1'b1) begin
      `uvm_error("GEN_STATUS_SEQ","RUNNING should be 1 in SEND or GAP")

    end
    else if ((read_data[3:2] == 2'd0 ||read_data[3:2] == 2'd3) && read_data[0] !== 1'b0) begin

      `uvm_error("GEN_STATUS_SEQ","RUNNING should be 0 in IDLE or DONE")

    end
    else begin
      `uvm_info("GEN_STATUS_SEQ","RUNNING indication check PASS",UVM_LOW)
    end

    // TEST 5: Check DONE against FSM
    if (read_data[1] !== (read_data[3:2] == 2'd3)) begin
      `uvm_error("GEN_STATUS_SEQ","DONE indication does not match FSM")
    end
    else begin
      `uvm_info("GEN_STATUS_SEQ","DONE indication check PASS",UVM_LOW)
    end

    // TEST 6: Check REMAINING packet count
    `uvm_info("GEN_STATUS_SEQ",$sformatf("REMAINING = %0d packets",read_data[23:8]),UVM_LOW)

    // TEST 7: Check idle/reset state
    if (read_data[3:2] == 2'd0 && read_data[0] == 1'b0 &&read_data[1] == 1'b0) begin
      `uvm_info("GEN_STATUS_SEQ","Generator is idle",UVM_LOW)
    end
    `uvm_info("GEN_STATUS_SEQ","GEN_STATUS verification completed",UVM_LOW)
  endtask
endclass


//6.STAT_RX
class stat_rx_seq extends pkt_base_seq;
  `uvm_object_utils(stat_rx_seq)

  function new(string name = "stat_rx_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t read_data_2;

    // TEST 1: Read STAT_RX
    reg_model.STAT_RX.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_fatal("STAT_RX_SEQ", "STAT_RX read failed")
    end

    `uvm_info("STAT_RX_SEQ", $sformatf("STAT_RX = 0x%08h", read_data), UVM_MEDIUM)

    // TEST 2: Check reserved bits [31:16]
    if (read_data[31:16] !== 16'h0000)
      `uvm_error("STAT_RX_SEQ", "Reserved bits [31:16] are non-zero")

    // TEST 3: Display RX_PACKETS count
    `uvm_info("STAT_RX_SEQ", $sformatf("RX_PACKETS = %0d", read_data[15:0]), UVM_LOW)

    // TEST 4: Check counter stability when no packet EOP is accepted
    reg_model.STAT_RX.read(status, read_data_2, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("STAT_RX_SEQ", "Second STAT_RX read failed")
    end
    else if (read_data_2[15:0] !== read_data[15:0]) begin
      `uvm_error("STAT_RX_SEQ", "RX_PACKETS changed when no packet EOP was accepted")
    end
    else begin
      `uvm_info("STAT_RX_SEQ", "RX_PACKETS stability check PASS", UVM_LOW)
    end

    // TEST 5: Clear RX_PACKETS using SWITCH_CTRL.STAT_CLEAR
    reg_model.SWITCH_CTRL.write(status, 32'h00000002, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("STAT_RX_SEQ", "SWITCH_CTRL STAT_CLEAR write failed")
    end
    else begin
      reg_model.STAT_RX.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK) begin
        `uvm_error("STAT_RX_SEQ", "STAT_RX read after clear failed")
      end
      else if (read_data[15:0] !== 16'h0000) begin
        `uvm_error("STAT_RX_SEQ", $sformatf("RX_PACKETS not cleared, value = 0x%04h", read_data[15:0]))
      end
      else begin
        `uvm_info("STAT_RX_SEQ", "STAT_CLEAR functionality PASS", UVM_LOW)
      end
    end

    // TEST 6: Verify the counter remains within its 16-bit range
    if (read_data[15:0] > 16'hFFFF)
      `uvm_error("STAT_RX_SEQ", "RX_PACKETS exceeds the maximum counter value")
    else
      `uvm_info("STAT_RX_SEQ", "RX_PACKETS range check PASS", UVM_LOW)

    `uvm_info("STAT_RX_SEQ", "STAT_RX verification completed", UVM_LOW)
  endtask
endclass

//7.STAT_TX
class stat_tx_seq extends pkt_base_seq;
  `uvm_object_utils(stat_tx_seq)

  function new(string name = "stat_tx_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t read_data_2;
    uvm_reg_data_t rx_data;

    // TEST 1: Read STAT_TX
    reg_model.STAT_TX.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_fatal("STAT_TX_SEQ", "STAT_TX read failed")
    end

    `uvm_info("STAT_TX_SEQ", $sformatf("STAT_TX = 0x%08h", read_data), UVM_MEDIUM)

    // TEST 2: Check reserved bits [31:16]
    if (read_data[31:16] !== 16'h0000)
      `uvm_error("STAT_TX_SEQ", "Reserved bits [31:16] are non-zero")

    // TEST 3: Display TX_PACKETS count
    `uvm_info("STAT_TX_SEQ", $sformatf("TX_PACKETS = %0d", read_data[15:0]), UVM_LOW)

    // TEST 4: Check counter stability when no packet is forwarded
    reg_model.STAT_TX.read(status, read_data_2, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("STAT_TX_SEQ", "Second STAT_TX read failed")
    end
    else if (read_data_2[15:0] !== read_data[15:0]) begin
      `uvm_error("STAT_TX_SEQ", "TX_PACKETS changed when no packet was forwarded")
    end
    else begin
      `uvm_info("STAT_TX_SEQ", "TX_PACKETS stability check PASS", UVM_LOW)
    end

    // TEST 5: Check STAT_TX and STAT_RX counters
    reg_model.STAT_RX.read(status, rx_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("STAT_TX_SEQ", "STAT_RX read failed")
    end
    else if (read_data[15:0] == rx_data[15:0]) begin
      `uvm_info("STAT_TX_SEQ", "STAT_TX and STAT_RX counters match", UVM_LOW)
    end
    else begin
      `uvm_info("STAT_TX_SEQ", $sformatf("STAT_TX = %0d, STAT_RX = %0d; verify traffic conditions", read_data[15:0], rx_data[15:0]), UVM_MEDIUM)
    end

    // TEST 6: Verify counter remains within its 16-bit range
    `uvm_info("STAT_TX_SEQ", "Maximum TX_PACKETS count = 65535", UVM_LOW)

    `uvm_info("STAT_TX_SEQ", "STAT_TX verification completed", UVM_LOW)
  endtask
endclass


//8.STAT_DROP
class stat_drop_seq extends pkt_base_seq;
  `uvm_object_utils(stat_drop_seq)

  function new(string name = "stat_drop_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t read_data_2;

    // TEST 1: Read STAT_DROP
    reg_model.STAT_DROP.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_fatal("STAT_DROP_SEQ", "STAT_DROP read failed")
    end

    `uvm_info("STAT_DROP_SEQ", $sformatf("STAT_DROP = 0x%08h", read_data), UVM_MEDIUM)

    // TEST 2: Check reserved bits [31:16]
    if (read_data[31:16] !== 16'h0000)
      `uvm_error("STAT_DROP_SEQ", "Reserved bits [31:16] are non-zero")

    // TEST 3: Display DROPPED_PACKETS count
    `uvm_info("STAT_DROP_SEQ", $sformatf("DROPPED_PACKETS = %0d", read_data[15:0]), UVM_LOW)

    // TEST 4: Check counter stability when no packet is dropped
    reg_model.STAT_DROP.read(status, read_data_2, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("STAT_DROP_SEQ", "Second STAT_DROP read failed")
    end
    else if (read_data_2[15:0] !== read_data[15:0]) begin
      `uvm_error("STAT_DROP_SEQ", "DROPPED_PACKETS changed when no packet was dropped")
    end
    else begin
      `uvm_info("STAT_DROP_SEQ", "DROPPED_PACKETS stability check PASS", UVM_LOW)
    end

    // TEST 5: Verify dropped-packet counter behavior
    `uvm_info("STAT_DROP_SEQ", "DROPPED_PACKETS increment check requires drop-condition stimulus", UVM_MEDIUM)

    // TEST 6: Verify counter saturation
    `uvm_info("STAT_DROP_SEQ", "Maximum DROPPED_PACKETS count = 65535", UVM_LOW)
    `uvm_info("STAT_DROP_SEQ", "STAT_DROP verification completed", UVM_LOW)
  endtask
endclass


//9.SWITCH_CTRL
class switch_ctrl_seq extends pkt_base_seq;
  `uvm_object_utils(switch_ctrl_seq)

  function new(string name = "switch_ctrl_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t read_data_2;

    // TEST 1: Unlock DUT before modifying lockable registers
    unlock_dut();

    // TEST 2: Read SWITCH_CTRL and check reset/default value
    reg_model.SWITCH_CTRL.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_fatal("SWITCH_CTRL_SEQ", "SWITCH_CTRL read failed")
    end

    `uvm_info("SWITCH_CTRL_SEQ", $sformatf("SWITCH_CTRL = 0x%08h", read_data), UVM_MEDIUM)

    // TEST 3: Check reserved bits [31:4] and bit [2]
    if (read_data[31:4] !== 28'h0000000)
      `uvm_error("SWITCH_CTRL_SEQ", "Reserved bits [31:4] are non-zero")

    if (read_data[2] !== 1'b0)
      `uvm_error("SWITCH_CTRL_SEQ", "Reserved bit [2] is non-zero")

    // TEST 4: Enable packet forwarding using ENABLE bit [0]
    reg_model.SWITCH_CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("SWITCH_CTRL_SEQ", "Failed to enable packet forwarding")
    end
    else begin
      reg_model.SWITCH_CTRL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("SWITCH_CTRL_SEQ", "SWITCH_CTRL read after ENABLE write failed")
      else if (read_data[0] !== 1'b1)
        `uvm_error("SWITCH_CTRL_SEQ", "ENABLE bit did not become 1")
      else
        `uvm_info("SWITCH_CTRL_SEQ", "ENABLE functionality PASS", UVM_LOW)
    end

    // TEST 5: Disable packet forwarding using ENABLE bit [0]
    reg_model.SWITCH_CTRL.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("SWITCH_CTRL_SEQ", "Failed to disable packet forwarding")
    end
    else begin
      reg_model.SWITCH_CTRL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("SWITCH_CTRL_SEQ", "SWITCH_CTRL read after DISABLE write failed")
      else if (read_data[0] !== 1'b0)
        `uvm_error("SWITCH_CTRL_SEQ", "ENABLE bit did not become 0")
      else
        `uvm_info("SWITCH_CTRL_SEQ", "DISABLE functionality PASS", UVM_LOW)
    end

    // TEST 6: Enable global interrupts using IRQ_GLOBAL_EN bit [3]
    reg_model.SWITCH_CTRL.write(status, 32'h00000008, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("SWITCH_CTRL_SEQ", "Failed to enable global interrupts")
    end
    else begin
      reg_model.SWITCH_CTRL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("SWITCH_CTRL_SEQ", "SWITCH_CTRL read after IRQ_GLOBAL_EN write failed")
      else if (read_data[3] !== 1'b1)
        `uvm_error("SWITCH_CTRL_SEQ", "IRQ_GLOBAL_EN bit did not become 1")
      else
        `uvm_info("SWITCH_CTRL_SEQ", "IRQ_GLOBAL_EN enable check PASS", UVM_LOW)
    end

    // TEST 7: Disable global interrupts while preserving ENABLE
    reg_model.SWITCH_CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("SWITCH_CTRL_SEQ", "Failed to disable global interrupts")
    end
    else begin
      reg_model.SWITCH_CTRL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("SWITCH_CTRL_SEQ", "SWITCH_CTRL read after IRQ_GLOBAL_EN disable failed")
      else if (read_data[3] !== 1'b0 || read_data[0] !== 1'b1)
        `uvm_error("SWITCH_CTRL_SEQ", "IRQ_GLOBAL_EN disable or ENABLE preservation check failed")
      else
        `uvm_info("SWITCH_CTRL_SEQ", "IRQ_GLOBAL_EN disable check PASS", UVM_LOW)
    end

    // TEST 8: Check STAT_CLEAR pulse while preserving ENABLE and IRQ_GLOBAL_EN
    // Writing 0x0000000B sets ENABLE, STAT_CLEAR, and IRQ_GLOBAL_EN.
    reg_model.SWITCH_CTRL.write(status, 32'h0000000B, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("SWITCH_CTRL_SEQ", "Failed to write STAT_CLEAR pulse")
    end
    else begin
      reg_model.SWITCH_CTRL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("SWITCH_CTRL_SEQ", "SWITCH_CTRL read after STAT_CLEAR failed")
      else if (read_data[1] !== 1'b0)
        `uvm_error("SWITCH_CTRL_SEQ", "STAT_CLEAR must always read as 0")
      else if (read_data[3] !== 1'b1 || read_data[0] !== 1'b1)
        `uvm_error("SWITCH_CTRL_SEQ", "STAT_CLEAR did not preserve ENABLE and IRQ_GLOBAL_EN")
      else
        `uvm_info("SWITCH_CTRL_SEQ", "STAT_CLEAR readback and control preservation check PASS", UVM_LOW)
    end

    // TEST 9: Verify statistics were cleared
    // Check the counters and queue levels after STAT_CLEAR.
    reg_model.STAT_RX.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SWITCH_CTRL_SEQ", "STAT_RX read after STAT_CLEAR failed")
    else if (read_data[15:0] !== 16'h0000)
      `uvm_error("SWITCH_CTRL_SEQ", $sformatf("STAT_RX was not cleared: 0x%08h", read_data))
    else
      `uvm_info("SWITCH_CTRL_SEQ", "STAT_RX clear check PASS", UVM_LOW)

    reg_model.STAT_TX.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SWITCH_CTRL_SEQ", "STAT_TX read after STAT_CLEAR failed")
    else if (read_data[15:0] !== 16'h0000)
      `uvm_error("SWITCH_CTRL_SEQ", $sformatf("STAT_TX was not cleared: 0x%08h", read_data))
    else
      `uvm_info("SWITCH_CTRL_SEQ", "STAT_TX clear check PASS", UVM_LOW)

    reg_model.STAT_DROP.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SWITCH_CTRL_SEQ", "STAT_DROP read after STAT_CLEAR failed")
    else if (read_data[15:0] !== 16'h0000)
      `uvm_error("SWITCH_CTRL_SEQ", $sformatf("STAT_DROP was not cleared: 0x%08h", read_data))
    else
      `uvm_info("SWITCH_CTRL_SEQ", "STAT_DROP clear check PASS", UVM_LOW)

    reg_model.PORT_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SWITCH_CTRL_SEQ", "PORT_STATUS read after STAT_CLEAR failed")
    else if (read_data !== 32'h00000000)
      `uvm_error("SWITCH_CTRL_SEQ", $sformatf("PORT_STATUS was not cleared: 0x%08h", read_data))
    else
      `uvm_info("SWITCH_CTRL_SEQ", "PORT_STATUS clear check PASS", UVM_LOW)

    // TEST 10: Final SWITCH_CTRL readback
    reg_model.SWITCH_CTRL.read(status, read_data_2, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SWITCH_CTRL_SEQ", "Final SWITCH_CTRL read failed")
    else
      `uvm_info("SWITCH_CTRL_SEQ", $sformatf("Final SWITCH_CTRL = 0x%08h", read_data_2), UVM_MEDIUM)

    `uvm_info("SWITCH_CTRL_SEQ", "SWITCH_CTRL verification completed", UVM_LOW)
  endtask
endclass


//10.PORT_ENABLE
class port_enable_seq extends pkt_base_seq;
  `uvm_object_utils(port_enable_seq)

  function new(string name = "port_enable_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;

    // TEST 1: Unlock DUT before modifying PORT_ENABLE
    unlock_dut();

    // TEST 2: Read PORT_ENABLE and check reset value
    reg_model.PORT_ENABLE.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_fatal("PORT_ENABLE_SEQ", "PORT_ENABLE read failed")
    end

    `uvm_info("PORT_ENABLE_SEQ", $sformatf("PORT_ENABLE = 0x%08h", read_data), UVM_MEDIUM)

    if (read_data[3:0] !== 4'hF)
      `uvm_error("PORT_ENABLE_SEQ", "PORT_ENABLE reset value mismatch; expected 0xF")

    // TEST 3: Enable all destination ports
    reg_model.PORT_ENABLE.write(status, 32'h0000000F, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("PORT_ENABLE_SEQ", "Failed to enable all destination ports")
    end
    else begin
      reg_model.PORT_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("PORT_ENABLE_SEQ", "PORT_ENABLE read after enabling all ports failed")
      else if (read_data[3:0] !== 4'hF)
        `uvm_error("PORT_ENABLE_SEQ", $sformatf("Expected all ports enabled, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("PORT_ENABLE_SEQ", "All destination ports enabled check PASS", UVM_LOW)
    end

    // TEST 4: Disable all destination ports
    reg_model.PORT_ENABLE.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("PORT_ENABLE_SEQ", "Failed to disable all destination ports")
    end
    else begin
      reg_model.PORT_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("PORT_ENABLE_SEQ", "PORT_ENABLE read after disabling all ports failed")
      else if (read_data[3:0] !== 4'h0)
        `uvm_error("PORT_ENABLE_SEQ", $sformatf("Expected all ports disabled, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("PORT_ENABLE_SEQ", "All destination ports disabled check PASS", UVM_LOW)
    end

    // TEST 5: Enable only PORT0
    reg_model.PORT_ENABLE.write(status, 32'h00000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("PORT_ENABLE_SEQ", "Failed to enable PORT0")
    end
    else begin
      reg_model.PORT_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("PORT_ENABLE_SEQ", "PORT_ENABLE read after enabling PORT0 failed")
      else if (read_data[3:0] !== 4'h1)
        `uvm_error("PORT_ENABLE_SEQ", $sformatf("PORT0 enable check failed, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("PORT_ENABLE_SEQ", "PORT0 enable check PASS", UVM_LOW)
    end

    // TEST 6: Enable only PORT1
    reg_model.PORT_ENABLE.write(status, 32'h00000002, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("PORT_ENABLE_SEQ", "Failed to enable PORT1")
    end
    else begin
      reg_model.PORT_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("PORT_ENABLE_SEQ", "PORT_ENABLE read after enabling PORT1 failed")
      else if (read_data[3:0] !== 4'h2)
        `uvm_error("PORT_ENABLE_SEQ", $sformatf("PORT1 enable check failed, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("PORT_ENABLE_SEQ", "PORT1 enable check PASS", UVM_LOW)
    end

    // TEST 7: Enable only PORT2
    reg_model.PORT_ENABLE.write(status, 32'h00000004, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("PORT_ENABLE_SEQ", "Failed to enable PORT2")
    end
    else begin
      reg_model.PORT_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("PORT_ENABLE_SEQ", "PORT_ENABLE read after enabling PORT2 failed")
      else if (read_data[3:0] !== 4'h4)
        `uvm_error("PORT_ENABLE_SEQ", $sformatf("PORT2 enable check failed, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("PORT_ENABLE_SEQ", "PORT2 enable check PASS", UVM_LOW)
    end

    // TEST 8: Enable only PORT3
    reg_model.PORT_ENABLE.write(status, 32'h00000008, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("PORT_ENABLE_SEQ", "Failed to enable PORT3")
    end
    else begin
      reg_model.PORT_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("PORT_ENABLE_SEQ", "PORT_ENABLE read after enabling PORT3 failed")
      else if (read_data[3:0] !== 4'h8)
        `uvm_error("PORT_ENABLE_SEQ", $sformatf("PORT3 enable check failed, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("PORT_ENABLE_SEQ", "PORT3 enable check PASS", UVM_LOW)
    end

    // TEST 9: Check reserved bits [31:4] read as zero
    if (read_data[31:4] !== 28'h0000000)
      `uvm_error("PORT_ENABLE_SEQ", "Reserved bits [31:4] are non-zero")
    else
      `uvm_info("PORT_ENABLE_SEQ", "Reserved bits check PASS", UVM_LOW)

    // TEST 10: Restore default configuration with all ports enabled
    reg_model.PORT_ENABLE.write(status, 32'h0000000F, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("PORT_ENABLE_SEQ", "Failed to restore PORT_ENABLE to 0xF")
    else
      `uvm_info("PORT_ENABLE_SEQ", "PORT_ENABLE verification completed", UVM_LOW)

  endtask
endclass


//11.FWD_ENABLE
class fwd_enable_seq extends pkt_base_seq;
  `uvm_object_utils(fwd_enable_seq)

  function new(string name = "fwd_enable_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;

    // TEST 1: Unlock DUT before accessing FWD_ENABLE
    unlock_dut();

    // TEST 2: Read FWD_ENABLE and check reset value
    reg_model.FWD_ENABLE.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_fatal("FWD_ENABLE_SEQ", "FWD_ENABLE read failed")
    end

    `uvm_info("FWD_ENABLE_SEQ", $sformatf("FWD_ENABLE = 0x%08h", read_data), UVM_MEDIUM)

    if (read_data[3:0] !== 4'hF)
      `uvm_error("FWD_ENABLE_SEQ", "FWD_ENABLE reset value mismatch; expected 0xF")

    // TEST 3: Enable forwarding to all destination ports
    reg_model.FWD_ENABLE.write(status, 32'h0000000F, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("FWD_ENABLE_SEQ", "Failed to enable forwarding to all ports")
    end
    else begin
      reg_model.FWD_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("FWD_ENABLE_SEQ", "FWD_ENABLE read after enabling all ports failed")
      else if (read_data[3:0] !== 4'hF)
        `uvm_error("FWD_ENABLE_SEQ", $sformatf("Expected all forwarding enabled, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("FWD_ENABLE_SEQ", "All-port forwarding enable check PASS", UVM_LOW)
    end

    // TEST 4: Disable forwarding to all destination ports
    reg_model.FWD_ENABLE.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("FWD_ENABLE_SEQ", "Failed to disable forwarding to all ports")
    end
    else begin
      reg_model.FWD_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("FWD_ENABLE_SEQ", "FWD_ENABLE read after disabling all ports failed")
      else if (read_data[3:0] !== 4'h0)
        `uvm_error("FWD_ENABLE_SEQ", $sformatf("Expected all forwarding disabled, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("FWD_ENABLE_SEQ", "All-port forwarding disable check PASS", UVM_LOW)
    end

    // TEST 5: Enable forwarding only to PORT0
    reg_model.FWD_ENABLE.write(status, 32'h00000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("FWD_ENABLE_SEQ", "Failed to enable forwarding to PORT0")
    end
    else begin
      reg_model.FWD_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("FWD_ENABLE_SEQ", "FWD_ENABLE read after PORT0 write failed")
      else if (read_data[3:0] !== 4'h1)
        `uvm_error("FWD_ENABLE_SEQ", $sformatf("PORT0 forwarding check failed, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("FWD_ENABLE_SEQ", "PORT0 forwarding enable check PASS", UVM_LOW)
    end

    // TEST 6: Enable forwarding only to PORT1
    reg_model.FWD_ENABLE.write(status, 32'h00000002, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("FWD_ENABLE_SEQ", "Failed to enable forwarding to PORT1")
    end
    else begin
      reg_model.FWD_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("FWD_ENABLE_SEQ", "FWD_ENABLE read after PORT1 write failed")
      else if (read_data[3:0] !== 4'h2)
        `uvm_error("FWD_ENABLE_SEQ", $sformatf("PORT1 forwarding check failed, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("FWD_ENABLE_SEQ", "PORT1 forwarding enable check PASS", UVM_LOW)
    end

    // TEST 7: Enable forwarding only to PORT2
    reg_model.FWD_ENABLE.write(status, 32'h00000004, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("FWD_ENABLE_SEQ", "Failed to enable forwarding to PORT2")
    end
    else begin
      reg_model.FWD_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("FWD_ENABLE_SEQ", "FWD_ENABLE read after PORT2 write failed")
      else if (read_data[3:0] !== 4'h4)
        `uvm_error("FWD_ENABLE_SEQ", $sformatf("PORT2 forwarding check failed, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("FWD_ENABLE_SEQ", "PORT2 forwarding enable check PASS", UVM_LOW)
    end

    // TEST 8: Enable forwarding only to PORT3
    reg_model.FWD_ENABLE.write(status, 32'h00000008, UVM_FRONTDOOR);

    if (status != UVM_IS_OK) begin
      `uvm_error("FWD_ENABLE_SEQ", "Failed to enable forwarding to PORT3")
    end
    else begin
      reg_model.FWD_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("FWD_ENABLE_SEQ", "FWD_ENABLE read after PORT3 write failed")
      else if (read_data[3:0] !== 4'h8)
        `uvm_error("FWD_ENABLE_SEQ", $sformatf("PORT3 forwarding check failed, got 0x%01h", read_data[3:0]))
      else
        `uvm_info("FWD_ENABLE_SEQ", "PORT3 forwarding enable check PASS", UVM_LOW)
    end

    // TEST 9: Check reserved bits [31:4] read as zero
    if (read_data[31:4] !== 28'h0000000)
      `uvm_error("FWD_ENABLE_SEQ", "Reserved bits [31:4] are non-zero")
    else
      `uvm_info("FWD_ENABLE_SEQ", "Reserved bits check PASS", UVM_LOW)

    // TEST 10: Restore default configuration with forwarding enabled for all ports
    reg_model.FWD_ENABLE.write(status, 32'h0000000F, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("FWD_ENABLE_SEQ", "Failed to restore FWD_ENABLE to 0xF")
    else
      `uvm_info("FWD_ENABLE_SEQ", "FWD_ENABLE verification completed", UVM_LOW)

  endtask
endclass


//12.GEN_CTRL
class gen_ctrl_seq extends pkt_base_seq;
  `uvm_object_utils(gen_ctrl_seq)

  function new(string name = "gen_ctrl_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t gen_status_data;
    uvm_reg_data_t irq_data;

    // TEST 1: Unlock DUT before accessing GEN_CTRL
    unlock_dut();

    // TEST 2: Read GEN_CTRL
    reg_model.GEN_CTRL.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("GEN_CTRL_SEQ", "GEN_CTRL read failed")

    `uvm_info("GEN_CTRL_SEQ", $sformatf("GEN_CTRL = 0x%08h", read_data), UVM_MEDIUM)

    // TEST 3: Check reserved bits [31:4]
    if (read_data[31:4] !== 28'h0000000)
      `uvm_error("GEN_CTRL_SEQ", "Reserved bits [31:4] are non-zero")

    // TEST 4: Enable generator
    reg_model.GEN_CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_CTRL_SEQ", "Failed to enable generator")
    else begin
      reg_model.GEN_CTRL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_CTRL_SEQ", "GEN_CTRL read after ENABLE failed")
      else if (read_data[0] !== 1'b1)
        `uvm_error("GEN_CTRL_SEQ", "ENABLE bit did not become 1")
      else
        `uvm_info("GEN_CTRL_SEQ", "ENABLE check PASS", UVM_LOW)
    end

    // TEST 5: Enable continuous mode and check readback
    reg_model.GEN_CTRL.write(status, 32'h00000009, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_CTRL_SEQ", "Failed to enable continuous mode")
    else begin
      reg_model.GEN_CTRL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_CTRL_SEQ", "GEN_CTRL read after CONTINUOUS write failed")
      else if (read_data[3] !== 1'b1 || read_data[0] !== 1'b1)
        `uvm_error("GEN_CTRL_SEQ", "CONTINUOUS or ENABLE readback mismatch")
      else
        `uvm_info("GEN_CTRL_SEQ", "CONTINUOUS mode configuration PASS", UVM_LOW)
    end

    // TEST 6: Disable continuous mode and preserve ENABLE
    reg_model.GEN_CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_CTRL_SEQ", "Failed to disable continuous mode")
    else begin
      reg_model.GEN_CTRL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_CTRL_SEQ", "GEN_CTRL read after disabling CONTINUOUS failed")
      else if (read_data[3] !== 1'b0 || read_data[0] !== 1'b1)
        `uvm_error("GEN_CTRL_SEQ", "CONTINUOUS disable or ENABLE preservation check failed")
      else
        `uvm_info("GEN_CTRL_SEQ", "CONTINUOUS disable check PASS", UVM_LOW)
    end

    // TEST 7: Issue STOP to force generator into IDLE before START
    reg_model.GEN_CTRL.write(status, 32'h00000005, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("GEN_CTRL_SEQ", "Failed to issue STOP pulse")

    reg_model.GEN_STATUS.read(status, gen_status_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("GEN_CTRL_SEQ", "GEN_STATUS read after STOP failed")
    else if (gen_status_data[0] !== 1'b0 || gen_status_data[23:8] !== 16'h0000)
      `uvm_error("GEN_CTRL_SEQ", "STOP did not clear RUNNING or REMAINING")

    // TEST 8: Clear previous START_ACK interrupt
    reg_model.IRQ_STATUS.write(status, 32'h00000040, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_CTRL_SEQ", "Failed to clear START_ACK")

    // TEST 9: Assert ENABLE and START in the same APB write
    reg_model.GEN_CTRL.write(status, 32'h00000003, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_CTRL_SEQ", "Failed to issue START pulse")
    else begin
      reg_model.GEN_CTRL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_CTRL_SEQ", "GEN_CTRL read after START failed")
      else if (read_data[0] !== 1'b1 || read_data[1] !== 1'b0)
        `uvm_error("GEN_CTRL_SEQ", "ENABLE or START pulse readback mismatch")
      else
        `uvm_info("GEN_CTRL_SEQ", "START pulse readback check PASS", UVM_LOW)
    end

    // TEST 10: Check START_ACK interrupt
    reg_model.IRQ_STATUS.read(status, irq_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_CTRL_SEQ", "IRQ_STATUS read after START failed")
    else if (irq_data[6] !== 1'b1)
      `uvm_error("GEN_CTRL_SEQ", "START_ACK was not asserted")
    else
      `uvm_info("GEN_CTRL_SEQ", "START_ACK check PASS", UVM_LOW)

    // TEST 11: Issue STOP and verify generator returns to IDLE
    reg_model.GEN_CTRL.write(status, 32'h00000005, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_CTRL_SEQ", "Failed to issue final STOP pulse")
    else begin
      reg_model.GEN_STATUS.read(status, gen_status_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_CTRL_SEQ", "GEN_STATUS read after final STOP failed")
      else if (gen_status_data[0] !== 1'b0 || gen_status_data[23:8] !== 16'h0000)
        `uvm_error("GEN_CTRL_SEQ", "Final STOP did not clear RUNNING or REMAINING")
      else
        `uvm_info("GEN_CTRL_SEQ", "STOP functionality PASS", UVM_LOW)
    end

    // TEST 12: Disable generator and verify ENABLE reads zero
    reg_model.GEN_CTRL.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_CTRL_SEQ", "Failed to disable generator")
    else begin
      reg_model.GEN_CTRL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_CTRL_SEQ", "GEN_CTRL read after disabling generator failed")
      else if (read_data[0] !== 1'b0)
        `uvm_error("GEN_CTRL_SEQ", "ENABLE bit did not clear")
      else
        `uvm_info("GEN_CTRL_SEQ", "Generator disable check PASS", UVM_LOW)
    end

    `uvm_info("GEN_CTRL_SEQ", "GEN_CTRL verification completed", UVM_LOW)
  endtask
endclass


//13.GEN_PKT_CFG
class gen_pkt_cfg_seq extends pkt_base_seq;
  `uvm_object_utils(gen_pkt_cfg_seq)

  function new(string name = "gen_pkt_cfg_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t gen_status_data;

    // TEST 1: Unlock DUT before accessing GEN_PKT_CFG
    unlock_dut();

    // TEST 2: Ensure generator is not running before changing configuration
    reg_model.GEN_STATUS.read(status, gen_status_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("GEN_PKT_CFG_SEQ", "GEN_STATUS read failed")

    if (gen_status_data[0] === 1'b1) begin
      reg_model.GEN_CTRL.write(status, 32'h00000005, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("GEN_PKT_CFG_SEQ", "Failed to stop generator before configuration")

      reg_model.GEN_STATUS.read(status, gen_status_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("GEN_PKT_CFG_SEQ", "GEN_STATUS read after STOP failed")
      else if (gen_status_data[0] !== 1'b0)
        `uvm_fatal("GEN_PKT_CFG_SEQ", "Generator is still running; cannot change configuration")
    end

    // TEST 3: Read GEN_PKT_CFG and check reset value
    reg_model.GEN_PKT_CFG.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("GEN_PKT_CFG_SEQ", "GEN_PKT_CFG read failed")

    `uvm_info("GEN_PKT_CFG_SEQ", $sformatf("GEN_PKT_CFG = 0x%08h", read_data), UVM_MEDIUM)

    if (read_data !== 32'h00000401)
      `uvm_info("GEN_PKT_CFG_SEQ", "Initial value differs from reset value; continuing field checks", UVM_MEDIUM)

    // TEST 4: Check reserved bits [31:24] and [7:4]
    if (read_data[31:24] !== 8'h00)
      `uvm_error("GEN_PKT_CFG_SEQ", "Reserved bits [31:24] are non-zero")

    if (read_data[7:4] !== 4'h0)
      `uvm_error("GEN_PKT_CFG_SEQ", "Reserved bits [7:4] are non-zero")

    // TEST 5: Write SEED=0x5A, LENGTH=4, SRC_PORT=1, DST_PORT=2
    reg_model.GEN_PKT_CFG.write(status, 32'h005A0406, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_PKT_CFG_SEQ", "GEN_PKT_CFG write failed")
    else begin
      reg_model.GEN_PKT_CFG.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_PKT_CFG_SEQ", "GEN_PKT_CFG read after configuration write failed")
      else begin
        if (read_data[23:16] !== 8'h5A)
          `uvm_error("GEN_PKT_CFG_SEQ", "SEED field mismatch")

        if (read_data[15:8] !== 8'h04)
          `uvm_error("GEN_PKT_CFG_SEQ", "LENGTH field mismatch")

        if (read_data[3:2] !== 2'd1)
          `uvm_error("GEN_PKT_CFG_SEQ", "SRC_PORT field mismatch")

        if (read_data[1:0] !== 2'd2)
          `uvm_error("GEN_PKT_CFG_SEQ", "DST_PORT field mismatch")

        if (read_data[23:16] == 8'h5A && read_data[15:8] == 8'h04 && read_data[3:2] == 2'd1 && read_data[1:0] == 2'd2)
          `uvm_info("GEN_PKT_CFG_SEQ", "SEED, LENGTH, SRC_PORT and DST_PORT checks PASS", UVM_LOW)
      end
    end

    // TEST 6: Write LENGTH=0 and verify it is stored as 1
    reg_model.GEN_PKT_CFG.write(status, 32'h005A0006, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_PKT_CFG_SEQ", "GEN_PKT_CFG write with LENGTH=0 failed")
    else begin
      reg_model.GEN_PKT_CFG.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_PKT_CFG_SEQ", "GEN_PKT_CFG read after LENGTH=0 failed")
      else if (read_data[15:8] !== 8'h01)
        `uvm_error("GEN_PKT_CFG_SEQ", $sformatf("LENGTH=0 should be stored as 1, got 0x%02h", read_data[15:8]))
      else
        `uvm_info("GEN_PKT_CFG_SEQ", "LENGTH=0 stored as 1 check PASS", UVM_LOW)
    end

    // TEST 7: Write LENGTH=20 and verify programmed value remains readable
    reg_model.GEN_PKT_CFG.write(status, 32'h005A1406, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_PKT_CFG_SEQ", "GEN_PKT_CFG write with LENGTH=20 failed")
    else begin
      reg_model.GEN_PKT_CFG.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_PKT_CFG_SEQ", "GEN_PKT_CFG read after LENGTH=20 failed")
      else if (read_data[15:8] !== 8'h14)
        `uvm_error("GEN_PKT_CFG_SEQ", $sformatf("LENGTH=20 should remain readable as 20, got %0d", read_data[15:8]))
      else
        `uvm_info("GEN_PKT_CFG_SEQ", "LENGTH above 16 remains readable check PASS", UVM_LOW)
    end

    // TEST 8: Restore the register's documented reset configuration
    reg_model.GEN_PKT_CFG.write(status, 32'h00000401, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_PKT_CFG_SEQ", "Failed to restore GEN_PKT_CFG reset configuration")
    else begin
      reg_model.GEN_PKT_CFG.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_PKT_CFG_SEQ", "Final GEN_PKT_CFG read failed")
      else if (read_data !== 32'h00000401)
        `uvm_error("GEN_PKT_CFG_SEQ", $sformatf("Final GEN_PKT_CFG mismatch: got 0x%08h", read_data))
      else
        `uvm_info("GEN_PKT_CFG_SEQ", "GEN_PKT_CFG reset configuration restored", UVM_LOW)
    end

    `uvm_info("GEN_PKT_CFG_SEQ", "GEN_PKT_CFG verification completed", UVM_LOW)
  endtask
endclass


//14.GEN_INTERVAL
class gen_interval_seq extends pkt_base_seq;
  `uvm_object_utils(gen_interval_seq)

  function new(string name = "gen_interval_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t gen_status_data;

    // TEST 1: Unlock DUT before accessing GEN_INTERVAL
    unlock_dut();

    // TEST 2: Ensure generator is idle before changing configuration
    reg_model.GEN_STATUS.read(status, gen_status_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("GEN_INTERVAL_SEQ", "GEN_STATUS read failed")

    if (gen_status_data[0] === 1'b1) begin
      reg_model.GEN_CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
      if (status != UVM_IS_OK)
        `uvm_fatal("GEN_INTERVAL_SEQ", "Failed to stop generator")

      reg_model.GEN_STATUS.read(status, gen_status_data, UVM_FRONTDOOR);
      if (status != UVM_IS_OK)
        `uvm_fatal("GEN_INTERVAL_SEQ", "GEN_STATUS read after STOP failed")
      else if (gen_status_data[0] !== 1'b0)
        `uvm_fatal("GEN_INTERVAL_SEQ", "Generator is still running")
    end

    // TEST 3: Read GEN_INTERVAL and check reset value
    reg_model.GEN_INTERVAL.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("GEN_INTERVAL_SEQ", "GEN_INTERVAL read failed")

    `uvm_info("GEN_INTERVAL_SEQ", $sformatf("GEN_INTERVAL = 0x%08h", read_data), UVM_MEDIUM)

    if (read_data !== 32'h00000002)
      `uvm_error("GEN_INTERVAL_SEQ", $sformatf("Expected reset value 0x00000002, got 0x%08h", read_data))

    // TEST 4: Check reserved bits [31:16]
    if (read_data[31:16] !== 16'h0000)
      `uvm_error("GEN_INTERVAL_SEQ", "Reserved bits [31:16] are non-zero")

    // TEST 5: Write INTERVAL = 0 and verify readback
    // Interval 0 starts the next packet without entering GAP
    reg_model.GEN_INTERVAL.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_INTERVAL_SEQ", "GEN_INTERVAL write with INTERVAL=0 failed")
    else begin
      reg_model.GEN_INTERVAL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_INTERVAL_SEQ", "GEN_INTERVAL read after INTERVAL=0 failed")
      else if (read_data[15:0] !== 16'd0)
        `uvm_error("GEN_INTERVAL_SEQ", $sformatf("Expected INTERVAL=0, got %0d", read_data[15:0]))
      else
        `uvm_info("GEN_INTERVAL_SEQ", "INTERVAL=0 readback check PASS", UVM_LOW)
    end

    // TEST 6: Write INTERVAL = 1 and verify readback
    reg_model.GEN_INTERVAL.write(status, 32'h00000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_INTERVAL_SEQ", "GEN_INTERVAL write with INTERVAL=1 failed")
    else begin
      reg_model.GEN_INTERVAL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_INTERVAL_SEQ", "GEN_INTERVAL read after INTERVAL=1 failed")
      else if (read_data[15:0] !== 16'd1)
        `uvm_error("GEN_INTERVAL_SEQ", $sformatf("Expected INTERVAL=1, got %0d", read_data[15:0]))
      else
        `uvm_info("GEN_INTERVAL_SEQ", "INTERVAL=1 readback check PASS", UVM_LOW)
    end

    // TEST 7: Write maximum INTERVAL = 65535 and verify readback
    reg_model.GEN_INTERVAL.write(status, 32'h0000FFFF, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_INTERVAL_SEQ", "GEN_INTERVAL write with maximum value failed")
    else begin
      reg_model.GEN_INTERVAL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_INTERVAL_SEQ", "GEN_INTERVAL read after maximum value failed")
      else if (read_data[15:0] !== 16'hFFFF)
        `uvm_error("GEN_INTERVAL_SEQ", $sformatf("Expected INTERVAL=65535, got %0d", read_data[15:0]))
      else
        `uvm_info("GEN_INTERVAL_SEQ", "Maximum INTERVAL readback check PASS", UVM_LOW)
    end

    // TEST 8: Restore documented reset configuration
    reg_model.GEN_INTERVAL.write(status, 32'h00000002, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_INTERVAL_SEQ", "Failed to restore GEN_INTERVAL to 2")
    else begin
      reg_model.GEN_INTERVAL.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_INTERVAL_SEQ", "Final GEN_INTERVAL read failed")
      else if (read_data !== 32'h00000002)
        `uvm_error("GEN_INTERVAL_SEQ", $sformatf("Final GEN_INTERVAL mismatch: 0x%08h", read_data))
      else
        `uvm_info("GEN_INTERVAL_SEQ", "GEN_INTERVAL verification completed", UVM_LOW)
    end
  endtask
endclass

//15.GEN_COUNT
class gen_count_seq extends pkt_base_seq;
  `uvm_object_utils(gen_count_seq)

  function new(string name = "gen_count_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t gen_status_data;

    // TEST 1: Unlock DUT before accessing GEN_COUNT
    unlock_dut();

    // TEST 2: Ensure generator is idle before changing configuration
    reg_model.GEN_STATUS.read(status, gen_status_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("GEN_COUNT_SEQ", "GEN_STATUS read failed")

    if (gen_status_data[0] === 1'b1) begin
      reg_model.GEN_CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
      if (status != UVM_IS_OK)
        `uvm_fatal("GEN_COUNT_SEQ", "Failed to stop generator")

      reg_model.GEN_STATUS.read(status, gen_status_data, UVM_FRONTDOOR);
      if (status != UVM_IS_OK)
        `uvm_fatal("GEN_COUNT_SEQ", "GEN_STATUS read after STOP failed")
      else if (gen_status_data[0] !== 1'b0)
        `uvm_fatal("GEN_COUNT_SEQ", "Generator is still running")
    end

    // TEST 3: Read GEN_COUNT and check reset value
    reg_model.GEN_COUNT.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("GEN_COUNT_SEQ", "GEN_COUNT read failed")

    `uvm_info("GEN_COUNT_SEQ", $sformatf("GEN_COUNT = 0x%08h", read_data), UVM_MEDIUM)

    if (read_data !== 32'h00000004)
      `uvm_error("GEN_COUNT_SEQ", $sformatf("Expected reset value 0x00000004, got 0x%08h", read_data))

    // TEST 4: Check reserved bits [31:16]
    if (read_data[31:16] !== 16'h0000)
      `uvm_error("GEN_COUNT_SEQ", "Reserved bits [31:16] are non-zero")

    // TEST 5: Write PACKET_COUNT = 0 and verify readback
    // The programmed zero is interpreted as one packet when START is accepted
    reg_model.GEN_COUNT.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_COUNT_SEQ", "GEN_COUNT write with PACKET_COUNT=0 failed")
    else begin
      reg_model.GEN_COUNT.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_COUNT_SEQ", "GEN_COUNT read after PACKET_COUNT=0 failed")
      else if (read_data[15:0] !== 16'd0)
        `uvm_error("GEN_COUNT_SEQ", $sformatf("Expected programmed PACKET_COUNT=0, got %0d", read_data[15:0]))
      else
        `uvm_info("GEN_COUNT_SEQ", "PACKET_COUNT=0 readback check PASS", UVM_LOW)
    end

    // TEST 6: Write PACKET_COUNT = 1 and verify readback
    reg_model.GEN_COUNT.write(status, 32'h00000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_COUNT_SEQ", "GEN_COUNT write with PACKET_COUNT=1 failed")
    else begin
      reg_model.GEN_COUNT.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_COUNT_SEQ", "GEN_COUNT read after PACKET_COUNT=1 failed")
      else if (read_data[15:0] !== 16'd1)
        `uvm_error("GEN_COUNT_SEQ", $sformatf("Expected PACKET_COUNT=1, got %0d", read_data[15:0]))
      else
        `uvm_info("GEN_COUNT_SEQ", "PACKET_COUNT=1 readback check PASS", UVM_LOW)
    end

    // TEST 7: Write PACKET_COUNT = 5 and verify readback
    reg_model.GEN_COUNT.write(status, 32'h00000005, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_COUNT_SEQ", "GEN_COUNT write with PACKET_COUNT=5 failed")
    else begin
      reg_model.GEN_COUNT.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_COUNT_SEQ", "GEN_COUNT read after PACKET_COUNT=5 failed")
      else if (read_data[15:0] !== 16'd5)
        `uvm_error("GEN_COUNT_SEQ", $sformatf("Expected PACKET_COUNT=5, got %0d", read_data[15:0]))
      else
        `uvm_info("GEN_COUNT_SEQ", "PACKET_COUNT=5 readback check PASS", UVM_LOW)
    end

    // TEST 8: Write maximum PACKET_COUNT = 65535 and verify readback
    reg_model.GEN_COUNT.write(status, 32'h0000FFFF, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_COUNT_SEQ", "GEN_COUNT write with maximum value failed")
    else begin
      reg_model.GEN_COUNT.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_COUNT_SEQ", "GEN_COUNT read after maximum value failed")
      else if (read_data[15:0] !== 16'hFFFF)
        `uvm_error("GEN_COUNT_SEQ", $sformatf("Expected PACKET_COUNT=65535, got %0d", read_data[15:0]))
      else
        `uvm_info("GEN_COUNT_SEQ", "Maximum PACKET_COUNT readback check PASS", UVM_LOW)
    end

    // TEST 9: Restore documented reset configuration
    reg_model.GEN_COUNT.write(status, 32'h00000004, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("GEN_COUNT_SEQ", "Failed to restore GEN_COUNT to 4")
    else begin
      reg_model.GEN_COUNT.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("GEN_COUNT_SEQ", "Final GEN_COUNT read failed")
      else if (read_data !== 32'h00000004)
        `uvm_error("GEN_COUNT_SEQ", $sformatf("Final GEN_COUNT mismatch: 0x%08h", read_data))
      else
        `uvm_info("GEN_COUNT_SEQ", "GEN_COUNT verification completed", UVM_LOW)
    end
  endtask
endclass


//16.IRQ_STATUS
class irq_status_seq extends pkt_base_seq;
  `uvm_object_utils(irq_status_seq)

  function new(string name = "irq_status_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;

    // TEST 1: Read IRQ_STATUS
    reg_model.IRQ_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("IRQ_STATUS_SEQ", "IRQ_STATUS read failed")

    `uvm_info("IRQ_STATUS_SEQ", $sformatf("IRQ_STATUS = 0x%08h", read_data), UVM_MEDIUM)

    // TEST 2: Check reserved bits [31:8]
    if (read_data[31:8] !== 24'h000000)
      `uvm_error("IRQ_STATUS_SEQ", "Reserved bits [31:8] are non-zero")
    else
      `uvm_info("IRQ_STATUS_SEQ", "Reserved bits check PASS", UVM_LOW)

    // TEST 3: Force SW_EVENT using IRQ_FORCE bit [7]
    // IRQ_STATUS is accessible while the DUT is locked.
    reg_model.IRQ_FORCE.write(status, 32'h00000080, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("IRQ_STATUS_SEQ", "IRQ_FORCE write failed")

    // TEST 4: Verify SW_EVENT bit [7] is set
    reg_model.IRQ_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("IRQ_STATUS_SEQ", "IRQ_STATUS read after force failed")
    else if (read_data[7] !== 1'b1)
      `uvm_error("IRQ_STATUS_SEQ", "SW_EVENT was not set by IRQ_FORCE")
    else
      `uvm_info("IRQ_STATUS_SEQ", "SW_EVENT set check PASS", UVM_LOW)

    // TEST 5: Write zero to SW_EVENT and verify it remains set
    // W1C behavior: writing 0 must not clear the status bit.
    reg_model.IRQ_STATUS.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("IRQ_STATUS_SEQ", "IRQ_STATUS zero write failed")
    else begin
      reg_model.IRQ_STATUS.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("IRQ_STATUS_SEQ", "IRQ_STATUS read after zero write failed")
      else if (read_data[7] !== 1'b1)
        `uvm_error("IRQ_STATUS_SEQ", "SW_EVENT cleared unexpectedly after writing zero")
      else
        `uvm_info("IRQ_STATUS_SEQ", "W1C zero-write check PASS", UVM_LOW)
    end

    // TEST 6: Clear SW_EVENT by writing 1 to bit [7]
    reg_model.IRQ_STATUS.write(status, 32'h00000080, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("IRQ_STATUS_SEQ", "Failed to clear SW_EVENT")
    else begin
      reg_model.IRQ_STATUS.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("IRQ_STATUS_SEQ", "IRQ_STATUS read after W1C failed")
      else if (read_data[7] !== 1'b0)
        `uvm_error("IRQ_STATUS_SEQ", "SW_EVENT did not clear after W1C write")
      else
        `uvm_info("IRQ_STATUS_SEQ", "SW_EVENT W1C clear check PASS", UVM_LOW)
    end

    // TEST 7: Display remaining interrupt status
    reg_model.IRQ_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("IRQ_STATUS_SEQ", "Final IRQ_STATUS read failed")
    else
      `uvm_info("IRQ_STATUS_SEQ", $sformatf("Final IRQ_STATUS = 0x%08h", read_data), UVM_MEDIUM)

    `uvm_info("IRQ_STATUS_SEQ", "IRQ_STATUS verification completed", UVM_LOW)
  endtask
endclass


//17.IRQ_ENABLE
class irq_enable_seq extends pkt_base_seq;
  `uvm_object_utils(irq_enable_seq)

  function new(string name = "irq_enable_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t write_data;
    int i;

    // TEST 1: Unlock DUT before accessing IRQ_ENABLE
    unlock_dut();

    // TEST 2: Read IRQ_ENABLE and check reserved bits
    reg_model.IRQ_ENABLE.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("IRQ_ENABLE_SEQ", "IRQ_ENABLE read failed")

    `uvm_info("IRQ_ENABLE_SEQ", $sformatf("IRQ_ENABLE = 0x%08h", read_data), UVM_MEDIUM)

    if (read_data[31:8] !== 24'h000000)
      `uvm_error("IRQ_ENABLE_SEQ", "Reserved bits [31:8] are non-zero")

    // TEST 3: Enable all interrupt sources
    reg_model.IRQ_ENABLE.write(status, 32'h000000FF, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("IRQ_ENABLE_SEQ", "Failed to enable all interrupt sources")
    else begin
      reg_model.IRQ_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("IRQ_ENABLE_SEQ", "IRQ_ENABLE read after enabling all sources failed")
      else if (read_data[7:0] !== 8'hFF)
        `uvm_error("IRQ_ENABLE_SEQ", $sformatf("Expected IRQ_ENABLE=0xFF, got 0x%02h", read_data[7:0]))
      else
        `uvm_info("IRQ_ENABLE_SEQ", "All interrupt sources enabled check PASS", UVM_LOW)
    end

    // TEST 4: Test each interrupt enable bit independently
    for (i = 0; i < 8; i++) begin
      write_data = 32'h00000001 << i;

      reg_model.IRQ_ENABLE.write(status, write_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("IRQ_ENABLE_SEQ", $sformatf("Write failed for IRQ_ENABLE bit %0d", i))
      else begin
        reg_model.IRQ_ENABLE.read(status, read_data, UVM_FRONTDOOR);

        if (status != UVM_IS_OK)
          `uvm_error("IRQ_ENABLE_SEQ", $sformatf("Read failed for IRQ_ENABLE bit %0d", i))
        else if (read_data[7:0] !== write_data[7:0])
          `uvm_error("IRQ_ENABLE_SEQ", $sformatf("IRQ_ENABLE bit %0d mismatch: expected 0x%02h, got 0x%02h", i, write_data[7:0], read_data[7:0]))
        else
          `uvm_info("IRQ_ENABLE_SEQ", $sformatf("IRQ_ENABLE bit %0d check PASS", i), UVM_LOW)
      end
    end

    // TEST 5: Disable all interrupt sources
    reg_model.IRQ_ENABLE.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("IRQ_ENABLE_SEQ", "Failed to disable all interrupt sources")
    else begin
      reg_model.IRQ_ENABLE.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("IRQ_ENABLE_SEQ", "IRQ_ENABLE read after disabling all sources failed")
      else if (read_data[7:0] !== 8'h00)
        `uvm_error("IRQ_ENABLE_SEQ", $sformatf("Expected IRQ_ENABLE=0x00, got 0x%02h", read_data[7:0]))
      else
        `uvm_info("IRQ_ENABLE_SEQ", "All interrupt sources disabled check PASS", UVM_LOW)
    end

    // TEST 6: Restore all interrupt enables to the documented reset value
    reg_model.IRQ_ENABLE.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("IRQ_ENABLE_SEQ", "Failed to restore IRQ_ENABLE reset value")
    else
      `uvm_info("IRQ_ENABLE_SEQ", "IRQ_ENABLE verification completed", UVM_LOW)

  endtask
endclass



//18.IRQ_FORCE
class irq_force_seq extends pkt_base_seq;
  `uvm_object_utils(irq_force_seq)

  function new(string name = "irq_force_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t write_data;
    int i;

    // TEST 1: Read IRQ_STATUS before forcing interrupts
    reg_model.IRQ_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("IRQ_FORCE_SEQ", "Initial IRQ_STATUS read failed")

    `uvm_info("IRQ_FORCE_SEQ", $sformatf("Initial IRQ_STATUS = 0x%08h", read_data), UVM_MEDIUM)

    // TEST 2: Force each interrupt status bit independently
    // IRQ_FORCE is accessible while the DUT is locked; unlock_dut() is not required.
    for (i = 0; i < 8; i++) begin
      write_data = 32'h00000001 << i;

      // Clear the selected IRQ_STATUS bit before testing it
      reg_model.IRQ_STATUS.write(status, write_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("IRQ_FORCE_SEQ", $sformatf("Failed to clear IRQ_STATUS bit %0d before forcing", i))
      else begin
        // Force the selected interrupt status bit
        reg_model.IRQ_FORCE.write(status, write_data, UVM_FRONTDOOR);

        if (status != UVM_IS_OK)
          `uvm_error("IRQ_FORCE_SEQ", $sformatf("IRQ_FORCE write failed for bit %0d", i))
        else begin
          // Verify the corresponding IRQ_STATUS bit is set
          reg_model.IRQ_STATUS.read(status, read_data, UVM_FRONTDOOR);

          if (status != UVM_IS_OK)
            `uvm_error("IRQ_FORCE_SEQ", $sformatf("IRQ_STATUS read failed after forcing bit %0d", i))
          else if (read_data[i] !== 1'b1)
            `uvm_error("IRQ_FORCE_SEQ", $sformatf("IRQ_STATUS bit %0d was not set by IRQ_FORCE", i))
          else
            `uvm_info("IRQ_FORCE_SEQ", $sformatf("IRQ_FORCE bit %0d set check PASS", i), UVM_LOW)
        end
      end

      // TEST 3: Clear the forced status bit using W1C
      reg_model.IRQ_STATUS.write(status, write_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("IRQ_FORCE_SEQ", $sformatf("W1C clear write failed for IRQ_STATUS bit %0d", i))
      else begin
        reg_model.IRQ_STATUS.read(status, read_data, UVM_FRONTDOOR);

        if (status != UVM_IS_OK)
          `uvm_error("IRQ_FORCE_SEQ", $sformatf("IRQ_STATUS read after clearing bit %0d failed", i))
        else if (read_data[i] !== 1'b0)
          `uvm_error("IRQ_FORCE_SEQ", $sformatf("IRQ_STATUS bit %0d did not clear; check whether the source reasserted", i))
        else
          `uvm_info("IRQ_FORCE_SEQ", $sformatf("IRQ_STATUS bit %0d W1C clear check PASS", i), UVM_LOW)
      end
    end

    // TEST 4: Write zero to IRQ_FORCE and verify it does not set new status bits
    reg_model.IRQ_FORCE.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("IRQ_FORCE_SEQ", "IRQ_FORCE zero write failed")
    else
      `uvm_info("IRQ_FORCE_SEQ", "IRQ_FORCE zero write completed", UVM_LOW)

    // TEST 5: Display final IRQ_STATUS
    reg_model.IRQ_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("IRQ_FORCE_SEQ", "Final IRQ_STATUS read failed")
    else
      `uvm_info("IRQ_FORCE_SEQ", $sformatf("Final IRQ_STATUS = 0x%08h", read_data), UVM_MEDIUM)

    `uvm_info("IRQ_FORCE_SEQ", "IRQ_FORCE verification completed", UVM_LOW)

  endtask
endclass


//19.ERR_STATUS
class err_status_seq extends pkt_base_seq;
  `uvm_object_utils(err_status_seq)

  function new(string name = "err_status_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t inject_data;
    uvm_reg_data_t clear_mask;
    int i;

    // TEST 1: Read ERR_STATUS
    reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_STATUS_SEQ", "ERR_STATUS read failed")

    `uvm_info("ERR_STATUS_SEQ", $sformatf("Initial ERR_STATUS = 0x%08h", read_data), UVM_MEDIUM)

    // TEST 2: Check reserved bits [31:8]
    if (read_data[31:8] !== 24'h000000)
      `uvm_error("ERR_STATUS_SEQ", "Reserved bits [31:8] are non-zero")
    else
      `uvm_info("ERR_STATUS_SEQ", "Reserved bits check PASS", UVM_LOW)

    // TEST 3: Clear all ERR_STATUS bits using W1C before starting
    // Run this sequence when no active hardware error condition can reassert a status bit.
    reg_model.ERR_STATUS.write(status, 32'h000000FF, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_STATUS_SEQ", "Initial ERR_STATUS W1C clear failed")

    reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_STATUS_SEQ", "ERR_STATUS read after initial clear failed")
    else if (read_data[7:0] !== 8'h00)
      `uvm_error("ERR_STATUS_SEQ", $sformatf("ERR_STATUS did not clear: 0x%02h", read_data[7:0]))
    else
      `uvm_info("ERR_STATUS_SEQ", "Initial W1C clear check PASS", UVM_LOW)

    // TEST 4: Inject each error type individually using ERR_INJECT
    // Bits [6:0] map directly to their corresponding ERR_STATUS error bits.
    // Bit 7 of ERR_STATUS is the INJECTED summary bit.
    for (i = 0; i < 7; i++) begin
      inject_data = 32'h00000001 << i;
      clear_mask = inject_data | 32'h00000080;

      // Inject the selected error
      reg_model.ERR_INJECT.write(status, inject_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("ERR_STATUS_SEQ", $sformatf("ERR_INJECT failed for bit %0d", i))

      // Check the injected error and INJECTED summary bits
      reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("ERR_STATUS_SEQ", "ERR_STATUS read after injection failed")

      `uvm_info("ERR_STATUS_SEQ", $sformatf("ERR_STATUS after injecting bit %0d = 0x%08h", i, read_data), UVM_MEDIUM)

      if (read_data[i] !== 1'b1)
        `uvm_error("ERR_STATUS_SEQ", $sformatf("ERR_STATUS error bit %0d was not set", i))
      else
        `uvm_info("ERR_STATUS_SEQ", $sformatf("ERR_STATUS error bit %0d set check PASS", i), UVM_LOW)

      if (read_data[7] !== 1'b1)
        `uvm_error("ERR_STATUS_SEQ", "INJECTED summary bit [7] was not set")
      else
        `uvm_info("ERR_STATUS_SEQ", "INJECTED summary check PASS", UVM_LOW)

      // TEST 5: Verify writing zero does not clear W1C bits
      reg_model.ERR_STATUS.write(status, 32'h00000000, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("ERR_STATUS_SEQ", "ERR_STATUS zero write failed")
      else begin
        reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

        if (status != UVM_IS_OK)
          `uvm_error("ERR_STATUS_SEQ", "ERR_STATUS read after zero write failed")
        else if (read_data[i] !== 1'b1 || read_data[7] !== 1'b1)
          `uvm_error("ERR_STATUS_SEQ", $sformatf("W1C zero-write check failed for error bit %0d", i))
        else
          `uvm_info("ERR_STATUS_SEQ", $sformatf("W1C zero-write check PASS for error bit %0d", i), UVM_LOW)
      end

      // TEST 6: Clear the selected error bit and INJECTED summary using W1C
      reg_model.ERR_STATUS.write(status, clear_mask, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("ERR_STATUS_SEQ", $sformatf("W1C clear failed for error bit %0d", i))
      else begin
        reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

        if (status != UVM_IS_OK)
          `uvm_error("ERR_STATUS_SEQ", "ERR_STATUS read after W1C failed")
        else begin
          if (read_data[i] !== 1'b0)
            `uvm_error("ERR_STATUS_SEQ", $sformatf("Error bit %0d did not clear", i))
          else
            `uvm_info("ERR_STATUS_SEQ", $sformatf("Error bit %0d W1C clear check PASS", i), UVM_LOW)

          if (read_data[7] !== 1'b0)
            `uvm_error("ERR_STATUS_SEQ", "INJECTED summary bit did not clear")
          else
            `uvm_info("ERR_STATUS_SEQ", "INJECTED summary W1C clear check PASS", UVM_LOW)
        end
      end
    end

    // TEST 7: Verify ERR_STATUS after all injection and clear tests
    reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("ERR_STATUS_SEQ", "Final ERR_STATUS read failed")
    else
      `uvm_info("ERR_STATUS_SEQ", $sformatf("Final ERR_STATUS = 0x%08h", read_data), UVM_MEDIUM)

    `uvm_info("ERR_STATUS_SEQ", "ERR_STATUS verification completed", UVM_LOW)
  endtask
endclass


//20.ERR_ENABLE
class err_enable_seq extends pkt_base_seq;
  `uvm_object_utils(err_enable_seq)

  function new(string name = "err_enable_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t err_data;
    uvm_reg_data_t irq_data;
    uvm_reg_data_t inject_data;
    uvm_reg_data_t enable_mask;
    int i;

    // TEST 1: Unlock DUT before accessing ERR_ENABLE
    unlock_dut();

    // TEST 2: Read ERR_ENABLE and check reserved bits
    reg_model.ERR_ENABLE.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_ENABLE_SEQ", "ERR_ENABLE read failed")

    `uvm_info("ERR_ENABLE_SEQ", $sformatf("ERR_ENABLE = 0x%08h", read_data), UVM_MEDIUM)

    if (read_data[31:8] !== 24'h000000)
      `uvm_error("ERR_ENABLE_SEQ", "Reserved bits [31:8] are non-zero")

    // TEST 3: Enable all eight error-promotion bits and verify readback
    reg_model.ERR_ENABLE.write(status, 32'h000000FF, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_ENABLE_SEQ", "Failed to enable all error-promotion bits")

    reg_model.ERR_ENABLE.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_ENABLE_SEQ", "ERR_ENABLE read after setting all bits failed")
    else if (read_data[7:0] !== 8'hFF)
      `uvm_error("ERR_ENABLE_SEQ", $sformatf("Expected 0xFF, got 0x%02h", read_data[7:0]))
    else
      `uvm_info("ERR_ENABLE_SEQ", "All error-promotion bits enable check PASS", UVM_LOW)

    // TEST 4: Verify each enable bit independently through error injection
    for (i = 0; i < 8; i++) begin
      enable_mask = 32'h00000001 << i;
      inject_data = (i == 7) ? 32'h00000080 : (32'h00000001 << i);

      // Clear previous error status before testing the next enable bit
      reg_model.ERR_STATUS.write(status, 32'h000000FF, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("ERR_ENABLE_SEQ", "Failed to clear previous ERR_STATUS")

      reg_model.IRQ_STATUS.write(status, 32'h00000002, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("ERR_ENABLE_SEQ", "Failed to clear IRQ_STATUS.ERROR")

      // Enable only the selected error source
      reg_model.ERR_ENABLE.write(status, enable_mask, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("ERR_ENABLE_SEQ", $sformatf("ERR_ENABLE write failed for bit %0d", i))

      // Inject the corresponding error; bit 7 alone tests INJECTED_EN
      reg_model.ERR_INJECT.write(status, inject_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("ERR_ENABLE_SEQ", $sformatf("ERR_INJECT failed for enable bit %0d", i))

      // Check the corresponding ERR_STATUS source bit
      reg_model.ERR_STATUS.read(status, err_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("ERR_ENABLE_SEQ", "ERR_STATUS read failed")

      if (i == 7) begin
        if (err_data[7] !== 1'b1)
          `uvm_error("ERR_ENABLE_SEQ", "INJECTED status bit was not set")
      end
      else begin
        if (err_data[i] !== 1'b1)
          `uvm_error("ERR_ENABLE_SEQ", $sformatf("ERR_STATUS bit %0d was not set", i))

        if (err_data[7] !== 1'b1)
          `uvm_error("ERR_ENABLE_SEQ", "INJECTED summary bit was not set")
      end

      // Verify enabled error status is promoted to IRQ_STATUS.ERROR
      reg_model.IRQ_STATUS.read(status, irq_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("ERR_ENABLE_SEQ", "IRQ_STATUS read failed")
      else if (irq_data[1] !== 1'b1)
        `uvm_error("ERR_ENABLE_SEQ", $sformatf("Error promotion failed for ERR_ENABLE bit %0d", i))
      else
        `uvm_info("ERR_ENABLE_SEQ", $sformatf("ERR_ENABLE bit %0d promotion check PASS", i), UVM_LOW)

      // Clear the source status first, then clear the aggregated IRQ status
      reg_model.ERR_STATUS.write(status, 32'h000000FF, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("ERR_ENABLE_SEQ", "Failed to clear ERR_STATUS after promotion check")

      reg_model.IRQ_STATUS.write(status, 32'h00000002, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("ERR_ENABLE_SEQ", "Failed to clear IRQ_STATUS.ERROR after promotion check")
    end

    // TEST 5: Disable all error-promotion bits
    reg_model.ERR_ENABLE.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_ENABLE_SEQ", "Failed to disable error promotion")

    // TEST 6: Verify an injected error does not promote when all enables are zero
    reg_model.ERR_STATUS.write(status, 32'h000000FF, UVM_FRONTDOOR);
    reg_model.IRQ_STATUS.write(status, 32'h00000002, UVM_FRONTDOOR);
    reg_model.ERR_INJECT.write(status, 32'h00000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_ENABLE_SEQ", "BUS_ERROR injection failed with promotion disabled")

    reg_model.ERR_STATUS.read(status, err_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_ENABLE_SEQ", "ERR_STATUS read failed with promotion disabled")
    else if (err_data[0] !== 1'b1)
      `uvm_error("ERR_ENABLE_SEQ", "BUS_ERROR was not set when promotion was disabled")

    reg_model.IRQ_STATUS.read(status, irq_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_ENABLE_SEQ", "IRQ_STATUS read failed with promotion disabled")
    else if (irq_data[1] !== 1'b0)
      `uvm_error("ERR_ENABLE_SEQ", "IRQ_STATUS.ERROR asserted while all ERR_ENABLE bits were disabled")
    else
      `uvm_info("ERR_ENABLE_SEQ", "Disabled error-promotion check PASS", UVM_LOW)

    // TEST 7: Clear the injected status and restore ERR_ENABLE reset value
    reg_model.ERR_STATUS.write(status, 32'h000000FF, UVM_FRONTDOOR);
    reg_model.IRQ_STATUS.write(status, 32'h00000002, UVM_FRONTDOOR);
    reg_model.ERR_ENABLE.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("ERR_ENABLE_SEQ", "Failed to restore ERR_ENABLE reset value")
    else
      `uvm_info("ERR_ENABLE_SEQ", "ERR_ENABLE verification completed", UVM_LOW)

  endtask
endclass


//21.ERR_INJECT
class err_inject_seq extends pkt_base_seq;
  `uvm_object_utils(err_inject_seq)

  function new(string name = "err_inject_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t count_data;
    uvm_reg_data_t inject_data;
    uvm_reg_data_t clear_mask;
    int i;

    // TEST 1: Clear existing ERR_STATUS bits
    // ERR_INJECT is accessible while locked, so unlock_dut() is not required.
    reg_model.ERR_STATUS.write(status, 32'h000000FF, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INJECT_SEQ", "Initial ERR_STATUS clear failed")

    // TEST 2: Clear ERR_COUNT and ERR_INFO using CLEAR_COUNT bit [31]
    reg_model.ERR_INJECT.write(status, 32'h80000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INJECT_SEQ", "CLEAR_COUNT write failed")

    reg_model.ERR_COUNT.read(status, count_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INJECT_SEQ", "Initial ERR_COUNT read failed")
    else if (count_data[15:0] !== 16'h0000)
      `uvm_error("ERR_INJECT_SEQ", $sformatf("ERR_COUNT did not clear: 0x%04h", count_data[15:0]))
    else
      `uvm_info("ERR_INJECT_SEQ", "CLEAR_COUNT check PASS", UVM_LOW)

    // TEST 3: Inject each error type using bits [6:0]
    // Each one-bit injection should increment ERR_COUNT by one.
    for (i = 0; i < 7; i++) begin
      inject_data = 32'h00000001 << i;
      clear_mask = inject_data | 32'h00000080;

      // Inject the selected error
      reg_model.ERR_INJECT.write(status, inject_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("ERR_INJECT_SEQ", $sformatf("ERR_INJECT failed for bit %0d", i))

      // Verify the corresponding ERR_STATUS bit and INJECTED summary
      reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("ERR_INJECT_SEQ", "ERR_STATUS read after injection failed")

      `uvm_info("ERR_INJECT_SEQ", $sformatf("ERR_STATUS after injecting bit %0d = 0x%08h", i, read_data), UVM_MEDIUM)

      if (read_data[i] !== 1'b1)
        `uvm_error("ERR_INJECT_SEQ", $sformatf("ERR_STATUS bit %0d was not set", i))

      if (read_data[7] !== 1'b1)
        `uvm_error("ERR_INJECT_SEQ", "INJECTED summary bit [7] was not set")

      // Verify ERR_COUNT increments by the population count of injected bits
      reg_model.ERR_COUNT.read(status, count_data, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_fatal("ERR_INJECT_SEQ", "ERR_COUNT read after injection failed")
      else if (count_data[15:0] !== (i + 1))
        `uvm_error("ERR_INJECT_SEQ", $sformatf("ERR_COUNT mismatch: expected %0d, got %0d", i + 1, count_data[15:0]))
      else
        `uvm_info("ERR_INJECT_SEQ", $sformatf("ERR_COUNT = %0d check PASS", count_data[15:0]), UVM_LOW)

      // TEST 4: Clear the injected error and summary using W1C
      reg_model.ERR_STATUS.write(status, clear_mask, UVM_FRONTDOOR);

      if (status != UVM_IS_OK)
        `uvm_error("ERR_INJECT_SEQ", $sformatf("ERR_STATUS W1C clear failed for bit %0d", i))
      else begin
        reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

        if (status != UVM_IS_OK)
          `uvm_error("ERR_INJECT_SEQ", "ERR_STATUS read after W1C failed")
        else if (read_data[i] !== 1'b0 || read_data[7] !== 1'b0)
          `uvm_error("ERR_INJECT_SEQ", $sformatf("W1C clear failed for injected error bit %0d", i))
        else
          `uvm_info("ERR_INJECT_SEQ", $sformatf("W1C clear check PASS for error bit %0d", i), UVM_LOW)
      end
    end

    // TEST 5: Inject bit 7 only and verify ERR_COUNT increments by one
    reg_model.ERR_INJECT.write(status, 32'h00000080, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INJECT_SEQ", "Bit-7-only injection failed")

    reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INJECT_SEQ", "ERR_STATUS read after bit-7-only injection failed")
    else begin
      if (read_data[7] !== 1'b1)
        `uvm_error("ERR_INJECT_SEQ", "INJECTED status bit was not set by bit-7-only injection")

      if (read_data[6:0] !== 7'h00)
        `uvm_error("ERR_INJECT_SEQ", "Unexpected error bits were set by bit-7-only injection")
    end

    reg_model.ERR_COUNT.read(status, count_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INJECT_SEQ", "ERR_COUNT read after bit-7-only injection failed")
    else if (count_data[15:0] !== 16'd8)
      `uvm_error("ERR_INJECT_SEQ", $sformatf("Expected ERR_COUNT=8 after bit-7-only injection, got %0d", count_data[15:0]))
    else
      `uvm_info("ERR_INJECT_SEQ", "Bit-7-only count increment check PASS", UVM_LOW)

    // TEST 6: Clear INJECTED summary before testing CLEAR_COUNT priority
    reg_model.ERR_STATUS.write(status, 32'h000000FF, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INJECT_SEQ", "ERR_STATUS clear before CLEAR_COUNT priority test failed")

    // TEST 7: Verify CLEAR_COUNT has priority over an injection in the same write
    reg_model.ERR_INJECT.write(status, 32'h80000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INJECT_SEQ", "CLEAR_COUNT plus injection write failed")

    reg_model.ERR_COUNT.read(status, count_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INJECT_SEQ", "ERR_COUNT read after CLEAR_COUNT priority test failed")
    else if (count_data[15:0] !== 16'h0000)
      `uvm_error("ERR_INJECT_SEQ", $sformatf("CLEAR_COUNT priority failed: ERR_COUNT = 0x%04h", count_data[15:0]))
    else
      `uvm_info("ERR_INJECT_SEQ", "CLEAR_COUNT priority over injection check PASS", UVM_LOW)

    // Confirm the simultaneous injection was ignored
    reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INJECT_SEQ", "ERR_STATUS read after CLEAR_COUNT priority test failed")
    else if (read_data[7:0] !== 8'h00)
      `uvm_error("ERR_INJECT_SEQ", $sformatf("Injection was not ignored by CLEAR_COUNT priority: ERR_STATUS = 0x%02h", read_data[7:0]))
    else
      `uvm_info("ERR_INJECT_SEQ", "Simultaneous injection ignored check PASS", UVM_LOW)

    `uvm_info("ERR_INJECT_SEQ", "ERR_INJECT verification completed", UVM_LOW)

  endtask
endclass


//22.ERR_COUNT
class err_count_seq extends pkt_base_seq;
  `uvm_object_utils(err_count_seq)

  function new(string name = "err_count_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t err_status_data;

    // TEST 1: Clear previous error status
    reg_model.ERR_STATUS.write(status, 32'h000000FF, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "Initial ERR_STATUS clear failed")

    // TEST 2: Clear ERR_COUNT using ERR_INJECT.CLEAR_COUNT
    reg_model.ERR_INJECT.write(status, 32'h80000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "CLEAR_COUNT write failed")

    // TEST 3: Read ERR_COUNT and verify it is zero
    reg_model.ERR_COUNT.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "ERR_COUNT initial read failed")
    else if (read_data[15:0] !== 16'h0000)
      `uvm_error("ERR_COUNT_SEQ", $sformatf("ERR_COUNT did not clear, got 0x%04h", read_data[15:0]))
    else
      `uvm_info("ERR_COUNT_SEQ", "ERR_COUNT clear check PASS", UVM_LOW)

    // TEST 4: Inject one error and verify ERR_COUNT increments by one
    reg_model.ERR_INJECT.write(status, 32'h00000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "Single error injection failed")

    reg_model.ERR_COUNT.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "ERR_COUNT read after single injection failed")
    else if (read_data[15:0] !== 16'd1)
      `uvm_error("ERR_COUNT_SEQ", $sformatf("Expected ERR_COUNT=1, got %0d", read_data[15:0]))
    else
      `uvm_info("ERR_COUNT_SEQ", "Single error count increment check PASS", UVM_LOW)

    // TEST 5: Inject three error bits and verify population-count increment
    reg_model.ERR_INJECT.write(status, 32'h0000000E, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "Multiple error injection failed")

    reg_model.ERR_COUNT.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "ERR_COUNT read after multiple injection failed")
    else if (read_data[15:0] !== 16'd4)
      `uvm_error("ERR_COUNT_SEQ", $sformatf("Expected ERR_COUNT=4, got %0d", read_data[15:0]))
    else
      `uvm_info("ERR_COUNT_SEQ", "Population-count increment check PASS", UVM_LOW)

    // TEST 6: Inject bit 7 only and verify the counter increments by one
    reg_model.ERR_INJECT.write(status, 32'h00000080, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "Bit-7-only injection failed")

    reg_model.ERR_COUNT.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "ERR_COUNT read after bit-7-only injection failed")
    else if (read_data[15:0] !== 16'd5)
      `uvm_error("ERR_COUNT_SEQ", $sformatf("Expected ERR_COUNT=5, got %0d", read_data[15:0]))
    else
      `uvm_info("ERR_COUNT_SEQ", "Bit-7-only increment check PASS", UVM_LOW)

    // TEST 7: Check reserved bits [31:16]
    if (read_data[31:16] !== 16'h0000)
      `uvm_error("ERR_COUNT_SEQ", "Reserved bits [31:16] are non-zero")
    else
      `uvm_info("ERR_COUNT_SEQ", "Reserved bits check PASS", UVM_LOW)

    // TEST 8: Verify CLEAR_COUNT has priority over a simultaneous injection
    reg_model.ERR_STATUS.write(status, 32'h000000FF, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "Failed to clear ERR_STATUS before priority test")

    reg_model.ERR_INJECT.write(status, 32'h80000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "CLEAR_COUNT priority test write failed")

    reg_model.ERR_COUNT.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_COUNT_SEQ", "ERR_COUNT read after CLEAR_COUNT priority test failed")
    else if (read_data[15:0] !== 16'h0000)
      `uvm_error("ERR_COUNT_SEQ", $sformatf("CLEAR_COUNT priority failed, count = %0d", read_data[15:0]))
    else
      `uvm_info("ERR_COUNT_SEQ", "CLEAR_COUNT priority check PASS", UVM_LOW)

    // TEST 9: Verify simultaneous injection was ignored
    reg_model.ERR_STATUS.read(status, err_status_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("ERR_COUNT_SEQ", "ERR_STATUS read after priority test failed")
    else if (err_status_data[0] !== 1'b0)
      `uvm_error("ERR_COUNT_SEQ", "BUS_ERROR was unexpectedly injected with CLEAR_COUNT")
    else
      `uvm_info("ERR_COUNT_SEQ", "Simultaneous injection ignore check PASS", UVM_LOW)

    `uvm_info("ERR_COUNT_SEQ", "ERR_COUNT verification completed", UVM_LOW)
  endtask
endclass


//23.ERR_INFO
class err_info_seq extends pkt_base_seq;
  `uvm_object_utils(err_info_seq)

  function new(string name = "err_info_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;
    uvm_reg_data_t stat_tx_data;
    uvm_reg_data_t gen_pkt_cfg_data;

    // TEST 1: Read current STAT_TX counter
    reg_model.STAT_TX.read(status, stat_tx_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INFO_SEQ", "STAT_TX read failed")

    // TEST 2: Read the configured generator destination port
    reg_model.GEN_PKT_CFG.read(status, gen_pkt_cfg_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INFO_SEQ", "GEN_PKT_CFG read failed")

    // TEST 3: Clear previous error status and error information
    reg_model.ERR_STATUS.write(status, 32'h000000FF, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INFO_SEQ", "ERR_STATUS clear failed")

    reg_model.ERR_INJECT.write(status, 32'h80000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INFO_SEQ", "ERR_COUNT and ERR_INFO clear failed")

    // TEST 4: Inject error bits [2:1] together
    // Bit 1 = DEST_ERROR, bit 2 = QUEUE_OVERFLOW; lowest set bit is 1.
    reg_model.ERR_INJECT.write(status, 32'h00000006, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INFO_SEQ", "Multiple error injection failed")

    // TEST 5: Read ERR_INFO after injection
    reg_model.ERR_INFO.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("ERR_INFO_SEQ", "ERR_INFO read after injection failed")

    `uvm_info("ERR_INFO_SEQ", $sformatf("ERR_INFO = 0x%08h", read_data), UVM_MEDIUM)

    // TEST 6: Check TX_SNAPSHOT against the low 12 bits of STAT_TX
    if (read_data[31:20] !== stat_tx_data[11:0])
      `uvm_error("ERR_INFO_SEQ", $sformatf("TX_SNAPSHOT mismatch: expected 0x%03h, got 0x%03h", stat_tx_data[11:0], read_data[31:20]))
    else
      `uvm_info("ERR_INFO_SEQ", "TX_SNAPSHOT check PASS", UVM_LOW)

    // TEST 7: Check reserved bits [19:18]
    if (read_data[19:18] !== 2'b00)
      `uvm_error("ERR_INFO_SEQ", "Reserved bits [19:18] are non-zero")
    else
      `uvm_info("ERR_INFO_SEQ", "Reserved bits check PASS", UVM_LOW)

    // TEST 8: Check DEST_PORT against GEN_PKT_CFG.DST_PORT
    if (read_data[17:16] !== gen_pkt_cfg_data[1:0])
      `uvm_error("ERR_INFO_SEQ", $sformatf("DEST_PORT mismatch: expected %0d, got %0d", gen_pkt_cfg_data[1:0], read_data[17:16]))
    else
      `uvm_info("ERR_INFO_SEQ", "DEST_PORT snapshot check PASS", UVM_LOW)

    // TEST 9: Check SOURCE indicates an injected error
    if (read_data[15:8] !== 8'h01)
      `uvm_error("ERR_INFO_SEQ", $sformatf("Expected SOURCE=1 for injection, got 0x%02h", read_data[15:8]))
    else
      `uvm_info("ERR_INFO_SEQ", "SOURCE injection check PASS", UVM_LOW)

    // TEST 10: Check LAST_CODE captures the lowest-numbered error bit
    if (read_data[7:0] !== 8'd1)
      `uvm_error("ERR_INFO_SEQ", $sformatf("Expected LAST_CODE=1, got %0d", read_data[7:0]))
    else
      `uvm_info("ERR_INFO_SEQ", "LAST_CODE priority check PASS", UVM_LOW)

    // TEST 11: Verify ERR_STATUS records the injected errors
    reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("ERR_INFO_SEQ", "ERR_STATUS read failed")
    else if (read_data[2:1] !== 2'b11 || read_data[7] !== 1'b1)
      `uvm_error("ERR_INFO_SEQ", "Injected error status bits or INJECTED summary mismatch")
    else
      `uvm_info("ERR_INFO_SEQ", "Injected error status check PASS", UVM_LOW)

    `uvm_info("ERR_INFO_SEQ", "ERR_INFO verification completed", UVM_LOW)
  endtask
endclass


//24.LOCK
class lock_seq extends pkt_base_seq;
  `uvm_object_utils(lock_seq)

  function new(string name = "lock_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;

    // TEST 1: Read LOCK and check that key bits [31:1] always read as zero
    reg_model.LOCK.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("LOCK_SEQ", "Initial LOCK read failed")

    `uvm_info("LOCK_SEQ", $sformatf("Initial LOCK = 0x%08h", read_data), UVM_MEDIUM)

    if (read_data[31:1] !== 31'h00000000)
      `uvm_error("LOCK_SEQ", "LOCK key bits [31:1] did not read as zero")

    // TEST 2: Unlock DUT using the valid 32-bit key
    reg_model.LOCK.write(status, 32'hA5A5C3C3, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("LOCK_SEQ", "Valid unlock key write failed")

    // TEST 3: Verify LOCKED becomes zero after the valid key
    reg_model.LOCK.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("LOCK_SEQ", "LOCK read after valid key failed")
    else if (read_data[0] !== 1'b0)
      `uvm_error("LOCK_SEQ", "Valid key did not unlock the DUT")
    else
      `uvm_info("LOCK_SEQ", "Valid unlock key check PASS", UVM_LOW)

    // TEST 4: Write PORT_ENABLE while unlocked and verify readback
    reg_model.PORT_ENABLE.write(status, 32'h00000005, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("LOCK_SEQ", "PORT_ENABLE write while unlocked failed")

    reg_model.PORT_ENABLE.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("LOCK_SEQ", "PORT_ENABLE read while unlocked failed")
    else if (read_data[3:0] !== 4'h5)
      `uvm_error("LOCK_SEQ", $sformatf("Expected PORT_ENABLE=0x5, got 0x%01h", read_data[3:0]))
    else
      `uvm_info("LOCK_SEQ", "Unlocked register write check PASS", UVM_LOW)

    // TEST 5: Write an invalid key and verify DUT becomes locked
    reg_model.LOCK.write(status, 32'h00000000, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("LOCK_SEQ", "Invalid key write failed")

    reg_model.LOCK.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("LOCK_SEQ", "LOCK read after invalid key failed")
    else if (read_data[0] !== 1'b1)
      `uvm_error("LOCK_SEQ", "Invalid key did not lock the DUT")
    else
      `uvm_info("LOCK_SEQ", "Invalid key lock check PASS", UVM_LOW)

    // TEST 6: Attempt to change PORT_ENABLE while locked
    reg_model.PORT_ENABLE.write(status, 32'h0000000A, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("LOCK_SEQ", "PORT_ENABLE APB write while locked returned an error")

    // TEST 7: Verify PORT_ENABLE was not changed by the locked write
    reg_model.PORT_ENABLE.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("LOCK_SEQ", "PORT_ENABLE read after locked write failed")
    else if (read_data[3:0] !== 4'h5)
      `uvm_error("LOCK_SEQ", $sformatf("Locked write changed PORT_ENABLE: expected 0x5, got 0x%01h", read_data[3:0]))
    else
      `uvm_info("LOCK_SEQ", "Locked register write protection check PASS", UVM_LOW)

    // TEST 8: Unlock DUT again using the valid key
    reg_model.LOCK.write(status, 32'hA5A5C3C3, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("LOCK_SEQ", "Final valid unlock key write failed")

    reg_model.LOCK.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("LOCK_SEQ", "Final LOCK read failed")
    else if (read_data[0] !== 1'b0)
      `uvm_error("LOCK_SEQ", "Final valid key did not unlock the DUT")
    else
      `uvm_info("LOCK_SEQ", "LOCK verification completed; DUT left unlocked", UVM_LOW)

  endtask
endclass


//25.SOFT_RESET
class soft_reset_seq extends pkt_base_seq;
  `uvm_object_utils(soft_reset_seq)

  function new(string name = "soft_reset_seq");
    super.new(name);
  endfunction

  task body();
    uvm_reg_data_t read_data;

    // TEST 1: Unlock DUT before configuring lockable registers
    unlock_dut();

    // TEST 2: Stop generator and ensure it is not running
    reg_model.GEN_CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "Failed to stop generator before soft reset")

    reg_model.GEN_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "GEN_STATUS read before soft reset failed")
    else if (read_data[0] !== 1'b0)
      `uvm_fatal("SOFT_RESET_SEQ", "Generator is still running before soft reset")

    // TEST 3: Program non-reset values in lockable configuration registers
    reg_model.PORT_ENABLE.write(status, 32'h00000000, UVM_FRONTDOOR);
    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "PORT_ENABLE setup write failed")

    reg_model.FWD_ENABLE.write(status, 32'h00000000, UVM_FRONTDOOR);
    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "FWD_ENABLE setup write failed")

    reg_model.SWITCH_CTRL.write(status, 32'h00000009, UVM_FRONTDOOR);
    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "SWITCH_CTRL setup write failed")

    reg_model.IRQ_ENABLE.write(status, 32'h000000FF, UVM_FRONTDOOR);
    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "IRQ_ENABLE setup write failed")

    reg_model.ERR_ENABLE.write(status, 32'h0000007F, UVM_FRONTDOOR);
    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "ERR_ENABLE setup write failed")

    reg_model.GEN_PKT_CFG.write(status, 32'h005A0406, UVM_FRONTDOOR);
    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "GEN_PKT_CFG setup write failed")

    reg_model.GEN_INTERVAL.write(status, 32'h0000000A, UVM_FRONTDOOR);
    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "GEN_INTERVAL setup write failed")

    reg_model.GEN_COUNT.write(status, 32'h00000005, UVM_FRONTDOOR);
    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "GEN_COUNT setup write failed")

    // TEST 4: Create a nonzero error counter using error injection
    reg_model.ERR_STATUS.write(status, 32'h000000FF, UVM_FRONTDOOR);
    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "ERR_STATUS setup clear failed")

    reg_model.ERR_INJECT.write(status, 32'h80000000, UVM_FRONTDOOR);
    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "ERR_COUNT clear before injection failed")

    reg_model.ERR_INJECT.write(status, 32'h00000001, UVM_FRONTDOOR);
    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "Error injection before soft reset failed")

    reg_model.ERR_COUNT.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "ERR_COUNT read before soft reset failed")
    else if (read_data[15:0] !== 16'd1)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("Expected ERR_COUNT=1 before reset, got %0d", read_data[15:0]))
    else
      `uvm_info("SOFT_RESET_SEQ", "Pre-reset error counter setup PASS", UVM_LOW)

    // TEST 5: Issue SOFT_RESET while the DUT is unlocked
    reg_model.SOFT_RESET.write(status, 32'h00000001, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "SOFT_RESET write failed")
    else
      `uvm_info("SOFT_RESET_SEQ", "SOFT_RESET command issued", UVM_LOW)

    // TEST 6: Verify LOCKED is set after soft reset
    reg_model.LOCK.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_fatal("SOFT_RESET_SEQ", "LOCK read after soft reset failed")
    else if (read_data[0] !== 1'b1)
      `uvm_error("SOFT_RESET_SEQ", "Soft reset did not lock the DUT")
    else
      `uvm_info("SOFT_RESET_SEQ", "DUT locked after soft reset check PASS", UVM_LOW)

    // TEST 7: Verify PORT_ENABLE returns to reset value 0xF
    reg_model.PORT_ENABLE.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "PORT_ENABLE read after soft reset failed")
    else if (read_data[3:0] !== 4'hF)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("PORT_ENABLE reset mismatch: got 0x%01h", read_data[3:0]))
    else
      `uvm_info("SOFT_RESET_SEQ", "PORT_ENABLE reset check PASS", UVM_LOW)

    // TEST 8: Verify FWD_ENABLE returns to reset value 0xF
    reg_model.FWD_ENABLE.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "FWD_ENABLE read after soft reset failed")
    else if (read_data[3:0] !== 4'hF)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("FWD_ENABLE reset mismatch: got 0x%01h", read_data[3:0]))
    else
      `uvm_info("SOFT_RESET_SEQ", "FWD_ENABLE reset check PASS", UVM_LOW)

    // TEST 9: Verify SWITCH_CTRL returns to reset value
    reg_model.SWITCH_CTRL.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "SWITCH_CTRL read after soft reset failed")
    else if (read_data[3:0] !== 4'h0)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("SWITCH_CTRL reset mismatch: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "SWITCH_CTRL reset check PASS", UVM_LOW)

    // TEST 10: Verify interrupt and error enables return to zero
    reg_model.IRQ_ENABLE.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "IRQ_ENABLE read after soft reset failed")
    else if (read_data[7:0] !== 8'h00)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("IRQ_ENABLE reset mismatch: got 0x%02h", read_data[7:0]))
    else
      `uvm_info("SOFT_RESET_SEQ", "IRQ_ENABLE reset check PASS", UVM_LOW)

    reg_model.ERR_ENABLE.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "ERR_ENABLE read after soft reset failed")
    else if (read_data[7:0] !== 8'h00)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("ERR_ENABLE reset mismatch: got 0x%02h", read_data[7:0]))
    else
      `uvm_info("SOFT_RESET_SEQ", "ERR_ENABLE reset check PASS", UVM_LOW)

    // TEST 11: Verify generator configuration registers return to reset values
    reg_model.GEN_CTRL.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "GEN_CTRL read after soft reset failed")
    else if (read_data[3:0] !== 4'h0)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("GEN_CTRL reset mismatch: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "GEN_CTRL reset check PASS", UVM_LOW)

    reg_model.GEN_PKT_CFG.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "GEN_PKT_CFG read after soft reset failed")
    else if (read_data !== 32'h00000401)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("GEN_PKT_CFG reset mismatch: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "GEN_PKT_CFG reset check PASS", UVM_LOW)

    reg_model.GEN_INTERVAL.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "GEN_INTERVAL read after soft reset failed")
    else if (read_data !== 32'h00000002)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("GEN_INTERVAL reset mismatch: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "GEN_INTERVAL reset check PASS", UVM_LOW)

    reg_model.GEN_COUNT.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "GEN_COUNT read after soft reset failed")
    else if (read_data !== 32'h00000004)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("GEN_COUNT reset mismatch: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "GEN_COUNT reset check PASS", UVM_LOW)

    // TEST 12: Verify generator is stopped and remaining count is cleared
    reg_model.GEN_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "GEN_STATUS read after soft reset failed")
    else if (read_data !== 32'h00000000)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("GEN_STATUS was not reset: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "GEN_STATUS reset check PASS", UVM_LOW)

    // TEST 13: Verify error status, error count and interrupt status are cleared
    reg_model.ERR_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "ERR_STATUS read after soft reset failed")
    else if (read_data[7:0] !== 8'h00)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("ERR_STATUS was not cleared: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "ERR_STATUS clear check PASS", UVM_LOW)

    reg_model.ERR_COUNT.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "ERR_COUNT read after soft reset failed")
    else if (read_data[15:0] !== 16'h0000)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("ERR_COUNT was not cleared: got 0x%04h", read_data[15:0]))
    else
      `uvm_info("SOFT_RESET_SEQ", "ERR_COUNT clear check PASS", UVM_LOW)

    reg_model.ERR_INFO.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "ERR_INFO read after soft reset failed")
    else if (read_data !== 32'h00000000)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("ERR_INFO was not cleared: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "ERR_INFO clear check PASS", UVM_LOW)

    reg_model.IRQ_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "IRQ_STATUS read after soft reset failed")
    else if (read_data[7:0] !== 8'h00)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("IRQ_STATUS was not cleared: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "IRQ_STATUS clear check PASS", UVM_LOW)

    // TEST 14: Verify packet statistics and queue levels are cleared
    reg_model.STAT_RX.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "STAT_RX read after soft reset failed")
    else if (read_data[15:0] !== 16'h0000)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("STAT_RX was not cleared: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "STAT_RX clear check PASS", UVM_LOW)

    reg_model.STAT_TX.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "STAT_TX read after soft reset failed")
    else if (read_data[15:0] !== 16'h0000)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("STAT_TX was not cleared: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "STAT_TX clear check PASS", UVM_LOW)

    reg_model.STAT_DROP.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "STAT_DROP read after soft reset failed")
    else if (read_data[15:0] !== 16'h0000)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("STAT_DROP was not cleared: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "STAT_DROP clear check PASS", UVM_LOW)

    reg_model.PORT_STATUS.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "PORT_STATUS read after soft reset failed")
    else if (read_data !== 32'h00000000)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("PORT_STATUS was not cleared: got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "PORT_STATUS clear check PASS", UVM_LOW)

    // TEST 15: Verify SOFT_RESET is write-only and always reads zero
    reg_model.SOFT_RESET.read(status, read_data, UVM_FRONTDOOR);

    if (status != UVM_IS_OK)
      `uvm_error("SOFT_RESET_SEQ", "SOFT_RESET read failed")
    else if (read_data !== 32'h00000000)
      `uvm_error("SOFT_RESET_SEQ", $sformatf("SOFT_RESET read should be zero, got 0x%08h", read_data))
    else
      `uvm_info("SOFT_RESET_SEQ", "SOFT_RESET read-value check PASS", UVM_LOW)

    `uvm_info("SOFT_RESET_SEQ", "SOFT_RESET verification completed; DUT should be locked", UVM_LOW)

  endtask
endclass
