/* addchecksum.c -- Calculate byte-wise checksum and overwrite last byte for PCI 
 * Copyright (C) 2014, Tobias Kaiser <mail@tb-kaiser.de>
 */ 

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if(argc!=2) {
        fprintf(stderr, "Usage: %s FILE\n\n", argv[0]);
        exit(1);
    }
    FILE *f=fopen(argv[1], "r+");
    if(!f) {
        perror("fopen failed");
        exit(1);
    }
    fseek(f, 0, SEEK_END);
    int f_size=ftell(f);
    fseek(f, 0, SEEK_SET);
    unsigned char sum=0;
    int i;
    for(i=0;i<f_size-1;i++) {
        sum+=fgetc(f);
    }
    fputc((0x100-sum)&0xff, f);
    fclose(f);
    return 0; 
}
