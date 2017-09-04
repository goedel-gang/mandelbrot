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

//generates a file name which serializes the current state of the screen.  the
//Doubles used are serialized by converting their bits to a long integer, and
//encoding that in a base. this guarantees absolute, bit-certain precision,
//which is needed at the scale the program works at
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
