import java.util.List;

class LCDD extends Sprite {
  boolean tvOn = false;
  // Resolution
  int pwRes = 0; // Pixels per Line
  int phRes = 0; // Number of lines
  int pxSize = 3; // Pixel size ( 3 X 3 -> Each subpixel is 1 X 3
  // Display Pixels
  ArrayList<Pixel> _pixels = new ArrayList<Pixel>();
  // Invalid pixel range for redraw
  int[] redrawRange = new int[2];
  boolean fullRedraw = false;
  // Transform
  float scale = 1.0;
  float transX = 0.0;
  float transY = 0.0;
  // Scanline Animation
  float scanInterval = 1;
  float scanLine = 0;
  int pvscanLine = 0;
  // Thumbnail preview
  boolean pipOn = false;
  // Source to display
  PImage source;
  // Station logo
  PImage logo;
  boolean logoOn = false;
  // Brightness Mode
  int bright = 1;
  // Overscan
  color overScanColor = blueDD;
  int overScanInterval = 10;
  int overScanSize = 2;
  int overScanAlpha = 50;
  boolean overScanOn = false;
  
  LCDD(float x, float y, float w, float h, int psize) {
    super(x, y, w, h);
    setResolution(w, h, psize);
    invalidate();   
    println("Starting LCDD/TV™", pwRes, phRes, 1 << subPixelDisclination);   
  }

  void setResolution(float w, float h, int psize) {
    pxSize = psize;
    _width = w;
    _height = h;
    pwRes = floor(_width/pxSize);
    phRes = floor(_height/pxSize);

    _pixels.clear();
    
    for (int py = 0; py < phRes; py++) {
      for (int px = 0; px < pwRes; px++) {
        Pixel pixel = new Pixel(
          position.x + px * pxSize,
          position.y + py * pxSize,
          pxSize , pxSize,
          (py * pwRes) + px, this);
        _pixels.add(pixel);
      }
    }
      
    println("Set Resolution", pwRes, phRes);
  }
  
  Pixel pixelAt(int x, int y) {
    int index = (y * pwRes) + x;
    if (index >= 0 && index < _pixels.size())
      return _pixels.get(index);
      
    return null;
  }
  
  List<Pixel> getHLine(int row) {
    if (row >= 0 && row < phRes) {
      int startIndex = row * pwRes;
      return _pixels.subList(startIndex, startIndex + pwRes);
    }
    
    return null;
  }
  
  List<Pixel> getVLine(int column) {
    List<Pixel> col_pixels = new ArrayList<Pixel>();
    for (int row = 0; row < phRes; row++) {
      int index = column + row * pwRes;
      col_pixels.add(_pixels.get(index));
    }
        
    return col_pixels;
  }
    
  void sourceImage(String fname) {
    source = loadImage(fname);
    sourceImage(source);
    //println("Loaded Image", source.width, source.height);
  }
  
  void sourceImage(PImage image) {
    source = image;
    source.loadPixels();
    //source.resize(pwRes, 0);
    //println("----->", source.width, source.height);
    int xoff = (pwRes - source.width) / 2;
    source.loadPixels();
    for (int y = 0; y < phRes; y++) {
      for (int x = 0; x < pwRes; x++) {
        if (x < source.width && y < source.height) {
          // Get the color of the pixel at (x, y) in the source image and set the color to the LCDD pixel
          int pixelColor = source.get(x, y);
          
          // Extract the RGB components
          int a = (pixelColor >> 24) & 0xFF;
          int r = (pixelColor >> 16) & 0xFF;
          int g = (pixelColor >> 8) & 0xFF;
          int b = pixelColor & 0xFF;
          
          Pixel px = pixelAt(xoff + x, y);
          if (px == null) {
            continue;
          }
          
          if (a == 0) {
            px.setRGB((slideTint >> 16) & 0xFF, (slideTint >> 8) & 0xFF, slideTint & 0xF, .5);
          }
          else {
            switch (bright) {
              case 0:
                px.setRGB(r, g, b, y % 2 == 0 ? .5 : 1.0);
                break;
              case 1:
                px.setRGB(r, g, b, 1.0);
                break;
              case 2:
                px.setRGB(r, g, b, brightness(pixelColor));
                break;
            }
          }
        }
      }
    }
  }

  void rescanLine(int line) {
    if (line < 0 || line >= phRes)
      scanLine = line = 0;
    
    List<Pixel> l = getHLine(line);
    for (Pixel pixel : l) {
      pixel.setRGB(0, 0, 0, random(.2, 1.0));
    }
    
    if (source == null)
      return;
      
    int xoff = (pwRes - source.width) / 2;
    for (int x = 0; x < pwRes; x++) {
      if (x < source.width && line < source.height) {
        int pixelColor = source.get(x, line);
        
        boolean lerped = false;
        if (brightness(pixelColor) > 165) {
          pixelColor = neonDD2; //lerpColor(pixelColor, neon2, .75);
          lerped = true;
        }
        
        // Extract the RGB components
        int a = (pixelColor >> 24) & 0xFF;
        int r = (pixelColor >> 16) & 0xFF;
        int g = (pixelColor >> 8) & 0xFF;
        int b = pixelColor & 0xFF;
        
        Pixel px = l.get(xoff + x);
        if (px == null)
          continue;
  
        if (a == 0)
          px.setRGB(0, 0, 0, 1.0);
        else
          px.setRGB(r, g, b, lerped ? 1.0 : px.lumos);
      }
    }
  }  
  
  void scanComplete() {
    redrawRange = new int[] { pwRes * phRes, 0 };
    fullRedraw = false;
  }

  void invalidate() {
    redrawRange = new int[] { 0, (pwRes * phRes) -1 };
    fullRedraw = true;
  }
  
  void invalidate(Pixel pixel) {
    invalidate(pixel.pixelIndex, pixel.pixelIndex);
    pixel.dirty = true;
  }
  
  void invalidate(int s, int e) {  
    redrawRange[0] = min(redrawRange[0], s);
    redrawRange[1] = max(redrawRange[1], e);
  }
  
  void display() { 
    if (overScanOn) {
      // Overscan lines directly to screen
      push();
      fill(overScanColor, overScanAlpha);
      for (int x = 0; x < _width; x += overScanInterval) {
        rect(location().x + x, location().y, overScanSize, _height);
      }
      pop();
    }
     
    pushMatrix();
    scale(scale);
    translate(transX, transY);

    if (scanInterval > 0)
      scanner();
      
    pinky();
    
    //int c = 0;
    for (int i = redrawRange[0]; i <= redrawRange[1]; i++) {
      Pixel pixel = _pixels.get(i);
      if (pixel.dirty || fullRedraw) {
        pixel.display();
        //c++;
      }
        
      pixel.dirty = false;
    }
    
    //if (c > 0 && !fullRedraw)
    //  println(c, "PIXELS SET");
    popMatrix();
    
    if (logo != null && logoOn) {
      image(logo, location().x + _width - logo.width, location().y + _height - logo.height);
    }

    if (pipOn)
      image(source, location().x + _width - source.width, location().y + _height - source.height);
    
    scanComplete();
  } 
  
  void scanner() {
    if (scanLine == 0) {
      pvscanLine = phRes -1;
    }

    rescanLine(pvscanLine);

    List<Pixel> l = getHLine(floor(scanLine));
    for (Pixel pixel : l) {
      pixel.setRGB(255, 255, 255, random(1.5,1));
    }  
    
    pvscanLine = floor(scanLine);
    scanLine += scanInterval;
    
    if (scanLine >= phRes) {
      scanLine = 0;
    }
  }

  void pinky() {
    int pi = (int)random(0, pwRes * phRes);

    for (int i = 0; i < (int)random(25, 50); i++) {
      
      int pi2 = (int)random(0, 3 * pwRes);
      Pixel pix = _pixels.get(min(pi + pi2, pwRes * phRes -1 ));
      color pixelColor = color(pix.rv, pix.gv, pix.bv);
      if (brightness(pixelColor) > 165) {
        pixelColor = lerpColor(pixelColor, neonDD2, .9);
      
        // Extract the RGB components
        //int a = (pixelColor >> 24) & 0xFF;
        int r = (pixelColor >> 16) & 0xFF;
        int g = (pixelColor >> 8) & 0xFF;
        int b = pixelColor & 0xFF;
        
        pix.setRGB(r, g, b, 1);
      }
    }
  }
}
