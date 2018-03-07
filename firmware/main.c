#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <irq.h>
#include <uart.h>
#include <console.h>

#include "sdram.h"
#include "serwb.h"

static char *readstr(void)
{
	char c[2];
	static char s[64];
	static int ptr = 0;

	if(readchar_nonblock()) {
		c[0] = readchar();
		c[1] = 0;
		switch(c[0]) {
			case 0x7f:
			case 0x08:
				if(ptr > 0) {
					ptr--;
					putsnonl("\x08 \x08");
				}
				break;
			case 0x07:
				break;
			case '\r':
			case '\n':
				s[ptr] = 0x00;
				putsnonl("\n");
				ptr = 0;
				return s;
			default:
				if(ptr >= (sizeof(s) - 1))
					break;
				putsnonl(c);
				s[ptr] = c[0];
				ptr++;
				break;
		}
	}

	return NULL;
}

static char *get_token(char **str)
{
	char *c, *d;

	c = (char *)strchr(*str, ' ');
	if(c == NULL) {
		d = *str;
		*str = *str+strlen(*str);
		return d;
	}
	*c = 0;
	d = *str;
	*str = c+1;
	return d;
}

static void prompt(void)
{
	printf("RUNTIME>");
}

static void help(void)
{
	puts("Available commands:");
	puts("help        - this command");
	puts("reboot      - reboot CPU");
#ifdef CSR_SDRAM_BASE
	puts("memdqs      - get dqs taps");
	puts("meminit     - run a memory initialization");
	puts("memtest     - run a memory test");
#endif
#ifdef CSR_SERWB_PHY_BASE
    puts("serwb_init  - (re)initialize SERWB link");
	puts("serwb_test  - test SERWB link");
	puts("serwb_dump  - dump SERBWB remote memory");
#endif
}

static void reboot(void)
{
	asm("call r0");
}

static void memdqs(void) {
	printf("dqs taps after init: %d\n", ddrphy_wdly_dqs_taps_read());
	ddrphy_en_vtc_write(0);
	ddrphy_dly_sel_write(1 << 0);
	ddrphy_wdly_dq_rst_write(1);
	ddrphy_wdly_dqs_rst_write(1);
	printf("dqs taps after reset: %d\n", ddrphy_wdly_dqs_taps_read());
	ddrphy_en_vtc_write(1);
}

static void console_service(void)
{
	char *str;
	char *token;

	str = readstr();
	if(str == NULL) return;
	token = get_token(&str);
	if(strcmp(token, "help") == 0)
		help();
	else if(strcmp(token, "reboot") == 0)
		reboot();
#ifdef CSR_SDRAM_BASE
	else if(strcmp(token, "memdqs") == 0)
		memdqs();
	else if(strcmp(token, "meminit") == 0)
		sdrinit();
	else if(strcmp(token, "memtest") == 0)
		memtest();
#endif
#ifdef CSR_SERWB_PHY_BASE
	else if(strcmp(token, "serwb_init") == 0)
		serwb_init();
	else if(strcmp(token, "serwb_test") == 0)
		serwb_test();
	else if(strcmp(token, "serwb_dump") == 0)
		serwb_dump();
#endif
	prompt();
}

int main(void)
{
	irq_setmask(0);
	irq_setie(1);
	uart_init();

	puts("\nSayma AMC CPU testing software built "__DATE__" "__TIME__);
	prompt();

	while(1) {
		console_service();
	}

	return 0;
}


