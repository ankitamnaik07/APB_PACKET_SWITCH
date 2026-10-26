class pkt_base_seq extends uvm_reg_sequence;
  `uvm_object_utils(pkt_base_seq)

  pkt_reg_block  rm;
  apb_sequencer  apb_sqr;
  virtual apb_if vif;
  uvm_status_e   status;

  localparam bit [31:0] KEY = 32'hA5A5_C3C3;

  // lockable registers with their side-effect-free write masks / RW bit masks
  uvm_reg        lk_regs[$];
  bit [31:0]     lk_safe[$];      // pattern bits that may be written without triggering pulses
  bit [31:0]     lk_rwmask[$];    // bits that really store data

  function new(string name = "pkt_base_seq");
    super.new(name);
  endfunction

  // ---- setup -----------------------------------------------------------------
  protected function void init();
    if (!$cast(rm, model)) `uvm_fatal(get_type_name(), "model is not a pkt_reg_block")
    if (apb_sqr == null)   `uvm_fatal(get_type_name(), "apb_sqr not set")
    lk_regs   = '{rm.SWITCH_CTRL, rm.PORT_ENABLE, rm.FWD_ENABLE, rm.GEN_CTRL, rm.GEN_PKT_CFG,
                 rm.GEN_INTERVAL, rm.GEN_COUNT, rm.IRQ_ENABLE, rm.ERR_ENABLE};
    lk_safe   = '{~32'h2, 32'hFFFF_FFFF, 32'hFFFF_FFFF, ~32'h6, 32'hFFFF_FFFF,
                 32'hFFFF_FFFF, 32'hFFFF_FFFF, 32'hFFFF_FFFF, 32'hFFFF_FFFF};
    lk_rwmask = '{32'h0000_0009, 32'h0000_000F, 32'h0000_000F, 32'h0000_0009, 32'h00FF_FF0F,
                 32'h0000_FFFF, 32'h0000_FFFF, 32'h0000_00FF, 32'h0000_00FF};
  endfunction

  // value a lockable register must hold after writing 'd' while unlocked (spec 5.x)
  protected function bit [31:0] exp_after_write(int idx, bit [31:0] d);
    bit [31:0] e = d & lk_rwmask[idx];
    if (lk_regs[idx] == rm.GEN_PKT_CFG && e[15:8] == 8'h00) e[8] = 1'b1;   // LENGTH 0 -> 1
    return e;
  endfunction

  // ---- RAL helpers -------------------------------------------------------------
  task wr(uvm_reg r, uvm_reg_data_t v);
    r.write(status, v, UVM_FRONTDOOR, .parent(this));
    if (status != UVM_IS_OK)
      `uvm_error(get_type_name(), $sformatf("write %s status=%s", r.get_name(), status.name()))
  endtask

  task rd(uvm_reg r, output uvm_reg_data_t v);
    r.read(status, v, UVM_FRONTDOOR, .parent(this));
    if (status != UVM_IS_OK)
      `uvm_error(get_type_name(), $sformatf("read %s status=%s", r.get_name(), status.name()))
  endtask

  function void chk(string what, uvm_reg_data_t got, uvm_reg_data_t exp, uvm_reg_data_t mask = '1);
    if (((got ^ exp) & mask) !== 0)
      `uvm_error(get_type_name(), $sformatf("%s: got 0x%08h expected 0x%08h (mask 0x%08h)", what, got, exp, mask))
    else
      `uvm_info(get_type_name(), $sformatf("%s: OK (0x%08h)", what, got), UVM_HIGH)
  endfunction

  // rd + expected-value check in one call
  task rd_chk(uvm_reg r, uvm_reg_data_t exp, uvm_reg_data_t mask = '1, string tag = "");
    uvm_reg_data_t v;
    rd(r, v);
    chk({r.get_name(), tag}, v, exp, mask);
  endtask

  // ---- raw APB helpers ---------------------------------------------------------
  task raw(bit [15:0] a, bit w, bit [31:0] d, output bit [31:0] rdata, output bit err);
    apb_base_seq s = apb_base_seq::type_id::create("raw");
    s.addr = a; s.write = w; s.data = d;
    s.start(apb_sqr, this);
    rdata = s.rdata;
    err   = s.slverr;
  endtask

  task raw_wr(bit [15:0] a, bit [31:0] d, bit exp_err = 0);
    bit [31:0] r; bit e;
    raw(a, 1'b1, d, r, e);
    if (e !== exp_err) `uvm_error(get_type_name(), $sformatf("raw write 0x%04h PSLVERR=%0b expected %0b", a, e, exp_err))
  endtask

  task raw_rd(bit [15:0] a, output bit [31:0] r, input bit exp_err = 0);
    bit e;
    raw(a, 1'b0, 32'h0, r, e);
    if (e !== exp_err) `uvm_error(get_type_name(), $sformatf("raw read 0x%04h PSLVERR=%0b expected %0b", a, e, exp_err))
  endtask

  // ---- misc -------------------------------------------------------------------
  task unlock();  wr(rm.LOCK, KEY);  endtask
  task relock();  wr(rm.LOCK, 32'h0); endtask
  task soft_reset(); wr(rm.SOFT_RESET, 32'h1); endtask

  task clks(int n);
    repeat (n) @(vif.mon_cb);
  endtask

  // irq is a level output of the CSR bank: allow a few cycles for status -> irq
  task expect_irq(bit exp, string tag = "");
    clks(4);
    if (vif.mon_cb.irq !== exp)
      `uvm_error(get_type_name(), $sformatf("irq=%0b expected %0b %s", vif.mon_cb.irq, exp, tag))
  endtask

  // read every register once: values are compared against the mirror by the predictor
  task read_all_regs();
    uvm_reg regs[$];
    uvm_reg_data_t v;
    rm.get_registers(regs);
    foreach (regs[i]) rd(regs[i], v);
  endtask
endclass

// ============================================================================
// 1. Reset values: every register vs. the spec reset value (volatile fields included)
// ============================================================================
class pkt_reset_value_seq extends pkt_base_seq;
  `uvm_object_utils(pkt_reset_value_seq)
  bit skip_sticky = 0;   // set when the DUT keeps IRQ/ERR sticky bits over SOFT_RESET
  function new(string name = "pkt_reset_value_seq"); super.new(name); endfunction

  virtual task body();
    uvm_reg regs[$];
    uvm_reg_data_t v;
    init();
    rm.get_registers(regs);
    foreach (regs[i]) begin
      if (skip_sticky && (regs[i] == rm.IRQ_STATUS || regs[i] == rm.ERR_STATUS ||
                          regs[i] == rm.ERR_COUNT)) continue;
      rd(regs[i], v);
      chk($sformatf("%s reset value", regs[i].get_name()), v, regs[i].get_reset());
    end
    // spec 5.1 / 5.2 / 5.3 explicit constants
    rd_chk(rm.DEVICE_ID,     32'h02A5_5357);
    rd_chk(rm.VERSION,       32'h0001_0200);
    rd_chk(rm.SWITCH_STATUS, 32'h0000_00F9);
    rd_chk(rm.LOCK,          32'h0000_0001);
  endtask
endclass

// ============================================================================
// 2. Dirty the programmable state (used before reset tests)
// ============================================================================
class pkt_dirty_seq extends pkt_base_seq;
  `uvm_object_utils(pkt_dirty_seq)
  function new(string name = "pkt_dirty_seq"); super.new(name); endfunction
  virtual task body();
    init();
    unlock();
    wr(rm.SWITCH_CTRL,   32'h9);
    wr(rm.PORT_ENABLE,   32'h5);
    wr(rm.FWD_ENABLE,    32'hA);
    wr(rm.GEN_CTRL,      32'h8);
    wr(rm.GEN_PKT_CFG,   32'h00AB_0A0E);
    wr(rm.GEN_INTERVAL,  32'h1234);
    wr(rm.GEN_COUNT,     32'h0042);
    wr(rm.IRQ_ENABLE,    32'hA5);
    wr(rm.ERR_ENABLE,    32'h5A);
    wr(rm.IRQ_FORCE,     32'h81);
    wr(rm.ERR_INJECT,    32'h0000_0006);
    read_all_regs();
  endtask
endclass

// ============================================================================
// 3. Lock / unlock behaviour (spec 3.6, 5.24)
// ============================================================================
class pkt_lock_seq extends pkt_base_seq;
  `uvm_object_utils(pkt_lock_seq)
  function new(string name = "pkt_lock_seq"); super.new(name); endfunction

  virtual task body();
    uvm_reg_data_t v;
    init();
    soft_reset();                                    // known state: relocked, defaults
    // --- power-up / reset state: locked --------------------------------------
    rd_chk(rm.LOCK, 32'h1);
    rd_chk(rm.SWITCH_STATUS, 32'h8, 32'h8, ".LOCKED");
    // --- lockable registers ignore writes while locked -----------------------
    foreach (lk_regs[i]) begin
      wr(lk_regs[i], lk_safe[i]);
      rd_chk(lk_regs[i], lk_regs[i].get_reset(), '1, " (write while locked)");
      wr(lk_regs[i], 32'h0);
      rd_chk(lk_regs[i], lk_regs[i].get_reset(), '1, " (write 0 while locked)");
    end
    // --- W1C / WO diagnostic registers stay accessible while locked ----------
    wr(rm.IRQ_FORCE, 32'h80);
    rd_chk(rm.IRQ_STATUS, 32'h80, 32'hFF, " (IRQ_FORCE while locked)");
    wr(rm.IRQ_STATUS, 32'h80);
    rd_chk(rm.IRQ_STATUS, 32'h00, 32'hFF, " (W1C while locked)");
    wr(rm.ERR_INJECT, 32'h80);
    rd_chk(rm.ERR_STATUS, 32'h80, 32'hFF, " (ERR_INJECT while locked)");
    rd_chk(rm.ERR_COUNT, 32'h1);
    wr(rm.ERR_STATUS, 32'hFF);
    wr(rm.ERR_INJECT, 32'h8000_0000);                // CLEAR_COUNT
    rd_chk(rm.ERR_COUNT, 32'h0);
    rd_chk(rm.ERR_STATUS, 32'h0, 32'hFF);
    // --- unlock with the key ---------------------------------------------------
    unlock();
    rd_chk(rm.LOCK, 32'h0);                          // bit0 = LOCKED = 0, key never read back
    rd_chk(rm.SWITCH_STATUS, 32'h0, 32'h8, ".LOCKED");
    foreach (lk_regs[i]) begin
      wr(lk_regs[i], lk_safe[i]);
      rd_chk(lk_regs[i], exp_after_write(i, lk_safe[i]), '1, " (write while unlocked)");
    end
    // --- any other value locks again ---------------------------------------------
    foreach (lk_regs[i]) begin
      wr(lk_regs[i], 32'h0);                         // clean slate (unlocked)
    end
    rd_chk(rm.PORT_ENABLE, 32'h0);
    wr(rm.PORT_ENABLE, 32'h6);
    rd_chk(rm.PORT_ENABLE, 32'h6);
    relock();                                        // key = 0
    rd_chk(rm.LOCK, 32'h1);
    wr(rm.PORT_ENABLE, 32'hF);
    rd_chk(rm.PORT_ENABLE, 32'h6, '1, " (ignored after relock)");
    // --- every single-bit flip of the key must NOT unlock ---------------------------
    for (int b = 0; b < 32; b++) begin
      unlock();
      rd_chk(rm.LOCK, 32'h0);
      wr(rm.LOCK, KEY ^ (32'h1 << b));
      rd_chk(rm.LOCK, 32'h1, '1, $sformatf(" (key^bit%0d)", b));
      wr(rm.PORT_ENABLE, 32'h3);
      rd_chk(rm.PORT_ENABLE, 32'h6, '1, $sformatf(" (locked by key^bit%0d)", b));
    end
    // --- unlock, then a non-key write that only has bit0 set / all ones ------------
    unlock();
    wr(rm.LOCK, 32'hFFFF_FFFF);
    rd_chk(rm.LOCK, 32'h1);
    unlock();
    wr(rm.LOCK, 32'h0000_0000);
    rd_chk(rm.LOCK, 32'h1);
    // --- SOFT_RESET relocks and restores defaults ----------------------------------
    unlock();
    wr(rm.PORT_ENABLE, 32'h2);
    soft_reset();
    rd_chk(rm.LOCK, 32'h1);
    rd_chk(rm.PORT_ENABLE, 32'hF);
    // --- SOFT_RESET works while locked (also exercised above) ---------------------
    soft_reset();
    rd_chk(rm.LOCK, 32'h1);
  endtask
endclass

// ============================================================================
// 4. RW registers: walking / pattern / random data incl. reserved bits (RAZ/WI)
// ============================================================================
class pkt_rw_seq extends pkt_base_seq;
  `uvm_object_utils(pkt_rw_seq)
  int unsigned n_random = 20;
  function new(string name = "pkt_rw_seq"); super.new(name); endfunction

  protected task one(int i, bit [31:0] d);
    bit [31:0] w = d & lk_safe[i];
    wr(lk_regs[i], w);
    rd_chk(lk_regs[i], exp_after_write(i, w), '1, $sformatf(" <- 0x%08h", w));
  endtask

  virtual task body();
    init();
    soft_reset();
    unlock();
    foreach (lk_regs[i]) begin
      one(i, 32'hFFFF_FFFF);
      one(i, 32'h0000_0000);
      one(i, 32'hAAAA_AAAA);
      one(i, 32'h5555_5555);
      for (int b = 0; b < 32; b++) begin one(i, 32'h1 << b); one(i, ~(32'h1 << b)); end
      repeat (n_random) one(i, $urandom());
      one(i, 32'h0);
    end
    // GEN_PKT_CFG.LENGTH special cases (spec 5.13)
    wr(rm.GEN_PKT_CFG, 32'h0000_0000);               // LENGTH 0 is stored as 1
    rd_chk(rm.GEN_PKT_CFG, 32'h0000_0100);
    wr(rm.GEN_PKT_CFG, 32'h0000_1100);               // 17 beats stays readable (clamped by the generator)
    rd_chk(rm.GEN_PKT_CFG, 32'h0000_1100);
    wr(rm.GEN_PKT_CFG, 32'h0000_FF00);
    rd_chk(rm.GEN_PKT_CFG, 32'h0000_FF00);
    // GEN_COUNT 0 stays readable as 0 (interpreted as 1 only at START)
    wr(rm.GEN_COUNT, 32'h0);
    rd_chk(rm.GEN_COUNT, 32'h0);
    soft_reset();
  endtask
endclass

// ============================================================================
// 5. RO registers ignore writes, WO registers read 0, pulse bits read 0
// ============================================================================
class pkt_ro_wo_seq extends pkt_base_seq;
  `uvm_object_utils(pkt_ro_wo_seq)
  function new(string name = "pkt_ro_wo_seq"); super.new(name); endfunction

  virtual task body();
    uvm_reg ro_regs[$];
    bit [31:0] r;
    init();
    soft_reset();
    ro_regs = '{rm.DEVICE_ID, rm.VERSION, rm.SWITCH_STATUS, rm.PORT_STATUS, rm.GEN_STATUS,
               rm.STAT_RX, rm.STAT_TX, rm.STAT_DROP, rm.ERR_COUNT, rm.ERR_INFO};
    // writes to RO registers are legal (no PSLVERR) and ignored
    foreach (ro_regs[i]) begin
      raw_wr(ro_regs[i].get_address(), 32'hFFFF_FFFF);
      raw_wr(ro_regs[i].get_address(), 32'h0000_0000);
      raw_wr(ro_regs[i].get_address(), 32'hA5A5_A5A5);
      rd_chk(ro_regs[i], ro_regs[i].get_reset(), '1, " (after write to RO)");
    end
    rd_chk(rm.DEVICE_ID, 32'h02A5_5357);
    rd_chk(rm.DEVICE_ID, 32'h0000_5357, 32'hFFFF, ".PRODUCT_ID ('SW')");
    rd_chk(rm.VERSION,   32'h0001_0200);
    // WO registers read back 0
    unlock();
    wr(rm.IRQ_FORCE, 32'h0000_00FF);   rd_chk(rm.IRQ_FORCE, 32'h0);
    wr(rm.IRQ_STATUS, 32'h0000_00FF);
    wr(rm.ERR_INJECT, 32'h0000_007F);  rd_chk(rm.ERR_INJECT, 32'h0);
    wr(rm.ERR_STATUS, 32'h0000_00FF);
    wr(rm.ERR_INJECT, 32'h8000_0000);
    wr(rm.SOFT_RESET, 32'h0);          rd_chk(rm.SOFT_RESET, 32'h0);
    // reserved/WI bits of the WO registers do nothing
    wr(rm.IRQ_FORCE,  32'hFFFF_FF00);  rd_chk(rm.IRQ_STATUS, 32'h0, 32'hFF, " (IRQ_FORCE reserved)");
    wr(rm.ERR_INJECT, 32'h7FFF_FF00);  rd_chk(rm.ERR_STATUS, 32'h0, 32'hFF, " (ERR_INJECT reserved)");
    rd_chk(rm.ERR_COUNT, 32'h0);
    // SOFT_RESET: writing 0 / reserved bits has no effect, LOCK stays unlocked
    wr(rm.SOFT_RESET, 32'hFFFF_FFFE);
    rd_chk(rm.LOCK, 32'h0, '1, " (SOFT_RESET[0]=0)");
    // pulse bits read back 0 / stored value excludes the pulse (spec 5.9, 5.12)
    wr(rm.SWITCH_CTRL, 32'h0000_000B); rd_chk(rm.SWITCH_CTRL, 32'h0000_0009);
    wr(rm.SWITCH_CTRL, 32'h0);
    wr(rm.GEN_CTRL,    32'h0000_0006); rd_chk(rm.GEN_CTRL, 32'h0);      // STOP|START, ENABLE=0: no run
    wr(rm.GEN_CTRL,    32'h0000_000E); rd_chk(rm.GEN_CTRL, 32'h8);
    wr(rm.GEN_CTRL,    32'h0000_000C); rd_chk(rm.GEN_CTRL, 32'h8);
    wr(rm.GEN_CTRL,    32'h0);
    rd_chk(rm.GEN_STATUS, 32'h0, 32'h3, " (no run started)");
    soft_reset();
  endtask
endclass

// ============================================================================
// 6. IRQ_STATUS / IRQ_FORCE / IRQ_ENABLE / irq pin, ERR_* diagnostics (spec 5.16 - 5.23)
// ============================================================================
class pkt_irq_err_seq extends pkt_base_seq;
  `uvm_object_utils(pkt_irq_err_seq)
  bit run_saturation = 0;     // 9363 injections: ERR_COUNT saturation at 0xFFFF
  function new(string name = "pkt_irq_err_seq"); super.new(name); endfunction

  protected function bit [7:0] exp_last_code(bit [7:0] inj);
    for (int i = 0; i < 7; i++) if (inj[i]) return i;
    return 8'd7;                                    // INJECTED-only
  endfunction

  protected task inject_and_check(bit [7:0] inj);
    uvm_reg_data_t tx, cfg, v;
    bit [7:0] exp_st, n;
    wr(rm.ERR_STATUS, 32'hFF);
    wr(rm.ERR_INJECT, 32'h8000_0000);
    rd(rm.STAT_TX, tx);
    rd(rm.GEN_PKT_CFG, cfg);
    wr(rm.ERR_INJECT, {24'h0, inj});
    exp_st = {1'b1, inj[6:0]};
    n = $countones(inj[6:0]); if (n == 0) n = 1;
    rd_chk(rm.ERR_STATUS, exp_st, 32'hFF, $sformatf(" (inject 0x%02h)", inj));
    rd_chk(rm.ERR_COUNT, n, '1, $sformatf(" (inject 0x%02h)", inj));
    rd_chk(rm.ERR_INFO, {tx[11:0], 2'b00, cfg[1:0], 8'h01, exp_last_code(inj)}, '1,
           $sformatf(" (inject 0x%02h)", inj));
    rd_chk(rm.SWITCH_STATUS, 32'h200, 32'h200, ".ERR_PENDING");
  endtask

  virtual task body();
    uvm_reg_data_t v;
    bit [7:0] en_list[$] = '{8'h00, 8'h01, 8'h80, 8'hFF, 8'h7F, 8'h42};
    bit [7:0] f_list [$] = '{8'h00, 8'h01, 8'h80, 8'h40, 8'hFF, 8'h22};
    init();
    soft_reset();
    unlock();

    // ---------------- IRQ_FORCE -> IRQ_STATUS -> W1C ---------------------------------
    for (int b = 0; b < 8; b++) begin
      wr(rm.IRQ_FORCE, 32'h1 << b);
      rd_chk(rm.IRQ_STATUS, 32'h1 << b, 32'hFF, $sformatf(" (force bit%0d)", b));
      wr(rm.IRQ_STATUS, 32'h0);                                      // writing 0 leaves it
      rd_chk(rm.IRQ_STATUS, 32'h1 << b, 32'hFF, " (W1C with 0)");
      wr(rm.IRQ_STATUS, ~(32'h1 << b) & 32'hFF);                     // other bits: unchanged
      rd_chk(rm.IRQ_STATUS, 32'h1 << b, 32'hFF, " (W1C other bits)");
      wr(rm.IRQ_STATUS, 32'h1 << b);
      rd_chk(rm.IRQ_STATUS, 32'h0, 32'hFF, " (W1C cleared)");
    end
    wr(rm.IRQ_FORCE, 32'hFF);
    wr(rm.IRQ_STATUS, 32'h0000_0041);                                // spec 6.2 example
    rd_chk(rm.IRQ_STATUS, 32'hBE, 32'hFF, " (spec 6.2 example)");
    wr(rm.IRQ_STATUS, 32'hFFFF_FF00);                                // reserved bits: no effect
    rd_chk(rm.IRQ_STATUS, 32'hBE, 32'hFF);
    wr(rm.IRQ_STATUS, 32'hFF);
    rd_chk(rm.IRQ_STATUS, 32'h00, 32'hFF);

    // ---------------- irq output equation (spec 5.17) --------------------------------
    wr(rm.SWITCH_CTRL, 32'h8);                                       // IRQ_GLOBAL_EN = 1
    foreach (en_list[e]) begin
      wr(rm.IRQ_ENABLE, en_list[e]);
      foreach (f_list[f]) begin
        wr(rm.IRQ_FORCE, f_list[f]);
        rd_chk(rm.IRQ_STATUS, f_list[f], 32'hFF);
        expect_irq(|(f_list[f] & en_list[e]), $sformatf("(en=0x%02h force=0x%02h)", en_list[e], f_list[f]));
        wr(rm.IRQ_STATUS, 32'hFF);
        expect_irq(1'b0, "(after W1C)");
      end
    end
    wr(rm.IRQ_ENABLE, 32'hFF);
    wr(rm.IRQ_FORCE, 32'hFF);
    expect_irq(1'b1, "(all enabled)");
    wr(rm.SWITCH_CTRL, 32'h0);                                       // global gate closed
    expect_irq(1'b0, "(IRQ_GLOBAL_EN=0)");
    wr(rm.SWITCH_CTRL, 32'h8);
    expect_irq(1'b1, "(IRQ_GLOBAL_EN=1 again)");
    wr(rm.IRQ_ENABLE, 32'h0);                                        // mask closed, status stays
    expect_irq(1'b0, "(IRQ_ENABLE=0)");
    rd_chk(rm.IRQ_STATUS, 32'hFF, 32'hFF, " (status independent of mask)");
    wr(rm.IRQ_STATUS, 32'hFF);

    // ---------------- ERR_INJECT -> ERR_STATUS / ERR_COUNT / ERR_INFO ----------------
    for (int b = 0; b < 8; b++) inject_and_check(8'h1 << b);
    inject_and_check(8'h0E);
    inject_and_check(8'h7F);
    inject_and_check(8'hFF);
    inject_and_check(8'h80 | 8'h10);
    // accumulating count
    wr(rm.ERR_INJECT, 32'h8000_0000);
    wr(rm.ERR_INJECT, 32'h0000_0003);     // +2
    wr(rm.ERR_INJECT, 32'h0000_0080);     // +1 (bit-7-only)
    wr(rm.ERR_INJECT, 32'h0000_0070);     // +3
    rd_chk(rm.ERR_COUNT, 32'd6);
    // CLEAR_COUNT clears count + info, and has priority over an injection in the same write
    wr(rm.ERR_INJECT, 32'h8000_0000);
    rd_chk(rm.ERR_COUNT, 32'h0);
    rd_chk(rm.ERR_INFO,  32'h0);
    wr(rm.ERR_INJECT, 32'h8000_0001);
    rd_chk(rm.ERR_COUNT, 32'h0, '1, " (CLEAR_COUNT priority)");
    wr(rm.ERR_STATUS, 32'hFF);            // (ERR_STATUS effect of the combined write is not specified)
    // ERR_STATUS W1C
    wr(rm.ERR_INJECT, 32'h7F);
    wr(rm.ERR_STATUS, 32'h0);             rd_chk(rm.ERR_STATUS, 32'hFF, 32'hFF, " (W1C with 0)");
    wr(rm.ERR_STATUS, 32'h0000_0002);     rd_chk(rm.ERR_STATUS, 32'hFD, 32'hFF, " (W1C DEST_ERROR only, spec 6.2)");
    wr(rm.ERR_STATUS, 32'hFFFF_FFFF);     rd_chk(rm.ERR_STATUS, 32'h00, 32'hFF);
    wr(rm.ERR_INJECT, 32'h8000_0000);

    // ---------------- ERR_ENABLE promotion into IRQ_STATUS.ERROR --------------------------
    wr(rm.IRQ_ENABLE, 32'h2);             // ERROR_EN
    wr(rm.SWITCH_CTRL, 32'h8);
    for (int b = 0; b < 8; b++) begin
      wr(rm.ERR_ENABLE, 32'h1 << b);
      wr(rm.ERR_INJECT, 32'h1 << b);
      rd_chk(rm.IRQ_STATUS, 32'h2, 32'hFF, $sformatf(" (ERR_ENABLE bit%0d promotes)", b));
      expect_irq(1'b1, "(enabled error)");
      wr(rm.IRQ_STATUS, 32'h2);                                      // error still pending -> re-asserts
      rd_chk(rm.IRQ_STATUS, 32'h2, 32'hFF, " (re-assert while error pending)");
      wr(rm.ERR_STATUS, 32'hFF);                                     // remove the source
      wr(rm.IRQ_STATUS, 32'h2);
      rd_chk(rm.IRQ_STATUS, 32'h0, 32'hFF, " (cleared after source gone)");
      expect_irq(1'b0, "(error cleared)");
    end
    wr(rm.ERR_ENABLE, 32'h0);                                        // not enabled: no promotion
    wr(rm.ERR_INJECT, 32'h7F);
    rd_chk(rm.IRQ_STATUS, 32'h0, 32'hFF, " (error not enabled)");
    wr(rm.ERR_ENABLE, 32'h80);                                       // INJECTED_EN: any injection promotes
    wr(rm.ERR_INJECT, 32'h08);
    rd_chk(rm.IRQ_STATUS, 32'h2, 32'hFF, " (INJECTED_EN)");
    wr(rm.ERR_ENABLE, 32'h0);                                        // masking releases the level
    wr(rm.IRQ_STATUS, 32'h2);
    rd_chk(rm.IRQ_STATUS, 32'h0, 32'hFF, " (cleared after mask)");
    wr(rm.ERR_STATUS, 32'hFF);
    wr(rm.ERR_INJECT, 32'h8000_0000);

    // ---------------- optional: ERR_COUNT saturation (+PKT_ERR_SAT) ----------------------
    if (run_saturation) begin
      repeat (9363) wr(rm.ERR_INJECT, 32'h7F);
      rd_chk(rm.ERR_COUNT, 32'hFFFF, '1, " (saturated)");
      wr(rm.ERR_INJECT, 32'h7F);
      rd_chk(rm.ERR_COUNT, 32'hFFFF, '1, " (stays saturated)");
      wr(rm.ERR_STATUS, 32'hFF);
      wr(rm.ERR_INJECT, 32'h8000_0000);
    end
    wr(rm.IRQ_ENABLE, 32'h0);
    wr(rm.SWITCH_CTRL, 32'h0);
    soft_reset();
  endtask
endclass

// ============================================================================
// 7. APB error responses (spec 3.5): unaligned and out-of-range addresses
// ============================================================================
class pkt_apb_err_seq extends pkt_base_seq;
  `uvm_object_utils(pkt_apb_err_seq)
  function new(string name = "pkt_apb_err_seq"); super.new(name); endfunction

  virtual task body();
    bit [15:0] oor[$] = '{16'h0064, 16'h0068, 16'h006C, 16'h007C, 16'h0100, 16'h0400,
                          16'h1000, 16'h8000, 16'hFFFC, 16'h0063, 16'h0061, 16'hFFFF};
    bit [31:0] r;
    init();
    soft_reset();
    unlock();
    wr(rm.PORT_ENABLE, 32'h5);
    wr(rm.GEN_INTERVAL, 32'h0000_0123);
    // legal boundary addresses: no error
    raw_rd(16'h0000, r, 0);
    raw_rd(16'h0060, r, 0);
    chk("read of WO register SOFT_RESET", r, 32'h0);
    // unaligned: write has no effect, read returns 0, PSLVERR = 1
    for (int o = 0; o <= 'h60; o += 4) begin
      for (int k = 1; k < 4; k++) begin
        raw_wr(o + k, 32'hFFFF_FFFF, 1);
        raw_rd(o + k, r, 1);
        chk($sformatf("unaligned read 0x%04h", o + k), r, 32'h0);
      end
    end
    // out of range
    foreach (oor[i]) begin
      raw_wr(oor[i], 32'hFFFF_FFFF, 1);
      raw_rd(oor[i], r, 1);
      chk($sformatf("out-of-range read 0x%04h", oor[i]), r, 32'h0);
    end
    // no side effects on any register (reads are compared with the mirror)
    rd_chk(rm.PORT_ENABLE, 32'h5);
    rd_chk(rm.GEN_INTERVAL, 32'h0123);
    rd_chk(rm.LOCK, 32'h0);
    read_all_regs();
    soft_reset();
  endtask
endclass

// ============================================================================
// 8. Datapath smoke through the CSRs (spec 6.1 and 6.3). Requires set_idle_checks(0).
// ============================================================================
class pkt_traffic_seq extends pkt_base_seq;
  `uvm_object_utils(pkt_traffic_seq)
  int unsigned timeout_polls = 2000;
  function new(string name = "pkt_traffic_seq"); super.new(name); endfunction

  protected task wait_done();
    uvm_reg_data_t v;
    int unsigned n = 0;
    do begin
      rd(rm.GEN_STATUS, v);
      n++;
    end while (v[1] == 1'b0 && n < timeout_polls);
    if (v[1] == 1'b0) `uvm_error(get_type_name(), "timeout waiting for GEN_STATUS.DONE")
  endtask

  virtual task body();
    uvm_reg_data_t v;
    init();
    rm.set_idle_checks(0);                       // hardware fields now move on their own
    soft_reset();
    // ---- 6.1 generate four packets from source 0 to destination 1 ----------
    unlock();
    wr(rm.PORT_ENABLE,  32'h0000_000F);
    wr(rm.FWD_ENABLE,   32'h0000_000F);
    wr(rm.SWITCH_CTRL,  32'h0000_0009);
    wr(rm.GEN_PKT_CFG,  32'h0010_0401);
    wr(rm.GEN_INTERVAL, 32'h0000_0002);
    wr(rm.GEN_COUNT,    32'h0000_0004);
    wr(rm.IRQ_ENABLE,   32'h0000_0041);
    wr(rm.GEN_CTRL,     32'h0000_0003);          // ENABLE + START
    rd_chk(rm.GEN_CTRL, 32'h0000_0001);          // START is a pulse
    wait_done();
    rd_chk(rm.STAT_RX,   32'd4);
    rd_chk(rm.STAT_TX,   32'd4);
    rd_chk(rm.STAT_DROP, 32'd0);
    rd_chk(rm.GEN_STATUS, 32'h2, 32'h3, ".DONE/.RUNNING");
    rd_chk(rm.GEN_STATUS, 32'hC, 32'hC, ".FSM=DONE");
    rd_chk(rm.IRQ_STATUS, 32'h41, 32'h41, " (GEN_DONE, START_ACK)");
    expect_irq(1'b1, "(GEN_DONE enabled)");
    wr(rm.IRQ_STATUS, 32'h41);                    // spec 6.2: clear DONE and START_ACK
    rd_chk(rm.IRQ_STATUS, 32'h00, 32'h41);
    expect_irq(1'b0, "(cleared)");
    // ---- STAT_CLEAR ---------------------------------------------------------------
    wr(rm.SWITCH_CTRL, 32'h0000_000B);
    rd_chk(rm.SWITCH_CTRL, 32'h9);
    rd_chk(rm.STAT_RX, 32'h0);
    rd_chk(rm.STAT_TX, 32'h0);
    rd_chk(rm.STAT_DROP, 32'h0);
    // ---- 6.3 cause and observe a destination drop ------------------------------------
    wr(rm.FWD_ENABLE,  32'h0000_0001);            // only destination 0 allowed
    wr(rm.GEN_PKT_CFG, 32'h0010_0401);            // DST_PORT = 1 -> blocked
    wr(rm.ERR_STATUS,  32'hFF);
    wr(rm.GEN_CTRL,    32'h0000_0003);
    wait_done();
    rd_chk(rm.STAT_DROP, 32'd4);
    rd_chk(rm.STAT_TX,   32'd0);
    rd_chk(rm.IRQ_STATUS, 32'h08, 32'h08, ".PACKET_DROPPED");
    rd_chk(rm.ERR_STATUS, 32'h02, 32'h02, ".DEST_ERROR");
    // ---- generator STOP / ENABLE=0 return to IDLE -----------------------------------
    wr(rm.FWD_ENABLE, 32'hF);
    wr(rm.GEN_CTRL,   32'h0000_000B);             // ENABLE | START | CONTINUOUS
    clks(20);
    rd_chk(rm.GEN_STATUS, 32'h1, 32'h1, ".RUNNING (continuous)");
    wr(rm.GEN_CTRL,   32'h0000_000D);             // STOP
    clks(5);
    rd_chk(rm.GEN_STATUS, 32'h0, 32'h3, ".IDLE after STOP");
    soft_reset();
    rm.set_idle_checks(1);
  endtask
endclass

// ============================================================================
// Small helper sequences used by the tests
// ============================================================================
class pkt_unlock_seq extends pkt_base_seq;
  `uvm_object_utils(pkt_unlock_seq)
  function new(string name = "pkt_unlock_seq"); super.new(name); endfunction
  virtual task body(); init(); unlock(); endtask
endclass

class pkt_soft_reset_seq extends pkt_base_seq;
  `uvm_object_utils(pkt_soft_reset_seq)
  function new(string name = "pkt_soft_reset_seq"); super.new(name); endfunction
  virtual task body(); init(); soft_reset(); endtask
endclass

