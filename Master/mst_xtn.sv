class mst_xtn extends uvm_sequence_item;

    `uvm_object_utils(mst_xtn)


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "mst_xtn");
        super.new(name);
    endfunction


    //--------------------------------------------------------------------------
    // AHB Transaction Signals
    //--------------------------------------------------------------------------

    bit          HRESET;
    rand bit     HWRITE;
    rand bit [31:0] HADDR;
    bit [1:0]    HTRANS;
    rand bit [2:0] HSIZE;
    rand bit [2:0] HBURST;
    rand bit [31:0] HWDATA[];
    logic [31:0] HRDATA[];
    logic        HREADY;
    logic        HRESP;


    //--------------------------------------------------------------------------
    // Burst Information
    //--------------------------------------------------------------------------

    rand bit [4:0] length;
    bit [31:0]     addr[];


    //--------------------------------------------------------------------------
    // Constraints
    //--------------------------------------------------------------------------

    constraint c1 {
        HSIZE inside {[0:2]};
    }

    constraint c2 {
        (HSIZE == 1) -> (HADDR % 2 == 0);
        (HSIZE == 2) -> (HADDR % 4 == 0);
    }

    constraint c3 {
        if (HBURST == 0)
            length == 1;
        else if ((HBURST == 2) || (HBURST == 3))
            length == 4;
        else if ((HBURST == 4) || (HBURST == 5))
            length == 8;
        else if ((HBURST == 6) || (HBURST == 7))
            length == 16;
    }

    constraint c4 {
        HWDATA.size == length;
    }


    //--------------------------------------------------------------------------
    // UVM Print Method
    //--------------------------------------------------------------------------

    function void do_print(uvm_printer printer);
        super.do_print(printer);

        printer.print_field("HWRITE", HWRITE, 1, UVM_BIN);

        foreach (addr[i])
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


    //--------------------------------------------------------------------------
    // Address Generation
    //--------------------------------------------------------------------------

    function void post_randomize();

        // Single transfer
        if (HBURST == 0) begin
            addr = new[length];

            foreach (addr[i])
                addr[i] = HADDR;
        end

        // Incrementing bursts
        else if ((HBURST == 1) ||
                 (HBURST == 3) ||
                 (HBURST == 5) ||
                 (HBURST == 7)) begin

            addr = new[length];
            addr[0] = HADDR;

            for (int i = 1; i < length; i++)
                addr[i] = addr[i-1] + 2**HSIZE;
        end

        // Wrapping bursts
        else begin
            bit [31:0] start_boundary;
            bit [31:0] end_boundary;

            addr = new[length];
            addr[0] = HADDR;

            start_boundary =
                (HADDR / (length * (2**HSIZE))) *
                (length * (2**HSIZE));

            end_boundary =
                start_boundary + (length * (2**HSIZE));

            for (int i = 1; i < length; i++) begin
                addr[i] = addr[i-1] + 2**HSIZE;

                if (addr[i] >= end_boundary)
                    addr[i] = start_boundary;
            end
        end

    endfunction

endclass
