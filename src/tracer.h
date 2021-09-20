#ifndef _TRACER_H_INCLUDE
#define _TRACER_H_INCLUDE

#include "vga.h"

class Tracer{
	

	Screen *screen;

	void tracePixel(int px, int py);
	
public:
	
	Tracer(Screen *s);

	void traceToFrameBuffer();

};

#endif // _TRACER_H_INCLUDE
