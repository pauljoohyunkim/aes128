//AES128 - CTR Encryptor
//

#include <stdio.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "aes128_info.h"
#define NUM_OF_ROUND_KEY 11

void nonce_gen();
void counter_inc();
void xor(uint8_t* a, uint8_t* b);
void aes(uint8_t* buffer);
void key_schedule();
void sbox_text(uint8_t* buffer);
void permutation();
void switch_pos(int a, int b);
void mult(uint8_t* buffer);


uint8_t buffer[16] = {0};
uint8_t key[16] = {0};
uint8_t expanded_key[16 * NUM_OF_ROUND_KEY] = {0};          //11 is the number of round keys.
uint8_t nonce[16];
uint8_t counter_vec[16] = {0};
uint8_t inputBuffer[16];
unsigned long long filelen = 0;

int main(int argc, char** argv)
{
    if(argc != 4)
    {
        printf("Syntax: aes128_enc [input filename] [16-byte key file] [output filename]\n");
        return 1;
    }
    //Input filename argv[1]
    //Keyfile argv[2]
    //Output filename argv[3]
    if(strcmp(argv[1],argv[3]) == 0)
    {
        printf("Input file has the same name as the output name. This will cause a problem. Aborted.\n");
        return 1;
    }

    //Reading Key
    FILE* keyfile = fopen(argv[2],"rb");
    fread(key,1,16,keyfile);
    fclose(keyfile);

    key_schedule();

    //Finding length of input file.
    struct stat st;
    stat(argv[1], &st);
    filelen = st.st_size;

    //Generating nonce
    nonce_gen();

    //Reading the file, 16 byte at a time, and using AES-CTR to encrypt (nonce ^ counter),
    //and xor-ing the encrypted (nonce ^ counter) with the previously read 16 bytes.
    FILE* input = fopen(argv[1],"rb");
    FILE* output = fopen(argv[3],"wb");


    unsigned long long num_of_full_blocks = filelen / 16;
    unsigned long long len_of_incomplete_block = filelen % 16;

    //Writing nonce in the beginning of the encrypted file.
    fwrite(nonce,1,16,output);

    //Full blocks
    for(int counter = 0; counter < num_of_full_blocks; counter++)
    {
        fread(inputBuffer,1,16,input);
        xor(nonce, counter_vec);                //Xoring nonce and counter, and then storing into buffer
        counter_inc();                      //Increase counter for next block.
        aes(buffer);                              //Perform aes128 encryption to create counter block in buffer
        xor(inputBuffer,buffer);            //Xoring inputBuffer and buffer, and storing into buffer
                                            //Note that this is okay since xor function works "byte-wisely" for the array.
        fwrite(buffer,1,16,output);
    }

    //Incomplete blocks needs extra care at the end.
    if(len_of_incomplete_block != 0)
    {
        fread(inputBuffer,1,16,input);
        xor(nonce, counter_vec);
        //No need for increasing the counter
        aes(buffer);
        xor(inputBuffer,buffer);

        fwrite(buffer,1,len_of_incomplete_block,output);        //Only writing the required bits.
    }
    
    fclose(input);
    fclose(output);


    return 0;
}





//Functions

void nonce_gen()
{
    srand(time(NULL));
    for(int i = 0; i < 16; i++)
    {
        nonce[i] = rand() % 256;
    }
}

//Counter Increment for 16 digit base-256 number labelled "counter_vec".
void counter_inc()
{
    for(int index = 15; index >= 0; index--)
    {
        if(counter_vec[index] != 255)
        {
            counter_vec[index]++;
            break;
        }
        else
        {
            counter_vec[index] = 0;
        }
        
    }
}

void xor(uint8_t* a, uint8_t* b)
{
    for(int i = 0; i < 16; i++)
    {
        buffer[i] = a[i] ^ b[i];
    }
}

void aes(uint8_t* buffer)
{
//Initialization
    for(int i = 0; i < 16; i++)
    {
        buffer[i] = buffer[i] ^ key[i];     //Adding initial key.
    }

    
    //Round 1 ~ 9
    for(int i = 1; i < 10; i++)
    {
        sbox_text(buffer);
        permutation();
        mult(buffer);
        //Adding subkey
        for(int j = 0; j < 16; j++)
        {
            buffer[j] = buffer[j] ^ expanded_key[16 * i + j];
        }
    }
    //Round 10: Multiplication by matrix excluded.
    sbox_text(buffer);
    permutation();
    for(int j = 0; j < 16; j++)
    {
        buffer[j] = buffer[j] ^ expanded_key[160 + j];
    }
}

//Generates expanded_key
void key_schedule()
{
    //Initial Key
    for(int i = 0; i < 16; i++)
    {
        expanded_key[i] = key[i];           //Copying key to the first 16 bytes of expanded_key.
    }
    uint8_t prevword[4],currentword[5];     //Extra byte for rotation
    for(int i = 4; i < 4 * NUM_OF_ROUND_KEY; i++)       //Index for words
    {
        //Copying words
        prevword[0] = expanded_key[4 * i - 16];
        prevword[1] = expanded_key[4 * i - 15];
        prevword[2] = expanded_key[4 * i - 14];
        prevword[3] = expanded_key[4 * i - 13];
        currentword[0] = expanded_key[4 * i - 4];
        currentword[1] = expanded_key[4 * i - 3];
        currentword[2] = expanded_key[4 * i - 2];
        currentword[3] = expanded_key[4 * i - 1];
        

        if(i % 4 == 0)
        {
            //Rotating and Substituting current word
            currentword[4] = currentword[0];
            currentword[0] = sbox[currentword[1]];
            currentword[1] = sbox[currentword[2]];
            currentword[2] = sbox[currentword[3]];
            currentword[3] = sbox[currentword[4]];
            expanded_key[4 * i] = prevword[0] ^ currentword[0] ^ rci[i / 4];
            expanded_key[4 * i + 1] = prevword[1] ^ currentword[1] ^ 0x00;
            expanded_key[4 * i + 2] = prevword[2] ^ currentword[2] ^ 0x00;
            expanded_key[4 * i + 3] = prevword[3] ^ currentword[3] ^ 0x00;
        }
        else
        {
            expanded_key[4 * i] = prevword[0] ^ currentword[0];
            expanded_key[4 * i + 1] = prevword[1] ^ currentword[1];
            expanded_key[4 * i + 2] = prevword[2] ^ currentword[2];
            expanded_key[4 * i + 3] = prevword[3] ^ currentword[3];
        }

    }
}



//Byte string substitution using single byte substitution
void sbox_text(uint8_t* buffer)
{
    for(int i = 0; i < 16; i++)
    {
        *(buffer + i) = sbox[*(buffer + i)];
    }
}

void switch_pos(int a, int b)
{
    uint8_t tmp;
    tmp = buffer[a];
    buffer[a] = buffer[b];
    buffer[b] = tmp;
}

void permutation()
{
    //2nd row
    switch_pos(0x01,0x05);
    switch_pos(0x05,0x09);
    switch_pos(0x09,0x0d);
    //3rd row
    switch_pos(0x02,0x0a);
    switch_pos(0x06,0x0e);
    //4th row
    switch_pos(0x03,0x07);
    switch_pos(0x03,0x0f);
    switch_pos(0x0b,0x0f);

}

void mult(uint8_t* buffer)
{
    //Copying buffer onto temp_buffer
    uint8_t temp_buffer[16];
    for(int i = 0; i < 16; i++)
    {
        temp_buffer[i] = buffer[i];
    }

    //Multiplication by matrix
    /*
    This can be done with a loop, but direct coding bypasses a few steps,
    And it isn't much easier with a loop anyways.
    The matrix used to multiply is:
                                    2,3,1,1
                                    1,2,3,1
                                    1,1,2,3
                                    3,1,1,2
    */
    buffer[0] = table_2[temp_buffer[0]] ^ table_3[temp_buffer[1]] ^ temp_buffer[2] ^ temp_buffer[3];
    buffer[1] = temp_buffer[0] ^ table_2[temp_buffer[1]] ^ table_3[temp_buffer[2]] ^ temp_buffer[3];
    buffer[2] = temp_buffer[0] ^ temp_buffer[1] ^ table_2[temp_buffer[2]] ^ table_3[temp_buffer[3]];
    buffer[3] = table_3[temp_buffer[0]] ^ temp_buffer[1] ^ temp_buffer[2] ^ table_2[temp_buffer[3]];
    buffer[4] = table_2[temp_buffer[4]] ^ table_3[temp_buffer[5]] ^ temp_buffer[6] ^ temp_buffer[7];
    buffer[5] = temp_buffer[4] ^ table_2[temp_buffer[5]] ^ table_3[temp_buffer[6]] ^ temp_buffer[7];
    buffer[6] = temp_buffer[4] ^ temp_buffer[5] ^ table_2[temp_buffer[6]] ^ table_3[temp_buffer[7]];
    buffer[7] = table_3[temp_buffer[4]] ^ temp_buffer[5] ^ temp_buffer[6] ^ table_2[temp_buffer[7]];
    buffer[8] = table_2[temp_buffer[8]] ^ table_3[temp_buffer[9]] ^ temp_buffer[10] ^ temp_buffer[11];
    buffer[9] = temp_buffer[8] ^ table_2[temp_buffer[9]] ^ table_3[temp_buffer[10]] ^ temp_buffer[11];
    buffer[10] = temp_buffer[8] ^ temp_buffer[9] ^ table_2[temp_buffer[10]] ^ table_3[temp_buffer[11]];
    buffer[11] = table_3[temp_buffer[8]] ^ temp_buffer[9] ^ temp_buffer[10] ^ table_2[temp_buffer[11]];
    buffer[12] = table_2[temp_buffer[12]] ^ table_3[temp_buffer[13]] ^ temp_buffer[14] ^ temp_buffer[15];
    buffer[13] = temp_buffer[12] ^ table_2[temp_buffer[13]] ^ table_3[temp_buffer[14]] ^ temp_buffer[15];
    buffer[14] = temp_buffer[12] ^ temp_buffer[13] ^ table_2[temp_buffer[14]] ^ table_3[temp_buffer[15]];
    buffer[15] = table_3[temp_buffer[12]] ^ temp_buffer[13] ^ temp_buffer[14] ^ table_2[temp_buffer[15]];
}