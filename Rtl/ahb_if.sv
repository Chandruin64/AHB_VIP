interface ahb_if (input bit clk);

    //--------------------------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------------------------

    bit   HCLK;
    logic HRESET;


    //--------------------------------------------------------------------------
    // Master-Slave Signals
    //--------------------------------------------------------------------------

    logic        HWRITE;
    logic [31:0] HADDR;
    logic [1:0]  HTRANS;
    logic [2:0]  HSIZE;
    logic [2:0]  HBURST;
    logic [31:0] HWDATA;
    logic [31:0] HRDATA;
    logic        HREADY;
    logic        HREADYOUT;
    logic        HRESP;

    assign HCLK   = clk;
    assign HREADY = HREADYOUT;


    //--------------------------------------------------------------------------
    // Master Driver Clocking Block
    //--------------------------------------------------------------------------

    clocking mst_drv_cb @(posedge clk);
        default input #1 output #1;

        input  HREADY;
        input  HREADYOUT;
        input  HRDATA;
        input  HRESP;

        output HWRITE;
        output HADDR;
        output HTRANS;
        output HSIZE;
        output HBURST;
        output HWDATA;
    endclocking


    //--------------------------------------------------------------------------
    // Master Monitor Clocking Block
    //--------------------------------------------------------------------------

    clocking mst_mon_cb @(posedge clk);
        default input #1 output #1;

        input HREADY;
        input HREADYOUT;
        input HRDATA;
        input HRESP;
        input HWRITE;
        input HADDR;
        input HTRANS;
        input HSIZE;
        input HBURST;
        input HWDATA;
    endclocking


    //--------------------------------------------------------------------------
    // Slave Driver Clocking Block
    //--------------------------------------------------------------------------

    clocking slv_drv_cb @(posedge clk);
        default input #1 output #1;

        output HREADYOUT;
        output HRDATA;
        output HRESP;

        input  HWRITE;
        input  HADDR;
        input  HTRANS;
        input  HSIZE;
        input  HBURST;
        input  HWDATA;
    endclocking


    //--------------------------------------------------------------------------
    // Slave Monitor Clocking Block
    //--------------------------------------------------------------------------

    clocking slv_mon_cb @(posedge clk);
        default input #1 output #1;

        input HREADY;
        input HREADYOUT;
        input HRDATA;
        input HRESP;
        input HWRITE;
        input HADDR;
        input HTRANS;
        input HSIZE;
        input HBURST;
        input HWDATA;
    endclocking


    //--------------------------------------------------------------------------
    // Modports
    //--------------------------------------------------------------------------

    modport MST_DRV (clocking mst_drv_cb);
    modport MST_MON (clocking mst_mon_cb);
    modport SLV_DRV (clocking slv_drv_cb);
    modport SLV_MON (clocking slv_mon_cb);


    //--------------------------------------------------------------------------
    // Assertions
    //--------------------------------------------------------------------------

    property stable1;
        @(posedge clk)
        (HTRANS == 2 && !HREADY)
        |=> ($stable(HADDR) &&
             $stable(HBURST) &&
             $stable(HSIZE) &&
             $stable(HWRITE));
    endproperty

    property stable2;
        @(posedge clk)
        (HTRANS == 3 && !HREADY)
        |=> ($stable(HADDR) &&
             $stable(HBURST) &&
             $stable(HSIZE) &&
             $stable(HWRITE));
    endproperty

    property rsize;
        @(posedge clk)
        !HWRITE |-> ((HSIZE == 0) ||
                     (HSIZE == 1) ||
                     (HSIZE == 2));
    endproperty

    property wsize;
        @(posedge clk)
        HWRITE |-> ((HSIZE == 0) ||
                    (HSIZE == 1) ||
                    (HSIZE == 2));
    endproperty

    property htrans;
        @(posedge clk)
        $rose(HREADY)
        |-> ((HTRANS == 0) ||
             (HTRANS == 1) ||
             (HTRANS == 2) ||
             (HTRANS == 3));
    endproperty

    property first_transfer;
        @(posedge HCLK)
        $rose(HREADY) && $past(HTRANS) == 0
        |-> (HTRANS == 2 || HTRANS == 0);
    endproperty


    //--------------------------------------------------------------------------
    // Assertion Instances
    //--------------------------------------------------------------------------

    assert_stable1      : assert property (stable1);
    assert_stable2      : assert property (stable2);
    assert_rsize        : assert property (rsize);
    assert_wsize        : assert property (wsize);
    assert_htrans       : assert property (htrans);
    assert_first_transfer : assert property (first_transfer);

endinterface
