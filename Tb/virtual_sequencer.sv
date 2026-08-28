//------------------------------------------------------------------------------
// Virtual Sequencer
//------------------------------------------------------------------------------

class virtual_sequencer extends uvm_sequencer#(uvm_sequence_item);

    `uvm_component_utils(virtual_sequencer)


    //--------------------------------------------------------------------------
    // Physical Sequencer Handles
    //--------------------------------------------------------------------------

    mst_sequencer mst_seqr;
    slv_sequencer slv_seqr;


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "virtual_sequencer",
                 uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
