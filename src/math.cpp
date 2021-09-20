#include "math.h"

float sqrt(float x){

	float res;
	asm ("fsqrt" : "=t" (res) : "0" (x));
	return res;

}

float abs(float i){
	return i < 0 ? -i : i;
}
