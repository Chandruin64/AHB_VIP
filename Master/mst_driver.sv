//------------------------------------------------------------------------------
// Master Driver
//------------------------------------------------------------------------------

class mst_driver extends uvm_driver#(mst_xtn);

    `uvm_component_utils(mst_driver)


    //--------------------------------------------------------------------------
    // Interface and Configuration
    //--------------------------------------------------------------------------

    virtual ahb_if.MST_DRV vif;
    mst_config cfg;


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "mst_driver",
                 uvm_component parent);
        super.new(name, parent);
    endfunction


    //--------------------------------------------------------------------------
    // Build Phase
    //--------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(mst_config)::get(
                this, "", "mst_config", cfg))
            `uvm_fatal("MASTER DRIVER CONFIG", "FAILED")
    endfunction


    //--------------------------------------------------------------------------
    // Connect Phase
    //--------------------------------------------------------------------------

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        vif = cfg.vif;
    endfunction


    //--------------------------------------------------------------------------
    // Run Phase
    //--------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            seq_item_port.get_next_item(req);

            req.print();
            drive(req);

            seq_item_port.item_done();
        end
    endtask


    //--------------------------------------------------------------------------
    // Drive AHB Transaction
    //--------------------------------------------------------------------------

    task drive(mst_xtn xtn);

        // Drive first transfer
        vif.mst_drv_cb.HADDR  <= xtn.addr[0];
        vif.mst_drv_cb.HWRITE <= xtn.HWRITE;
        vif.mst_drv_cb.HSIZE  <= xtn.HSIZE;
        vif.mst_drv_cb.HBURST <= xtn.HBURST;
        vif.mst_drv_cb.HTRANS <= 2'b10;

        @(vif.mst_drv_cb);
        wait (vif.mst_drv_cb.HREADY);


        // Drive remaining burst transfers
        for (int i = 1; i < xtn.length; i++) begin

            vif.mst_drv_cb.HADDR  <= xtn.addr[i];
            vif.mst_drv_cb.HTRANS <= 2'b11;

            if (xtn.HWRITE)
                vif.mst_drv_cb.HWDATA <= xtn.HWDATA[i-1];

            @(vif.mst_drv_cb);
            wait (vif.mst_drv_cb.HREADY);


            // Insert IDLE transfers
            repeat ($urandom_range(0, 5)) begin
                vif.mst_drv_cb.HTRANS <= 2'b01;

                @(vif.mst_drv_cb);
            end

        end


        // Drive final write data
        if (xtn.HWRITE)
            vif.mst_drv_cb.HWDATA <= xtn.HWDATA[xtn.length-1];

        vif.mst_drv_cb.HTRANS <= 2'b00;

        @(vif.mst_drv_cb);
        wait (vif.mst_drv_cb.HREADY);

    endtask

endclass
