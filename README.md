# 🧮 Floating-Point Arithmetic Logic Unit (ALU) - VHDL

This project consists of the design and implementation of a Floating-Point Unit (FPU) that adheres to the **IEEE-754** standard. The system is capable of performing 32-bit **Addition** and **Multiplication** operations (single precision).

## ✨ Technical Features
* **Standard:** IEEE-754 (Single Precision).
* **Supported Operations:** Addition (+) and Multiplication (*).
* **Architecture:** Modularized pipeline for efficiency.
* **Language:** VHDL.
* **Tools:** Xilinx Vivado / ModelSim.

## 🛠️ Implementation Structure (Stages)
The implementation follows the critical hardware calculation flow:
1. **Unpack:** Extracting the sign, exponent, and mantissa.
2. **Exponent Subtract & Alignment:** Equalizing exponents by shifting the mantissa.
3. **Addition/Multiplication:** The actual calculation of the intermediate result.
4. **Normalization:** Bringing the result back into the standard format.
5. **Rounding:** Rounding according to IEEE norms.
6. **Pack:** Reassembling the final 32-bit result.

## 🚀 Validation
The project includes a complex **Testbench** that verifies arithmetic precision for:
* Positive and negative numbers.
* Overflow and Underflow cases.
* Additions with different exponents.

---
*Project developed for the "Computer Systems Architecture" course at UTCN.*
