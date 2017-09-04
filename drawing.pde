//converts a value for divergence rate to a nice rainbow colour, using offset sine waves
color get_colour(int val, float mag) {
  int r = (int)((sin(((1.0 * val) / lim) * mag * 2 * PI + 0 * 2 * PI / 3) + 1) * 255 / 2);
  int g = (int)((sin(((1.0 * val) / lim) * mag * 2 * PI + 1 * 2 * PI / 3) + 1) * 255 / 2);
  int b = (int)((sin(((1.0 * val) / lim) * mag * 2 * PI + 2 * 2 * PI / 3) + 1) * 255 / 2);
  
  return color(r, g, b);
}

//draws points in the mandelbrot set, and shades those that are not, pixel by pixel

void draw_brot() {
  loadPixels();
  
  int i = 0;
  
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int conv_time = is_brot(get_x(x), get_y(y));
      
      color c;
      
      if (conv_time == lim) {
        c = color(255);
      } else {
        c = get_colour(conv_time, 5);
      }
      
      pixels[i] = c;
      
      i++;
    }
  }
  
  updatePixels();
}
