int subPixelDisclination = 2;

class SubPixel extends Sprite {
  color pColor;
  
  SubPixel(float x, float y, float w, float h) {
    super(x, y, w, h);
    setColor(luminosity(0, 0, 0, 1.0));
  }
  
  void setColor(color c1) {
    pColor = c1;
    //pColor = (pColor & 0xFFFFFF) | (int(245) << 24);
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
