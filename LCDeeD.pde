// LCDeeD - An LCD TV rendering simulation for Processing
// © Dan DeGeest 2024

import java.util.HashMap;

// The LCDD/TV Screens 2 X 2 or single enlarged
LCDD lcds[];

HashMap<String, Integer> palette = new HashMap<String, Integer>() {{
  //RetroTV
  put("darkGrey", #1c1c1c);
  put("mediumGrey", #6b6b6b);
  put("lightGrey", #b1b1b1);
  put("darkRed", #670000);
  put("red", #8a0707);
  put("lightRed", #b91313);
  put("brightRed", #e51919);
  put("darkGreen", #005915);
  put("green", #008721);
  put("lightGreen", #0daf30);
  put("brightGreen", #10e538);
  put("darkBlue", #000d99);
  put("blue", #0030ff);
  put("lightBlue", #4683ff);
  put("brightBlue", #6ba4ff);
}};
// Quick Colors
color reDD = palette.get("red");
color greenDD = palette.get("green");
color blueDD = palette.get("blue");
color whiteDD = palette.get("lightGrey");
color blackDD = palette.get("darkGrey");

// Runtime options
boolean debugOn = false;
boolean autoOn = false;

//Active TV Input
int input = 0;

// Timers
Timer fxTimer;
Timer zoomTimer;

void setup() {
  size(1280, 720);
  frameRate(30);
  //Important for pixel accuracy in LCDD rendering
  pixelDensity(1);
  //fullScreen();
  
  lcds = new LCDD[4];
  lcds[0] = new LCDD(0, 0, width, height, 3.0);
  lcds[0].tvOn = true;
  lcds[0].scanInterval = 2;
  lcds[0].sourceInput = new FireFliesLCDDInput(0, 0, width, height);
  lcds[0].enableLCDDInput();
  
  // Split screens
  lcds[1] = new LCDD(width/2, 0, width/2, height/2, 1.5);
  lcds[1].scanInterval = 1.5;
  lcds[1].overScanColor = palette.get("lightGreen");
  lcds[1].overScanOn = true;
  lcds[1].overScanSize = 5;
  lcds[1].overScanInterval = 10;
  lcds[1].sourceInput = new ImageLCDDInput(0, 0,  width/2, height/2, "JunkLCD.jpg");
  lcds[1].enableLCDDInput();
  
  lcds[2] = new LCDD(0, height/2, width/2, height/2, 1.5);
  lcds[2].scanInterval = .5;
  lcds[2].overScanColor = whiteDD;
  lcds[2].overScanOn = true;
  lcds[2].overScanSize = 15;
  lcds[2].overScanInterval = 40;
  lcds[2].sourceInput = new GridLCDDInput(0, 0,  width/2, height/2);
  lcds[2].enableLCDDInput();

  lcds[3] = new LCDD(width/2, height/2, width/2, height/2, 1.5);
  lcds[3].overScanColor = greenDD;
  lcds[3].overScanOn = true;
  lcds[3].sourceInput = new PulseLCDDInput(0, 0,  width/2, height/2);
  lcds[3].enableLCDDInput();
  
  loadKeyboardEvents();
  loadTimerEvents();
  
  fxTimer = new Timer();
  fxTimer.interval = 30 * 1000;
  fxTimer.tfx = () -> {
    if (!autoOn) return;
    int pInput = input;
    input = 0;
    fx.get(floor(random(fx.size()))).fire();
    input = pInput;
  };
  
  zoomTimer = new Timer();
  zoomTimer.interval = 15 * 1000;
  zoomTimer.tfx = () -> {
    if (!autoOn) return;
    int pInput = input;
    input = 0;
    zoom.get(floor(random(zoom.size()))).fire();
    input = pInput;
  };
}

void draw() { 
  timer(fxTimer);
  timer(zoomTimer);
    
  boolean anyTVOn = false;
  for (LCDD lcdd : lcds) {
    lcdd.update();
    if (lcdd.tvOn) {
      lcdd.display();
      anyTVOn = true;
    }
  }

  if (!anyTVOn) {
    int l = input; //(int)random(lcds.length);
    image(lcds[l].backBuffer, lcds[l].position.x, lcds[l].position.y);
  }

  drawOSD();
}

void keyPressed() {
  if (key == CODED) handleCoded();
  
  if (keyEvents.containsKey(key)) {
    keyEvents.get(key).fire();
  }  
}

void handleCoded() {
  if (keyCode == LEFT) transLeft.fire();
  if (keyCode == RIGHT) transRight.fire();
  if (keyCode == UP) transUp.fire();
  if (keyCode == DOWN) transDown.fire();
}

void drawOSD() {
  if (debugOn) {
    int indY = 20;
    int indW = 60;
    int indH = 10;

    push();
    noStroke();
    fill(0, 255);
    rect(0, 0, indW, 20);
    rect(0, indY, indW, 200);  
    textAlign(LEFT, TOP);
    fill(128, 255, 128);
    textSize(12);
    text(nf(frameRate, 2, 2), 0, 0, 200, 50);
    pop();
  }
}
