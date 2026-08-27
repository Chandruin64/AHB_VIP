//------------------------------------------------------------------------------
// Base Master Sequence
//------------------------------------------------------------------------------

class base_mst_seq extends uvm_sequence#(mst_xtn);

    `uvm_object_utils(base_mst_seq)


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "base_mst_seq");
        super.new(name);
    endfunction

endclass


//------------------------------------------------------------------------------
// Single Transfer Sequence
//------------------------------------------------------------------------------

class mst_single_seq extends base_mst_seq;

    `uvm_object_utils(mst_single_seq)


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "mst_single_seq");
        super.new(name);
    endfunction


    //--------------------------------------------------------------------------
    // Sequence Body
    //--------------------------------------------------------------------------

    task body();

        repeat (30) begin
            req = mst_xtn::type_id::create("req");

            start_item(req);
            assert(req.randomize() with {
                HBURST == 3'd0;
            });
            finish_item(req);
        end

    endtask

endclass


//------------------------------------------------------------------------------
// Incrementing Burst Sequence
//------------------------------------------------------------------------------

class mst_incr_seq extends base_mst_seq;

    `uvm_object_utils(mst_incr_seq)


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "mst_incr_seq");
        super.new(name);
    endfunction


    //--------------------------------------------------------------------------
    // Sequence Body
    //--------------------------------------------------------------------------

    task body();

        repeat (30) begin
            req = mst_xtn::type_id::create("req");

            start_item(req);
            assert(req.randomize() with {
                (HBURST == 3'd1) ||
                (HBURST == 3'd3) ||
                (HBURST == 3'd5) ||
                (HBURST == 3'd7);
            });
            finish_item(req);
        end


        req = mst_xtn::type_id::create("req");

        start_item(req);
        assert(req.randomize() with {
            HBURST == 3'd3;
        });
        finish_item(req);


        req = mst_xtn::type_id::create("req");

        start_item(req);
        assert(req.randomize() with {
            HBURST == 3'd7;
            HWRITE == 1;
        });
        finish_item(req);

    endtask

endclass


//------------------------------------------------------------------------------
// Wrapping Burst Sequence
//------------------------------------------------------------------------------

class mst_wrap_seq extends base_mst_seq;

    `uvm_object_utils(mst_wrap_seq)


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "mst_wrap_seq");
        super.new(name);
    endfunction


    //--------------------------------------------------------------------------
    // Sequence Body
    //--------------------------------------------------------------------------

    task body();

        repeat (30) begin
            req = mst_xtn::type_id::create("req");

            start_item(req);
            assert(req.randomize() with {
                (HBURST == 3'd2) ||
                (HBURST == 3'd4) ||
                (HBURST == 3'd6);
            });
            finish_item(req);
        end

    endtask

endclass
