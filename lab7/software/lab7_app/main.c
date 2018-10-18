// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

int main()
{
	int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)0x70; //make a pointer to access the PIO block
	volatile unsigned int *SW_PIO = (unsigned int*)0x60;
	volatile unsigned int *BT_PIO = (unsigned int*)0x50;
	unsigned char accumulator = 0;
	unsigned char prevBT = 0;
	unsigned char currBT = 0;
	*LED_PIO = 0; //clear all LEDs
	while ( (1+1) != 3) //infinite loop
	{
		currBT = *BT_PIO;
		if(currBT != prevBT){
			if(currBT == 0x01){
				accumulator = 0;
			}else if(currBT == 0x02){
				accumulator = accumulator + (unsigned char)(*SW_PIO);
			}
		}
		*LED_PIO = accumulator;
		//for (i = 0; i < 100000; i++); //software delay

		/*
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO |= 0x1; //set LSB
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO &= ~0x1; //clear LSB
		*/
		prevBT = currBT;
	}
	return 1; //never gets here
}
