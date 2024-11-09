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

void Keys_init(void)
{
}


void Switchs_init(void)
{
}

void Leds_init(void)
{
	Leds_write(LED_INIT);
}

bool Key_read(int key_number)
{
	return (AVL_REG(BUTTONS_OFFSET) & (1 << key_number)) == 0;
}

uint32_t Switchs_read(void)
{
	return (AVL_REG(SWITCHES_OFFSET) & SW90_BITMASK) >> SW90_SHIFT;
}

uint32_t Leds_read(void)
{
	return (AVL_REG(LEDS_OFFSET) & LED_BITMASK) >> LED_SHIFT;
}

void Leds_write(uint32_t value)
{
	AVL_REG(LEDS_OFFSET) = (AVL_REG(LEDS_OFFSET) & ~LED_BITMASK) | ((value << 16) & LED_BITMASK);
}

void Leds_set(uint32_t maskleds)
{
	AVL_REG(LEDS_OFFSET) |= (maskleds << LED_SHIFT);
}

void Leds_clear(uint32_t maskleds)
{
	AVL_REG(LEDS_OFFSET) &= ~(maskleds << LED_SHIFT);
}

void Leds_toggle(uint32_t maskleds)
{
	AVL_REG(LEDS_OFFSET) ^= (maskleds << LED_SHIFT) & LED_BITMASK;
}


