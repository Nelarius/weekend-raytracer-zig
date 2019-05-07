#include <stdint.h>

struct SDL_Surface;

void setPixel(SDL_Surface *surface, int x, int y, uint32_t pixel);
