#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ex1.h"
#include <inttypes.h>
int main(int argc, char **argv) {
	if (strcmp(argv[1], "--is-big-endian") == 0)
	{
		printf("%d", is_big_endian());
		return 0;
	}

	if (strcmp(argv[1], "--merge-bytes") == 0)
	{
		uint64_t val1 = (uint64_t) strtoul(argv[2], NULL, 16);
		uint64_t val2 = (uint64_t) strtoul(argv[3], NULL, 16);

		printf("%016lX", merge_bytes(val1, val2));
		return 0;
	}

	if (strcmp(argv[1], "--put-byte") == 0)
	{
		uint64_t val = strtoul(argv[2], NULL, 16);
		unsigned char b = strtol(argv[3], NULL, 16);
		unsigned char i = strtol(argv[4], NULL, 10);

		printf("%016lX", put_byte(val, b, i));
		return 0;
	}

	return -1;
}