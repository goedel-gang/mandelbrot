/* use:
general:
r - Reset
[esc] - exit


changing the scale:
left click to zoom in
right click to centre

b - zoom Back out
space - zoom in
z - zoom in a lot

o - subtler zoom in
p - subtler zoom out


changing "multibrot value" (exponent of z)
0 - increase multibrot value
9 - decrease multibrot value


changing iteration cap:
h - set iteration limit to 1000
i - increase limit by 100
u - decrease limit by 100
t - set limit to 100


move screen:
[left]  - move the screen left
[right] - move the screen right
[up]    - move the screen up
[down]  - move the screen down

a - move the screen left a smaller amount
d - move the screen right a smaller amount
w - move the screen up a smaller amount
s - move the screen down a smaller amount


resize screen:
1 - decrease width
2 - increase width
3 - decrease height
4 - increase height

5 - decrease width a smaller amount
6 - increase width a smaller amount
7 - decrease height a smaller amount
8 - increase height a smaller amount

f - set screen size to full screen
y - set screen size to 700*700

v - force rerender the display. use liberally when resizing


q - get stats


saving pictures and serializing:
k - save an image of the sketch - Keep it
l - get the expected filename (serialization) to save

my way to get nice pictures:
find something you think will look interesting, and do rough navigation in a low limit and small screen size,
THEN enhance and set to full screen

This is a program that renders the mandelbrot set. This set is defined as the set of the complex numbers, c
such that there is no divergence when 0 is iterated under f(z) = z^2 + c
The program works by simply iterating and observing if this number becomes large.
The speed of divergence is then used to give colourings.
The parameters kept track of are - x, y, scale, iteration cap, multibrot value (alternative exponent for z), width and height.

*/

int lim;
double screen_x, screen_y, scale;

int brotval;

boolean refresh;
boolean reading_input;

String start_point;

String alph;
int base;

//a quick recursive function to calculate powers of long integers, for base conversion

long pow (long a, int b) {
    if ( b == 0)        return 1;
    if ( b == 1)        return a;
    if ( b % 2 == 0 )   return     pow ( a * a, b/2);
    else                return a * pow ( a * a, b/2);
}

//gets the real part of the result of multiplying two complex numbers

double mult_re(double a_re, double a_im, double b_re, double b_im) {
  return a_re * b_re - a_im * b_im;
}

//gets the imaginary part of the result of multiplying two complex numbers

double mult_im(double a_re, double a_im, double b_re, double b_im) {
  return a_re * b_im + b_re * a_im;
}

//encodes a long integer using the base and alphabet in the global variables alph and base

String encode(long gval) {
  long val = gval;
  
  String digits = "";
  
  if (val < 0) {
    digits += '-';
    val *= -1;;
  }
  
  int exp = 1;
  
  while (val != 0) {
    long remainder = val % pow(base, exp);
    val -= remainder;
    
    long digit = remainder / pow(base, exp - 1);
    
    digits += alph.charAt((int)digit);
    
    exp++;
  }
  
  return digits;
}

//decodes a long integer using the base and alphabet in the global variables alph and base

long decode(String t) {
  long val = 0;
  
  if (t.length() == 0) {
    return 0;
  }
  
  int mult = 1;
  int offs = 0;
  
  if (t.charAt(0) == '-') {
    mult = -1;
    offs = 1;
  }
  
  for (int exp = offs; exp < t.length(); exp++) {
    val += pow(base, exp - offs) * alph.indexOf(t.charAt(exp));
  }
  
  return mult * val;
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

//generates a file name which serializes the current state of the screen.
//the Doubles used are serialized by converting their bits to a long integer, and encoding that in a base.
//this guarantees absolute, bit-certain precision, which is needed at the scale the program works at

String generateFileName() {
  long scrx = Double.doubleToLongBits(screen_x);
  long scry = Double.doubleToLongBits(screen_y);
  long rn = Double.doubleToLongBits(scale);
  
  return
  encode(scrx) +
  "+" + encode(scry) +
  "+" + encode(rn) +
  "+" + encode(lim) +
  "+" + encode(brotval) +
  "+" + encode(width) +
  "+" + encode(height) +
  ".tiff";
  
}

//translates an x coordinate on the screen to the complex coordinate at the scale and translation the user has navigated to 

double get_x(int x) {
  return (1.0 * x) / 700 * scale + screen_x;
}

//translates a y coordinate on the screen to the complex coordinate at the scale and translation the user has navigated to 

double get_y(int y) {
  return (1.0 * y) / 700 * scale + screen_y;
}

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

//reads the serialized values back into the appropriate global variables, using the high base encoding

void doSetup(String svals) {
  String[] vals = svals.split("\\+");
  
  screen_x = Double.longBitsToDouble(decode(vals[0]));
  screen_y = Double.longBitsToDouble(decode(vals[1]));
  scale = Double.longBitsToDouble(decode(vals[2]));
  lim = (int)decode(vals[3]);
  brotval = (int)decode(vals[4]);
  surface.setSize((int)decode(vals[5]), (int)decode(vals[6]));
}

//reads the serialized values as base 10

void oldschool_Setup(String svals) {
  String[] vals = svals.split("\\+");
  
  screen_x = Double.longBitsToDouble(Long.parseLong(vals[1]));
  screen_y = Double.longBitsToDouble(Long.parseLong(vals[2]));
  scale = Double.longBitsToDouble(Long.parseLong(vals[3]));
  lim = Integer.parseInt(vals[4]);
  brotval = Integer.parseInt(vals[5]);
  surface.setSize(Integer.parseInt(vals[6]), Integer.parseInt(vals[7]));
}

void setup() {
  size(700, 700);
  surface.setResizable(true);
  
  alph = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
  base = alph.length();
  
  //this is the complex alphabet assumed to be used if a coded filename is given, and used to generate filenames
  
  start_point = "no";
  //change this to start_point = file name given (without extension)
  //i swear to god it is impossible to get text input from the user
  //prefix with a + if it is old-style (base 10)
  //also REMEMBER i added multibrots - if an index error happens, try adding a +2 between the limit value (likely to be a multiple of 100)
  //and the width (likely to be 1920 or the first 700)
  
  //some examples i've found on my travels/left behind from testing:

  //start_point = "+-4612830631290218946+-4646758215971268196+4517110426252607488+1000+2+1920+986";
  //start_point = "-KSgvFO_7wH4+-j_Qy46PSzH4+xhrjp8bm6E4+Tf+2+uu+Ff";
  //start_point = "-AI9lteh8zH4+-kG00tJWZgH4+zzA_rcVxpG4+M4+3+7b+7b";
  //start_point = "-WhRxO0Ls3H4+-a3iar6Y6XL4+SPwtJ7tzaC4+Ic+2+uu+Ff";
  //start_point = "-cmw_nqCn3H4+-Dldf8vn2vN4+uRIhl25AEA4+Tf+2+uu+Ff";
  //start_point = "-4ESFsdBQZG4+-4ESFsdBQZG4+kG00tJWZgH4+B0+3+7b+7b";
  //start_point = "+-4611782863411562414+-4664288062075075300+4562146422526312448+300+2+1920+986";
  //start_point = "+-4611967514234689946+-4682177907907362816+4517110426252607488+600+2+1920+986";
  //start_point = "+-4612822613663070288+-4645198573696314246+4463067230724161536+1000+2+1920+986"; 
  //start_point = "+-4612830631290218946+-4646758215971268196+4517110426252607488+1000+2+1920+986";
  //start_point = "+-4612956530563319070+-4753729550674653348+4472074429978902528+1000+2+1920+986";
  //start_point = "+-4617440862287167488+-4625718601547576772+4562146422526312448+1000+2+1920+986";
  //start_point = "+-4619744647010613986+-4619215474054397952+4584664420663164928+1000+2+1920+986";
  //start_point = "+-4620555822709122008+-4620487740949130112+4566650022153682944+1000+2+1920+986";
  //start_point = "+-4628138814416281928+-4616000646473056256+4512606826625236992+1000+2+1920+986";
  //start_point = "+-4629497596003945022+-4616280337361959648+4476578029606273024+1500+2+1920+986";
  //start_point = "+-4631952216750555136+-4619004367821864960+4584664420663164928+1000+2+1920+986";
  //start_point = "+-4640970580235911168+-4616196493433037126+4485585228861014016+1000+2+1920+986";
  //start_point = "+-4640984045065758309+-4616194752774060114+4553139223271571456+200+2+1920+986";
  //start_point = "+4552778935301381816+-4618426794363794227+4553139223271571456+1000+2+1920+986";
  //start_point = "+4567685850067978158+-4619238343896255695+4566650022153682944+1000+2+1920+986";
  //start_point = "+4576518534837158552+-4618353984703802900+4566650022153682944+600+2+1920+986";
  //start_point = "+4598364335545253888+-4654605322876228731+4562146422526312448+1000+2+1920+986";
  //start_point = "+4598985955439133328+-4642587748745567272+4562146422526312448+1000+2+1920+986";
  //start_point = "+4600271746628059136+-4619868542274612756+4499096027743125504+1200+2+1920+986";
  
  if (start_point != "no") {
    if (start_point.charAt(0) != '+') {
      doSetup(start_point);
    } else {
      oldschool_Setup(start_point);
    }
  
  } else {
    surface.setSize(700, 700);
    
    lim = 100;
  
    screen_x = -2;
    screen_y = -2;
    scale = 4;
    
    brotval = 2;
  }

  background(0);
  
  refresh = true;
}

void draw() {
  if (refresh) {
    draw_brot();
    refresh = false;  
  }
}

//handling a mouse click event - zooming or centreing

void mousePressed() {
  screen_x = (get_x(mouseX)) - (1.0 * width / 700) * scale / 2;
  screen_y = (get_y(mouseY)) - (1.0 * height / 700) * scale / 2;
  
  if (mouseButton == LEFT) {
    scale /= 2;
    screen_x += (1.0 * width / 700) * scale / 2;
    screen_y += (1.0 * height / 700) * scale / 2;
  }
  
  refresh = true;
}

//handling a keypress event - see the list at the top

void keyPressed() {
  switch (keyCode) {
    case 'R':
      setup();
      break;

    case 'Q':
      println("\nscreen_x: ", screen_x, "(", Double.doubleToLongBits(screen_x), ")",
              "\nscreen_y: ", screen_y, "(", Double.doubleToLongBits(screen_y), ")",
              "\nscale: ", scale, "(", Double.doubleToLongBits(scale), ")",
              "\nlim: ", lim,
              "\nbrotval: ", brotval,
              "\nwidth: ", width,
              "\nheight: ", height);
      break;

    case 'B':
      screen_x -= (1.0 * width / 700) * scale / 2;
      screen_y -= (1.0 * height / 700) * scale / 2;
      scale *= 2;
      break;
    case ' ':
      scale /= 2;
      screen_x += (1.0 * width / 700) * scale / 2;
      screen_y += (1.0 * height / 700) * scale / 2;
      break;
      
    case 'O':
      scale /= 1.05;
      screen_x += (1.0 * width / 700) * scale * 0.05 / 2;
      screen_y += (1.0 * height / 700) * scale * 0.05 / 2;
      break;
   case 'P':
      screen_x -= (1.0 * width / 700) * scale * 0.05 / 2;
      screen_y -= (1.0 * height / 700) * scale * 0.05 / 2;
      scale *= 1.05;
      break;
      
    case 'V':
      refresh = true;
      break;
      
    case 'K':
      String file = generateFileName();
      save(file);
      println(file);
      break;
    case 'L':
      String tfile = generateFileName();
      println(tfile);
      break;
      
    case 'H':
      lim = 1000;
      break;      
    case 'I':
      lim += 100;
      break;
    case 'U':
      lim -= 100;
      break;
    case 'T':
      lim = 100;
      break;
      
    case LEFT:
      screen_x -= scale / 4;
      break;
    case RIGHT:
      screen_x += scale / 4;
      break;
    case UP:
      screen_y -= scale / 4;
      break;
    case DOWN:
      screen_y += scale / 4;
      break;
      
    case 'A':
      screen_x -= scale / 50;
      break;
    case 'D':
      screen_x += scale / 50;
      break;
    case 'W':
      screen_y -= scale / 50;
      break;
    case 'S':
      screen_y += scale / 50;
      break;
      
    case '1':
      surface.setSize(width - 100, height);
      break;
    case '2':
      surface.setSize(width + 100, height);
      break;
    case '3':
      surface.setSize(width, height - 100);
      break;
    case '4':
      surface.setSize(width, height + 100);
      break;
      
    case '5':
      surface.setSize(width - 10, height);
      break;
    case '6':
      surface.setSize(width + 10, height);
      break;
    case '7':
      surface.setSize(width, height - 10);
      break;
    case '8':
      surface.setSize(width, height + 10);
      break;

    case 'F':
      surface.setSize(displayWidth, displayHeight);
      break;
      
    case 'Y':
      surface.setSize(700, 700);
      break;

    case 'Z':
      for (int i = 0; i < 6; i++) {
        scale /= 2;
        screen_x += (1.0 * width / 700) * scale / 2;
        screen_y += (1.0 * height / 700) * scale / 2;
      }
      break;
      
   case '0':
     brotval++;
     break;
   case '9':
     brotval--;
     break;
      
    case ESC:
      exit();
      break;
      
    default:
      break;
  }
  
  refresh = true;
}
