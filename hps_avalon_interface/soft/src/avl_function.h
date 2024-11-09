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
#define AVL_REG(_x_)   *(volatile uint32_t *)(AVL_BASE_ADD + _x_)

// Offset
#define ID_OFFSET          0x0000
#define BUTTONS_OFFSET     0x0004
#define SWITCHES_OFFSET    0x000C
#define LP36_STATUS_OFFSET 0x0010
#define LP36_READY_OFFSET  0x0014
#define LEDS_OFFSET        0x0080
#define LP36_SEL_OFFSET    0x0084
#define LP36_DATA_OFFSET   0x0088

// Define AVL bitmask
#define SW90_BITMASK      0x000003FF
#define LED_BITMASK       0x000003FF

// Init
#define KEY_INIT          0xF
#define LED_INIT          0x155


//***************************//
//****** Init function ******//

// Keys_init function : Initialize all Keys in PIO core (KEY3 to KEY0)
void Keys_init(void);

// Swicths_init function : Initialize all Switchs in PIO core (SW9 to SW0)
void Switchs_init(void);

// Leds_init function : Initialize all Leds in PIO core (LED9 to LED0)
void Leds_init(void);

//***********************************//
//****** Global usage function ******//

// Key_read function : Read one Key status, pressed or not (KEY0 or KEY1 or KEY2 or KEY3)
// Parameter : "key_number"= select the key number to read, from 0 to 3
// Return : True(1) if key is pressed, and False(0) if key is not pressed
bool Key_read(int key_number);

// Switchs_read function : Read the switchs value
// Parameter : None
// Return : Value of all Switchs (SW9 to SW0)
uint32_t Switchs_read(void);

// Leds_read function : Read the leds value
// Parameter : None
// Return : Value of all leds (Led7 to Led0)
uint32_t Leds_read(void);

// Leds_write function : Write a value to all Leds (LED9 to LED0)
// Parameter : "value"= data to be applied to all Leds
// Return : None
void Leds_write(uint32_t value);

// Leds_set function : Set to ON some or all Leds (LED9 to LED0)
// Parameter : "maskleds"= Leds selected to apply a set (maximum 0x3FF)
// Return : None
void Leds_set(uint32_t maskleds);

// Leds_clear function : Clear to OFF some or all Leds (LED9 to LED0)
// Parameter : "maskleds"= Leds selected to apply a clear (maximum 0x3FF)
// Return : None
void Leds_clear(uint32_t maskleds);

// Leds_toggle function : Toggle the curent value of some or all Leds (LED9 to LED0)
// Parameter : "maskleds"= Leds selected to apply a toggle (maximum 0x3FF)
// Return : None
void Leds_toggle(uint32_t maskleds);
