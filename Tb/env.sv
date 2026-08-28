//------------------------------------------------------------------------------
// AHB Verification Environment
//------------------------------------------------------------------------------

class environment extends uvm_env;

    `uvm_component_utils(environment)


    //--------------------------------------------------------------------------
    // Environment Configuration
    //--------------------------------------------------------------------------

    env_config cfg;


    //--------------------------------------------------------------------------
    // Environment Components
    //--------------------------------------------------------------------------

    mst_agt_top       mst_top;
    slv_agt_top       slv_top;
    scoreboard        sb;
    virtual_sequencer vseqr;


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "environment",
                 uvm_component parent);
        super.new(name, parent);
    endfunction


    //--------------------------------------------------------------------------
    // Build Phase
    //--------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(env_config)::get(
                this, "", "env_config", cfg))
            `uvm_fatal("ENVIRONMENT CONFIG", "FAILED")


        // Create and configure Master Agent
        if (cfg.has_master_agent) begin

            mst_top =
                mst_agt_top::type_id::create(
                    "mst_top",
                    this
                );

            uvm_config_db#(mst_config)::set(
                this,
                "*",
                "mst_config",
                cfg.mst_cfg
            );

        end


        // Create and configure Slave Agent
        if (cfg.has_slave_agent) begin

            slv_top =
                slv_agt_top::type_id::create(
                    "slv_top",
                    this
                );

            uvm_config_db#(slv_config)::set(
                this,
                "*",
                "slv_config",
                cfg.slv_cfg
            );

        end


        // Create Scoreboard
        if (cfg.has_scoreboard)
            sb = scoreboard::type_id::create(
                "scoreboard",
                this
            );


        // Create Virtual Sequencer
        if (cfg.has_virtual_seqs)
            vseqr =
                virtual_sequencer::type_id::create(
                    "vseqr",
                    this
                );

    endfunction


    //--------------------------------------------------------------------------
    // Connect Phase
    //--------------------------------------------------------------------------

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);


        // Connect Monitor Ports to Scoreboard FIFOs
        if (cfg.has_scoreboard) begin

            mst_top.agent.mon.monitor_port.connect(
                sb.mst_fifo.analysis_export
            );

            slv_top.agent.mon.monitor_port.connect(
                sb.slv_fifo.analysis_export
            );

        end


        // Assign Physical Sequencers to Virtual Sequencer
        if (cfg.has_virtual_seqs) begin

            vseqr.mst_seqr = mst_top.agent.seqr;

        end

    endfunction

endclass
