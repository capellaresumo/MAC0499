#include "omsp_system.h"
#include "hardware.h"
#include "cprintf.h"
#include <stdlib.h>
#include <stdio.h>

char sha256_flush (char init) {
    if (init) {
        init = 0;
        SHA_CONFIG = SHA_MODE | SHA_INIT | SHA_ON;
    } else {
        SHA_CONFIG = SHA_MODE | SHA_NEXT | SHA_ON;
    }

    SHA_CONFIG = SHA_MODE | SHA_ON;
    while (!(SHA_STATUS & (SHA_READY)));
    
    return init;
}

// the return value are in the periphel
void sha256 (unsigned char *str, unsigned int length) {
    unsigned long size = length * 8;
    unsigned int i = 0;
    char init = 1;

    unsigned long in;

    while (i <= length/4) {
        in = 0;
        for (unsigned int j = 0; j < 4; j++) {
            if (i*4+j < length) {
                ((unsigned char *) &in)[3-j] = str[i*4+j];
            } else if (i*4+j == length) {
                ((unsigned char *) &in)[3-j] = 0x80;
                break;
            }
        }

        (&SHA_INPUT)[15 - i%16] = in;
        i++;

        if (i%16 == 0 && i != 0)
            init = sha256_flush(init);
    }

    // set zeros
    for (unsigned int j = i%16; j < 15; j++) {
        (&SHA_INPUT)[15 - i%16] = 0;
        i++;
    }
    (&SHA_INPUT)[15 - i%16] = size;

    sha256_flush(init);
}

//--------------------------------------------------//
// Main function with init an an endless loop that  //
// is synced with the interrupts trough the         //
// lowpower mode.                                   //
//--------------------------------------------------//
int main(void) {

    unsigned char string[] = "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.";

    WDTCTL = WDTPW | WDTHOLD;           // Init watchdog timer

    UART_BAUD = BAUD;                   // Init UART
    UART_CTL  = UART_EN | UART_IEN_RX;

    sha256(string, 89);


    for (int i = 0; i < 16; ++i) {
        unsigned int c = ((unsigned int *)&SHA_OUTPUT)[15-i];
        cprintf("%w", c);
    }
    cprintf("\n");

    while(1) {
    }

}