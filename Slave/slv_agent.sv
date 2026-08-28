//------------------------------------------------------------------------------
// Slave Agent
//------------------------------------------------------------------------------

class slv_agent extends uvm_agent;

    `uvm_component_utils(slv_agent)


    //--------------------------------------------------------------------------
    // Agent Components and Configuration
    //--------------------------------------------------------------------------

    slv_driver    drv;
    slv_monitor   mon;
    slv_config    cfg;


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "slv_agent",
                 uvm_component parent);
        super.new(name, parent);
    endfunction


    //--------------------------------------------------------------------------
    // Build Phase
    //--------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(slv_config)::get(
                this, "", "slv_config", cfg))
            `uvm_fatal("SLAVE DRIVER CONFIG", "FAILED")

        // Monitor is created for both active and passive agents
        mon = slv_monitor::type_id::create("mon", this);

        // Driver and sequencer are created only for an active agent
      if (cfg.is_active == UVM_ACTIVE) begin
            drv  = slv_driver::type_id::create("drv", this);
        end
    endfunction


endclass
