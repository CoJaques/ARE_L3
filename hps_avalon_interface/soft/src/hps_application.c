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

int __auto_semihosting;

int main(void){
    
    printf("Laboratoire: Conception d'une interface simple \n");

    //****** Init ******//
    Switchs_init();
    Leds_init();
    Keys_init();

    // Variables to track the previous state of keys (pressed or not)
    uint8_t wasKEY0Pressed = 0;
    uint8_t wasKEY1Pressed = 0;
    uint8_t wasKEY2Pressed = 0;
    uint8_t wasKEY3Pressed = 0;

    printf("The constant ID is: 0x%X \n", AXI_LW_REG(0x0));

    while(true)
    {
        uint8_t isKEY0Pressed = Key_read(0);
        uint8_t isKEY1Pressed = Key_read(1);
        uint8_t isKEY2Pressed = Key_read(2);
        uint8_t isKEY3Pressed = Key_read(3);

        const uint32_t switchs_read = Switchs_read();
        const uint32_t SW70         = switchs_read & 0x0FF;
        const uint32_t SW98         = switchs_read >> 8;

        if(isKEY0Pressed && !wasKEY0Pressed)
        {
            if (SW98 == 0x0)
            {
                Leds_write(SW70);
            }
            else if(SW98 == 0x1)
            {
                Leds_set(SW70);
            }
            else if(SW98 == 0x2)
            {
                Leds_clear(SW70);
            }
            else
            {
                Leds_toggle(0xFF);
            }
        }

        if(isKEY1Pressed && !wasKEY1Pressed)
        {

        }

        if(isKEY2Pressed && !wasKEY2Pressed)
        {

        }

        if(isKEY3Pressed && !wasKEY3Pressed)
        {

        }

        // Update the previous key states for the next loop iteration
        wasKEY0Pressed = isKEY0Pressed;
        wasKEY1Pressed = isKEY1Pressed;
        wasKEY2Pressed = isKEY2Pressed;
        wasKEY3Pressed = isKEY3Pressed;
    }
}
