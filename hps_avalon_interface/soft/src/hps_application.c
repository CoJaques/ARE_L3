/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : hps_application.c
 * Author               : 
 * Date                 : 
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: Conception d'une interface simple sur le bus Avalon avec la carte DE1-SoC
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 
 *
*****************************************************************************************/
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include "axi_lw.h"
#include "avl_function.h"

#define LEDS_BY_ROW 5
#define ROWS	    5
#define LEDS_TOTAL  (LEDS_BY_ROW * ROWS)
#define NUM_KEYS    4

int __auto_semihosting;

void read_keys(bool *keys_state)
{
	for (int i = 0; i < NUM_KEYS; i++) {
		keys_state[i] = key_read(i);
	}
}

void update_old_keys(bool *keys_state, bool *keys_state_old)
{
	for (int i = 0; i < NUM_KEYS; i++) {
		keys_state_old[i] = keys_state[i];
	}
}

int main(void)
{
	printf("Laboratoire: Interface simple\n");
	printf("Constant ID interface = 0x%lx\n", (unsigned long)AVL_REG(ID));
	printf("Constant ID AXI_LW_HPS_FPGA_BASE_ADD = 0x%lx\n",
	       (unsigned long)AXI_REG(ID));

	// Init
	leds_init();
	if (lp36_init() != 1) {
		printf("Error: LP36 ERROR\n");
		return -1;
	}

	bool keys_state[NUM_KEYS] = { false, false, false, false };
	bool keys_state_old[NUM_KEYS] = { false, false, false, false };

	int dm_counter = 0;

	while (true) {
		volatile uint32_t switchs_value = switchs_read();
		read_keys(keys_state);

		// Update DE1-SoC LEDs based on switch values
		leds_write(switchs_value & 0x3FF);

		// Read SW9-8 to select which LEDs to update
		uint8_t sw98 = (switchs_value >> 8) & 0x3;

		// Read KEY1-0 to define the value to display on the selected LEDs
		uint8_t key10 = (keys_state[KEY_1] << 1) | keys_state[KEY_0];
		uint32_t leds_value = 0;

		switch (key10) {
		case 0: // Copy SW0-SW7 to the lower bits, upper bits off
			leds_value = switchs_value & 0xFF;
			break;
		case 1: // Display 1010...1010
			leds_value = 0xAAAAAAAA;
			break;
		case 2: // Display 0101...0101
			leds_value = 0x55555555;
			break;
		case 3: // Display 1111...1111
			leds_value = 0xFFFFFFFF;
			break;
		}

		// Handle KEY10 actions, make the LEDs rotate from left to right
		if (key10 == 0 && sw98 == 3) {
			leds_value =
				((leds_value << (LEDS_BY_ROW * dm_counter)) |
				 (leds_value >>
				  (LEDS_TOTAL - (LEDS_BY_ROW * dm_counter))));
		}

		// Handle KEY2 actions
		if (keys_state[KEY_2] && !keys_state_old[KEY_2]) {
			if (sw98 == 3 && key10 == 0) {
				dm_counter = (dm_counter + 1) % ROWS;
			}
		}

		lp36_write(leds_value, sw98);

		// Handle KEY3 actions -- clean
		if (keys_state[KEY_3] && !keys_state_old[KEY_3]) {
			// Turn off all LEDs on the Max10_leds board
			for (int i = 0; i < 4; i++) {
				lp36_write(0, i);
			}

			dm_counter = 0;
		}

		update_old_keys(keys_state, keys_state_old);
	}
}
