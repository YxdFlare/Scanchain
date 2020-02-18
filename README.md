# Scanchain

Simple scanchain to read out the states

## Introduction

This design is a simple scan-chain controller unit, along with a serial-in-parallel-out (SIPO) buffer.

## Interface

To start a scan-based readout, pull up the *dft_val_op* signal and wait for the *dft_op_ack* to be high, which indicates the controller has received your request.
Then the controller will automatically read out all the states inside the design under test (DUT)'s scan registers, based on the chain length. After scaning, the controller will output its collected value in a sequence of 32-bit values. Each valid output is marked by the *dft_out_strobe* sinal. Once all operations are completed, the *dft_op_commit* will be high, and the controller will wait for the *dft_commit_ack* signal to be high to restore into IDLE state and be ready for next request.

**TWO IMPORTANT PARAMETERS:**
**chain_len** : total length of the scan chain (in bits).
**dumpNbr**  : the number of 32-bit values needed for storing all the data inside the scan chain.

## Data Format

The data is stored in first-in-first-out order. The LSB inside a 32-bit value is one bit that comes out of the scan chain first in these 32 bits, and the MSB is the last one. The 32-bit value that comes out of the dft controller is the first 32 bits inside the scan chain.