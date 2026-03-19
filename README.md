# 🧮 Floating-Point Arithmetic Logical Unit (ALU) - VHDL

Acest proiect constă în proiectarea și implementarea unei unități de calcul în virgulă mobilă (FPU) care respectă standardul **IEEE-754**. Sistemul este capabil să execute operații de **Adunare** și **Înmulțire** pe 32 de biți (single precision).

## ✨ Caracteristici Tehnice
* **Standard:** IEEE-754 (Single Precision).
* **Operații Suportate:** Adunare (+) și Înmulțire (*).
* **Arhitectură:** Pipeline modularizat pentru eficiență.
* **Limbaj:** VHDL.
* **Tool-uri:** Xilinx Vivado / ModelSim.

## 🛠️ Structura Implementării (Etape)
Implementarea urmează fluxul critic de calcul hardware:
1. **Unpack:** Extragerea semnului, exponentului și mantisei.
2. **Exponent Subtract & Alignment:** Egalarea exponenților prin shiftarea mantisei.
3. **Addition/Multiplication:** Calculul propriu-zis al rezultatului intermediar.
4. **Normalization:** Readucerea rezultatului în formatul standard.
5. **Rounding:** Rotunjirea conform normelor IEEE.
6. **Pack:** Reasamblarea rezultatului final pe 32 de biți.

## 🚀 Validare
Proiectul include un **Testbench** complex care verifică precizia aritmetică pentru:
* Numere pozitive și negative.
* Cazuri de Overflow și Underflow.
* Adunări cu exponenți diferiți.

---
*Proiect realizat în cadrul disciplinei "Structura Sistemelor de Calcul" la UTCN.*
