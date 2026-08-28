//------------------------------------------------------------------------------
// AHB UVM Verification Package
//------------------------------------------------------------------------------

package pkg;

    //--------------------------------------------------------------------------
    // UVM Import and Macros
    //--------------------------------------------------------------------------

    import uvm_pkg::*;

    `include "uvm_macros.svh"


    //--------------------------------------------------------------------------
    // Configuration Classes
    //--------------------------------------------------------------------------

    `include "mst_config.sv"
    `include "slv_config.sv"
    `include "env_config.sv"


    //--------------------------------------------------------------------------
    // Master Agent Components
    //--------------------------------------------------------------------------

    `include "mst_xtn.sv"
    `include "mst_seqs.sv"
    `include "mst_sequencer.sv"
    `include "mst_driver.sv"
    `include "mst_monitor.sv"
    `include "mst_agent.sv"
    `include "mst_agt_top.sv"


    //--------------------------------------------------------------------------
    // Slave Agent Components
    //--------------------------------------------------------------------------

    `include "slv_xtn.sv"
    `include "slv_driver.sv"
    `include "slv_monitor.sv"
    `include "slv_agent.sv"
    `include "slv_agt_top.sv"


    //--------------------------------------------------------------------------
    // Environment Components
    //--------------------------------------------------------------------------

    `include "virtual_sequencer.sv"
    `include "virtual_seqs.sv"
    `include "scoreboard.sv"
    `include "env.sv"


    //--------------------------------------------------------------------------
    // Tests
    //--------------------------------------------------------------------------

    `include "test.sv"

endpackage
