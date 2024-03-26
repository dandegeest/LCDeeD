static int subPixelDisclination = 2;
static int subPixelAlpha = 240;

class SubPixel extends Sprite {
  color pColor;
  
  SubPixel(float x, float y, float w, float h) {
    super(x, y, w, h);
    setColor(luminosity(0, 0, 0, 1.0));
  }
  
  void setColor(color c1) {
    pColor = c1;
    pColor = (pColor & 0xFFFFFF) | (int(subPixelAlpha) << 24);
  }
  
  void display() { 
    strokeCap(1 << subPixelDisclination);
    for (int p = 0; p < _width; p++) {        
      noFill();
      strokeWeight(1);
      stroke(pColor);
      line(location().x + p, location().y, location().x + p, location().y + _height);        
    }
  }
}
