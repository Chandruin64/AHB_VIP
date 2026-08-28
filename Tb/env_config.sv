//------------------------------------------------------------------------------
// Environment Configuration
//------------------------------------------------------------------------------

class env_config extends uvm_object;

    `uvm_object_utils(env_config)


    //--------------------------------------------------------------------------
    // Environment Configuration Flags
    //--------------------------------------------------------------------------

    bit has_master_agent = 1;
    bit has_slave_agent  = 1;
    bit has_scoreboard   = 1;
    bit has_virtual_seqs = 1;


    //--------------------------------------------------------------------------
    // Agent Configurations
    //--------------------------------------------------------------------------

    slv_config slv_cfg;
    mst_config mst_cfg;


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "env_config");
        super.new(name);
    endfunction

endclass
