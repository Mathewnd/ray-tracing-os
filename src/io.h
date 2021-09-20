#ifndef _IO_H_DEFINE
#define _IO_H_DEFINE

#include "stdint.h"

uint8_t inb(uint16_t port){
	
	uint8_t out;
	
	asm volatile( "inb %1, %0" : "=a"(out) : "Nd"(port) );

	return out;
}

void outb(uint16_t port, uint8_t value){	

	asm volatile( "outb %0, %1" : : "a"(value), "Nd"(port) );

}


#endif // _IO_H_DEFINE
