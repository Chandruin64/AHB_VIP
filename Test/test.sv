//------------------------------------------------------------------------------
// Base Test
//------------------------------------------------------------------------------

class base_test extends uvm_test;

    `uvm_component_utils(base_test)


    //--------------------------------------------------------------------------
    // Environment and Configuration Handles
    //--------------------------------------------------------------------------

    environment env;
    env_config  env_cfg;
    mst_config  mst_cfg;
    slv_config  slv_cfg;


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "base_test",
                 uvm_component parent);
        super.new(name, parent);
    endfunction


    //--------------------------------------------------------------------------
    // Build Phase
    //--------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);


        // Create Configuration Objects
        env_cfg = env_config::type_id::create("env_cfg");
        mst_cfg = mst_config::type_id::create("mst_cfg");
        slv_cfg = slv_config::type_id::create("slv_cfg");


        // Get Master Virtual Interface
        if (!uvm_config_db#(virtual ahb_if)::get(
                this,
                "",
                "ahb_if",
                mst_cfg.vif
            ))
            `uvm_fatal(
                "MASTER INTERFACE CONFIG",
                "FAILED"
            )


        // Get Slave Virtual Interface
        if (!uvm_config_db#(virtual ahb_if)::get(
                this,
                "",
                "ahb_if",
                slv_cfg.vif
            ))
            `uvm_fatal(
                "SLAVE INTERFACE CONFIG",
                "FAILED"
            )


        // Assign Agent Configurations
        env_cfg.mst_cfg = mst_cfg;
        env_cfg.slv_cfg = slv_cfg;


        // Set Environment Configuration
        uvm_config_db#(env_config)::set(
            this,
            "*",
            "env_config",
            env_cfg
        );


        // Create Environment
        env = environment::type_id::create(
            "env",
            this
        );

    endfunction


    //--------------------------------------------------------------------------
    // End of Elaboration Phase
    //--------------------------------------------------------------------------

    function void end_of_elaboration_phase(
        uvm_phase phase
    );
        super.end_of_elaboration_phase(phase);

        uvm_top.print_topology();
    endfunction

endclass

//------------------------------------------------------------------------------
// Single Transfer Test
//------------------------------------------------------------------------------

class single_test extends base_test;

    `uvm_component_utils(single_test)


    //--------------------------------------------------------------------------
    // Virtual Sequence
    //--------------------------------------------------------------------------

    single_vseq seq;


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "single_test",
                 uvm_component parent);
        super.new(name, parent);
    endfunction


    //--------------------------------------------------------------------------
    // Run Phase
    //--------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);

        seq = single_vseq::type_id::create("seq");
        seq.start(env.vseqr);

        #100;

        phase.drop_objection(this);
    endtask

endclass

//------------------------------------------------------------------------------
// Incrementing Burst Test
//------------------------------------------------------------------------------

class incr_test extends base_test;

    `uvm_component_utils(incr_test)


    //--------------------------------------------------------------------------
    // Virtual Sequence
    //--------------------------------------------------------------------------

    incr_vseq seq;


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "incr_test",
                 uvm_component parent);
        super.new(name, parent);
    endfunction


    //--------------------------------------------------------------------------
    // Run Phase
    //--------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);

        seq = incr_vseq::type_id::create("seq");
        seq.start(env.vseqr);

        phase.drop_objection(this);
    endtask

endclass

//------------------------------------------------------------------------------
// Wrapping Burst Test
//------------------------------------------------------------------------------

class wrap_test extends base_test;

    `uvm_component_utils(wrap_test)


    //--------------------------------------------------------------------------
    // Virtual Sequence
    //--------------------------------------------------------------------------

    wrap_vseq seq;


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "wrap_test",
                 uvm_component parent);
        super.new(name, parent);
    endfunction


    //--------------------------------------------------------------------------
    // Run Phase
    //--------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);

        seq = wrap_vseq::type_id::create("seq");
        seq.start(env.vseqr);

        phase.drop_objection(this);
    endtask

endclass

