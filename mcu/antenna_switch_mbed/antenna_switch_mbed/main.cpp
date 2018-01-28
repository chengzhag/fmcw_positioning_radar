#include <mbed.h>

DigitalOut g_LED(LED1);

int main() 
{
	for (;;)
	{
		g_LED = 1;
		wait_ms(500);
		g_LED = 0;
		wait_ms(500);
	}
}