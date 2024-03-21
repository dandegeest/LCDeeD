class Pixel extends Sprite {

  LCDD lcdd;
  SubPixel[] subPixels;
  int pixelIndex;
  int rv = 0;
  int gv = 0;
  int bv = 0;
  int alpha = 255;
  float lumos = 0.0;
  boolean dirty = true;
  
  Pixel(float x, float y, float w, float h, int pidx, LCDD lcd) {
    super(x, y, w, h);
    
    subPixels = new SubPixel[3];
    
    int subPixWidth = floor(w / 3);
    for (int i = 0; i < 3; i++) {
      subPixels[i] = new SubPixel(position.x + i * subPixWidth, position.y, subPixWidth, h);
    }
    
    pixelIndex = pidx;
    lcdd = lcd;
    setRGB(0, 0, 0, 1.0);
  }

  void setRGB(int r, int g, int b, float l) {
    if (r == rv && g == gv && b == bv && l == lumos)
      return;

    rv = r;
    gv = g;
    bv = b;
    lumos = l;
    
    subPixels[0].setColor(luminosity(rv, 0, 0, lumos));
    subPixels[1].setColor(luminosity(0, gv, 0, lumos));
    subPixels[2].setColor(luminosity(0, 0, bv, lumos));

    lcdd.invalidate(this);
  }
  
  void display() {
    for (SubPixel sp: subPixels) {
      sp.offset = offset;
      sp.display();
    }
    
    dirty = false;
  }
}
