#include "tracer.h"

#include "vector.h"
#include "math.h"

Tracer::Tracer(Screen *s){
	screen = s;
}

void Tracer::traceToFrameBuffer(){
	
	for(int x = 0; x < 320; ++x){
		for(int y = 0; y < 200; ++y){
			tracePixel(x, y);
		}
	}

}

void Tracer::tracePixel(int px, int py){
	
	bool empty = true;

	// limit
	float lx = 5.f;
	float ly = 3.125f;
	// screen size
	int sx = 320;
	int sy = 200;
	// origin coords
	float x = ((float)(px * 2 - sx) / sx);
	float y = ((float)(py * 2 - sy) / sy);
	// ray
	Vector3 ro = Vector3(x * lx, y * ly, 0);
	Vector3 rd = Vector3(0, 0, -1);
	// sphere
	int spherecount = 5;
	Vector3 sp = Vector3(0, 0, 0);
	float sr = 0.5;
	Vector3 omc = ro - sp;
	float b = dot(rd, omc);
	float c = dot(omc, omc) - sr * sr;
	float bsqmc = b * b - c;
	if(bsqmc >= 0)
		empty = false;
	screen->putC(px, py, empty ? 0x7 : 0xA);

}
