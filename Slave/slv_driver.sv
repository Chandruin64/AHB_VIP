//------------------------------------------------------------------------------
// Slave Driver
//------------------------------------------------------------------------------

class slv_driver extends uvm_driver#(slv_xtn);

    `uvm_component_utils(slv_driver)


    //--------------------------------------------------------------------------
    // Interface and Configuration
    //--------------------------------------------------------------------------

    virtual ahb_if.SLV_DRV vif;
    slv_config cfg;


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "slv_driver",
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
            drive();
        end
    endtask


    //--------------------------------------------------------------------------
    // Drive Slave Response
    //--------------------------------------------------------------------------

    task drive();

        slv_xtn xtn;

        xtn = slv_xtn::type_id::create("xtn");


        // Wait for the start of a valid transfer
        vif.slv_drv_cb.HREADYOUT <= 1'b0;

        wait (vif.slv_drv_cb.HTRANS == 2'b10);

        vif.slv_drv_cb.HREADYOUT <= 1'b1;
        vif.slv_drv_cb.HRESP     <= 1'b0;


        // Capture transaction attributes
        @(vif.slv_drv_cb);

        vif.slv_drv_cb.HREADYOUT <= 1'b0;

        xtn.HBURST = vif.slv_drv_cb.HBURST;
        xtn.HWRITE = vif.slv_drv_cb.HWRITE;


        @(vif.slv_drv_cb);


        // Read transfer response
        if (!vif.slv_drv_cb.HWRITE) begin

            while ((vif.slv_drv_cb.HTRANS != 2'b00) &&
                   (vif.slv_drv_cb.HTRANS != 2'b10)) begin

                // Insert wait states
                repeat ($urandom_range(1, 5)) begin
                    vif.slv_drv_cb.HREADYOUT <= 1'b0;

                    @(vif.slv_drv_cb);
                end


                // Wait for BUSY transfers to complete
                while (vif.slv_drv_cb.HTRANS == 2'b01) begin
                    @(vif.slv_drv_cb);
                end


                // Provide read data and response
                vif.slv_drv_cb.HRDATA    <= $urandom;
                vif.slv_drv_cb.HREADYOUT <= 1'b1;
                vif.slv_drv_cb.HRESP     <= 1'b0;

                @(vif.slv_drv_cb);

                vif.slv_drv_cb.HREADYOUT <= 1'b0;

            end

        end
        else begin

            // Write transfer response
            while ((vif.slv_drv_cb.HTRANS != 2'b00) &&
                   (vif.slv_drv_cb.HTRANS != 2'b10)) begin

                // Insert wait states
                repeat ($urandom_range(1, 5)) begin
                    vif.slv_drv_cb.HREADYOUT <= 1'b0;

                    @(vif.slv_drv_cb);
                end


                // Wait for BUSY transfers to complete
                while (vif.slv_drv_cb.HTRANS == 2'b01)
                    @(vif.slv_drv_cb);


                // Complete the transfer
                vif.slv_drv_cb.HREADYOUT <= 1'b1;
                vif.slv_drv_cb.HRESP     <= 1'b0;

                @(vif.slv_drv_cb);

                vif.slv_drv_cb.HREADYOUT <= 1'b0;

            end

        end


        // Complete the final transfer
        if (!xtn.HWRITE) begin

            repeat ($urandom_range(1, 5)) begin
                vif.slv_drv_cb.HREADYOUT <= 1'b0;

                @(vif.slv_drv_cb);
            end

            while (vif.slv_drv_cb.HTRANS == 2'b01)
                @(vif.slv_drv_cb);

            vif.slv_drv_cb.HRDATA    <= $urandom;
            vif.slv_drv_cb.HREADYOUT <= 1'b1;
            vif.slv_drv_cb.HRESP     <= 1'b0;

            @(vif.slv_drv_cb);

            vif.slv_drv_cb.HREADYOUT <= 1'b0;

        end
        else begin

            repeat ($urandom_range(1, 5)) begin
                vif.slv_drv_cb.HREADYOUT <= 1'b0;

                @(vif.slv_drv_cb);
            end

            while (vif.slv_drv_cb.HTRANS == 2'b01)
                @(vif.slv_drv_cb);

            vif.slv_drv_cb.HREADYOUT <= 1'b1;
            vif.slv_drv_cb.HRESP     <= 1'b0;

            @(vif.slv_drv_cb);

            vif.slv_drv_cb.HREADYOUT <= 1'b0;

        end

    endtask

endclass
