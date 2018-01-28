#include <mbed.h>

#define WIDTH_BIT 100

InterruptIn triger(D4);
DigitalOut switchV1(D2), switchV2(D3);
DigitalOut usrpSyn(D5);

void switchAnt()
{
	static int Rxi = 0;
	usrpSyn=1;
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
	wait_us(WIDTH_BIT);
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
	usrpSyn = 0;
	
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