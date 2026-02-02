class Pixel extends Sprite {

  LCDD lcdd;
  SubPixel[] subPixels;
  int pixelIndex;
  int rv = 0;
  int gv = 0;
  int bv = 0;
  float lumos = 0.0;
  boolean dirty = true;
  
  // Original color storage for scanline effect
  int originalR = 0;
  int originalG = 0;
  int originalB = 0;
  float originalLumos = 0.0;
  boolean hasStoredColor = false;
  
  Pixel(float x, float y, float w, float h, int pidx, LCDD lcd) {
    super(x, y, w, h);
    
    subPixels = new SubPixel[3];
    
    float subPixWidth = w / 3.0;  // Use float to handle fractional widths
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
  
  void saveOriginalColor() {
    if (!hasStoredColor) {
      originalR = rv;
      originalG = gv;
      originalB = bv;
      originalLumos = lumos;
      hasStoredColor = true;
    }
  }
  
  void restoreOriginalColor() {
    if (hasStoredColor) {
      setRGB(originalR, originalG, originalB, originalLumos);
      hasStoredColor = false;
    }
  }
  
  // Convenience getters for color values
  int r() { return rv; }
  int g() { return gv; }
  int b() { return bv; }
  
  // Packed RGB for faster comparison
  int getRGB() { 
    return (rv << 16) | (gv << 8) | bv; 
  }
  
  void display() {
    for (SubPixel sp: subPixels) {
      sp.offset = offset;
      sp.display();
    }
    
    dirty = false;
  }
}
