#include "SDL.h"

void setPixel(SDL_Surface *surface, int x, int y, uint32_t pixel) {
  uint8_t *target_pixel =
      (uint8_t *)surface->pixels + y * surface->pitch + x * 4;
  *(uint32_t *)target_pixel = pixel;
}
