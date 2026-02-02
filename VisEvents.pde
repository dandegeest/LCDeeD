@FunctionalInterface
interface VisEvent {
    void fire();
}

HashMap<Character, VisEvent> keyEvents = new HashMap();
ArrayList<VisEvent> fx = new ArrayList();
ArrayList<VisEvent> zoom = new ArrayList();

VisEvent toggleAuto = () -> {
  autoOn = !autoOn;
  println("AUTO", autoOn);
};

// Custom LCDDInput Events
VisEvent togglesourceInput = () -> {
  for (LCDD lcd : lcds) {
    if (lcd != null) {
      lcd.toggleLCDDInput();
    }
  }
  boolean anyEnabled = false;
  for (LCDD lcd : lcds) {
    if (lcd != null && lcd.getLCDDInput() != null && lcd.getLCDDInput().isEnabled()) {
      anyEnabled = true;
      break;
    }
  }
  println("CUSTOM LCDDInputS", anyEnabled ? "ON" : "OFF");
};

VisEvent cyclesourceInput = () -> {
  for (LCDD lcd : lcds) {
    if (lcd != null) {
      // Cycle between different LCDDInput types
      LCDDInput current = lcd.getLCDDInput();
      if (current instanceof PulseLCDDInput) {
        lcd.setLCDDInput(new GridLCDDInput(lcd.location().x, lcd.location().y, lcd._width, lcd._height));
      } else if (current instanceof GridLCDDInput) {
        // Create ImageLCDDInput with a sample image
        ImageLCDDInput imgVis = new ImageLCDDInput(lcd.location().x, lcd.location().y, lcd._width, lcd._height);
        imgVis.setImage(sketchPath("") + "imagesDev/testPattern.png"); // You can change this path
        lcd.setLCDDInput(imgVis);
      } else if (current instanceof ImageLCDDInput) {
        lcd.setLCDDInput(new PulseLCDDInput(lcd.location().x, lcd.location().y, lcd._width, lcd._height));
      } else {
        // Fallback to PulseLCDDInput if unknown type
        lcd.setLCDDInput(new PulseLCDDInput(lcd.location().x, lcd.location().y, lcd._width, lcd._height));
      }
      // Keep the same enabled state
      if (current != null && current.isEnabled()) {
        lcd.enableLCDDInput();
      }
    }
  }
  println("LCDDInput TYPE CYCLED");
};

VisEvent resetsourceInput = () -> {
  for (LCDD lcd : lcds) {
    if (lcd != null) {
      lcd.resetLCDDInput();
    }
  }
  println("CUSTOM LCDDInputS RESET");
};

VisEvent innerConnect = () -> {
  connected = !connected;
  println(key, "INNERCONNECTED", connected);
};

VisEvent toggleDebug = () -> {
  debugOn = !debugOn;
  println("OSD", debugOn);
};

VisEvent toggleBackground = () -> {
  lcds[input].eraseBackground = !lcds[input].eraseBackground;
  lcds[input].invalidate();
  println("BACKGROUND", lcds);
};

VisEvent resetAll = () -> {
  for (int i = 0; i < 4; i++) {
    lcds[i].scale = 1.0;
    lcds[i].transX = 0.0;
    lcds[i].transY = 0.0;
  }
  println("RESET");
};

VisEvent saveFrame = () -> {
  String frameName = "screenshots/LCDD#####.png";
  saveFrame(frameName);
  println("SAVE FRAME", frameName);
};

VisEvent transLeft = () -> {
  lcds[input].transX -= lcds[input].scale * 10;
  println("TX", lcds[input].transX);
};

VisEvent transRight = () -> {
  lcds[input].transX += lcds[input].scale * 10;
  println("TX", lcds[input].transX);
};

VisEvent transUp = () -> {
  lcds[input].transY -= lcds[input].scale * 10;
  println("TY", lcds[input].transY);
};

VisEvent transDown = () -> {
  lcds[input].transY += lcds[input].scale * 10;
  println("TY", lcds[input].transY);
};

VisEvent scaleUp = () -> {
  lcds[input].scale += .5;
  println("SCALE TV", input, lcds[input].scale);
};

VisEvent scaleDown = () -> {
  lcds[input].scale -= .5;
  println("SCALE TV", input, lcds[input].scale);
};

void toggleTV(int tv) {
  lcds[tv].tvOn = !lcds[tv].tvOn;
  println(key, "TV/ON" + tv, lcds[tv].tvOn);
}

VisEvent toggleTV_0 = () -> {
  toggleTV(0);
};

VisEvent toggleTV_1 = () -> {
  toggleTV(1);
};

VisEvent toggleTV_2 = () -> {
  toggleTV(2);
};

VisEvent toggleTV_3 = () -> {
  toggleTV(3);
};

void selectInput(int tv) {
  input = tv;
  println("SELECT INPUT", input);
}

VisEvent selectTV_0 = () -> {
  selectInput(0);
};

VisEvent selectTV_1 = () -> {
  selectInput(1);
};

VisEvent selectTV_2 = () -> {
  selectInput(2);
};

VisEvent selectTV_3 = () -> {
  selectInput(3);
};

VisEvent centerScaleTV = () -> {
  lcds[input].centerScale = !lcds[input].centerScale;
  println("CENTER", input, lcds[input].centerScale);
};

VisEvent overScanColor = () -> {
  Object[] colorNames = palette.keySet().toArray();
  String randomColorName = (String) colorNames[(int)random(colorNames.length)];
  color c = palette.get(randomColorName);
  lcds[input].overScanColor = c;
  println("Overscan Color TV " + input, red(c), green(c), blue(c));
};

VisEvent overScanColorReset = () -> {
  lcds[input].overScanColor = blackDD;
  println("Overscan Color Reset TV " + input);
};

VisEvent overScanWidth = () -> {
  lcds[input].overScanSize++;
  println("OVERSCAN WIDTH " + input, lcds[input].overScanSize);
};

VisEvent overScanWidthReset = () -> {
  lcds[input].overScanSize = 2;
  println("OVERSCAN WIDTH " + input, lcds[input].overScanSize);
};

VisEvent overScanInterval = () -> {
  lcds[input].overScanInterval++;
  println("OVERSCAN INTERVAL " + input, lcds[input].overScanInterval);
};

VisEvent overScanIntervalReset = () -> {
  lcds[input].overScanInterval = 3;
  println("OVERSCAN INTERVAL " + input, lcds[input].overScanInterval);
};

VisEvent overScanToggle = () -> {
  lcds[input].overScanOn = !lcds[input].overScanOn;
  println("Overscan TV " + input, lcds[input].overScanOn);
};

VisEvent pixelMode = () -> {    
  subPixelDisclination++;
  if (subPixelDisclination > 2)
    subPixelDisclination = 0;
  
  println("Pixel Mode", 1 << subPixelDisclination);
};

VisEvent scaleReset = () -> { 
  lcds[input].scale = 1.0;
  println("SCALE RESET TV", input, lcds[input].scale);
};

VisEvent transReset = () -> { 
  lcds[input].transX = 0.0;
  lcds[input].transY = 0.0;
  println(key, "TRANS RESET TV", input, "(0,0)");
};

void splitScreen(boolean split) {
  if (split == true) {
    lcds[0].setResolution(width/2, height/2, 3);
    for (int i = 0; i < lcds.length; i++)
      lcds[i].tvOn = true;
    println(key, "SPLIT/ON");
  }
  else {
    lcds[0].setResolution(width, height, 3);
    for (int i = 1; i < lcds.length; i++)
      lcds[i].tvOn = false;
    println(key, "SPLIT/OFF");
  }
}

VisEvent splitScreen = () -> {
  if (lcds[0]._width == width) {
    splitScreen(true);
  }
  else {
    splitScreen(false);
  }
};
  
VisEvent briteMode0 = () -> {
  lcds[input].lumosMode = 0;
  println("BRIGHT", input, lcds[input].lumosMode);
};

VisEvent briteMode1 = () -> {
  lcds[input].lumosMode = 1;
  println("BRIGHT", input, lcds[input].lumosMode);
};

VisEvent briteMode2 = () -> {
  lcds[input].lumosMode = 2;
  println("BRIGHT", input, lcds[input].lumosMode);
};

VisEvent togglePIP = () -> {
  for (int i = 0; i < lcds.length; i++)
    lcds[i].pipOn = !lcds[i].pipOn;
  println("PIP", lcds[0].pipOn);
};

VisEvent toggleLogo = () -> { 
  lcds[input].logoOn = !lcds[input].logoOn;
  println("LOGO", input, lcds[input].logoOn);
};


VisEvent innerDDieMode1 = () -> {   
  innerDDieMode = 1;
  println("INNERDDie", innerDDieMode);
};

VisEvent innerDDieMode2 = () -> {   
  innerDDieMode = 2;
  println("INNERDDie", innerDDieMode);
};

void loadKeyboardEvents() {
  keyEvents.put('%', toggleAuto);
  
  // BACK BUFFER
  keyEvents.put('b', toggleBackground);
  
  // PIXELS
  keyEvents.put(':', pixelMode);
  keyEvents.put('7', briteMode0);
  keyEvents.put('8', briteMode1);
  keyEvents.put('9', briteMode2);

  // CUSTOM LCDDInputS
  keyEvents.put('f', togglesourceInput);
  keyEvents.put('V', cyclesourceInput);
  keyEvents.put('r', resetsourceInput);
  
  // TV CONTROLS
  //    ON/OFF
  keyEvents.put('1', selectTV_0);
  keyEvents.put('2', selectTV_1);
  keyEvents.put('3', selectTV_2);
  keyEvents.put('4', selectTV_3);
  //    SELECT INPUT
  keyEvents.put(TAB, splitScreen);
  keyEvents.put('t', togglePIP);
  //    SELECT INPUT
  keyEvents.put('!', toggleTV_0);
  keyEvents.put('@', toggleTV_1);
  keyEvents.put('#', toggleTV_2);
  keyEvents.put('$', toggleTV_3);
  //    INPUT OPTIONS
  //          OVERSCAN
  keyEvents.put('M', overScanToggle);
  keyEvents.put('/', overScanColor);
  keyEvents.put('?', overScanColorReset); 
  keyEvents.put('<', overScanWidth); 
  keyEvents.put('>', overScanInterval); 
  keyEvents.put('.', overScanWidthReset); 
  keyEvents.put(',', overScanIntervalReset); 
  //          SCALING
  keyEvents.put('-', scaleDown);
  keyEvents.put('=', scaleUp);
  keyEvents.put('+', scaleReset);
  keyEvents.put('_', transReset);
  keyEvents.put('Z', centerScaleTV);
  //          LOGO
  keyEvents.put('L', toggleLogo);  
  
  // RESETS
  keyEvents.put('0', resetAll);
    
  // TOOL
  keyEvents.put('D', toggleDebug);
  keyEvents.put(ENTER, saveFrame);
}

void loadTimerEvents() {
  fx.add(innerConnect);
  fx.add(innerDDieMode1);
  fx.add(innerDDieMode2);

  fx.add(overScanToggle);
  fx.add(overScanColor);
  fx.add(overScanColorReset); 
  fx.add(overScanWidthReset); 
  fx.add(overScanIntervalReset); 

  for (int z = 0; z < 3; z++) {
    zoom.add(scaleUp);
    zoom.add(overScanInterval);
  }
  zoom.add(scaleDown);
  zoom.add(overScanWidth); 

  fx.add(briteMode0);
  fx.add(briteMode1);
  fx.add(briteMode2);
}
