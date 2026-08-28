//------------------------------------------------------------------------------
// Slave Transaction Item
//------------------------------------------------------------------------------

class slv_xtn extends uvm_sequence_item;

    `uvm_object_utils(slv_xtn)


    //--------------------------------------------------------------------------
    // AHB Transaction Signals
    //--------------------------------------------------------------------------

    bit          HRESET;
    bit          HWRITE;
    bit [31:0]   HADDR;
    bit [1:0]    HTRANS;
    bit [2:0]    HSIZE;
    bit [2:0]    HBURST;
    bit [31:0]   HWDATA[];
    logic [31:0] HRDATA[];
    logic        HREADY;
    logic        HRESP;


    //--------------------------------------------------------------------------
    // Burst Information
    //--------------------------------------------------------------------------

    bit [4:0] length;
    bit [31:0]     addr[];


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "slv_xtn");
        super.new(name);
    endfunction


    //--------------------------------------------------------------------------
    // UVM Print Method
    //--------------------------------------------------------------------------

    function void do_print(uvm_printer printer);
        super.do_print(printer);

        printer.print_field("HWRITE", HWRITE, 1, UVM_BIN);

        printer.print_field("HADDR", HADDR, 32, UVM_HEX);

        for (int i = 1; i < length; i++)
            printer.print_field("HADDR", addr[i], 32, UVM_HEX);

        printer.print_field("HTRANS", HTRANS, 2, UVM_BIN);
        printer.print_field("HSIZE", HSIZE, 3, UVM_DEC);
        printer.print_field("HBURST", HBURST, 3, UVM_DEC);
        printer.print_field("LENGTH", length, 5, UVM_DEC);

        foreach (HWDATA[i])
            printer.print_field("HWDATA", HWDATA[i], 32, UVM_HEX);

        foreach (HRDATA[i])
            printer.print_field("HRDATA", HRDATA[i], 32, UVM_HEX);

        printer.print_field("HREADY", HREADY, 1, UVM_BIN);
        printer.print_field("HRESP", HRESP, 1, UVM_BIN);
    endfunction

endclass
