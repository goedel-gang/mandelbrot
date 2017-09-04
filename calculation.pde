//a quick recursive function to calculate powers of long integers, for base conversion
long pow (long a, int b) {
    if ( b == 0)        return 1;
    if ( b == 1)        return a;
    if ( b % 2 == 0 )   return     pow ( a * a, b/2);
    else                return a * pow ( a * a, b/2);
}

//should this have been in Python this would be one tuple-returning function:

//gets the real part of the result of multiplying two complex numbers
double mult_re(double a_re, double a_im, double b_re, double b_im) {
  return a_re * b_re - a_im * b_im;
}

//gets the imaginary part of the result of multiplying two complex numbers
double mult_im(double a_re, double a_im, double b_re, double b_im) {
  return a_re * b_im + b_re * a_im;
}

//iterates the z^2 + c function on an imaginary number c for z=0, seeing how quickly or if the magnitude becomes greater than 2

int is_brot(double c_re, double c_im) {
  double z_re = 0;
  double z_im = 0;
  
  for (int i = 0; i < lim; i++) {
    if (z_re * z_re + z_im * z_im > 4) {
      return i;
    } else {
      double sz_re = z_re;
      double sz_im = z_im;
      
      for (int j = 0; j < brotval - 1; j++) {
        double tz_re = z_re;
        double tz_im = z_im;
        z_re = mult_re(sz_re, sz_im, tz_re, tz_im);
        z_im = mult_im(sz_re, sz_im, tz_re, tz_im);
      }
      
      z_re += c_re;
      z_im += c_im;
    }
  }
  
  return lim;
}

//translates an x coordinate on the screen to the complex coordinate at the scale and translation the user has navigated to 
double get_x(int x) {
  return (1.0 * x) / 700 * scale + screen_x;
}

//translates a y coordinate on the screen to the complex coordinate at the scale and translation the user has navigated to 
double get_y(int y) {
  return (1.0 * y) / 700 * scale + screen_y;
}
