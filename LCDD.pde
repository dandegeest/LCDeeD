import java.util.List;

class LCDD extends Sprite {
  boolean tvOn = false;
  // Resolution
  int pwRes = 0; // Pixels per Line
  int phRes = 0; // Number of lines
  int pxSize = 3; // Pixel size ( 3 X 3 -> Each subpixel is 1 X 3
  // Compositing Buffer
  PGraphics backBuffer;
  // Display Pixels
  ArrayList<Pixel> _pixels = new ArrayList<Pixel>();
  // Dirty regions for optimized redraw
  ArrayList<int[]> dirtyRects = new ArrayList<int[]>(); // [x1, y1, x2, y2]
  boolean fullRedraw = false;
  
  // Pre-allocated line arrays for performance
  private List<Pixel>[] cachedHLines;
  private boolean linesInitialized = false;
  // Transform
  float scale = 1.0;
  float transX = 0.0;
  float transY = 0.0;
  boolean centerScale = true;
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
  // Luminosity Mode
  int lumosMode = 0;
  // Overscan
  color overScanColor = blueDD;
  int overScanInterval = 10;
  int overScanSize = 2;
  int overScanAlpha = 50;
  boolean overScanOn = false;
  
  // Custom visualizer instance
  Visualizer customVisualizer;
  
  LCDD(float x, float y, float w, float h, int psize) {
    super(x, y, w, h);
    backBuffer = createGraphics((int)w, (int)h);
    setResolution(w, h, psize);
    
    // Initialize with pulse visualizer by default
    customVisualizer = new PulseVisualizer(position.x, position.y, w, h);
    
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
    
    // Initialize cached line arrays
    cachedHLines = new List[phRes];
    
    for (int py = 0; py < phRes; py++) {
      cachedHLines[py] = new ArrayList<Pixel>(pwRes);
      for (int px = 0; px < pwRes; px++) {
        Pixel pixel = new Pixel(
          position.x + px * pxSize,
          position.y + py * pxSize,
          pxSize , pxSize,
          (py * pwRes) + px, this);
        _pixels.add(pixel);
        cachedHLines[py].add(pixel);
      }
    }
    
    // Reset scanner variables to prevent out of bounds errors
    scanLine = 0;
    pvscanLine = 0;
    
    linesInitialized = true;
    println("Set Resolution", pwRes, phRes);
  }
  
  Pixel pixelAt(int x, int y) {
    int index = (y * pwRes) + x;
    if (index >= 0 && index < _pixels.size())
      return _pixels.get(index);
      
    return null;
  }
  
  List<Pixel> getHLine(int row) {
    if (row >= 0 && row < phRes && linesInitialized) {
      return cachedHLines[row]; // Direct access to pre-allocated array
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
    
  void update() {
    // Render custom visualizer if enabled
    if (customVisualizer != null && customVisualizer.isEnabled()) {
      customVisualizer.update();
      backBuffer.beginDraw();
      customVisualizer.render(backBuffer);
      backBuffer.endDraw();   
      PImage bImage = backBuffer.get();
      bImage.resize(0, phRes);
      sourceImage(bImage, 0);
    }    
  }

  void sourceImage(String fname) {
    source = null;
    source = loadImage(fname);
    if (source.width > source.height)
      source.resize(pwRes, 0);
    else
      source.resize(0, phRes);

    sourceImage(source, 0);
    println("----->", source.width, source.height);
    println("Loaded Image", source.width, source.height);
  }
  
  void sourceImage(PImage image, int brighT) {
    source = null;
    source = image;
    source.loadPixels();
    int xoff = (pwRes - source.width) / 2;
    for (int y = 0; y < phRes; y++) {
      for (int x = 0; x < pwRes; x++) {
        if (x < source.width && y < source.height) {
          // Get the color of the pixel at (x, y) in the source image and set the color to the LCDD pixel
          int pixelColor = source.get(x, y);
          
          // Extract the RGB components
          int a = (int)alpha(pixelColor);
          int r = (int)red(pixelColor);
          int g = (int)green(pixelColor);
          int b = (int)blue(pixelColor);
          
          Pixel px = pixelAt(xoff + x, y);
          if (px == null) {
            continue;
          }
          
          if (a == 0 || (brighT > 0 && brightness(pixelColor) < brighT)) { //r < brighT && g < brighT && b < brighT)) {
            continue;
          }
          else {
            switch (lumosMode) {
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
    if (l != null) {
      for (int i = 0; i < l.size(); i++) {
        Pixel pixel = l.get(i);
        pixel.setRGB(0, 0, 0, 1.0);
      }
    }
    
    if (l == null || source == null)
      return;
      
    int xoff = (pwRes - source.width) / 2;
    for (int x = 0; x < pwRes; x++) {
      if (x < source.width && line < source.height) {
        int pixelColor = source.get(x, line);
        
        boolean lerped = false;
        if (brightness(pixelColor) > 145) {
          pixelColor = neonDD;
          lerped = true;
        }
        
        // Extract the RGB components
        int a = (int)alpha(pixelColor);
        int r = (int)red(pixelColor);
        int g = (int)green(pixelColor);
        int b = (int)blue(pixelColor);
        
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
    dirtyRects.clear();
    fullRedraw = false;
  }

  void invalidate() {
    dirtyRects.clear();
    dirtyRects.add(new int[]{0, 0, pwRes-1, phRes-1});
    fullRedraw = true;
  }
  
  void invalidate(Pixel pixel) {
    int px = pixel.pixelIndex % pwRes;
    int py = pixel.pixelIndex / pwRes;
    addDirtyRect(px, py, px, py);
  }
  
  void addDirtyRect(int x1, int y1, int x2, int y2) {  
    dirtyRects.add(new int[]{x1, y1, x2, y2});
  }
  
  void display() { 
    if (logo != null && logoOn) {
      image(logo, location().x + (_width - logo.width)/2, location().y + (_height - logo.height)/2);
    }

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
    if (centerScale) {
      transX = -(_width * scale - _width)/2;
      transY = -(_height * scale - _height)/2;
    }
    translate(transX, transY);
    scale(scale);
    
    if (scanInterval > 0)
      scanner();
    
    // Optimized dirty region rendering
    if (fullRedraw) {
      for (Pixel pixel : _pixels) {
        pixel.display();
      }
    } else {
      // Only render dirty rectangles
      for (int[] rect : dirtyRects) {
        for (int y = rect[1]; y <= rect[3]; y++) {
          for (int x = rect[0]; x <= rect[2]; x++) {
            if (x >= 0 && x < pwRes && y >= 0 && y < phRes) {
              _pixels.get(y * pwRes + x).display();
            }
          }
        }
      }
    }
    
    popMatrix();

    if (pipOn)
      image(source, location().x + _width - source.width, location().y + _height - source.height);
    
    scanComplete();
  } 
  
  void scanner() {
    if (scanLine == 0) {
      pvscanLine = phRes - 1;
    }

    // Only update pixels if scanline actually moved
    int currentScanLine = floor(scanLine);
    if (currentScanLine != pvscanLine) {
      // Bounds check for previous scanline
      if (pvscanLine >= 0 && pvscanLine < phRes) {
        // Restore previous scanline to original colors
        int startIdx = pvscanLine * pwRes;
        if (startIdx >= 0 && startIdx + pwRes <= _pixels.size()) {
          for (int i = 0; i < pwRes; i++) {
            Pixel pixel = _pixels.get(startIdx + i);
            // Only restore if it was the scanline (bright white: 0xFFFFFF)
            if (pixel.getRGB() == 0xFFFFFF) {
              pixel.restoreOriginalColor();
            }
          }
        }
      }
      
      // Bounds check for current scanline
      if (currentScanLine >= 0 && currentScanLine < phRes) {
        // Set new scanline to bright
        int startIdx = currentScanLine * pwRes;
        if (startIdx >= 0 && startIdx + pwRes <= _pixels.size()) {
          for (int i = 0; i < pwRes; i++) {
            Pixel pixel = _pixels.get(startIdx + i);
            pixel.saveOriginalColor(); // Store current color
            pixel.setRGB(255, 255, 255, pixel.lumos);
          }
        }
      }
      
      pvscanLine = currentScanLine;
    }
    
    scanLine += scanInterval;
    if (scanLine >= phRes) {
      scanLine = 0;
    }
  }
  
  // Visualizer control methods
  void setVisualizer(Visualizer visualizer) {
    if (visualizer != null) {
      this.customVisualizer = visualizer;
      this.customVisualizer.setBounds(position.x, position.y, _width, _height);
    }
  }
  
  void enableVisualizer() {
    if (customVisualizer != null) {
      customVisualizer.enable();
    }
  }
  
  void disableVisualizer() {
    if (customVisualizer != null) {
      customVisualizer.disable();
    }
  }
  
  void toggleVisualizer() {
    if (customVisualizer != null) {
      if (customVisualizer.isEnabled()) {
        customVisualizer.disable();
      } else {
        customVisualizer.enable();
      }
    }
  }
  
  void resetVisualizer() {
    if (customVisualizer != null) {
      customVisualizer.reset();
    }
  }
  
  Visualizer getVisualizer() {
    return customVisualizer;
  }
}
