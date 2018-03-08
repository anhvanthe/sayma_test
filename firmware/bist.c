#include <generated/csr.h>
#ifdef CSR_GENERATOR_BASE
#include "bist.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <console.h>

unsigned int write_ticks = 0;
unsigned int read_ticks = 0;
unsigned int read_errors = 0;

static void busy_wait(unsigned int ds)
{
	timer0_en_write(0);
	timer0_reload_write(0);
	timer0_load_write(SYSTEM_CLOCK_FREQUENCY/10*ds);
	timer0_en_write(1);
	timer0_update_value_write(1);
	while(timer0_value_read()) timer0_update_value_write(1);
}

static void write_test(unsigned int base, unsigned int length)
{
	generator_reset_write(1);
	generator_reset_write(0);
	generator_base_write(base);
	generator_length_write(length);
	generator_start_write(1);
	while(generator_done_read() == 0);
	write_ticks = generator_ticks_read();
}

static void read_test(unsigned int base, unsigned int length)
{
	checker_reset_write(1);
	checker_reset_write(0);
	checker_base_write(base);
	checker_length_write(length);
	checker_start_write(1);
	while(checker_done_read() == 0);
	read_ticks = checker_ticks_read();
	read_errors += checker_errors_read();
}

void bist_test(void) {
	int i = 0;
	while(readchar_nonblock() == 0) {
  			if(i%100 == 0) {
				printf("WR_SPEED(Gbps) RD_SPEED(Gbps)         ERRORS\n");
  			}
  			i++;
			// write test (1Gb)
			write_test(i%2048, 128*1024*1024);

			// read test (1Gb)
			read_test(i%2048, 128*1024*1024);

			// infos
			if (i%10 == 0) {
 				printf("%14u %14u %14u\n",
 					SYSTEM_CLOCK_FREQUENCY/write_ticks,
 					SYSTEM_CLOCK_FREQUENCY/read_ticks,
 					read_errors);
 			}

	}
}

#endif