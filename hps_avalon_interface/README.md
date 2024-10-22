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

# In the addressing plan, the size of the zone available for your interface correspond to the 14 address bits defined in the Avalon bus? Why?



# Address plan

| **Offset**            | **Peripheral**                         | **Access Type**  | **Description**                               |
|-----------------------|----------------------------------------|------------------|-----------------------------------------------|
| 0x01_0000 – 0x01_0003 | **Interface user ID (32-bit)**          | Read Only        | 32-bit user ID for identification.            |
| 0x01_0004 – 0x01_0007 | **DE1-SoC Buttons (4 Keys)**           | Read/Write       | Access to 4 buttons on the DE1-SoC board.     |
| 0x01_0008 – 0x01_000B | **DE1-SoC Switches (10 Switches)**     | Read/Write       | Access to 10 switches on the DE1-SoC board.   |
| 0x01_000C – 0x01_001F | **DE1-SoC LEDs (10 LEDs)**             | Read/Write       | Access to 10 LEDs on the DE1-SoC board.       |
| 0x01_0020 – 0x01_002F | **Parallel Interface to Max10 LEDs**   | Read/Write       | Controls the Max10 LEDs through a 36-bit parallel interface. |