# Project for the Terasic DE1-Soc board

This projects used avalon bus from HPS and it is exported to design an interface in the FPGA side. 
The interface designed control DE1SoC IO (leds, buttons, switches) and parallel bus on Max10 with connector 80poles .


How to run the project:
    - compile Quartus project (located in hard/eda/DE1_SoC.qpf)
    - open Arm Development Studio, open the corresponding project located in soft/proj
    - Load the board with the .sof file (with python3 script setup_de1_soc.py), 
    - Compile the source files and load the processor
    - Run


folder structure:
    - doc: documentation
    - hard: files related to hardware, ie VHDL source and simulation files, Quartus and Qsys project
    - publi: publications
    - soft: files related to software, ie linux files and project, Altera Monitor Program source and project files

<br>

---

# In the addressing plan, the size of the zone available for your interface correspond to the 14 address bits defined in the Avalon bus? Why?

The size of the zone available for the interface corresponds to 14 address bits on the Avalon bus because the address range is 0x01_0000 to 0x01_FFFF, which provides 64 KB of space.

Since the bus is 32-bit, the two most significant bits (MSBs) are not used for addressing, leaving 14 bits to handle the addressing. These 14 bits are enough to cover the entire range, ensuring all addresses in the 0x01_0000 to 0x01_FFFF zone are accessible.

<br>

---

# Address plan

| **CPU**                        | **FPGA**           | **Read**                         | **Write**                 |
|--------------------------------|--------------------|----------------------------------|---------------------------|
| `0xFF21 0000`                  | `0x4000`           | `Constant[31:0]`                 | Reserved                  |
| `0xFF21 0004`                  | `0x4001`           | `res[31:4]  => 0 buttons[3:0]`   | Reserved                  |
| `0xFF21 000C`                  | `0x4003`           | `res[31:10] => 0 switches[9:0]`  | Reserved                  |
| `0xFF21 0010`                  | `0x4004`           | `res[31:2]  => 0 lp36-stat[1:0]` | Reserved                  |
| `0xFF21 0014`                  | `0x4005`           | `res[31:1]  => 0 lp36-rdy[0]`    | Reserved                  |
| `0xFF21 0018 -> 0x00FF21 007C` | `0x4006 -> 0x401F` | Reserved                         | Reserved                  |
| `0xFF21 0080`                  | `0x4020`           | `res[31:10] => 0 leds[9:0]`      | `res[31:10] leds[9:0]`    |
| `0xFF21 0084`                  | `0x4021`           | `res[31:4]  => 0 lp36_sel[3:0]`  | `res[31:4] lp36_sel[3:0]` |
| `0xFF21 0088`                  | `0x4022`           | `lp36_data[31:0]`                | `lp36_data[31:0]`         |
| `0xFF21 008C -> 0x00FF21 00FC` | `0x4023 -> 0x403F` | Reserved                         | Reserved                  |
| `0xFF21 0100 -> 0x00FF21 FFFF` | `0x4040 -> 0x7FF`  | libre                            | libre                     |

---

# TODO 

- Répondre correctement à la question 1
- Synchroniser les entrées
- Reprendre les process dispo sur cyberlearn
- Finir les schema bloc