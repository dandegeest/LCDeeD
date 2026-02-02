import java.util.List;

class LCDD extends Sprite {
  boolean tvOn = false;
  // Resolution
  int pxWidth = 0; // dspPixels width
  int pxHeight = 0; // dspPixels height
  float pxSize = 3.0; // Pixel size (now supports fractional values)
  // Display Pixels - pxWidth x pxHeight pixels
  ArrayList<Pixel> dspPixels = new ArrayList<Pixel>(); 
  // Compositing Buffer (pxWidth x psSize X pxHeight x pxSize)
  PGraphics backBuffer;
  // Dirty regions for optimized redraw
  ArrayList<int[]> dirtyRects = new ArrayList<int[]>(); // [x1, y1, x2, y2]
  
  // Pre-allocated line arrays for performance
  private List<Pixel>[] cachedHLines;
  private List<Pixel>[] cachedVLines;
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
  // Background
  boolean eraseBackground = true;
  
  // Custom LCDDInput instance
  LCDDInput sourceInput;
  
  LCDD(float x, float y, float w, float h, float psize) {
    super(x, y, w, h);
    backBuffer = createGraphics((int)w, (int)h);
    
    setResolution(w, h, psize);
    
    invalidate();   
    println("Starting LCDD/TV™", pxWidth, pxHeight, 1 << subPixelDisclination);   
  }

  void setResolution(float w, float h, float psize) {
    pxSize = psize;
    _width = w;
    _height = h;
    pxWidth = floor(_width/pxSize);
    pxHeight = floor(_height/pxSize);

    println("Setting Resolution to", pxWidth, "x", pxHeight, "with pixel size", pxSize);
    dspPixels.clear();  
    
    // Initialize cached line arrays
    cachedHLines = new List[pxHeight];
    cachedVLines = new List[pxWidth];
    
    for (int py = 0; py < pxHeight; py++) {
      cachedHLines[py] = new ArrayList<Pixel>(pxWidth);
    }
    for (int px = 0; px < pxWidth; px++) {
      cachedVLines[px] = new ArrayList<Pixel>(pxHeight);
    }
    
    for (int py = 0; py < pxHeight; py++) {
      for (int px = 0; px < pxWidth; px++) {
        Pixel pixel = new Pixel(
          position.x + px * pxSize,
          position.y + py * pxSize,
          pxSize , pxSize,
          (py * pxWidth) + px, this);
        dspPixels.add(pixel);
        cachedHLines[py].add(pixel);
        cachedVLines[px].add(pixel);
      }
    }
    
    // Reset scanner variables to prevent out of bounds errors
    scanLine = 0;
    pvscanLine = 0;
    
    linesInitialized = true;
  }
  
  Pixel pixelAt(int x, int y) {
    int index = (y * pxWidth) + x;
    if (index >= 0 && index < dspPixels.size())
      return dspPixels.get(index);
      
    return null;
  }
  
  List<Pixel> getHLine(int row) {
    if (row >= 0 && row < pxHeight && linesInitialized) {
      return cachedHLines[row]; // Direct access to pre-allocated array
    }
    return null;
  }
  
  List<Pixel> getVLine(int column) {
    if (column >= 0 && column < pxWidth && linesInitialized) {
      return cachedVLines[column]; // Direct access to pre-allocated array
    }
    return null;
  }
    
  void update() {
    // Render custom LCDDInput if enabled
    if (sourceInput != null && sourceInput.isEnabled()) {
      sourceInput.update();
      backBuffer.beginDraw();
      if (eraseBackground) {
        backBuffer.background(blackDD);
      }
      sourceInput.render(backBuffer);
      backBuffer.endDraw();   
      PImage bImage = backBuffer.get();
      bImage.resize(0, pxHeight);
      sourceImage(bImage, 0);
    }    
  }

  void sourceImage(String fname) {
    source = null;
    source = loadImage(fname);
    if (source.width > source.height)
      source.resize(pxWidth, 0);
    else
      source.resize(0, pxHeight);

    println("Loaded Static Image", pxWidth, pxHeight, source.width, source.height);
    sourceImage(source, 0);
  }
  
  void sourceImage(PImage image, int brighT) {
    source = image;
    source.loadPixels();
    int xoff = (pxWidth - source.width) / 2;
    
    for (int y = 0; y < pxHeight; y++) {
      for (int x = 0; x < pxWidth; x++) {
        if (x < source.width && y < source.height) {
          // Get the color of the pixel at (x, y) in the source image
          int pixelColor = source.get(x, y);
          
          // Cache color components to avoid repeated function calls
          int a = (pixelColor >> 24) & 0xFF;
          int r = (pixelColor >> 16) & 0xFF;
          int g = (pixelColor >> 8) & 0xFF;
          int b = pixelColor & 0xFF;
          
          Pixel px = pixelAt(xoff + x, y);
          if (px == null) continue;
          
          if (a == 0 || (brighT > 0 && brightness(pixelColor) < brighT)) {
            continue;
          }
          else {
            switch (lumosMode) {
              case 0:
                px.setRGB(r, g, b, y % 2 == 0 ? .75 : 1.0);
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
    if (line < 0 || line >= pxHeight)
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
      
    int xoff = (pxWidth - source.width) / 2;
    for (int x = 0; x < pxWidth; x++) {
      if (x < source.width && line < source.height) {
        int pixelColor = source.get(x, line);
        
        boolean lerped = false;
        if (brightness(pixelColor) > 145) {
          pixelColor = palette.get("lightGreen");
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
  }

  void invalidate() {
    dirtyRects.clear();
    dirtyRects.add(new int[]{0, 0, pxWidth-1, pxHeight-1});
  }
  
  void invalidate(Pixel pixel) {
    int px = pixel.pixelIndex % pxWidth;
    int py = pixel.pixelIndex / pxWidth;
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
    
    // Dirty region rendering with optimized pixel access
    for (int[] rect : dirtyRects) {
      for (int y = rect[1]; y <= rect[3]; y++) {
        if (y >= 0 && y < pxHeight) {
          int rowStart = y * pxWidth;
          for (int x = rect[0]; x <= rect[2]; x++) {
            if (x >= 0 && x < pxWidth) {
              dspPixels.get(rowStart + x).display();
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
      pvscanLine = pxHeight - 1;
    }

    // Only update pixels if scanline actually moved
    int currentScanLine = floor(scanLine);
    if (currentScanLine != pvscanLine) {
      // Bounds check for previous scanline
      if (pvscanLine >= 0 && pvscanLine < pxHeight) {
        // Restore previous scanline to original colors
        int startIdx = pvscanLine * pxWidth;
        if (startIdx >= 0 && startIdx + pxWidth <= dspPixels.size()) {
          for (int i = 0; i < pxWidth; i++) {
            Pixel pixel = dspPixels.get(startIdx + i);
            // Only restore if it was the scanline (bright white: 0xFFFFFF)
            if (pixel.getRGB() == 0xFFFFFF) {
              pixel.restoreOriginalColor();
            }
          }
        }
      }
      
      // Bounds check for current scanline
      if (currentScanLine >= 0 && currentScanLine < pxHeight) {
        // Set new scanline to bright
        int startIdx = currentScanLine * pxWidth;
        if (startIdx >= 0 && startIdx + pxWidth <= dspPixels.size()) {
          for (int i = 0; i < pxWidth; i++) {
            Pixel pixel = dspPixels.get(startIdx + i);
            pixel.saveOriginalColor(); // Store current color
            pixel.setRGB(255, 255, 255, pixel.lumos);
          }
        }
      }
      
      pvscanLine = currentScanLine;
    }
    
    scanLine += scanInterval;
    if (scanLine >= pxHeight) {
      scanLine = 0;
    }
  }
  
  // LCDDInput control methods
  void setLCDDInput(LCDDInput LCDDInput) {
    if (LCDDInput != null) {
      this.sourceInput = LCDDInput;
      this.sourceInput.setBounds(position.x, position.y, _width, _height);
    }
  }
  
  void enableLCDDInput() {
    if (sourceInput != null) {
      sourceInput.enable();
    }
  }
  
  void disableLCDDInput() {
    if (sourceInput != null) {
      sourceInput.disable();
    }
  }
  
  void toggleLCDDInput() {
    if (sourceInput != null) {
      if (sourceInput.isEnabled()) {
        sourceInput.disable();
      } else {
        sourceInput.enable();
      }
    }
  }
  
  void resetLCDDInput() {
    if (sourceInput != null) {
      sourceInput.reset();
    }
  }
  
  LCDDInput getLCDDInput() {
    return sourceInput;
  }
}
