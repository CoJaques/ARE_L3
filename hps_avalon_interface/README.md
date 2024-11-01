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

| **Offset CPU**         | **Offset FPGA** | **Peripheral**                        | **Access Type** | **Description**                                            |
|------------------------|-----------------|---------------------------------------|------------------|------------------------------------------------------------|
| 0x01_0000 – 0x01_0003  | 0x04000         | **Interface user ID (32-bit)**        | Read Only       | 32-bit user ID for identification.                         |
| 0x01_0004 – 0x01_0007  | 0x04001         | **DE1-SoC Buttons (4 Keys)** [3..0]   | Read            | Access to 4 buttons on the DE1-SoC board.                  |
| 0x01_0008 – 0x01_000B  | 0x04002         | **DE1-SoC Switches (10 Switches)** [9..0] | Read      | Access to 10 switches on the DE1-SoC board.                |
| 0x01_000C – 0x01_000F  | 0x04003         | **DE1-SoC LEDs (10 LEDs)** [9..0]     | Read/Write      | Access to 10 LEDs on the DE1-SoC board.                    |
| 0x01_0010 – 0x01_0013  | 0x04004         | **ip36_sel** [3..0]                   | Read/Write      | Controls the Max10 LEDs through a 36-bit parallel interface. |
| 0x01_0014 – 0x01_0017  | 0x04005         | **ip36_data** [31..0]                 | Read/Write      | Controls the Max10 LEDs through a 36-bit parallel interface. |
| 0x01_0018 – 0x01_001B  | 0x04006         | **ip36_we** [0]                       | Read/Write      | Controls the Max10 LEDs through a 36-bit parallel interface. |
| 0x01_001C – 0x01_001F  | 0x04007         | **ip36_status** [1..0]                | Read            | Status of the Max10 LEDs through a 36-bit parallel interface. |

---

# TODO 

- Répondre correctement à la question 1
- Synchroniser les entrées
- Reprendre les process dispo sur cyberlearn
- Finir les schema bloc