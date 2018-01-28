#include <mbed.h>
#define WIDTH_FALL 5
#define WIDTH_PULSE 95
#define WIDTH_BIT 100

InterruptIn triger(D4);
DigitalOut switchV1(D2), switchV2(D3);
DigitalInOut usrpSyn(D5, PIN_OUTPUT, OpenDrainNoPull, 1);

void switchAnt()
{
	static int Rxi = 0;
	
	//ÇÐ»»ÌìÏß
	switch (Rxi)
	{
	case 0:
		switchV1 = 0;
		switchV2 = 0;
		break;
	case 1:
		switchV1 = 1;
		switchV2 = 0;
		break;
	case 2:
		switchV1 = 0;
		switchV2 = 1;
		break;
	}

	//À­µÍÂö³å
	wait_us(WIDTH_FALL);
	usrpSyn=0;
	wait_us(WIDTH_PULSE);

	//·¢ËÍÌìÏß±àºÅ
	switch (Rxi)
	{
	case 0:
		usrpSyn = 0;
		wait_us(WIDTH_BIT);
		usrpSyn = 0;
		break;
	case 1:
		usrpSyn = 1;
		wait_us(WIDTH_BIT);
		usrpSyn = 0;
		break;
	case 2:
		usrpSyn = 0;
		wait_us(WIDTH_BIT);
		usrpSyn = 1;
		break;
	}
	wait_us(WIDTH_BIT);

	//Ðü¿ÕÊä³ö
	usrpSyn = 1;
	
	if (++Rxi>=3)
	{
		Rxi = 0;
	}
}

int main() 
{
	triger.fall(&switchAnt);
	for (;;)
	{
	}
}