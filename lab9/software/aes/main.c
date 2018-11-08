/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"

// Pointer to base address of AES module, make sure it matches Qsys
volatile unsigned int * AES_PTR = (unsigned int *) 0x00000100;

// Execution mode: 0 for testing, 1 for benchmarking
int run_mode = 0;

/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *  
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 */
char charToHex(char c)
{
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *  
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

//these can be optimized by... not... having them be function calls...
//but the lab specifically divides it like that, so eh, hope the compiler inlines 'em
void keyExpansion(uint key[4], uint w[44]) {
    uchar i;
    //copy key into first of 'em
    for (i=0;i<4;i++) w[i] = key[i];
    
    //then do stuff for the rest of 'em
    for (;i<44;i++) {
        w[i] = w[i-1];
        if (i % 4 == 0) 
            //w = subWord(rotWord(w)) xor Rcon[i/Nk]
            w[i] = (aes_sbox[w[i] >> 16 & 0xFF] << 24 |
                    aes_sbox[w[i] >>  8 & 0xFF] << 16 |
                    aes_sbox[w[i]       & 0xFF] <<  8 |
                    aes_sbox[w[i] >> 24 & 0xFF]
                ) ^ Rcon[i/4];
        //xor with older one
        w[i] ^= w[i-4];
    }
}
void addRoundKey(uchar state[16], uint **roundKey) {
    uchar i;
    for (i=0;i<4;i++) {
        state[4*i  ] ^= **roundKey >> 24 & 0xFF;
        state[4*i+1] ^= **roundKey >> 16 & 0xFF;
        state[4*i+2] ^= **roundKey >>  8 & 0xFF;
        state[4*i+3] ^= **roundKey       & 0xFF;
        (*roundKey)++;
    }
}
void subBytes(uchar state[16]) {
    uchar i;
    for (i=0;i<16;i++) state[i] = aes_sbox[state[i]];
}
void shiftRows(uchar s[16]) {
    //speed > artsiness :P
    //that said, this way is pretty damn ugly, but still, instruction memory is cheap :P
    uchar temp;
    //1 shift
    temp = s[0xd]; s[0xd] = s[0x1]; s[0x1] = s[0x5]; s[0x5] = s[0x9]; s[0x9] = temp;
    //2 shift (swap pairs)
    temp = s[0x2]; s[0x2] = s[0xa]; s[0xa] = temp;
    temp = s[0x6]; s[0x6] = s[0xe]; s[0xe] = temp;
    //3 shift (1 shift in reverse);
    temp = s[0x3]; s[0x3] = s[0xf]; s[0xf] = s[0xb]; s[0xb] = s[0x7]; s[0x7] = temp;
}
void mixColumns(uchar s[16]) {
    uchar i;
    //save state because the below can't be done on the fly
    uchar a[16];
    for (i=0;i<16;i++) a[i] = s[i];
    
    for (i=0;i<4;i++) {
        //gf_mul offsets
        //0     1     2     3     4     5
        //0x02, 0x03, 0x09, 0x0b, 0x0d, 0x0e
        s[0+4*i] = gf_mul[a[0+4*i]][0] ^ gf_mul[a[1+4*i]][1] ^        a[2+4*i]     ^        a[3+4*i]    ;
        s[1+4*i] =        a[0+4*i]     ^ gf_mul[a[1+4*i]][0] ^ gf_mul[a[2+4*i]][1] ^        a[3+4*i]    ;
        s[2+4*i] =        a[0+4*i]     ^        a[1+4*i]     ^ gf_mul[a[2+4*i]][0] ^ gf_mul[a[3+4*i]][1];
        s[3+4*i] = gf_mul[a[0+4*i]][1] ^        a[1+4*i]     ^        a[2+4*i]     ^ gf_mul[a[3+4*i]][0];
    }
}
/*
void shiftRows
void mixColumns
/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key)
{


    //key expansion
    sscanf(key_ascii, "%08x%08x%08x%08x", &key[0], &key[1], &key[2], &key[3]);
    uint w[44];
    keyExpansion(key, w);
    uint *roundKey = w;
    
    //set state to input message
    uchar state[16], i;
    for (i=0;i<16;i++) state[i] = charsToHex(msg_ascii[2*i], msg_ascii[2*i+1]);
    
    //do the things
    addRoundKey(state, &roundKey);
    for (i=0;i<9;i++) {
        subBytes(state);
        shiftRows(state);
        mixColumns(state);
        addRoundKey(state, &roundKey);
        /*
        printf("\n%d\n", i);
        uchar j,k;
        for(j=0; j < 4; printf("\n"), j++) for (k=0; k<4; k++) printf("%02x ", state[k*4+j]);
    	*/
    }
    subBytes(state);
    shiftRows(state);
    addRoundKey(state, &roundKey);
    //convert the thingie back into ints ;-;
    for (i=0;i<4;i++) 
        msg_enc[i] = state[4*i+0] << 24 |
                     state[4*i+1] << 16 |
                     state[4*i+2] <<  8 |
                     state[4*i+3]       ;

    AES_PTR[0] = key[0];
    AES_PTR[1] = key[1];
    AES_PTR[2] = key[2];
    AES_PTR[3] = key[3];
}

/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key)
{
	/*
	AES_PTR[0] = key[0];
	AES_PTR[1] = key[1];
	AES_PTR[2] = key[2];
	AES_PTR[3] = key[3];
	AES_PTR[4] = msg_enc[0];
	AES_PTR[5] = msg_enc[1];
	AES_PTR[6] = msg_enc[2];
	AES_PTR[7] = msg_enc[3];
	AES_PTR[14] = 1;

	while(AES_PTR[15] != 1){
		//spin
	}

	msg_dec[0] = AES_PTR[8];
	msg_dec[1] = AES_PTR[9];
	msg_dec[2] = AES_PTR[10];
	msg_dec[3] = AES_PTR[11];
	*/
}

/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */
int main()
{
	// Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
	unsigned char msg_ascii[33];
	unsigned char key_ascii[33];
	// Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
	unsigned int key[4];
	unsigned int msg_enc[4];
	unsigned int msg_dec[4];

	msg_dec[0] = 0;
	msg_dec[1] = 0;
	msg_dec[2] = 0;
	msg_dec[3] = 0;

	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		// Continuously Perform Encryption and Decryption
		while (1) {
			int i = 0;
			printf("\nEnter Message:\n");
			scanf("%s", msg_ascii);
			printf("\n");
			printf("\nEnter Key:\n");
			scanf("%s", key_ascii);
			printf("\n");
			encrypt(msg_ascii, key_ascii, msg_enc, key);
			printf("\nEncrpted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
			decrypt(msg_enc, msg_dec, key);
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_dec[i]);
			}
			printf("\n");
		}
	}
	else {
		// Run the Benchmark
		int i = 0;
		int size_KB = 2;
		// Choose a random Plaintext and Key
		for (i = 0; i < 32; i++) {
			msg_ascii[i] = 'a';
			key_ascii[i] = 'b';
		}
		// Run Encryption
		clock_t begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			encrypt(msg_ascii, key_ascii, msg_enc, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;
		printf("Software Encryption Speed: %f KB/s \n", speed);
		// Run Decryption
		begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			decrypt(msg_enc, msg_dec, key);
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;
		printf("Hardware Encryption Speed: %f KB/s \n", speed);
	}
	return 0;
}