#include "serial.h"

#include "io.h"

unsigned int strlen(const char* s){
	
	unsigned int l = 0;
	while(s[l])
		++l;

	return l;

}

const int serialIOPorts[4] = {0x3F8, 0x2F8, 0x3E8, 0x2E8};

bool Serial::initPort(int port){
	
	outb(serialIOPorts[port] + 1, 0x00); // disable interrupts
	outb(serialIOPorts[port] + 3, 0x80); // DLAB enable
	outb(serialIOPorts[port]    , 0x03); // divisor low
	outb(serialIOPorts[port] + 1, 0x00); // divisor high
	outb(serialIOPorts[port] + 3, 0x03); // 8b np 1s
	outb(serialIOPorts[port] + 2, 0xC7); // FIFO clear 14-byte threshold
	outb(serialIOPorts[port] + 4, 0x0B); // IRQ enabled, RTS/DSR
	outb(serialIOPorts[port] + 4, 0x1E); // loopback for testing
	
	outb(serialIOPorts[port], 0xAE);

	if(inb(serialIOPorts[port]) != 0xAE)
		return false;
	
	outb(serialIOPorts[port] + 4, 0x0F);
	return true;
}

void Serial::sendChar(int port, char c){
	
	while(inb(serialIOPorts[port] + 5) & 20 == 0);

	outb(serialIOPorts[port],c);
	

	
}

void Serial::sendString(int port, char* s){
	
	unsigned int size = strlen(s);

	for(unsigned int i = 0; i < size; ++i)
		sendChar(port, s[i]);

}
