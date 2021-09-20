#ifndef _VGA_H_DEFINE
#define _VGA_H_DEFINE

#include "stddef.h"
#include "stdint.h"

class Screen{
	
	
	const size_t screen_X = 320;
	const size_t screen_Y = 200;
	uint8_t* videomem = (uint8_t*)0xA0000;
	uint8_t* framebuffer = (uint8_t*)0x100000;
public:

	void putC(int x, int y, uint8_t c);
	void swapBuffer();


};


#endif //_VGA_H_DEFINE
