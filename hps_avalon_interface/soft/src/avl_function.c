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

void leds_init(void)
{
	leds_write(0);
}

bool key_read(int key_number)
{
	return (AVL_REG(BUTTONS) & (1 << key_number)) == 0;
}

uint32_t switchs_read(void)
{
	return AVL_REG(SWITCHES);
}

uint32_t leds_read(void)
{
	return AVL_REG(LEDS);
}

void leds_write(uint32_t value)
{
	AVL_REG(LEDS) = value;
}

void leds_set(uint32_t maskleds)
{
	AVL_REG(LEDS) |= maskleds;
}

void leds_clear(uint32_t maskleds)
{
	AVL_REG(LEDS) &= ~maskleds;
}

void leds_toggle(uint32_t maskleds)
{
	AVL_REG(LEDS) ^= maskleds;
}

uint32_t lp36_status(void)
{
	return AVL_REG(LP36_STATUS);
}

uint32_t is_lp36_ready(void)
{
	return lp36_status();
}

void lp36_write(uint32_t data, uint8_t sel)
{
	AVL_REG(LP36_DATA) = data;
	AVL_REG(LP36_SEL) = sel;
}
