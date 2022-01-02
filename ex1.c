// 206821258 Idan Simai

#include "ex1.h"
/*
 * This function checks whether the machine supports BIG or LITTLE endian.
 */
int is_big_endian() {
    long check = 2;
    //Here we create a new pointer which points to the address our checker is stored.
    char *c = (char*) & check;
    //If it's little, we return 0;Else we return 1.
    if (*c) {
        return 0;
    }
    else
    return 1;
}

/*
 * This function deals with merging bytes of two unsigned long ints.
 * We use Bitwise operators to achieve that.
 */
unsigned long merge_bytes(unsigned long x, unsigned long int y) {
    //We use masks to achieve that.
    unsigned long checker1 = 0xFFFFFFFF00000000;
    unsigned long checker2 = 0x00000000FFFFFFFF;
    //We return the bitwised integer.
        x = x & checker1;
        y = y & checker2;
        return (x | y);

}

/*
 * This function deals with changing 1 byte in an unsigned long int.
 * We use 2 for loops to achieve that.
 */
unsigned long put_byte(unsigned long x, unsigned char b, int i) {
    unsigned char *value = (unsigned char*) & x;
    unsigned char check [sizeof(long )];
    //Here, if the machine uses big, the i numbered byte is the one with the lowest address + i.
    if(is_big_endian()) {
        for (int j = 0; j < sizeof(long); ++j) {
            check[j] = value[j];
            if(j == (sizeof(long) - 1 - i)) {
                check[j] = b;
            }
        }
    }
    //Here, if the machine uses little, the i numbered byte is the one with the highest address - i.
    if(!is_big_endian()) {
        for (int j = sizeof(long) - 1; j >= 0; --j) {
            check[j] = value[j];
            if(j == (sizeof(long) - 1 - i)) {
                check[j] = b;
            }
        }
    }
    //We return a casted pointer which is our wanted.
    unsigned long * a = (unsigned long*)check;
    return *a;
}

