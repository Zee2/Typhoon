#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"

//this is definitely the industry-standard procedure for automating testing
#define main no
#include "main.c"
#undef main

//shh bby is ok
int main() {
    struct {
        unsigned char msg_ascii[33], key_ascii[33], enc_ascii[33];
    } tests[] = {
        {
            .msg_ascii = "ece298dcece298dcece298dcece298dc",
            .key_ascii = "000102030405060708090a0b0c0d0e0f", 
            .enc_ascii = "daec3055df058e1c39e814ea76f6747e"
        },
        {
            .msg_ascii = "dbe429ca8610ea6275b100476d87a2c5",
            .key_ascii = "3b280014beaac269d613a16bfdc2be03", 
            .enc_ascii = "439d619920ce415661019634f59fcf63"
        },
    };
    int i, j;
    
    for (i=0;i<sizeof(tests)/sizeof(tests[0]);i++) {
        unsigned int key[4];
        unsigned int msg_enc[4];
        encrypt(tests[i].msg_ascii, tests[i].key_ascii, msg_enc, key);
        
        char ret_ascii[33];
        char *p = ret_ascii;
        for (j=0;j<4;j++) p += sprintf(p, "%08x", msg_enc[j]);
        
        printf("\nTest case %d\n", i);
        printf("Message : %s\n", tests[i].msg_ascii);
        printf("Key     : %s\n", tests[i].key_ascii);
        printf("Expected: %s\n", tests[i].enc_ascii);
        printf("Returned: %s\n", ret_ascii);
        if (strcmp(tests[i].enc_ascii, ret_ascii)) {
            printf("Test failed! :(\n");
            break;
        }
        else printf("Test passed!\n");
    }
    
	return 0;
}
