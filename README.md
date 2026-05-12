# Asynchronous FIFO 

## Overview

This project implements a parameterized **Asynchronous FIFO (First-In-First-Out)** buffer in Verilog. It is designed to safely transfer data between two independent clock domains using Gray code pointers and two flip-flop synchronizers.

The FIFO supports independent write and read clocks, making it suitable for Clock Domain Crossing (CDC) applications in digital systems.

---

## Author

**Krishnashree D**  
B.E., Electronics and Communication Engineering  
College of Engineering, Guindy, Anna University  

---
## Project Structure

```text

├── src/
|   └──Verilog
│     ├── fifo.v
│     ├── fifo_memory.v
│     ├── rptr_empty.v
│     ├── wptr_full.v
│     ├── two_ff_sync.v
|   ├──Openlane
│     ├── config.json
|     ├── pin_order.cfg
|     ├── async_fifo.sdc
├── Output Waveform/
│   └── Output_waveform.png
├── Blocks/
|     ├── FIFO.png
│     ├── fifo_mem.png
│     ├── rptr_empty.png
│     ├── wptr_full.png
│     ├── sync_w2r.png
│     ├── sync_r2w.png
│     ├── Magic.png
│     ├── Klayout.png
│     ├── Async_FIFO.png
├── OpenLane_results.md
├── GDS Layout Analysis.md
└── README.md
```
---
## Tools Used

- **Vivado** – Functional simulation and verification  
- **OpenLane (Sky130 PDK)** – RTL-to-GDSII ASIC flow  
---
## Features

- Dual-clock FIFO with independent `wclk` and `rclk`
- Parameterized data width and address width
- Gray code based read and write pointers
- Two flip-flop synchronizers for CDC safety
- Full and empty flag generation
- Dual-port memory structure
- Verified using Vivado XSim simulation

---

## Architecture

<p align="center">
<img src=".\Blocks\Async_FIFO.png" alt="Alt Text" width="700">
</p>

The design consists of the following blocks:

### 1. FIFO Top Module

The top module connects the memory, write pointer logic, read pointer logic, and synchronizers.
<p align="center">
<img src=".\Blocks\FIFO.png" alt="Alt Text" width="700">
</p>

### 2. FIFO Memory

The memory block stores incoming data and supports independent write and read operations.

- Write operation occurs in the `wclk` domain  
- Read operation occurs in the `rclk` domain
<p align="center">
<img src=".\Blocks\fifo_mem.png" alt="Alt Text" width="700">
</p>

### 3. Write Pointer and Full Logic

The write pointer block maintains the write address and generates the `full` flag.

- Binary pointer is used for address generation  
- Gray pointer is used for clock domain crossing  
- Full condition is detected using the synchronized read pointer
<p align="center">
<img src=".\Blocks\wptr_full.png" alt="Alt Text" width="700">
</p>

### 4. Read Pointer and Empty Logic

The read pointer block maintains the read address and generates the `empty` flag.

- Binary pointer is used for address generation  
- Gray pointer is used for clock domain crossing  
- Empty condition is detected using the synchronized write pointer
<p align="center">
<img src=".\Blocks\rptr_empty.png" alt="Alt Text" width="700">
</p>

### 5. Two Flip-Flop Synchronizer

The synchronizer safely transfers pointers between clock domains.

- `wptr` is synchronized into the read clock domain  
- `rptr` is synchronized into the write clock domain
<p align="center">
<img src=".\Blocks\sync_w2r.png" alt="Alt Text" width="700">
<img src=".\Blocks\sync_r2w.png" alt="Alt Text" width="700">
</p>
---

## Clock Domain Crossing

Since `wclk` and `rclk` are independent, direct transfer of multi-bit signals can lead to metastability and incorrect sampling.

To ensure safe CDC:

1. Binary pointers are converted to **Gray code**
2. Gray code ensures **only one bit changes at a time**
3. Pointers are passed through **two flip-flop synchronizers**
4. Full and empty flags are generated only after synchronized pointer comparison

---

## Metastability Handling

Metastability occurs when a flip-flop samples a signal that is changing near the clock edge, resulting in an undefined intermediate state.

This design mitigates metastability using:

- **Two Flip-Flop Synchronizers (2FF):**  
  The first flip-flop may enter a metastable state, but the second flip-flop samples a stabilized value in the next clock cycle.

- **Gray Code Encoding:**  
  Since only one bit changes at a time, the probability of multiple bits being sampled incorrectly is minimized.

- **Conservative Flag Logic:**  
  Full and empty conditions are derived from synchronized pointers, ensuring safe operation even with slight delays.

This combination ensures that metastability does not propagate into functional logic, maintaining reliable FIFO behavior.

---

## Latency

Due to synchronization and registered memory read:

- Pointer synchronization delay: approximately **2 clock cycles**
- Registered memory read delay: approximately **1 read clock cycle**

Total observable latency:
- **~3 cycles from write to read visibility**

---

## Testbench

The FIFO is verified using three major test cases:

### Test Case 1: Normal Write and Read

Data is written into the FIFO and read back using different write and read clocks.

### Test Case 2: Full Condition

The FIFO is filled beyond its capacity to verify that additional writes are blocked when `full` is asserted.

### Test Case 3: Empty Condition

The FIFO is completely read out to verify that additional reads are blocked when `empty` is asserted.

---

## Simulation Observation
<p align="center">
<img src=".\Output Waveform\Output_waveform.png" alt="Alt Text" width="900">
</p>
The simulation confirms:

The waveform shows correct FIFO behavior during simultaneous write and read operations. Initially, `rdata` appears as unknown (`X`) because the memory is not reset, which is expected. Once valid writes occur, the data appears at the read side in the correct order, confirming proper FIFO functionality. However, the `empty` signal does not deassert immediately after a write because the write pointer must pass through a two-stage synchronizer before being visible in the read clock domain. This introduces a delay of about two `rclk` cycles, followed by an additional one-cycle delay due to registered memory read, resulting in an overall latency of roughly three read clock cycles from write to visible read data.

In the full condition scenario, the FIFO fills up as continuous writes are applied without reads. The `full` signal asserts only after a short delay because the read pointer must first be synchronized into the write clock domain before the full condition can be evaluated. This again introduces a latency of about two `wclk` cycles. Even though write enable (`winc`) continues toggling, no data overwrite occurs because internal logic gates the write operation using `wen = winc & ~full`. The delayed assertion of the `full` flag is intentional and ensures safe operation without risking data corruption.

During the empty condition, the FIFO is gradually drained as read operations continue. The `empty` signal asserts after a delay similar to the full condition, caused by synchronization of the write pointer into the read clock domain. Even when read enable (`rinc`) remains active, no invalid data is read because the operation is internally controlled using `ren = rinc & ~empty`. Overall, the observed behavior highlights that asynchronous FIFO designs inherently include synchronization delays, making them slightly conservative in flag updates, but guaranteeing correct data transfer without corruption across clock domains.


