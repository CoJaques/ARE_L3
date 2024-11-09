/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : avl_function.c
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
#include "avl_function.h"

void Switchs_init(void)
{
	AVL_REG(DIRECTION) &= ~SW90_BITMASK; // Set direction to input
}

void Leds_init(void)
{
	AVL_REG(DIRECTION) |= LED_BITMASK; // Set direction to output
	Leds_write(LED_INIT);
}

void Keys_init(void)
{
	AVL_REG(DIRECTION) &= ~KEY_INIT; // Set direction to input
}

uint32_t Leds_read(void)
{
	return (AVL_REG(DATA) & LED_BITMASK) >> LED_SHIFT;
}

void Leds_write(uint32_t value)
{
	AVL_REG(DATA) = (AVL_REG(DATA) & ~LED_BITMASK) | ((value << 16) & LED_BITMASK);
}

void Leds_set(uint32_t maskleds)
{
	AVL_REG(DATA) |= (maskleds << LED_SHIFT);
}

void Leds_clear(uint32_t maskleds)
{
	AVL_REG(DATA) &= ~(maskleds << LED_SHIFT);
}

void Leds_toggle(uint32_t maskleds)
{
	AVL_REG(DATA) ^= (maskleds << LED_SHIFT) & LED_BITMASK;
}

bool Key_read(int key_number)
{
	return (AVL_REG(DATA) & (1 << key_number)) == 0;
}

