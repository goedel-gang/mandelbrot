int lim;
double screen_x, screen_y, scale;

int brotval;

boolean refresh;
boolean reading_input;

String start_point;

String alph;
int base;

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
