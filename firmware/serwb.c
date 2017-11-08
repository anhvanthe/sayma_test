#include <generated/csr.h>
#ifdef CSR_SERWB_PHY_BASE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <generated/mem.h>
#include <system.h>
#include <console.h>

#include "serwb.h"

static void busy_wait(unsigned int ds)
{
	timer0_en_write(0);
	timer0_reload_write(0);
	timer0_load_write(CONFIG_CLOCK_FREQUENCY/10*ds);
	timer0_en_write(1);
	timer0_update_value_write(1);
	while(timer0_value_read()) {
		timer0_update_value_write(1);
	}
}

void serwb_init(void)
{
	int timeout = 10;

	serwb_phy_control_reset_write(1);
	while (((serwb_phy_control_ready_read() & 0x1) == 0) &
		   ((serwb_phy_control_error_read() & 0x1) == 0) &
		   (timeout > 0)) {
		busy_wait(1);
	    timeout--;
	}

	printf("delay_min_found: %d\n", serwb_phy_control_delay_min_found_read());
	printf("delay_min: %d\n", serwb_phy_control_delay_min_read());
	printf("delay_max_found: %d\n", serwb_phy_control_delay_max_found_read());
	printf("delay_max: %d\n", serwb_phy_control_delay_max_read());
	printf("bitslip: %d\n", serwb_phy_control_bitslip_read());
	printf("ready: %d\n", serwb_phy_control_ready_read());
	printf("error: %d\n", serwb_phy_control_error_read());
}


static unsigned int seed_to_data_32(unsigned int seed, int random)
{
	if (random)
		return 1664525*seed + 1013904223;
	else
		return seed + 1;
}

void serwb_test(void)
{
	volatile unsigned int *array = (unsigned int *)SERWB_BASE;
	int i, errors;
	unsigned int seed_32;

	errors = 0;
	seed_32 = 0;

	for(i=0;i<SERWB_SIZE/4;i++) {
		seed_32 = seed_to_data_32(seed_32, 1);
		array[i] = seed_32;
	}

	seed_32 = 0;
	flush_cpu_dcache();
	for(i=0;i<SERWB_SIZE/4;i++) {
		seed_32 = seed_to_data_32(seed_32, 1);
		if(array[i] != seed_32)
			errors++;
	}

	printf("errors: %d/%d\n", errors, SERWB_SIZE/4);
}

#define NUMBER_OF_BYTES_ON_A_LINE 16
static void dump_bytes(unsigned int *ptr, int count, unsigned addr)
{
	char *data = (char *)ptr;
	int line_bytes = 0, i = 0;

	putsnonl("Memory dump:");
	while(count > 0){
		line_bytes =
			(count > NUMBER_OF_BYTES_ON_A_LINE)?
				NUMBER_OF_BYTES_ON_A_LINE : count;

		printf("\n0x%08x  ", addr);
		for(i=0;i<line_bytes;i++)
			printf("%02x ", *(unsigned char *)(data+i));

		for(;i<NUMBER_OF_BYTES_ON_A_LINE;i++)
			printf("   ");

		printf(" ");

		for(i=0;i<line_bytes;i++) {
			if((*(data+i) < 0x20) || (*(data+i) > 0x7e))
				printf(".");
			else
				printf("%c", *(data+i));
		}

		for(;i<NUMBER_OF_BYTES_ON_A_LINE;i++)
			printf(" ");

		data += (char)line_bytes;
		count -= line_bytes;
		addr += line_bytes;
	}
	printf("\n");
}

void serwb_dump(void)
{
	dump_bytes((unsigned int *)SERWB_BASE, SERWB_SIZE, (unsigned)SERWB_BASE);
}

#endif
