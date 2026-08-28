//------------------------------------------------------------------------------
// Slave Monitor
//------------------------------------------------------------------------------

class slv_monitor extends uvm_monitor;

    `uvm_component_utils(slv_monitor)


    //--------------------------------------------------------------------------
    // Interface, Configuration, and Analysis Port
    //--------------------------------------------------------------------------

    virtual ahb_if.SLV_MON vif;
    slv_config cfg;

    uvm_analysis_port#(slv_xtn) monitor_port;


    //--------------------------------------------------------------------------
    // Transaction Variables
    //--------------------------------------------------------------------------

    slv_xtn xtn;
    bit [4:0] length;


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "slv_monitor",
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
            `uvm_fatal("SLAVE MONITOR CONFIG", "FAILED")

        monitor_port = new("monitor_port", this);
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
            collect_data();
        end
    endtask


    //--------------------------------------------------------------------------
    // Collect AHB Transaction
    //--------------------------------------------------------------------------

    task collect_data();

        xtn = slv_xtn::type_id::create("xtn");


        // Wait for the start of a valid transfer
        wait (vif.slv_mon_cb.HREADY &&
              (vif.slv_mon_cb.HTRANS == 2'b10));

        length     = 0;
        xtn.HADDR  = vif.slv_mon_cb.HADDR;
        xtn.HWRITE = vif.slv_mon_cb.HWRITE;
        xtn.HSIZE  = vif.slv_mon_cb.HSIZE;
        xtn.HTRANS = vif.slv_mon_cb.HTRANS;
        xtn.HBURST = vif.slv_mon_cb.HBURST;
        xtn.HRESP  = vif.slv_mon_cb.HRESP;

        xtn.addr = new[1](xtn.addr);
        xtn.addr[0] = vif.slv_mon_cb.HADDR;


        @(vif.slv_mon_cb);

        // Collect remaining transfers in the burst
        while ((vif.slv_mon_cb.HTRANS != 2'b00) &&
               (vif.slv_mon_cb.HTRANS != 2'b10)) begin

            if (vif.slv_mon_cb.HREADY &&
                (vif.slv_mon_cb.HTRANS == 2'b11)) begin

                if (xtn.HWRITE) begin
                    length = length + 1;

                    xtn.HWDATA = new[length](xtn.HWDATA);
                    xtn.HWDATA[length-1] =
                        vif.slv_mon_cb.HWDATA;
                end
                else begin
                    length = length + 1;

                    xtn.HRDATA = new[length](xtn.HRDATA);
                    xtn.HRDATA[length-1] =
                        vif.slv_mon_cb.HRDATA;
                end

                xtn.addr = new[length+1](xtn.addr);
                xtn.addr[length] =
                    vif.slv_mon_cb.HADDR;
            end

            @(vif.slv_mon_cb);
        end


        // Collect data for the final transfer
        wait (vif.slv_mon_cb.HREADY &&
             ((vif.slv_mon_cb.HTRANS == 2'b00) ||
              (vif.slv_mon_cb.HTRANS == 2'b10)));

        if (xtn.HWRITE) begin
            length = length + 1;

            xtn.HWDATA = new[length](xtn.HWDATA);
            xtn.HWDATA[length-1] =
                vif.slv_mon_cb.HWDATA;
        end
        else begin
            length = length + 1;

            xtn.HRDATA = new[length](xtn.HRDATA);
            xtn.HRDATA[length-1] =
                vif.slv_mon_cb.HRDATA;
        end

        xtn.length = length;


        // Publish the collected transaction
        `uvm_info(
            "SLAVE MONITOR",
            $sformatf(
                "The data collected from Slave Monitor: \n%s",
                xtn.sprint()
            ),
            UVM_LOW
        )

        monitor_port.write(xtn);

    endtask

endclass
