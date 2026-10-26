class pkt_reg_predictor extends uvm_reg_predictor #(apb_seq_item);
  `uvm_component_utils(pkt_reg_predictor)

  pkt_reg_block rm;                         // set by the env
  bit           soft_reset_clears_sticky = 1; // spec: SOFT_RESET "resets CSR state"

  localparam bit [31:0] UNLOCK_KEY = 32'hA5A5_C3C3;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  protected function bit is_lockable(bit [15:0] a);
    case (a)
      16'h20, 16'h24, 16'h28, 16'h2C, 16'h30, 16'h34, 16'h38, 16'h40, 16'h4C: return 1'b1;
      default: return 1'b0;
    endcase
  endfunction

  // |(ERR_STATUS & ERR_ENABLE)[7:0]
  protected function bit enabled_error_pending();
    uvm_reg_data_t s = rm.ERR_STATUS.get_mirrored_value();
    uvm_reg_data_t e = rm.ERR_ENABLE.get_mirrored_value();
    return ((s & e & 64'hFF) != 0);
  endfunction

  protected function void update_irq_error();
    uvm_reg_data_t v;
    if (enabled_error_pending()) begin
      v = rm.IRQ_STATUS.get_mirrored_value();
      void'(rm.IRQ_STATUS.predict(v | 64'h2));      // IRQ_STATUS.ERROR re-asserts
    end
  endfunction

  protected function void refresh_derived();
    uvm_reg_data_t v = 0;
    uvm_reg_data_t es = rm.ERR_STATUS.get_mirrored_value();
    uvm_reg_data_t pe = rm.PORT_ENABLE.get_mirrored_value();
    v[9]   = |es[7:0];                                            // ERR_PENDING
    v[7:4] = pe[3:0];                                             // PORT_ENABLED
    v[3]   = rm.LOCK.LOCKED.get_mirrored_value();                 // LOCKED
    v[2]   = rm.SWITCH_CTRL.ENABLE.get_mirrored_value();          // SWITCH_ENABLED
    v[0]   = 1'b1;                                                // READY (generator idle)
    void'(rm.SWITCH_STATUS.predict(v));
  endfunction

  protected function void model_err_inject(bit [31:0] d);
    uvm_reg_data_t st  = rm.ERR_STATUS.get_mirrored_value();
    uvm_reg_data_t cnt = rm.ERR_COUNT.get_mirrored_value();
    int unsigned   n;
    bit [7:0]      ev = d[7:0];
    if (ev != 0) begin
      st |= {56'h0, ev[7] | (|ev[6:0]) , ev[6:0]};                // injected bit + individual bits
      void'(rm.ERR_STATUS.predict(st));
    end
    if (d[31]) begin
      void'(rm.ERR_COUNT.predict(0));                             // CLEAR_COUNT has priority
    end else if (ev != 0) begin
      n = $countones(ev[6:0]);
      if (n == 0) n = 1;                                          // bit-7-only injection
      cnt = cnt + n;
      if (cnt > 64'hFFFF) cnt = 64'hFFFF;                         // saturating counter
      void'(rm.ERR_COUNT.predict(cnt));
    end
  endfunction

  virtual function void write(apb_seq_item tr);
    apb_seq_item   t;
    uvm_reg_data_t v, keep_irq, keep_err;

    if (rm == null) `uvm_fatal("PRED", "register model handle 'rm' not set")

    // error responses / non-register addresses: no architectural effect
    if (tr.slverr || tr.addr[1:0] != 2'b00 || tr.addr > 16'h0060) return;

    if (!tr.write) begin                      // reads: check against mirror, then predict
      super.write(tr);
      return;
    end

    // ---- writes -----------------------------------------------------------
    if (is_lockable(tr.addr) && rm.LOCK.LOCKED.get_mirrored_value()) begin
      `uvm_info("PRED", $sformatf("write 0x%04h ignored (LOCKED)", tr.addr), UVM_HIGH)
      return;
    end

    if (!$cast(t, tr.clone())) `uvm_fatal("PRED", "clone failed")

    case (tr.addr)
      16'h20: t.data[1]   = 1'b0;                                   // STAT_CLEAR pulse
      16'h2C: t.data[2:1] = 2'b00;                                  // STOP / START pulses
      16'h30: if (t.data[15:8] == 8'h00) t.data[8] = 1'b1;          // LENGTH 0 -> 1
      16'h3C: if (enabled_error_pending()) t.data[1] = 1'b0;        // ERROR level re-asserts
      16'h44, 16'h50: t.data = 32'h0;                               // WO pulse registers
      16'h5C: t.data = {31'h0, (tr.data == UNLOCK_KEY) ? 1'b0 : 1'b1};
      16'h60: begin
        if (tr.data[0]) begin
          keep_irq = rm.IRQ_STATUS.get_mirrored_value();
          keep_err = rm.ERR_STATUS.get_mirrored_value();
          rm.reset();                                               // all CSRs back to reset
          if (!soft_reset_clears_sticky) begin
            void'(rm.IRQ_STATUS.predict(keep_irq));
            void'(rm.ERR_STATUS.predict(keep_err));
          end
          refresh_derived();
          return;
        end
        t.data = 32'h0;
      end
      default: ;
    endcase

    super.write(t);                                                 // standard RAL prediction

    // ---- cross-register side effects --------------------------------------
    case (tr.addr)
      16'h44: begin                                                 // IRQ_FORCE -> IRQ_STATUS[7:0]
        v = rm.IRQ_STATUS.get_mirrored_value();
        void'(rm.IRQ_STATUS.predict(v | (tr.data & 32'hFF)));
      end
      16'h50: begin model_err_inject(tr.data); update_irq_error(); end
      16'h48, 16'h4C: update_irq_error();
      default: ;
    endcase
    refresh_derived();
  endfunction
endclass

