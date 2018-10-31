#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"

//this is definitely the industry-standard procedure for automating testing
#define main no
#include "main.c"
#undef main

//<3
void softwareDecrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key);

//shh bby is ok
int main() {
    //STATIC TEST CASES
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
        }
    };
    int i, j;
    
    for (i=0;i<sizeof(tests)/sizeof(tests[0]);i++) {
        unsigned int key[4];
        unsigned int msg_enc[4];
        encrypt(tests[i].msg_ascii, tests[i].key_ascii, msg_enc, key);
        
        char ret_ascii[33];
        char *p = ret_ascii;
        for (j=0;j<4;j++) p += sprintf(p, "%08x", msg_enc[j]);
        
        printf("\nStatic test case %d\n", i);
        printf("Message : %s\n", tests[i].msg_ascii);
        printf("Key     : %s\n", tests[i].key_ascii);
        printf("Expected: %s\n", tests[i].enc_ascii);
        printf("Returned: %s\n", ret_ascii);
        if (strcmp(tests[i].enc_ascii, ret_ascii)) {
            printf("Test failed! :(\n");
            return 0;
        }
        else printf("Test passed!\n");
    }
    
    printf("\n\n");
    //AUTOMATIC TEST CASES
    srand(time(0));
    for (i=0;1;i++) {
        //warning terrible code ahead
        unsigned char msg_ascii[33], key_ascii[33];
        unsigned int key[4];
        unsigned int msg_enc[4];
        unsigned int msg_dec[4];
        
        const char dict[17] = "0123456789abcdef";
        for (j=0;j<32;j++) {
            msg_ascii[j] = dict[rand()%16];
            key_ascii[j] = dict[rand()%16];
        }
        msg_ascii[32] = key_ascii[32] = 0;
        
        encrypt(msg_ascii, key_ascii, msg_enc, key);
        softwareDecrypt(msg_enc, msg_dec, key);
        
        char enc_ascii[33];
        char *p = enc_ascii;
        for (j=0;j<4;j++) p += sprintf(p, "%08x", msg_enc[j]);
        
        char dec_ascii[33];
        p = dec_ascii;
        for (j=0;j<4;j++) p += sprintf(p, "%08x", msg_dec[j]);
        if (strcmp(msg_ascii, dec_ascii)) {
            printf("Message : %s\n", msg_ascii);
            printf("Key     : %s\n", key_ascii);
            printf("Encrypt : %s\n", enc_ascii);
            printf("Decrypt : %s\n", dec_ascii);
            printf("%d Test failed! :(\n", i);
            return 0;
        }
        else printf("%d Test passed! Message: %s\n", i, msg_ascii);
    }
	return 0;
}

//this one is NOT gonna be turned in, it's just for auto testing the encryption
//so this is quick and sloppy
void softwareDecrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key) {
    //key expansion
    uint w[44];
    keyExpansion(key, w);
    uint *roundKey = &w[40];
    
    //set state to input message
    uchar state[16], i;
    for (i=0;i<4;i++) {
        state[4*i+0] = msg_enc[i] >> 24 & 0xFF;
        state[4*i+1] = msg_enc[i] >> 16 & 0xFF;
        state[4*i+2] = msg_enc[i] >>  8 & 0xFF;
        state[4*i+3] = msg_enc[i]       & 0xFF;
    }
    
    //impl below
    void invAddRoundKey(uchar s[16], uint **roundKey);
    void invSubBytes(uchar s[16]);
    void invShiftRows(uchar s[16]);
    void invMixColumns(uchar s[16]);
    
    //do the things
    invAddRoundKey(state, &roundKey);
    for (i=0;i<9;i++) {
        invShiftRows(state);
        invSubBytes(state);
        invAddRoundKey(state, &roundKey);
        invMixColumns(state);
    }
    invSubBytes(state);
    invShiftRows(state);
    invAddRoundKey(state, &roundKey);
    //convert the thingie back into ints ;-;
    for (i=0;i<4;i++) 
        msg_dec[i] = state[4*i+0] << 24 |
                     state[4*i+1] << 16 |
                     state[4*i+2] <<  8 |
                     state[4*i+3]       ;
}

void invSubBytes(uchar state[16]) {
    uchar i;
    for (i=0;i<16;i++) state[i] = aes_invsbox[state[i]];
}

void invShiftRows(uchar s[16]) {
    //you saw up there where it says this is quick and sloppy, right?
    //...just making sure
    shiftRows(s);
    shiftRows(s);
    shiftRows(s);
}

void invMixColumns(uchar s[16]) {
    uchar i;
    //save state because the below can't be done on the fly
    uchar a[16];
    for (i=0;i<16;i++) a[i] = s[i];
    
    for (i=0;i<4;i++) {
        //gf_mul offsets
        //0     1     2     3     4     5
        //0x02, 0x03, 0x09, 0x0b, 0x0d, 0x0e
        s[0+4*i] = gf_mul[a[0+4*i]][5] ^ gf_mul[a[1+4*i]][3] ^ gf_mul[a[2+4*i]][4] ^ gf_mul[a[3+4*i]][2];
        s[1+4*i] = gf_mul[a[0+4*i]][2] ^ gf_mul[a[1+4*i]][5] ^ gf_mul[a[2+4*i]][3] ^ gf_mul[a[3+4*i]][4];
        s[2+4*i] = gf_mul[a[0+4*i]][4] ^ gf_mul[a[1+4*i]][2] ^ gf_mul[a[2+4*i]][5] ^ gf_mul[a[3+4*i]][3];
        s[3+4*i] = gf_mul[a[0+4*i]][3] ^ gf_mul[a[1+4*i]][4] ^ gf_mul[a[2+4*i]][2] ^ gf_mul[a[3+4*i]][5];
    }
}

void invAddRoundKey(uchar state[16], uint **roundKey) {
    uchar i;
    for (i=0;i<4;i++) {
        state[4*i  ] ^= **roundKey >> 24 & 0xFF;
        state[4*i+1] ^= **roundKey >> 16 & 0xFF;
        state[4*i+2] ^= **roundKey >>  8 & 0xFF;
        state[4*i+3] ^= **roundKey       & 0xFF;
        (*roundKey)++;
    }
    (*roundKey) -= 8;
}