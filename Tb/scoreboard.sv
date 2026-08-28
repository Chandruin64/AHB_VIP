//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

class scoreboard extends uvm_scoreboard;

    `uvm_component_utils(scoreboard)


    //--------------------------------------------------------------------------
    // Transaction Handles
    //--------------------------------------------------------------------------

    mst_xtn mst;
    slv_xtn slv;


    //--------------------------------------------------------------------------
    // Packet Counters
    //--------------------------------------------------------------------------

    static int pkt_rcvd;
    static int pkt_cmprd;


    //--------------------------------------------------------------------------
    // Analysis FIFOs
    //--------------------------------------------------------------------------

    uvm_tlm_analysis_fifo#(mst_xtn) mst_fifo;
    uvm_tlm_analysis_fifo#(slv_xtn) slv_fifo;


    //--------------------------------------------------------------------------
    // Address and Control Signal Coverage
    //--------------------------------------------------------------------------

    covergroup a_c_signals;

        option.per_instance = 1;

        Addr: coverpoint mst.HADDR {
            bins addr = {[0 : 32'hffff_ffff]};
        }

        Write: coverpoint mst.HWRITE {
            bins write = {1};
            bins read  = {0};
        }

        Burst: coverpoint mst.HBURST {
            bins modes[] = {[0 : 7]};
        }

        Size: coverpoint mst.HSIZE {
            bins size = {[0 : 2]};
        }

        Resp: coverpoint mst.HRESP {
            bins okay = {0};
        }

        Write_Burst_Size: cross Write, Burst, Size;

    endgroup


    //--------------------------------------------------------------------------
    // Read and Write Data Coverage
    //--------------------------------------------------------------------------

    covergroup data_signals with function sample(int i);

        option.per_instance = 1;

        Wdata: coverpoint mst.HWDATA[i] {
            bins wdata = {[0 : 32'hffff_ffff]}
                iff (mst.HWRITE);
        }

        Rdata: coverpoint mst.HRDATA[i] {
            bins rdata = {[0 : 32'hffff_ffff]}
                iff (!mst.HWRITE);
        }

    endgroup


    //--------------------------------------------------------------------------
    // Constructor
    //--------------------------------------------------------------------------

    function new(string name = "scoreboard",
                 uvm_component parent);
        super.new(name, parent);

        a_c_signals = new();
        data_signals = new();
    endfunction


    //--------------------------------------------------------------------------
    // Build Phase
    //--------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mst_fifo = new("mst_fifo", this);
        slv_fifo = new("slv_fifo", this);
    endfunction


    //--------------------------------------------------------------------------
    // Run Phase
    //--------------------------------------------------------------------------

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            mst_fifo.get(mst);
            slv_fifo.get(slv);

            pkt_rcvd++;

            compare(mst, slv);
        end
    endtask


    //--------------------------------------------------------------------------
    // Transaction Comparison
    //--------------------------------------------------------------------------

    task compare(mst_xtn mst, slv_xtn slv);

        bit result;

        result = mst.addr   === slv.addr   &&
                 mst.HWRITE === slv.HWRITE &&
                 mst.HBURST === slv.HBURST &&
                 mst.HSIZE  === slv.HSIZE  &&
                 mst.HRESP  === slv.HRESP;

        if (mst.HWRITE)
            result &= mst.HWDATA === slv.HWDATA;
        else
            result &= mst.HRDATA === slv.HRDATA;


        if (result) begin

            pkt_cmprd++;

            a_c_signals.sample();

            if (mst.HWRITE) begin
                foreach (mst.HWDATA[i])
                    data_signals.sample(i);
            end
            else begin
                foreach (mst.HRDATA[i])
                    data_signals.sample(i);
            end

            `uvm_info(
                "SCOREBOARD",
                "DATA MATCHED SUCCESSFULLY",
                UVM_LOW
            )

        end
        else begin

            `uvm_error("SCOREBOARD", "DATA MISMATCH")

            $display(
                "Master Packet: \n%s",
                mst.sprint()
            )

            $display(
                "Slave Packet: \n%s",
                slv.sprint()
            )

        end

    endtask


    //--------------------------------------------------------------------------
    // Report Phase
    //--------------------------------------------------------------------------

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "No of packets received: %0d",
                pkt_rcvd
            ),
            UVM_LOW
        )

        `uvm_info(
            "SCOREBOARD",
            $sformatf(
                "No of packets compared: %0d",
                pkt_cmprd
            ),
            UVM_LOW
        )
    endfunction

endclass
