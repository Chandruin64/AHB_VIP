# AHB UVM Verification Environment

A reusable **UVM-based verification environment for the AMBA AHB protocol**, developed using **SystemVerilog and UVM**. The project implements configurable Master and Slave agents and supports protocol-level verification of AHB transfers, including **single, incremental, and wrapping bursts**.

The environment uses constrained-random stimulus, protocol assertions, functional coverage, monitors, a self-checking scoreboard, and virtual sequences to verify communication between the AHB Master and Slave.

---

## Features

* Reusable UVM-based AHB verification environment
* Configurable **Master and Slave agents**
* Active/Passive agent configuration support
* Support for:

  * Single transfers
  * Incrementing bursts
  * Wrapping bursts
* Support for AHB burst types:

  * `SINGLE`
  * `INCR`
  * `WRAP4`
  * `INCR4`
  * `WRAP8`
  * `INCR8`
  * `WRAP16`
  * `INCR16`
* Support for read and write transactions
* Configurable transfer sizes:

  * Byte
  * Halfword
  * Word
* Automatic burst address generation
* Address calculation for incrementing and wrapping bursts
* Randomized write and read data generation
* Randomized Slave wait-state insertion
* UVM virtual sequencer and virtual sequences for Master sequence control
* Master and Slave transaction monitoring
* Self-checking scoreboard using TLM analysis FIFOs
* Functional coverage with cross coverage
* SystemVerilog Assertions (SVA) for protocol checks
* Support for **Siemens Questa** and **Synopsys VCS**
* Waveform generation using WLF and FSDB formats
* Fixed random seeds for reproducible simulations

---

## Verification Environment Architecture

```text

                              +----------------------+
                              |      UVM TEST        |
                              +----------+-----------+
                                         |
                                         v
                              +----------------------+
                              |     ENVIRONMENT      |
                              |                      |
                              |  +----------------+  |
                              |  | Virtual        |  |
                              |  | Sequencer      |  |
                              |  +----------------+  |
                              +----------+-----------+
                                         |
                    +--------------------+--------------------+
                    |                    |                    |
                    v                    v                    v
           +----------------+    +----------------+    +----------------+
           | Master Agent   |    | Slave Agent    |    | Scoreboard     |
           |                |    |                |    |                |
           | Sequencer      |    | Driver         |    | Master FIFO    |
           | Driver         |    | Monitor        |    | Slave FIFO     |
           | Monitor        |    |                |    | Compare        |
           +-------+--------+    +-------+--------+    +----------------+
                   |                     |
                   |                     |
                   +----------+----------+
                              |
                              v
                    +----------------------+
                    |                      |
                    |      AHB Interface   |
                    |                      |
                    +----------------------+
```

---

## Project Structure

```text
AHB_UVM_Verification/
│
├── rtl/
│   └── ahb_if.sv
│
├── master/
│   ├── mst_config.sv
│   ├── mst_xtn.sv
│   ├── mst_seqs.sv
│   ├── mst_sequencer.sv
│   ├── mst_driver.sv
│   ├── mst_monitor.sv
│   ├── mst_agent.sv
│   └── mst_agt_top.sv
│
├── slave/
│   ├── slv_config.sv
│   ├── slv_xtn.sv
│   ├── slv_driver.sv
│   ├── slv_monitor.sv
│   ├── slv_agent.sv
│   └── slv_agt_top.sv
│
├── tb/
│   ├── env_config.sv
│   ├── virtual_sequencer.sv
│   ├── virtual_seqs.sv
│   ├── scoreboard.sv
│   ├── env.sv
│   └── top.sv
│
├── test/
│   ├── test.sv
│   └── pkg.sv
│
├── sim/
│   └── Makefile
│
└── README.md
```

---

# AHB Interface

The AHB interface contains the signals required for communication between the Master and Slave.

### Global Signals

| Signal   | Description  |
| -------- | ------------ |
| `HCLK`   | AHB clock    |
| `HRESET` | Reset signal |

### Address and Control Signals

| Signal   | Description        |
| -------- | ------------------ |
| `HADDR`  | Transfer address   |
| `HTRANS` | Transfer type      |
| `HWRITE` | Read/write control |
| `HSIZE`  | Transfer size      |
| `HBURST` | Burst type         |

### Data Signals

| Signal   | Description |
| -------- | ----------- |
| `HWDATA` | Write data  |
| `HRDATA` | Read data   |

### Response Signals

| Signal      | Description                                  |
| ----------- | -------------------------------------------- |
| `HREADY`    | Indicates completion of the current transfer |
| `HREADYOUT` | Slave ready response                         |
| `HRESP`     | Transfer response                            |

The interface also defines dedicated clocking blocks and modports for:

* Master Driver
* Master Monitor
* Slave Driver
* Slave Monitor

---

# Transaction Items

Separate transaction classes are implemented for the Master and Slave.

### Master Transaction

The Master transaction contains randomized fields for:

* `HWRITE`
* `HADDR`
* `HSIZE`
* `HBURST`
* `HWDATA`
* Burst `length`

The transaction also stores:

* Generated burst addresses
* Read data
* Ready status
* Response status

### Slave Transaction

The Slave transaction captures the AHB transfer information observed by the Slave side, including:

* Address information
* Transfer direction
* Burst type
* Transfer size
* Write data
* Read data
* Response
* Burst length

---

# Constrained-Random Burst Generation

The Master transaction applies constraints to generate valid transfer sizes and burst lengths.

### Supported Transfer Sizes

```text
HSIZE = 0 → Byte
HSIZE = 1 → Halfword
HSIZE = 2 → Word
```

### Supported Burst Lengths

| HBURST | Burst Type | Length                         |
| ------ | ---------- | ------------------------------ |
| `000`  | SINGLE     | 1                              |
| `001`  | INCR       | Undefined / sequence-dependent |
| `010`  | WRAP4      | 4                              |
| `011`  | INCR4      | 4                              |
| `100`  | WRAP8      | 8                              |
| `101`  | INCR8      | 8                              |
| `110`  | WRAP16     | 16                             |
| `111`  | INCR16     | 16                             |

The transaction class automatically generates burst addresses after randomization.

### Address Generation

* **SINGLE** transfers retain the same transfer address.
* **INCR / INCRx** bursts increment the address based on the transfer size.
* **WRAPx** bursts calculate the wrapping boundary and wrap the address when the boundary is reached.

---

# Master Agent

The Master agent consists of:

```text
Master Agent
│
├── Master Sequencer
├── Master Driver
└── Master Monitor
```

### Master Sequences

The following sequences are implemented:

#### Single Transfer Sequence

Generates multiple transactions constrained to:

```text
HBURST == SINGLE
```

#### Incrementing Burst Sequence

Generates incrementing burst transactions using:

```text
INCR
INCR4
INCR8
INCR16
```

#### Wrapping Burst Sequence

Generates wrapping burst transactions using:

```text
WRAP4
WRAP8
WRAP16
```

---

# Master Driver

The Master driver converts sequence items into AHB bus activity.

Key operations include:

* Driving the initial transfer as `NONSEQ`
* Driving subsequent burst transfers as `SEQ`
* Driving generated burst addresses
* Driving write data during write transfers
* Waiting for `HREADY`
* Handling transfer completion
* Inserting randomized `BUSY` transfers during burst activity
* Driving `IDLE` after transaction completion

The driver synchronizes each transfer with the AHB clocking block.

---

# Master Monitor

The Master monitor passively observes transactions on the AHB interface.

It captures:

* Burst start using `NONSEQ`
* Sequential transfers using `SEQ`
* Transfer addresses
* Transfer size
* Burst type
* Read/write information
* Write data
* Read data
* Response information
* Transaction length

The collected transaction is sent to the scoreboard through a UVM analysis port.

---

# Slave Agent

The Slave agent consists of:

```text
Slave Agent
│
├── Slave Driver
└── Slave Monitor
```

Unlike the Master agent, the Slave agent does not use sequences or a sequencer. The Slave driver directly responds to Master-generated AHB transfers and controls the Slave response signals.

The Slave driver responds to Master transfers and generates:

* `HREADYOUT`
* `HRESP`
* `HRDATA` for read transactions

---

# Slave Wait-State Generation

The Slave driver inserts randomized wait states by controlling `HREADYOUT`.

This allows the environment to verify Master behavior under variable response latency.

The Slave driver can:

1. Detect a valid `NONSEQ` transfer.
2. Insert one or more wait states.
3. Generate read data for read transfers.
4. Assert `HREADYOUT` to complete the transfer.
5. Continue handling sequential burst transfers.

This introduces timing variation into the verification environment and exercises AHB handshake behavior.

---

# Virtual Sequencer and Virtual Sequences

The virtual sequencer provides access to the Master sequencer at the environment level.

```text
Virtual Sequencer
│
└── Master Sequencer
```

Virtual sequences are used to coordinate higher-level verification scenarios and control Master transaction generation.

Implemented virtual sequences include:

* `single_vseq`
* `incr_vseq`
* `wrap_vseq`

Each virtual sequence starts the corresponding Master sequence through the virtual sequencer.

---

# Scoreboard

The scoreboard implements a self-checking mechanism using two UVM TLM analysis FIFOs:

```text
Master Monitor ──> Master Analysis FIFO ──┐
                                          ├──> Scoreboard Comparison
Slave Monitor  ──> Slave Analysis FIFO ───┘
```

The following fields are compared:

* Generated address array
* Read/write direction
* Burst type
* Transfer size
* Response
* Write data for write transactions
* Read data for read transactions

The scoreboard reports:

```text
DATA MATCHED SUCCESSFULLY
```

for successful comparisons and reports an error when a mismatch is detected.

Packet statistics are also displayed during the report phase.

---

# Functional Coverage

Functional coverage is implemented in the scoreboard.

### Covered Fields

* Address
* Read/write operation
* Burst type
* Transfer size
* Response

### Cross Coverage

The environment includes cross coverage for:

```text
Write × Burst × Size
```

### Data Coverage

Coverage is also sampled for:

* Write data during write transfers
* Read data during read transfers

Per-instance coverage is enabled for the implemented covergroups.

---

# SystemVerilog Assertions

Protocol assertions are implemented in the AHB interface.

The assertions check conditions related to:

* Stability of control signals when the bus is not ready
* Valid transfer size values
* Valid transfer type values
* Initial transfer behavior after an idle condition

Assertions are enabled during simulation using the simulator coverage options.

---

# Testcases

The verification environment includes the following UVM tests.

## 1. `single_test`

Verifies single AHB transfers.

```text
UVM_TESTNAME=single_test
```

This test starts the `single_vseq` virtual sequence.

---

## 2. `incr_test`

Verifies incrementing burst transfers.

```text
UVM_TESTNAME=incr_test
```

This test starts the `incr_vseq` virtual sequence.

---

## 3. `wrap_test`

Verifies wrapping burst transfers.

```text
UVM_TESTNAME=wrap_test
```

This test starts the `wrap_vseq` virtual sequence.

---

# Simulation Support

The project Makefile supports both:

* Siemens Questa
* Synopsys VCS

Select the simulator by changing:

```makefile
SIMULATOR = Questa
```

or:

```makefile
SIMULATOR = VCS
```

---

# Running with Questa

## Compile

```bash
make sv_cmp
```

## Run Single Transfer Test

```bash
make run_test
```

## Run Incrementing Burst Test

```bash
make run_test1
```

## Run Wrapping Burst Test

```bash
make run_test2
```

## Run Complete Regression

```bash
make regress
```

## View Waveforms

```bash
make view_wave1
make view_wave2
make view_wave3
```

## Generate Merged Coverage Report

```bash
make report
```

## Open Coverage Report

```bash
make cov
```

---

# Running with VCS

Change the simulator selection:

```makefile
SIMULATOR = VCS
```

Then use the same Makefile targets:

```bash
make sv_cmp
make run_test
make run_test1
make run_test2
make regress
```

Waveforms can be viewed using Verdi:

```bash
make view_wave1
make view_wave2
make view_wave3
```

---

# Random Seeds

Fixed random seeds are used for reproducible simulations.

| Test          |         Seed |
| ------------- | -----------: |
| `single_test` | `2969046076` |
| `incr_test`   | `3981970915` |
| `wrap_test`   | `4017622352` |

The same seed values are configured for both Questa and VCS runs.

> Note: Using the same seed value across different simulators does not necessarily guarantee identical randomization results because simulator randomization implementations may differ. However, each simulator run remains reproducible using its configured fixed seed.

---

# Key UVM Components

| Component         | Purpose                                                    |
| ----------------- | ---------------------------------------------------------- |
| Transaction       | Represents AHB transfer information                        |
| Master Sequence   | Generates constrained-random AHB transactions              |
| Master Sequencer  | Supplies transactions to the Master driver                 |
| Master Driver     | Converts transactions into AHB bus activity                |
| Slave Driver      | Generates Slave responses to Master transfers              |
| Monitor           | Observes and reconstructs bus transactions                 |
| Agent             | Groups the verification components for each interface side |
| Virtual Sequencer | Provides Master sequencer access at environment level      |
| Virtual Sequence  | Controls higher-level Master verification scenarios        |
| Scoreboard        | Compares Master and Slave transactions                     |
| Coverage          | Measures verification scenario coverage                    |
| Assertions        | Checks protocol behavior during simulation                 |
| Environment       | Integrates agents, scoreboard, and virtual sequencer       |
| Test              | Configures and executes verification scenarios             |

---

# Technologies Used

* **SystemVerilog**
* **Universal Verification Methodology (UVM)**
* **SystemVerilog Assertions (SVA)**
* **Functional Coverage**
* **Constrained-Random Verification**
* **TLM Analysis FIFOs**
* **Siemens Questa / ModelSim**
* **Synopsys VCS**
* **Verdi**

---

# Verification Highlights

* Developed reusable Master and Slave UVM agents for AHB protocol verification.
* Generated constrained-random single, incrementing, and wrapping burst transactions through the Master agent.
* Implemented automatic address generation for incrementing and wrapping burst types.
* Introduced randomized Slave wait states to verify handshake behavior.
* Used virtual sequences and a virtual sequencer for Master test-level sequence control.
* Built a self-checking scoreboard using UVM TLM analysis FIFOs.
* Implemented functional coverage and cross coverage for key protocol configurations.
* Added SystemVerilog Assertions for protocol-level checks.
* Created simulator-independent execution support through a Makefile for both Questa and VCS.

---

## Author

**Chandirapriyan K**

Design Verification | RTL Design

**Skills:** SystemVerilog, UVM, AHB, SystemVerilog Assertions (SVA), Functional Coverage, Constrained-Random Verification, TLM, QuestaSim, Synopsys VCS, Linux
