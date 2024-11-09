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
 * Brief: Pio function
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
#define PIO_CORE0_BASE_ADD (AXI_LW_HPS_FPGA_BASE_ADD + 0x100)

// ACCESS MACROS
#define PIO0_REG(_x_)   *(volatile uint32_t *)(PIO_CORE0_BASE_ADD + _x_)

// PIO Registers
#define	DATA 0x00
#define DIRECTION 0x04

// Define PIO bitmask
#define SW90_BITMASK      0x00003FF0
#define LED_BITMASK       0x03FF0000
#define SEG7_BITMASK      0x0FFFFFFF

// Shift
#define SW90_SHIFT        4
#define LED_SHIFT         16

// Init
#define KEY_INIT          0xF
#define LED_INIT          0x155

// Util
#define ARRAY_SIZE        16

//***************************//
//****** Init function ******//

// Swicths_init function : Initialize all Switchs in PIO core (SW9 to SW0)
void Switchs_init(void);

// Leds_init function : Initialize all Leds in PIO core (LED9 to LED0)
void Leds_init(void);

// Keys_init function : Initialize all Keys in PIO core (KEY3 to KEY0)
void Keys_init(void);

//***********************************//
//****** Global usage function ******//

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

// Key_read function : Read one Key status, pressed or not (KEY0 or KEY1 or KEY2 or KEY3)
// Parameter : "key_number"= select the key number to read, from 0 to 3
// Return : True(1) if key is pressed, and False(0) if key is not pressed
bool Key_read(int key_number);