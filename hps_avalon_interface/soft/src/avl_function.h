/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : avl_function.h
 * Author               :
 * Date                 :
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: AVL function
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 0.0    14.14.2024  TMU & CJS    AVL source function
 *
*****************************************************************************************/

#include <stdint.h>
#include <stdbool.h>
#include "axi_lw.h"

// Base address
#define AVL_BASE_ADD (AXI_LW_HPS_FPGA_BASE_ADD + 0x10000)

// Access macro
#define AVL_REG(_x_) *(volatile uint32_t *)(AVL_BASE_ADD + _x_)

// Offset
#define ID	     0x0000
#define BUTTONS	     0x0004
#define SWITCHES     0x000C
#define LP36_STATUS  0x0010
#define LP36_READY   0x0014
#define LEDS	     0x0080
#define LP36_SEL     0x0084
#define LP36_DATA    0x0088

#define NUM_KEYS     4
#define KEY_0	     0
#define KEY_1	     1
#define KEY_2	     2
#define KEY_3	     3
//***************************//
//****** Init function ******//

// Leds_init function : Initialize all Leds in PIO core (LED9 to LED0)
void leds_init(void);

//***********************************//
//****** Global usage function ******//

// Key_read function : Read one Key status, pressed or not (KEY0 or KEY1 or KEY2 or KEY3)
// Parameter : "key_number"= select the key number to read, from 0 to 3
// Return : True(1) if key is pressed, and False(0) if key is not pressed
bool key_read(int key_number);

// Switchs_read function : Read the switchs value
// Parameter : None
// Return : Value of all Switchs (SW9 to SW0)
uint32_t switchs_read(void);

// Leds_read function : Read the leds value
// Parameter : None
// Return : Value of all leds (Led7 to Led0)
uint32_t leds_read(void);

// Leds_write function : Write a value to all Leds (LED9 to LED0)
// Parameter : "value"= data to be applied to all Leds
// Return : None
void leds_write(uint32_t value);

// Leds_set function : Set to ON some or all Leds (LED9 to LED0)
// Parameter : "maskleds"= Leds selected to apply a set (maximum 0x3FF)
// Return : None
void leds_set(uint32_t maskleds);

// Leds_clear function : Clear to OFF some or all Leds (LED9 to LED0)
// Parameter : "maskleds"= Leds selected to apply a clear (maximum 0x3FF)
// Return : None
void leds_clear(uint32_t maskleds);

// Leds_toggle function : Toggle the curent value of some or all Leds (LED9 to LED0)
// Parameter : "maskleds"= Leds selected to apply a toggle (maximum 0x3FF)
// Return : None
void leds_toggle(uint32_t maskleds);

// lp36_init function : Initialize the LP36 and get the status to check if it is ready
// Parameter : None
// Return : Status of the LP36, must be 1 if lp36 is ready
uint32_t lp36_init(void);

// lp36 status function : Read the status of the LP36
// Parameter : None
// Return : Status of the LP36
uint32_t lp36_status(void);

// is_lp36_ready function : Check if the LP36 is ready
// Parameter : None
// Return : True(1) if LP36 is ready, and False(0) if LP36 is not ready
uint32_t is_lp36_ready(void);

// lp36_write function : Write a value to the LP36
// Parameter : "data"= data to be applied to the LP36
// "sel"= select the LP36 to write, from 0 to 3
// return : None
void lp36_write(uint32_t data, uint8_t sel);
