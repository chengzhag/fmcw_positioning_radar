#include <mbed.h>
#include <vector>
#include <bitset>
using namespace std;

#define WIDTH_FALL 0
#define WIDTH_PULSE 80
#define WIDTH_BIT 100

InterruptIn triger(D2);
DigitalInOut usrpSyn(D3, PIN_OUTPUT, OpenDrainNoPull, 1);
vector<vector<DigitalOut>>  switchs{ {D4,D5},{D6,D7},{D8} };


void switchAnt()
{
	static bitset<3> iRx(0);
	
	//ÇÐ»»ÌìÏß
	size_t iB = 0;
	for (auto &douts : switchs)
	{
		for (auto &dout : douts)
		{
			dout = iRx[iB];
		}
		++iB;
	}

	//À­µÍÂö³å
	wait_us(WIDTH_FALL);
	usrpSyn=0;
	wait_us(WIDTH_PULSE);

	//·¢ËÍÌìÏß±àºÅ
	for (int i = iRx.size() - 1; i >= 0; --i)
	{
		usrpSyn = iRx[i];
		wait_us(WIDTH_BIT);
	}
	
	

	//Ðü¿ÕÊä³ö
	usrpSyn = 1;
	
	
	if (iRx.to_ulong() >= 7)
	{
		iRx = 0;
	}
	else
	{
		iRx = iRx.to_ulong() + 1;
	}

}

int main() 
{
	triger.fall(&switchAnt);
	for (;;)
	{
	}
}