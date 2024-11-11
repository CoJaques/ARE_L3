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
#include <unistd.h>
#include <stdio.h>

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

uint32_t lp36_init(void)
{
	uint32_t status = lp36_status();

	if (status != 1) {
		return status;
	}

	for (int i = 0; i < 4; i++) {
		lp36_write(0, i);
	}

	return 1;
}

uint32_t lp36_status(void)
{
	return AVL_REG(LP36_STATUS);
}

uint32_t is_lp36_ready(void)
{
	return AVL_REG(LP36_READY);
}

void lp36_write(uint32_t data, uint8_t sel)
{
	int ok = 0;

	// Wait up to 50 µs for LP36 to be ready
	for (int i = 0; i < 5;
	     i++) { // Check every 10 µs, up to 5 iterations (50 µs total)
		if (is_lp36_ready()) {
			ok = 1;
			break; // Ready, exit the loop
		}
		// TODO MANAGE time
	}

	if (!ok)
		printf("error no time \n");

	if (sel == 3)
		printf("Data : %u mode : %u \n", data, sel);

	AVL_REG(LP36_DATA) = data;
	AVL_REG(LP36_SEL) = sel;
}
