Project for the Terasic DE1-Soc board

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

# Address plan

| **Offset**            | **Peripheral**                         | **Access Type** | **Description**                               |
|-----------------------|----------------------------------------|-----------------|-----------------------------------------------|
| 0x00_0000 – 0x00_0003 | **Interface user ID (32-bit)**          | Read Only       | Stores a 32-bit user ID for identification.   |
| 0x00_0004 – 0x00_0007 | **Reserved**                           | None            | Reserved for future expansion or unused.      |
| 0x00_0008 – 0x00_000B | **DE1-SoC Buttons (4 Keys)**           | Read/Write      | Access to 4 buttons on the DE1-SoC board.     |
| 0x00_000C – 0x00_000F | **DE1-SoC Switches (10 Switches)**     | Read/Write      | Access to 10 switches on the DE1-SoC board.   |
| 0x00_0010 – 0x00_0013 | **DE1-SoC LEDs (10 LEDs)**             | Read/Write      | Access to 10 LEDs on the DE1-SoC board.       |
| 0x01_0000 – 0x01_FFFF | **Parallel interface to Max10 LEDs**   | Read/Write      | Controls the Max10 LEDs through a 36-bit interface. |
| 0x02_0000 – 0x1F_FFFF | **Not Used**                           | None            | Available for future peripherals or unused.   |

### Detailed Peripheral Allocation:

1. **Interface User ID** (Offset: 0x00_0000 – 0x00_0003): This is a 32-bit read-only address used to identify the user interface.

2. **DE1-SoC Buttons (Keys)** (Offset: 0x00_0008 – 0x00_000B): These buttons are represented as 4 bits, allowing input actions (like control commands) from the DE1-SoC board.

3. **DE1-SoC Switches** (Offset: 0x00_000C – 0x00_000F): The 10 switches are used for configuration or selection inputs.

4. **DE1-SoC LEDs** (Offset: 0x00_0010 – 0x00_0013): The 10 LEDs reflect the state of the system or other visual feedback.

5. **Parallel Interface to Max10 LEDs** (Offset: 0x01_0000 – 0x01_007): This section is reserved for communication with the Max10 LED board. The Max10 has 36 direct links. The signals are divided into several groups, controlled using different signals such as `lp36_sel`, `lp36_data`, and `lp36_we` for selecting and controlling the LEDs.